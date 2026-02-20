from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from database import get_db
from models import Dealer
from pydantic import BaseModel

# Same secret as user auth
SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/dealer-auth/login")

router = APIRouter(prefix="/dealer-auth", tags=["Dealer Auth"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# SCHEMAS

class DealerRegister(BaseModel):
    name: str
    email: str
    password: str


class DealerLogin(BaseModel):
    email: str
    password: str

# UTILS

def verify_password(plain, hashed):
    return pwd_context.verify(plain, hashed)


def get_password_hash(password):
    return pwd_context.hash(password)


def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def get_current_dealer(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        dealer_id = payload.get("dealer_id")

        if dealer_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

    dealer = db.query(Dealer).filter(Dealer.id == int(dealer_id)).first()

    if dealer is None:
        raise HTTPException(status_code=401, detail="Dealer not found")

    return dealer


# REGISTER

@router.post("/register")
def register(data: DealerRegister, db: Session = Depends(get_db)):

    existing = db.query(Dealer).filter(Dealer.email == data.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    dealer = Dealer(
        name=data.name,
        email=data.email,
        hashed_password=get_password_hash(data.password),
    )

    db.add(dealer)
    db.commit()
    db.refresh(dealer)

    return {"message": "Dealer registered successfully"}

# LOGIN

@router.post("/login")
def login(data: DealerLogin, db: Session = Depends(get_db)):

    dealer = db.query(Dealer).filter(Dealer.email == data.email).first()

    if not dealer or not verify_password(data.password, dealer.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    access_token = create_access_token({"dealer_id": dealer.id})

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "dealer_id": dealer.id,
        "name": dealer.name,
    }
