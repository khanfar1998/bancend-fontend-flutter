import uuid
from typing import List, Optional

from sqlalchemy import select

from app.core.security import get_password_hash
from app.db.models.user import User as UserModel
from app.db.session import SessionLocal
from app.schemas.user import Role, UserInDB


def _to_schema(row: UserModel) -> UserInDB:
    return UserInDB(
        id=row.id,
        email=row.email,
        username=row.username,
        hashed_password=row.hashed_password,
        role=Role(row.role),
        is_active=row.is_active,
    )


def ensure_admin() -> None:
    db = SessionLocal()
    try:
        if db.query(UserModel).first() is None:
            admin = UserModel(
                id=str(uuid.uuid4()),
                email="admin@example.com",
                username="admin",
                hashed_password=get_password_hash("admin123"),
                role=Role.admin.value,
                is_active=True,
            )
            db.add(admin)
            db.commit()
    finally:
        db.close()


def get_user_by_id(user_id: str) -> Optional[UserInDB]:
    db = SessionLocal()
    try:
        row = db.get(UserModel, user_id) #select * from users where id = user_id
        return _to_schema(row) if row else None
    finally:
        db.close()


def get_user_by_username(username: str) -> Optional[UserInDB]:
    db = SessionLocal()
    try:
        row = db.execute(select(UserModel).where(UserModel.username == username)).scalar_one_or_none()
        #select * from users where user_name = user_id
        return _to_schema(row) if row else None
    finally:
        db.close()


def get_user_by_email(email: str) -> Optional[UserInDB]:
    db = SessionLocal()
    try:
        row = db.execute(select(UserModel).where(UserModel.email == email)).scalar_one_or_none()
        return _to_schema(row) if row else None
    finally:
        db.close()


def create_user(
    email: str, username: str, hashed_password: str, role: Role = Role.user
) -> UserInDB:
    if get_user_by_username(username):
        raise ValueError("Username already registered")
    if get_user_by_email(email):
        raise ValueError("Email already registered")
    db = SessionLocal()
    try:
        user = UserModel(
            id=str(uuid.uuid4()),
            email=email,
            username=username,
            hashed_password=hashed_password,
            role=role.value,
            is_active=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return _to_schema(user)
    finally:
        db.close()


def list_users() -> List[UserInDB]:
    db = SessionLocal()
    try:
        rows = db.execute(select(UserModel)).scalars().all()
        return [_to_schema(r) for r in rows]
    finally:
        db.close()


def update_user(user_id: str, **kwargs) -> Optional[UserInDB]:
    db = SessionLocal()
    try:
        row = db.get(UserModel, user_id)
        if not row:
            return None
        allowed = {"email", "username", "hashed_password", "role", "is_active"}
        for k, v in kwargs.items():
            if k in allowed and v is not None:
                setattr(row, k, v.value if hasattr(v, "value") else v)
        db.commit()
        db.refresh(row)
        return _to_schema(row)
    finally:
        db.close()


def delete_user(user_id: str) -> bool:
    db = SessionLocal()
    try:
        row = db.get(UserModel, user_id)
        if not row:
            return False
        db.delete(row)
        db.commit()
        return True
    finally:
        db.close()
