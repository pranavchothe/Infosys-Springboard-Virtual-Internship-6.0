from groq import Groq
import os
import re

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def analyze_lease(text: str):
    prompt = f"""
You are a legal document analyzer.

CRITICAL RULES:
1. If a value exists anywhere in the document text, you MUST extract it. DO NOT return null.
2. Return null ONLY if the information truly does not appear in the document.
3. DO NOT guess or invent values.
4. Carefully scan for:
   - Dates: "Start Date", "End Date", "Commencement", formats like "10 January 2026", "09 Jan 2029"
   - Totals: "Total of Payments", "Total Monthly", currency values like "INR 6,04,800"
   - Payment terms: "monthly", "due on", "payment schedule", "installments"
5. Even if the OCR text is broken across lines or spaces, reconstruct the value logically.
6. Return ONLY valid JSON. No markdown, no explanations.

Return exactly this structure:

{{
  "1.parties": {{"lessor": null, "lessee": null}},
  "2.lease_details": {{
    "lease_duration": null,
    "start_date": null,
    "end_date": null,
    "rent_amount": null,
    "payment_terms": null
  }},
  "3.vehicle_details": {{
    "maker": null,
    "model": null,
    "year": null,
    "body_style": null,
    "color": null,
    "vehicle_id_number": null,
    "registration_number": null
  }},
  "4.financials": {{
    "base_monthly_payment": null,
    "monthly_tax": null,
    "total_monthly_payment": null,
    "total_of_payments": null,
    "residual_value": null,
    "purchase_option_price": null
  }},
  "5.penalties": {{
    "early_termination_charge": null,
    "late_payment_fee": null,
    "excess_wear_charges": null
  }},
  "6.termination_clause": null
}}

Document text:
{text}
"""

    response = client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.0
    )

    raw_output = response.choices[0].message.content


    cleaned = re.sub(r"```json|```", "", str(raw_output)).strip()

    return cleaned
