from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import LeaseAnalysis, DealerChatMessage, DealerStatus
from datetime import datetime, timedelta
from sqlalchemy import func
from dealer_auth import get_current_dealer



router = APIRouter()

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
def dealer_dashboard(db: Session = Depends(get_db)):

    # Get all unique leases that have chats
    rows = (
        db.query(
            DealerChatMessage.lease_id,
            DealerChatMessage.vin,
            func.max(DealerChatMessage.created_at).label("last_time"),
        )
        .group_by(
            DealerChatMessage.lease_id,
            DealerChatMessage.vin,
        )
        .order_by(func.max(DealerChatMessage.created_at).desc())
        .all()
    )

    result = []

    for r in rows:
        # Get last message
        last_message_obj = (
            db.query(DealerChatMessage)
            .filter(DealerChatMessage.lease_id == r.lease_id)
            .order_by(DealerChatMessage.created_at.desc())
            .first()
        )

        # Count unread user messages
        unread_count = db.query(DealerChatMessage).filter(
            DealerChatMessage.lease_id == r.lease_id,
            DealerChatMessage.sender == "user",
            DealerChatMessage.is_read == False,
        ).count()

        result.append({
            "lease_id": r.lease_id,
            "vin": r.vin,
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
            "created_at": l.created_at,
        }
        for l in leases
    ]
