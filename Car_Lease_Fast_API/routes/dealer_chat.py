from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import LeaseAnalysis, DealerChatMessage, DealerStatus
from datetime import datetime, timedelta
from sqlalchemy import func
from dealer_auth import get_current_dealer
from pydantic import BaseModel
from auth import get_current_user
from external_ai import call_customer_negotiation_ai


router = APIRouter()

class NegotiationSuggestionRequest(BaseModel):
    lease_id: int
    dealer_message: str

@router.post("/dealer-chat/ai-suggestion")
def ai_negotiation_suggestion(
    request: NegotiationSuggestionRequest,
    db: Session = Depends(get_db),
    user = Depends(get_current_user)
):
    lease = db.query(LeaseAnalysis).filter(
        LeaseAnalysis.id == request.lease_id
    ).first()

    if lease is None:
        raise HTTPException(status_code=404, detail="Lease not found")

    # Extract values from stored JSON (VERY IMPORTANT for your schema)
    analysis = lease.analysis_result or {}
    fairness = lease.fairness_analysis or {}

    monthly_payment = analysis.get("monthly_payment", "Unknown")
    residual_value = analysis.get("residual_value", "Unknown")
    money_factor = analysis.get("money_factor", "Unknown")
    fairness_score = fairness.get("score", "Unknown")

    prompt = f"""
You are a professional car lease negotiation expert.

Lease Information:
VIN: {lease.vin}
Monthly Payment: {monthly_payment}
Residual Value: {residual_value}
Money Factor: {money_factor}
Fairness Score: {fairness_score}

Dealer just said:
"{request.dealer_message}"

Give 3 short, strong, polite negotiation responses 
the customer can say next.

Focus on:
- Lowering monthly payment
- Reducing fees
- Improving residual or money factor
- Asking for breakdown if unclear

Keep it concise and strategic.
"""

    vehicle_data = lease.vehicle_api_data or {}

    make = vehicle_data.get("make")
    model = vehicle_data.get("model")

    ai_response = call_customer_negotiation_ai(
        dealer_message=request.dealer_message,
        analysis=analysis,
        fairness=fairness,
        vin=lease.vin,
        make=make,
        model=model,
    )


    return {"suggestion": ai_response}

# CUSTOMER SENDS MESSAGE
@router.post("/dealer-chat")
def dealer_chat(payload: dict, db: Session = Depends(get_db)):

    lease_id = payload.get("lease_id")
    message = payload.get("message")

    if lease_id is None or not message:
        raise HTTPException(status_code=400, detail="Invalid payload")

    lease = (
        db.query(LeaseAnalysis)
        .filter(LeaseAnalysis.id == lease_id)
        .first()
    )

    if lease is None:
        raise HTTPException(status_code=404, detail="Lease not found")

    vin = lease.vin if lease.vin is not None else None

    db.add(
        DealerChatMessage(
            lease_id=lease.id,
            vin=vin,
            sender="user",
            message=message,
        )
    )
    db.commit()

    return {"status": "message_sent"}  

# LOAD CHAT HISTORY
@router.get("/dealer-chat/{lease_id}")
def get_chat_history(lease_id: int, db: Session = Depends(get_db)):
    chats = (
        db.query(DealerChatMessage)
        .filter(DealerChatMessage.lease_id == lease_id)
        .order_by(DealerChatMessage.created_at)
        .all()
    )

    return [
        {
            "sender": c.sender,
            "message": c.message,
            "created_at": c.created_at,
        }
        for c in chats
    ]

# DEALER REPLIES MANUALLY
@router.post("/dealer-chat/reply")
def dealer_reply(
    payload: dict,
    db: Session = Depends(get_db),
    dealer = Depends(get_current_dealer)
):
    lease_id = payload.get("lease_id")
    message = payload.get("message")

    if lease_id is None or not message:
        raise HTTPException(status_code=400, detail="Invalid payload")

    lease = (
        db.query(LeaseAnalysis)
        .filter(LeaseAnalysis.id == lease_id)
        .first()
    )

    if lease is None:
        raise HTTPException(status_code=404, detail="Lease not found")

    vin = lease.vin if lease.vin is not None else None

    db.add(
        DealerChatMessage(
            lease_id=lease.id,
            vin=vin,
            sender="dealer",
            message=message,
        )
    )
    db.commit()

    return {"status": "reply_sent"}

# MARK USER MESSAGES AS READ
@router.post("/dealer-chat/mark-read/{lease_id}")
def mark_messages_read(lease_id: int, db: Session = Depends(get_db)):
    db.query(DealerChatMessage).filter(
        DealerChatMessage.lease_id == lease_id,
        DealerChatMessage.sender == "user",
        DealerChatMessage.is_read == False,
    ).update({"is_read": True})

    db.commit()
    return {"status": "marked_read"}

# DEALER HEARTBEAT (ONLINE)
@router.post("/dealer/status/heartbeat")
def dealer_heartbeat( db: Session = Depends(get_db),
    dealer = Depends(get_current_dealer)):
    status = db.query(DealerStatus).first()

    if status is None:
        status = DealerStatus()
        db.add(status)

    status.is_online = True
    status.last_seen = datetime.utcnow()
    db.commit()

    return {"status": "ok"}

# DEALER ONLINE / OFFLINE
@router.get("/dealer/status")
def dealer_status(db: Session = Depends(get_db)):
    status = db.query(DealerStatus).first()

    if status is None or status.last_seen is None:
        return {"online": False}

    online = datetime.utcnow() - status.last_seen < timedelta(seconds=30)
    return {"online": online}

@router.get("/dealer/dashboard")
def dealer_dashboard(
    db: Session = Depends(get_db),
    dealer = Depends(get_current_dealer)
):

    rows = (
        db.query(
            DealerChatMessage.lease_id,
            func.max(DealerChatMessage.created_at).label("last_time"),
        )
        .group_by(DealerChatMessage.lease_id)
        .order_by(func.max(DealerChatMessage.created_at).desc())
        .all()
    )

    result = []

    for r in rows:

        lease = db.query(LeaseAnalysis).filter(
            LeaseAnalysis.id == r.lease_id
        ).first()

        if not lease:
            continue

        last_message_obj = (
            db.query(DealerChatMessage)
            .filter(DealerChatMessage.lease_id == r.lease_id)
            .order_by(DealerChatMessage.created_at.desc())
            .first()
        )

        unread_count = db.query(DealerChatMessage).filter(
            DealerChatMessage.lease_id == r.lease_id,
            DealerChatMessage.sender == "user",
            DealerChatMessage.is_read == False,
        ).count()

        result.append({
            "lease_id": r.lease_id,
            "vin": lease.vin,
            "customer_name": lease.user.name if lease.user else "Unknown",
            "last_message": last_message_obj.message if last_message_obj else "",
            "last_time": r.last_time,
            "unread": unread_count
        })

    return result




@router.get("/dealer/leases")
def get_all_leases_for_dealer(
    db: Session = Depends(get_db),
    dealer = Depends(get_current_dealer)
):
    leases = db.query(LeaseAnalysis).order_by(
        LeaseAnalysis.created_at.desc()
    ).all()

    return [
        {
            "lease_id": l.id,
            "vin": l.vin,
            "filename": l.filename,
            "customer_name": l.user.full_name if l.user else "Unknown",
            "created_at": l.created_at,
        }
        for l in leases
    ]
