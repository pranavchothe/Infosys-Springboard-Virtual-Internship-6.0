from sqlalchemy import Column, Integer, String, DateTime, JSON, ForeignKey, Text
from sqlalchemy.orm import relationship, Mapped, mapped_column
from datetime import datetime
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)

    leases = relationship("LeaseAnalysis", back_populates="user")

class LeaseAnalysis(Base):
    __tablename__ = "lease_analyses"

    id: Mapped[int] = mapped_column(primary_key=True)
    filename = Column(String(255), nullable=False)       
    stored_filename = Column(String(255), nullable=True) 

    analysis_result = Column(JSON)
    fairness_analysis = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)

    vin = Column(String(50), nullable=True)
    vehicle_api_data = Column(JSON, nullable=True)

    car_full_history: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    dealer_chats = relationship(
    "DealerChatMessage",
    back_populates="lease",
    cascade="all, delete-orphan"
)
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="leases")

class DealerChatMessage(Base):
    __tablename__ = "dealer_chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    lease_id = Column(Integer, ForeignKey("lease_analyses.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    vin = Column(String(50), index=True, nullable=False)
    sender = Column(String(20), nullable=False)  # "user" | "dealer"
    message = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    lease = relationship("LeaseAnalysis", back_populates="dealer_chats")
    user = relationship("User")
