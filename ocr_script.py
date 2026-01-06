import pytesseract
from pdf2image import convert_from_path
from pytesseract import Output
from PIL import Image, ImageFilter, ImageEnhance
import os

pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

pdf_folder = r"C:\Users\prana\Downloads\Car_lease\contracts"
output_folder = r"C:\Users\prana\Downloads\Car_lease\final_output"

os.makedirs(output_folder, exist_ok=True)

def preprocess_strong(image):
    image = image.convert("L")
    image = image.filter(ImageFilter.MedianFilter(size=5))
    image = ImageEnhance.Contrast(image).enhance(3.0)
    image = image.filter(ImageFilter.SHARPEN)
    image = image.filter(ImageFilter.SHARPEN)
    image = image.point(lambda x: 0 if x < 160 else 255, '1')
    return image

custom_config = r'--oem 3 --psm 4 -c preserve_interword_spaces=1'

for file in os.listdir(pdf_folder):
    if file.lower().endswith(".pdf"):
        pdf_path = os.path.join(pdf_folder, file)
        print(f"\nProcessing {file}")

        pages = convert_from_path(pdf_path, dpi=500)

        output_txt = os.path.join(
            output_folder,
            file.replace(".pdf", ".txt")
        )

        with open(output_txt, "w", encoding="utf-8") as out:
            for page_num, page in enumerate(pages, start=1):
                processed = preprocess_strong(page)

                data = pytesseract.image_to_data(
                    processed,
                    output_type=Output.DICT,
                    config=custom_config
                )

                words = []
                confidences = []

                for text, conf in zip(data["text"], data["conf"]):
                    if text.strip() and conf != "-1" and int(conf) > 60:
                        words.append(text)
                        confidences.append(int(conf))

                page_text = " ".join(words)
                avg_conf = sum(confidences) / len(confidences) if confidences else 0

                out.write(f"\n========== PAGE {page_num} ==========\n")
                out.write(f"[OCR Accuracy: {avg_conf:.2f}%]\n\n")
                out.write(page_text + "\n\n")

                print(f"Page {page_num} → Accuracy: {avg_conf:.2f}%")

        print(f"Saved → {output_txt}")
