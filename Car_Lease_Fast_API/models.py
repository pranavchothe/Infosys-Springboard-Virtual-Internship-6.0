from sqlalchemy import (
    Column,
    Integer,
    String,
    DateTime,
    JSON,
    ForeignKey,
    Text,
    Boolean,
)
from sqlalchemy.orm import relationship, Mapped, mapped_column
from datetime import datetime
from database import Base

# USER
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)

    leases = relationship("LeaseAnalysis", back_populates="user")

# LEASE ANALYSIS
class LeaseAnalysis(Base):
    __tablename__ = "lease_analyses"

    id: Mapped[int] = mapped_column(primary_key=True)

    filename = Column(String(255), nullable=False)
    stored_filename = Column(String(255), nullable=True)

    analysis_result = Column(JSON)
    fairness_analysis = Column(JSON)
    price_estimation = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    vin = Column(String(50), nullable=True)
    vehicle_api_data = Column(JSON, nullable=True)
    car_full_history: Mapped[dict | None] = mapped_column(JSON, nullable=True)

    # Relationships
    dealer_chats = relationship(
    "DealerChatMessage",
    back_populates="lease",
    cascade="all, delete-orphan"
    )


    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="leases")

# DEALER CHAT MESSAGE
class DealerChatMessage(Base):
    __tablename__ = "dealer_chat_messages"

    id = Column(Integer, primary_key=True)
    lease_id = Column(Integer, ForeignKey("lease_analyses.id"))
    vin = Column(String(50))
    sender = Column(String(20))  # "user" | "dealer"
    message = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    dealer_id = Column(Integer, ForeignKey("dealers.id"), nullable=True)

    # Relationships
    lease = relationship("LeaseAnalysis", back_populates="dealer_chats")
    dealer = relationship("Dealer", back_populates="chat_messages")

# DEALER ONLINE STATUS
class DealerStatus(Base):
    __tablename__ = "dealer_status"

    id: Mapped[int] = mapped_column(primary_key=True)
    is_online: Mapped[bool] = mapped_column(Boolean, default=False)
    last_seen: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

class Dealer(Base):
    __tablename__ = "dealers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    chat_messages = relationship(
        "DealerChatMessage",
        back_populates="dealer",
        cascade="all, delete-orphan"
    )

