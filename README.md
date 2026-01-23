# Car Lease Document Analyzer

This project extracts text from car lease contracts using OCR and converts them into structured JSON data using an AI model.

## 🔍 Features
- PDF → Image → OCR → Text
- Filters low-confidence OCR results
- Text → AI → JSON conversion
- Clean and structured output for analysis

## 📂 Project Structure

Car_Lease_Document_Analyzer/
│
├── backend/
│   ├── main.py                 # FastAPI entry point
│   ├── database.py             # Database connection
│   ├── models.py               # SQLAlchemy models
│   ├── schemas.py              # Pydantic schemas
│   ├── crud.py                 # Database operations
│   ├── routes/
│   │   ├── upload.py           # File upload endpoints
│   │   ├── analyze.py          # Document analysis endpoints
│   │   └── auth.py             # Authentication routes
│   └── services/
│       ├── ocr_service.py      # PDF → Image → OCR logic
│       ├── ai_service.py       # LLM (Groq / GPT) processing
│       └── parser.py           # Text → Structured JSON
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart           # Flutter entry point
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   └── pubspec.yaml
