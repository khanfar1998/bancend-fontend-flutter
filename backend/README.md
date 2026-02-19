# Auth API (FastAPI + JWT + RBAC)

FastAPI backend with JWT authentication and role-based access control (User, Admin). Admins can perform full CRUD on users.

## Setup

```bash
python3 -m venv .venv
source .venv/bin/activate   # or .venv\Scripts\activate on Windows
pip install -r requirements.txt
```

Optional: create a `.env` file to override defaults:

```env
SECRET_KEY=your-secret-key
ACCESS_TOKEN_EXPIRE_MINUTES=30
DATABASE_URL=sqlite:///./app.db
```

## Run

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

- API root: http://127.0.0.1:8000  
- Interactive docs: http://127.0.0.1:8000/docs  

## Database

SQLite by default (`app.db` in the project root). Tables are created on startup; a default admin is created if the database is empty.

## Default admin

- **Username:** `admin`  
- **Password:** `admin123`  

Change these in production.

## Endpoints (base path: `/api/v1`)

### Public

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/auth/register` | Register (body: `email`, `username`, `password`) |
| POST | `/api/v1/auth/login` | Login (body: `username`, `password`) → returns JWT |

### Authenticated (any role)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/auth/me` | Current user (header: `Authorization: Bearer <token>`) |

### Admin only

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/admin/users` | List all users |
| GET | `/api/v1/admin/users/{user_id}` | Get one user |
| POST | `/api/v1/admin/users` | Create user (body: `email`, `username`, `password`) |
| PATCH | `/api/v1/admin/users/{user_id}` | Update user (optional: `email`, `username`, `password`, `role`, `is_active`) |
| DELETE | `/api/v1/admin/users/{user_id}` | Delete user |

## Roles

- **user** – can register, login, and call `/auth/me`.
- **admin** – same as user, plus full CRUD on `/admin/users`.

## Project layout

Layered structure: **core** (config, security, deps) → **db** (ORM, session) → **schemas** (Pydantic) → **repositories** (data access) → **api** (routes).

```
backend/
├── main.py                 # Entry: exposes app from app.main
├── requirements.txt
└── app/
    ├── main.py             # FastAPI app, lifespan, CORS, include_router(api/v1)
    ├── core/               # Config, security, dependencies
    │   ├── config.py       # Settings (secret, JWT expiry, database_url)
    │   ├── security.py     # Password hash/verify, JWT create/decode
    │   └── deps.py         # get_current_user, require_admin
    ├── db/                 # SQLAlchemy
    │   ├── base.py         # DeclarativeBase
    │   ├── session.py      # Engine, SessionLocal, init_db, get_db
    │   └── models/
    │       └── user.py     # User ORM model
    ├── schemas/            # Pydantic request/response
    │   └── user.py         # Role, UserCreate, UserInDB, UserResponse, Token, etc.
    ├── repositories/      # Data access layer
    │   └── user_repository.py
    └── api/
        └── v1/
            ├── router.py   # Aggregates auth + admin_users
            ├── auth.py     # register, login, me
            └── admin_users.py  # admin CRUD users
```

Data is stored in SQLite (`app.db`). Set `DATABASE_URL` for another database (e.g. PostgreSQL).
