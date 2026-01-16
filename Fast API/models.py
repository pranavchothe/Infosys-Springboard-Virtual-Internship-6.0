from sqlalchemy import Column, Integer, String, DateTime, JSON
from datetime import datetime
from database import Base

class LeaseAnalysis(Base):
    __tablename__ = "lease_analysis"

    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String(255))
    analysis_result = Column(JSON)
    fairness_analysis = Column(JSON)

    vin = Column(String(17))
    vehicle_api_data = Column(JSON)

    created_at = Column(DateTime, default=datetime.utcnow)
