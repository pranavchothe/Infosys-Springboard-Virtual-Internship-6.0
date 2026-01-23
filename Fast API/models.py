from sqlalchemy import Column, Integer, String, DateTime, JSON, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)

    leases = relationship("LeaseAnalysis", back_populates="user")

class LeaseAnalysis(Base):
    __tablename__ = "lease_analyses"

    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String(255), nullable=False)        # original filename
    stored_filename = Column(String(255), nullable=True) # ✅ ADD THIS LINE

    analysis_result = Column(JSON)
    fairness_analysis = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)

    vin = Column(String(50), nullable=True)
    vehicle_api_data = Column(JSON, nullable=True)

    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="leases")