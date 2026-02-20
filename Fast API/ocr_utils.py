import os
import pytesseract
from pdf2image import convert_from_path
from PIL import Image, ImageEnhance, ImageFilter

pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

def preprocess_image(img: Image.Image) -> Image.Image:
    # Convert to grayscale
    img = img.convert("L")

    # Increase contrast
    img = ImageEnhance.Contrast(img).enhance(2.0)

    # Increase sharpness
    img = ImageEnhance.Sharpness(img).enhance(2.0)

    # Reduce noise
    img = img.filter(ImageFilter.MedianFilter())

    # Binarize using lookup table (editor-safe)
    threshold = 150
    table = [0 if i < threshold else 255 for i in range(256)]
    img = img.point(table)

    return img

def extract_text(file_path: str) -> str:
    ext = os.path.splitext(file_path)[1].lower()
    text = ""

    if ext == ".pdf":
        pages = convert_from_path(file_path, dpi=300)

        for page in pages:
            processed = preprocess_image(page)

            page_text = pytesseract.image_to_string(
                processed,
                config=(
                    "--oem 3 "
                    "--psm 4 "   # better for columns/tables
                    "-c preserve_interword_spaces=1 "
                    "-c tessedit_char_whitelist="
                    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,:/()- "
                )
            )
            text += page_text + "\n"

        return text

    elif ext in [".png", ".jpg", ".jpeg"]:
        img = Image.open(file_path)
        processed = preprocess_image(img)

        return pytesseract.image_to_string(
            processed,
            config=(
                "--oem 3 "
                "--psm 4 "
                "-c preserve_interword_spaces=1 "
                "-c tessedit_char_whitelist="
                "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,:/()- "
            )
        )

    elif ext == ".txt":
        with open(file_path, "r", encoding="utf-8") as f:
            return f.read()

    else:
        raise ValueError("Unsupported file format")
