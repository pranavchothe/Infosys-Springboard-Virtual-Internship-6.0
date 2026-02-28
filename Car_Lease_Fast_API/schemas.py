from pydantic import BaseModel

class CarFullHistoryRequest(BaseModel):
    vin: str

class CarFullHistoryResponse(BaseModel):
    vin: str
    make: str
    model: str
    year: str

    accidental: bool
    flood_damage: bool
    owners: int
    insurance_claims: int
    stolen: bool
    status: str
    source: str
