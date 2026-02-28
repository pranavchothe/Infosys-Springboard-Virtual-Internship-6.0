import os
from groq import Groq

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def call_dealer_ai(
    user_message,
    analysis,
    fairness,
    vin=None,
    make=None,
    model=None,
):

    # -------------------------------
    # NORMALIZE VALUES (CRITICAL)
    # -------------------------------
    make_val = str(make) if make is not None else None
    model_val = str(model) if model is not None else None
    vin_val = str(vin) if vin is not None else None

    # -------------------------------
    # VEHICLE CONTEXT (SAFE)
    # -------------------------------
    vehicle_context_lines: list[str] = []

    if make_val is not None or model_val is not None:
        vehicle_context_lines.append(
            f"Vehicle: {make_val or 'Unknown'} {model_val or ''}".strip()
        )

    if vin_val is not None:
        vehicle_context_lines.append(
            f"VIN (internal reference only): {vin_val}"
        )

    vehicle_context = ""
    if len(vehicle_context_lines) > 0:
        vehicle_context = (
            "Vehicle context (DO NOT mention unless customer asks):\n"
            + "\n".join(vehicle_context_lines)
        )

    # -------------------------------
    # SYSTEM PROMPT
    # -------------------------------
    system_prompt = f"""
You are a car dealership sales executive negotiating lease terms on WhatsApp.

{vehicle_context}

IMPORTANT RULES:
- Do NOT mention the VIN unless the customer explicitly asks for it
- Do NOT proactively reveal internal identifiers
- Sound human, professional, and realistic
- Be polite but slightly defensive
- Protect dealership interests but allow negotiation
- Avoid repeating the same sentence
- Keep replies concise (2–4 lines)

Lease fairness score: {fairness.get("fairness_score")}
Red flags: {fairness.get("red_flags")}
"""

    # -------------------------------
    # GROQ CALL
    # -------------------------------
    try:
        response = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message},
            ],
            temperature=0.7,
        )

        content = response.choices[0].message.content
        if content is not None:
            return content.strip()

        return "Let me review this internally and get back to you."

    except Exception as e:
        print("Groq AI error:", e)
        return (
            "I understand your concern. Let me check this with my team and "
            "see what options we may have."
        )

def call_customer_negotiation_ai(
    dealer_message,
    analysis,
    fairness,
    vin=None,
    make=None,
    model=None,
):
    """
    Customer-side hidden AI assistant.
    Gives negotiation suggestions.
    Never visible to dealer.
    """

    make_val = str(make) if make is not None else "Unknown"
    model_val = str(model) if model is not None else ""
    vin_val = str(vin) if vin is not None else "Unknown"

    monthly_payment = analysis.get("monthly_payment", "Unknown")
    residual_value = analysis.get("residual_value", "Unknown")
    money_factor = analysis.get("money_factor", "Unknown")
    fairness_score = fairness.get("fairness_score", "Unknown")
    red_flags = fairness.get("red_flags", [])

    system_prompt = f"""
You are a professional car lease negotiation expert helping a customer.

Vehicle: {make_val} {model_val}
VIN: {vin_val}

Lease Details:
Monthly Payment: {monthly_payment}
Residual Value: {residual_value}
Money Factor: {money_factor}
Fairness Score: {fairness_score}
Red Flags: {red_flags}

IMPORTANT:
- Provide EXACTLY 3 short negotiation suggestions.
- Each suggestion must be on a new line.
- Do NOT write a paragraph.
- Do NOT add explanations.
- Do NOT number them.
- Just plain short negotiation sentences.

Lease fairness score: {fairness.get("fairness_score")}
Red flags: {fairness.get("red_flags")}
"""

    try:
        response = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": system_prompt},
                {
                    "role": "user",
                    "content": f"Dealer just said:\n{dealer_message}\n\nWhat should I say next?",
                },
            ],
            temperature=0.6,
        )

        content = response.choices[0].message.content
        if content:
            return content.strip()

        return "Ask for breakdown of money factor and available incentives."

    except Exception as e:
        print("Customer Negotiation AI error:", e)
        return (
            "Request a breakdown of fees and ask if better terms are available."
        )
