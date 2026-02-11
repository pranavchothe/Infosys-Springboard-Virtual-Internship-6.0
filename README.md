🚗 Car Lease Analysis & Negotiation Assistant (AI-Powered)

An end-to-end AI-driven car lease analysis platform that allows users to upload lease documents, analyze fairness and risks, view VIN-based vehicle history, and negotiate lease terms with an AI dealer chatbot (WhatsApp-style experience).

Built using Flutter (Frontend), FastAPI (Backend), SQLAlchemy, MySQL, and Groq LLM API (Free).

✨ Key Features
📄 Lease Analysis

Upload car lease documents

Extract structured lease details

Analyze:

Monthly payments

Penalties

Termination clauses

Hidden risks

Generate a Fairness Score (0–100) with explanations

🚘 VIN-Based Vehicle Intelligence

VIN extraction from lease

Vehicle details (make, model, year, body type, color)

Car history:

Ownership

Accidents

Insurance claims

Flood / theft records

🤝 AI Dealer Chatbot (Negotiation Assistant)

WhatsApp-style chat UI

User negotiates directly with an AI car dealer

AI responses are:

Context-aware (lease + fairness + vehicle)

VIN-aware (VIN revealed only if user asks)

Professional and realistic

Full chat history saved per lease (VIN-linked)

🧠 Smart Fairness Engine

Detects:

Excessive penalties

Missing insurance clauses

One-sided termination terms

Lack of cooling-off period

Produces:

Fairness score

Verdict (Fair / Moderate / Unfair)

Red-flag explanations

📊 Reports & UI

Interactive fairness gauge

Downloadable PDF lease report

Modern glassmorphism UI

Dark, premium design

🛠️ Tech Stack
Frontend

Flutter (Dart)

Material UI

Syncfusion Gauges

REST API integration

Backend

FastAPI (Python)

SQLAlchemy ORM

MySQL

JWT Authentication

Groq LLM API (Free Tier)

AI / NLP

Groq API

LLaMA-3.1-8B-Instant model

Prompt-engineered dealer negotiation logic

📂 Project Structure
├── frontend/
│   ├── lib/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── services/
│   │   └── main.dart
│
├── backend/
│   ├── main.py
│   ├── database.py
│   ├── models.py
│   ├── auth.py
│   ├── fairness_utils.py
│   ├── external_ai.py
│   ├── routes/
│   │   ├── dealer_chat.py
│   │   └── car_history.py
│
└── README.md

⚙️ Backend Setup
1️⃣ Clone Repository
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name/backend

2️⃣ Create Virtual Environment
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate

3️⃣ Install Dependencies
pip install -r requirements.txt

4️⃣ Environment Variables

Create .env file:

DATABASE_URL=mysql+pymysql://user:password@localhost/car_lease_db
GROQ_API_KEY=your_groq_api_key
SECRET_KEY=your_jwt_secret

5️⃣ Run Server
uvicorn main:app --reload


Backend will run at:

http://127.0.0.1:8000

📱 Frontend Setup (Flutter)
- cd frontend
- flutter pub get
- flutter run


For Android emulator, backend base URL:

http://10.0.2.2:8000

🔐 Authentication

- JWT-based login & register

- Secure API endpoints

- User-specific lease & chat history

💬 Dealer Chat API
POST – Send Message
POST /dealer-chat

{
  "lease_id": 1,
  "message": "The early termination charge seems very high"
}

GET – Chat History
GET /dealer-chat/{lease_id}

🧠 Fairness Scoring Logic

- Score starts at 100

- Deductions applied based on:

- Penalty count

- Payment opacity

- Termination bias

- Missing consumer protections

Verdict:

- 80–100 → Fair

- 60–79 → Moderate

- <60 → Unfair

🚀 Why This Project Stands Out

- Real-world problem solving

- End-to-end system (UI + Backend + AI)

- No paid AI dependency (Groq Free Tier)

- Production-grade architecture

-Negotiation logic, not just Q&A

👤 Author

- Pranav Chothe

- Built as part of an advanced AI-powered car lease analysis & negotiation system.

⭐ Support

-If you found this project useful:

  ⭐ Star the repository

  🍴 Fork it

  🧠 Suggest improvements
