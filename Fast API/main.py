from fastapi import FastAPI, File, UploadFile
import re
import json
import shutil
import os
from ocr_utils import extract_text
from llm_utils import analyze_lease
from fairness_utils import calculate_fairness
from database import SessionLocal, engine
from models import LeaseAnalysis
from sqlalchemy.orm import Session

# Create DB tables
from database import Base
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Lease Document Analyzer API")

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)
LAST_UPLOADED_FILE = None

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

@app.post("/upload/")
async def upload_document(file: UploadFile = File(...)):
    global LAST_UPLOADED_FILE

    file_path = os.path.join(UPLOAD_DIR, file.filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    LAST_UPLOADED_FILE = file.filename 

    return {
        "filename": file.filename,
        "status": "uploaded successfully"
    }

from fastapi import Depends
from sqlalchemy.orm import Session

@app.get("/analyze/")
def analyze_document(db: Session = Depends(get_db)):
    try:
        global LAST_UPLOADED_FILE

        if not LAST_UPLOADED_FILE:
            return {"error": "No file uploaded yet. Please upload a file first."}

        file_path = os.path.join(UPLOAD_DIR, LAST_UPLOADED_FILE)

        if not os.path.exists(file_path):
            return {"error": "Uploaded file not found on server."}

        # CHECK IF FILE ALREADY EXISTS IN DATABASE
        existing_record = db.query(LeaseAnalysis)\
                            .filter(LeaseAnalysis.filename == LAST_UPLOADED_FILE)\
                            .first()

        if existing_record:
            return {
                "message": "Existing SLA analysis found in database",
                "record_id": existing_record.id,
                "filename": existing_record.filename,
                "analysis_result": existing_record.analysis_result,
                "fairness_analysis": existing_record.fairness_analysis
            }

        # OCR
        extracted_text = extract_text(file_path)

        # LLM Analysis
        raw_output = analyze_lease(extracted_text)
        cleaned = re.sub(r"```json|```", "", raw_output).strip()
        parsed_json = json.loads(cleaned)

        # Fairness / SLA Evaluation
        fairness_result = calculate_fairness(parsed_json)

        # STORE IN MYSQL
        record = LeaseAnalysis(
            filename=LAST_UPLOADED_FILE,
            analysis_result=parsed_json,
            fairness_analysis=fairness_result
        )

        db.add(record)
        db.commit()
        db.refresh(record)

        return {
            "message": "SLA analysis completed and stored in database",
            "record_id": record.id,
            "filename": LAST_UPLOADED_FILE,
            "analysis_result": parsed_json,
            "fairness_analysis": fairness_result
        }

    except Exception as e:
        return {
            "error": "Processing failed",
            "details": str(e)
        }

