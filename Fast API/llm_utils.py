from groq import Groq
import os

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def analyze_lease(text: str):
    prompt = f"""
You are a legal document analyzer.

Extract the following from this lease document and return ONLY a valid JSON object.
If any value is missing in the document, return null instead of guessing.
Do NOT include markdown, code blocks, or explanations.

Extract the following fields:

1. parties:
   - lessor
   - lessee

2. lease_details:
   - lease_duration
   - start_date
   - end_date
   - rent_amount
   - payment_terms

3. vehicle_details:
   - maker
   - model
   - year
   - body_style
   - color
   - vehicle_id_number (VIN)
   - registration_number (if available)

4. financials:
   - base_monthly_payment
   - monthly_tax
   - total_monthly_payment
   - total_of_payments
   - residual_value
   - purchase_option_price

5. penalties:
   - early_termination_charge
   - late_payment_fee
   - excess_wear_charges

6. termination_clause

Document:
{text}
"""


    response = client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.2
    )

    return response.choices[0].message.content

