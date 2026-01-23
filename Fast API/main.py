from email.mime import text
from fastapi import FastAPI, File, UploadFile, Depends, HTTPException, status
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


# Create DB tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Lease Document Analyzer API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # allow all for dev
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router, prefix="/auth", tags=["auth"])


UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

LAST_UPLOADED_FILE = None


def extract_vin_from_text(text: str):
    """
    Extract VIN even if OCR breaks it with spaces or newlines.
    """
    cleaned = text.replace(" ", "").replace("\n", "").upper()

    # VIN pattern: exactly 17 characters, no I O Q
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


@app.post("/upload")
def upload_file(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # Save file uniquely
    timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
    unique_filename = f"{current_user.id}_{timestamp}_{file.filename}"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    original_filename = file.filename

    #  EXTRACT TEXT USING OCR UTILS
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
            "vehicle_api_data": existing_record.vehicle_api_data
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

    #  CLEAN & PARSE JSON
    cleaned = re.sub(r"```json|```", "", raw_output).strip()

    try:
        parsed_json = json.loads(cleaned

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

    #  EXTRACT VIN
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

    # 7FAIRNESS
    fairness_result = calculate_fairness(parsed_json)

    # STORE IN DB
    record = LeaseAnalysis(
        user_id=current_user.id,
        filename=original_filename,
        stored_filename=unique_filename,
        analysis_result=parsed_json,
        fairness_analysis=fairness_result,
        vin=vin,
        vehicle_api_data=vehicle_api_data,
    )

    db.add(record)
    db.commit()
    db.refresh(record)

    # RETURN TO FLUTTER
    return {
        "message": "Lease analysis completed and stored",
        "record_id": record.id,
        "filename": original_filename,
        "vin": vin,
        "analysis_result": parsed_json,
        "fairness_analysis": fairness_result,
        "vehicle_api_data": vehicle_api_data
    }

# JWT protected history
@app.get("/history")
def get_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    records = (
        db.query(LeaseAnalysis)
        .filter(LeaseAnalysis.user_id == current_user.id)
        .order_by(LeaseAnalysis.created_at.desc())
        .all()
    )

    return [
        {
            "filename": r.filename,
            "analysis_result": r.analysis_result,
            "fairness_analysis": r.fairness_analysis,
            "created_at": r.created_at.isoformat(),
        }
        for r in records
    ]

