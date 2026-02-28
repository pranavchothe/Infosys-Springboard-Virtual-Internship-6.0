from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from database import SessionLocal
from models import LeaseAnalysis
from llm_utils import chat_with_llm
from auth import get_current_user

router = APIRouter()


# REQUEST SCHEMA
class ChatRequest(BaseModel):
    message: str
    record_id: int

# DB DEPENDENCY
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# CHAT ENDPOINT
@router.post("/")
def lease_aware_chat(
    chat: ChatRequest,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    # Fetch lease securely
    record = (
        db.query(LeaseAnalysis)
        .filter(
            LeaseAnalysis.id == chat.record_id,
            LeaseAnalysis.user_id == user.id,
        )
        .first()
    )

    if not record:
        raise HTTPException(status_code=404, detail="Lease record not found")

    user_msg = chat.message.lower().strip()
    fairness = record.fairness_analysis or {}

    # FAST RESPONSES (NO AI CALL)
    if user_msg in {"hi", "hello", "hey"}:
        return {
            "reply": "Hi! 👋 I can help you understand your car lease — risks, costs, fairness, or buying options."
        }

    if user_msg in {"thanks", "thank you"}:
        return {
            "reply": "You’re welcome! 😊 Feel free to ask if you need help with any part of the lease."
        }

    # LEASE FAIRNESS
    if "fairness" in user_msg or "contract" in user_msg:
        fairness = record.fairness_analysis
    if fairness is None:
        fairness = {}

        if not fairness:
            return {
                "reply": (
                    "📄 **Lease Fairness**\n\n"
                    "I couldn’t calculate a lease fairness score because some contract details are missing.\n\n"
                    "This usually happens when monthly payments, penalties, or end-of-lease terms are unclear."
                )
            }

        return {
            "reply": (
                "📄 **Lease Fairness Explained**\n\n"
                f"• Score: {fairness.get('score', 'N/A')}\n"
                f"• Summary: {fairness.get('summary', 'No summary available')}\n"
                f"• Recommendation: {fairness.get('recommendation', 'Review carefully')}"
            )
        }


    # CAR HISTORY / DAMAGE
    if any(word in user_msg for word in ["damage", "accident", "history", "car history"]):
        history = record.car_full_history or {}

        if history is None:
            return {
                "reply": (
                    "🚗 **Car History**\n\n"
                    "Car history data is not available yet.\n"
                    "This may take a few seconds after analysis or the VIN may be missing."
                )
            }

        return {
            "reply": (
                "🚗 **Car History Summary**\n\n"
                "• Accident history: "
                f"{history.get('accidents', 'Not reported')}\n"
                "• Damage reports: "
                f"{history.get('damage', 'Not reported')}\n"
                "• Ownership records: "
                f"{history.get('owners', 'Not available')}\n\n"
                "If you want, I can explain whether this history increases risk."
            )
        }


    # AI SYSTEM PROMPT
    system_prompt = f"""
You are a friendly, professional AI assistant inside a Car Lease Analysis app.

Your job:
- Help users understand their uploaded car lease
- Explain risks, costs, fairness, and buying decisions
- Respond naturally like a helpful human

Rules:
- Keep answers short and clear
- Use bullet points for explanations
- DO NOT return JSON
- DO NOT invent missing data
- If something is unclear, explain it simply

Tone:
- Friendly
- Clear
- Simple English
- Not robotic

Lease analysis:
{record.analysis_result}

Fairness analysis:
{fairness}

Car history:
{record.car_full_history or "No car history available"}
"""

    # AI RESPONSE
    try:
        reply = chat_with_llm(
            system_prompt=system_prompt,
            user_message=chat.message,
        )
    except Exception:
        reply = "⚠️ I had trouble answering that. Please try again."

    return {"reply": reply}
