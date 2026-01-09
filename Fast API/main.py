from fastapi import FastAPI, File, UploadFile
import re
import json
import shutil
import os
from ocr_utils import extract_text
from llm_utils import analyze_lease

app = FastAPI(title="Lease Document Analyzer API")

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)
LAST_UPLOADED_FILE = None

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


@app.get("/analyze/")
def analyze_document():
    try:
        global LAST_UPLOADED_FILE

        if not LAST_UPLOADED_FILE:
            return {"error": "No file uploaded yet. Please upload a file first."}

        file_path = os.path.join(UPLOAD_DIR, LAST_UPLOADED_FILE)

        if not os.path.exists(file_path):
            return {"error": "Uploaded file not found on server."}

        # Step 1: OCR
        extracted_text = extract_text(file_path)

        # Step 2: LLM
        raw_output = analyze_lease(extracted_text)

        # Step 3: Clean markdown
        cleaned = re.sub(r"```json|```", "", raw_output).strip()

        # Step 4: Convert to JSON
        parsed_json = json.loads(cleaned)

        return {
            "filename": LAST_UPLOADED_FILE,
            "extracted_text_preview": extracted_text[:500],
            "analysis_result": parsed_json
        }

    except Exception as e:
        return {
            "error": "Processing failed",
            "details": str(e)
        }
