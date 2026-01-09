import os
import pytesseract
from pdf2image import convert_from_path
from PIL import Image

pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

def extract_text(file_path: str) -> str:
    ext = os.path.splitext(file_path)[1].lower()

    if ext == ".pdf":
        pages = convert_from_path(file_path, dpi=300)
        text = ""
        for page in pages:
            text += pytesseract.image_to_string(page)
        return text

    elif ext in [".png", ".jpg", ".jpeg"]:
        img = Image.open(file_path)
        return pytesseract.image_to_string(img)

    elif ext == ".txt":
        with open(file_path, "r", encoding="utf-8") as f:
            return f.read()

    else:
        raise ValueError("Unsupported file format")
