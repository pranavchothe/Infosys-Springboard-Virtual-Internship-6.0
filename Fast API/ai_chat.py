from fastapi import APIRouter
from pydantic import BaseModel
import os
from groq import Groq

router = APIRouter()

client = Groq(
    api_key=os.getenv("GROQ_API_KEY")
)

class ChatRequest(BaseModel):
    message: str
    car_context: dict | None = None


@router.post("/ai-chat")
async def ai_chat(req: ChatRequest):
    system_prompt = (
        "You are a car analysis assistant. "
        "Explain car history, risk, lease advice, and buying guidance "
        "in simple and short language."
    )

    user_prompt = f"""
User Question:
{req.message}

Car History Data:
{req.car_context}
"""

    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        temperature=0.3,
    )

    return {
        "reply": response.choices[0].message.content
    }
