from email.mime import text
from fastapi import FastAPI, File, UploadFile, Depends, HTTPException, status, BackgroundTasks
import re
import json
import shutil
import os
from fastapi.middleware.cors import CORSMiddleware
from auth import router as auth_router
from sqlalchemy.orm import Session
from datetime import datetime
from llm_utils import analyze_lease
from database import SessionLocal, engine, Base
from models import User, LeaseAnalysis
from auth import get_current_user
from ocr_utils import extract_text
from llm_utils import analyze_lease
from fairness_utils import calculate_fairness
from vin_utils import decode_vin
from schemas import CarFullHistoryRequest, CarFullHistoryResponse
from services.car_full_history_service import CarFullHistoryService
from ai_chat import router as ai_chat_router
from routes.dealer_chat import router as dealer_chat_router
from price_estimator import estimate_car_price
from dealer_auth import router as dealer_auth_router

# Create DB tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Lease Document Analyzer API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(dealer_chat_router, tags=["Dealer Chat"])
app.include_router(auth_router, prefix="/auth", tags=["auth"])
app.include_router(ai_chat_router, prefix="/chatbot", tags=["chatbot"])
app.include_router(dealer_auth_router)

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

LAST_UPLOADED_FILE = None


def extract_vin_from_text(text: str):
    """
    Extract VIN even if OCR breaks it with spaces or newlines.
    """
    cleaned = text.replace(" ", "").replace("\n", "").upper()

    
    pattern = r"[A-HJ-NPR-Z0-9]{17}"
    match = re.search(pattern, cleaned)
    return match.group(0) if match else None


# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def root():
    return {"message": "Lease Document Analyzer API is running"}


def fetch_and_store_car_history(record_id: int, vin: str):

    db = SessionLocal()

    try:
        print(f"🌐 Background fetching car history for VIN: {vin}")

        history_service = CarFullHistoryService()
        car_history = history_service.fetch_full_history(vin)

        record = db.query(LeaseAnalysis).filter(
            LeaseAnalysis.id == record_id
        ).first()

        if record:
            record.car_full_history = car_history
            db.commit()

        print("✅ Background car history saved")

    except Exception as e:
        print("❌ Background history fetch failed:", str(e))

    finally:
        db.close()



@app.post("/upload")
async def upload_file(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # Save file uniquely
    timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
    unique_filename = f"{current_user.id}_{timestamp}_{file.filename}"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)

    # SAVE FILE FIRST (THIS WAS WRONG BEFORE)
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    original_filename = file.filename

    # EXTRACT TEXT USING OCR UTILS
    extracted_text = extract_text(file_path)

    print("EXTRACTED TEXT LENGTH:", len(extracted_text) if extracted_text else "NO TEXT")

    if not extracted_text or len(extracted_text.strip()) == 0:
        raise HTTPException(status_code=400, detail="No text extracted from PDF")
    
    # CHECK IF FILE ALREADY EXISTS FOR THIS USER
    existing_record = (
        db.query(LeaseAnalysis)
        .filter(
            LeaseAnalysis.filename == original_filename,
            LeaseAnalysis.user_id == current_user.id
        )
        .first()
    )

    if existing_record:
        return {
            "message": "Existing analysis found",
            "record_id": existing_record.id,
            "filename": existing_record.filename,
            "vin": existing_record.vin,
            "analysis_result": existing_record.analysis_result,
            "fairness_analysis": existing_record.fairness_analysis,
            "price_estimation": existing_record.price_estimation,  
            "vehicle_api_data": existing_record.vehicle_api_data,
            "car_full_history": existing_record.car_full_history
        }

    #  CALL GROQ ONCE (USING YOUR analyze_lease)
    print("====== OCR EXTRACTED TEXT (FIRST 2000 CHARS) ======")
    print(extracted_text[:2000])
    print("====== END OCR TEXT ======")

    raw_output = analyze_lease(extracted_text)

    print("====== GROQ RAW OUTPUT ======")
    print(raw_output)
    print("====== END GROQ OUTPUT ======")


    print("GROQ RAW RESPONSE:", raw_output)

    if not raw_output:
        raise HTTPException(status_code=500, detail="Groq returned empty response")

    # CLEAN & PARSE JSON
    cleaned = re.sub(r"```json|```", "", raw_output).strip()

    try:
        parsed_json = json.loads(cleaned)

        # Build summary from important fields
        lease_details = parsed_json.get("lease_details", {})
        financials = parsed_json.get("financials", {})
        penalties = parsed_json.get("penalties", {})

        summary_parts = []

        if lease_details.get("start_date"):
            summary_parts.append(f"Lease starts on {lease_details.get('start_date')}")

        if lease_details.get("end_date"):
            summary_parts.append(f"and ends on {lease_details.get('end_date')}")

        if lease_details.get("lease_duration"):
            summary_parts.append(f"for a duration of {lease_details.get('lease_duration')}")

        summary = " ".join(summary_parts) if summary_parts else None

        monthly_payment = financials.get("total_monthly_payment") or financials.get("base_monthly_payment")

        # Build potential issues list from penalties
        issues = []
        for k, v in penalties.items():
            if v:
                issues.append(f"{k.replace('_', ' ').title()}: {v}")

        # Simple negotiation tips (rule-based for now)
        negotiation_tips = []

        if monthly_payment:
            negotiation_tips.append("Ask if the monthly payment can be reduced or fixed.")

        if financials.get("residual_value"):
            negotiation_tips.append("Negotiate the residual value at the end of lease.")

        if penalties.get("early_termination_charge"):
            negotiation_tips.append("Try to reduce early termination charges.")

        print("MAPPED SUMMARY:", summary)
        print("MAPPED MONTHLY PAYMENT:", monthly_payment)
        print("MAPPED ISSUES:", issues)
        print("MAPPED NEGOTIATION TIPS:", negotiation_tips)

    except Exception as e:
        print("JSON PARSE ERROR:", e)
        print("RAW GROQ:", raw_output)
        raise HTTPException(status_code=500, detail="Groq returned invalid JSON")

    # EXTRACT VIN
    vehicle_section = parsed_json.get("vehicle_details", {})
    vin = vehicle_section.get("vehicle_id_number")

    # Fallback: extract VIN from OCR text
    if not vin:
        vin = extract_vin_from_text(extracted_text)

    # Validate VIN
    if vin and len(vin) != 17:
        vin = None

    # DECODE VIN
    vehicle_api_data = None
    if vin:
        try:
            vehicle_api_data = decode_vin(vin)
        except Exception as e:
            vehicle_api_data = {"error": str(e)}

    # FAIRNESS
    fairness_result = calculate_fairness(parsed_json)

    car_full_history = None

    price_estimation = estimate_car_price(
        vehicle_details=parsed_json.get("vehicle_details", {}),
        car_history=car_full_history,
        fairness_analysis=fairness_result,
    )

    # SMART CAR HISTORY FETCH (DB CACHE FIRST)
    car_full_history = None

    if vin:

        # CHECK IF VIN HISTORY ALREADY EXISTS IN DB
        existing_record = db.query(LeaseAnalysis).filter(
            LeaseAnalysis.vin == vin,
            LeaseAnalysis.car_full_history.isnot(None)
        ).first()

        if existing_record:
            print("✅ Using cached car history from DB")
            car_full_history = existing_record.car_full_history

        else:
            print("🌐 Fetching car history from API")



    # STORE IN DB
    record = LeaseAnalysis(
        user_id=current_user.id,
        filename=original_filename,
        stored_filename=unique_filename,
        analysis_result=parsed_json,
        fairness_analysis=fairness_result,
        price_estimation=price_estimation, 
        vin=vin,
        vehicle_api_data=vehicle_api_data,
        car_full_history=car_full_history,
    )


    print("===== ABOUT TO SAVE RECORD =====")
    print("User ID:", current_user.id)
    print("Filename:", original_filename)
    print("VIN:", vin)
    print("================================")


    db.add(record)
    db.commit()
    print("===== RECORD SAVED ID =====", record.id)
    db.refresh(record)

    # RUN BACKGROUND CAR HISTORY FETCH
    if vin and car_full_history is None:
        background_tasks.add_task(
            fetch_and_store_car_history,
            record.id,
            vin
    )


    # RETURN TO FLUTTER
    return {
        "message": "Lease analysis completed and stored",
        "record_id": record.id,
        "filename": original_filename,
        "vin": vin,
        "analysis_result": parsed_json,
        "fairness_analysis": fairness_result,
        "vehicle_api_data": vehicle_api_data,
        "car_full_history": car_full_history,
        "price_estimation": price_estimation,
    }



#  Car Full History API (JWT Protected)
@app.post("/car-full-history", response_model=CarFullHistoryResponse)
def get_car_full_history(
    request: CarFullHistoryRequest,
    current_user: User = Depends(get_current_user)
):
    service = CarFullHistoryService()
    result = service.fetch_full_history(request.vin)
    return result

@app.get("/lease/{lease_id}")
def get_lease_by_id(
    lease_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    record = (
        db.query(LeaseAnalysis)
        .filter(
            LeaseAnalysis.id == lease_id,
            LeaseAnalysis.user_id == current_user.id
        )
        .first()
    )

    if not record:
        raise HTTPException(status_code=404, detail="Lease not found")

    return {
         "record_id": record.id,
        "filename": record.filename,
        "vin": record.vin,
        "analysis_result": record.analysis_result,
        "fairness_analysis": record.fairness_analysis,
        "price_estimation": record.price_estimation,
        "vehicle_api_data": record.vehicle_api_data,
        "car_full_history": record.car_full_history,
    }

# ================= CAR HISTORY BY VIN (JWT PROTECTED) =================
@app.get("/car-history/{vin}")
def get_car_history_by_vin(
    vin: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    record = (
        db.query(LeaseAnalysis)
        .filter(
            LeaseAnalysis.vin == vin,
            LeaseAnalysis.user_id == current_user.id
        )
        .first()
    )

    if not record:
        raise HTTPException(
            status_code=404,
            detail=f"No car history found for VIN {vin}"
        )

    return {
        "vin": record.vin,
        "vehicle_api_data": record.vehicle_api_data,
        "car_full_history": record.car_full_history,
    }



# JWT protected history
@app.get("/history")
def get_lease_history(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    records = (
        db.query(LeaseAnalysis)
        .filter(LeaseAnalysis.user_id == current_user.id)
        .order_by(LeaseAnalysis.created_at.desc())
        .limit(5)
        .all()
    )

    return [
    {
        "id": r.id,
        "filename": r.filename,
        "vin": r.vin,
        "fairness_score": (
            r.fairness_analysis.get("fairness_score")
            if r.fairness_analysis is not None
            else None
        ),
        "maker": (
            r.analysis_result.get("vehicle_details", {}).get("maker")
            if r.analysis_result is not None
            else None
        ),
        "model": (
            r.analysis_result.get("vehicle_details", {}).get("model")
            if r.analysis_result is not None
            else None
        ),
        "created_at": r.created_at.isoformat(),
    }
    for r in records
]
