import os
import json
import re
from groq import Groq

API_KEY = os.getenv("GROQ_API_KEY")

INPUT_TXT_FOLDER = r"C:\Users\prana\Downloads\Car_lease\final_output"
OUTPUT_JSON_FOLDER = r"C:\Users\prana\Downloads\Car_lease\llm_json"

os.makedirs(OUTPUT_JSON_FOLDER, exist_ok=True)

client = Groq(api_key=API_KEY)

MODEL_NAME = "llama-3.1-8b-instant" 

def build_prompt(document_text):
    return f"""
You are a legal document analyst.

Analyze the following lease document text and extract key information.
Return ONLY valid JSON in the following format. Do NOT add explanations, comments, or markdown.

{{
  "parties": [],
  "lease_duration": "",
  "payment_terms": "",
  "vehicle_details": "",
  "start_date": "",
  "end_date": "",
  "special_clauses": [],
  "raw_summary": ""
}}

Document Text:
\"\"\"
{document_text}
\"\"\"
"""

# CLEAN JSON OUTPUT
def extract_json(text):
    """
    Extract the first JSON object from model output.
    Handles extra text or formatting.
    """
    match = re.search(r"\{.*\}", text, re.DOTALL)
    if match:
        return match.group()
    return text

# PROCESS FILES 
for file in os.listdir(INPUT_TXT_FOLDER):
    if file.lower().endswith(".txt"):
        txt_path = os.path.join(INPUT_TXT_FOLDER, file)
        print(f"\nProcessing TXT → LLM → JSON: {file}")

        # Read TXT
        with open(txt_path, "r", encoding="utf-8") as f:
            text_data = f.read()

        prompt = build_prompt(text_data)

        try:
            # Call Groq API
            response = client.chat.completions.create(
                model=MODEL_NAME,
                messages=[
                    {"role": "system", "content": "You are a precise legal document parser."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.2
            )

            llm_output = response.choices[0].message.content.strip()
            cleaned_output = extract_json(llm_output)

            json_filename = file.replace(".txt", ".json")
            json_path = os.path.join(OUTPUT_JSON_FOLDER, json_filename)

            try:
                parsed_json = json.loads(cleaned_output)

                with open(json_path, "w", encoding="utf-8") as jf:
                    json.dump(parsed_json, jf, indent=4, ensure_ascii=False)

                print(f"JSON saved → {json_path}\n")

            except json.JSONDecodeError as e:
                print("JSON parsing failed. Saving raw LLM output.")
                print("Error:", e)

                with open(json_path, "w", encoding="utf-8") as jf:
                    jf.write(llm_output)

        except Exception as e:
            print("Error during LLM processing:", e)

