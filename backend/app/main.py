from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1 import api_router
from app.db import init_db
from app.repositories.user_repository import ensure_admin
from app.core.deps import CurrentUser, AdminUser


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    ensure_admin()
    yield


application = FastAPI(
    title="Khanfar project",
    description="JWT auth with role-based access (User, Admin). Admin can CRUD users.",
    version="1.0.0",
    lifespan=lifespan,
)

application.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

application.include_router(api_router, prefix="/api/v1")


@application.get("/")
def root():
    return {"message": "Auth API", "docs": "/docs", "api": "/api/v1"}


@application.get("/test")
def x(current_user: AdminUser):
    return "hello world"
