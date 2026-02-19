from datetime import datetime, timedelta, timezone
from typing import Optional

import bcrypt
from jose import JWTError, jwt

from app.core.config import settings
from app.schemas.user import Role, TokenPayload, UserInDB


def get_password_hash(password: str) -> str:
    #123456 -> hashcode
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    #123456 -> hashcode db
    return bcrypt.checkpw(plain_password.encode("utf-8"), hashed_password.encode("utf-8"))


def create_access_token(sub: str, username: str, role: Role) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.access_token_expire_minutes)
    to_encode = {
        "sub": sub,
        "username": username,
        "role": role.value,
        "exp": expire,
    }
    return jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)


def decode_access_token(token: str) -> Optional[TokenPayload]:
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        return TokenPayload(
            sub=payload["sub"],
            username=payload["username"],
            role=Role(payload["role"]),
            exp=payload.get("exp"),
        )
    except (JWTError, KeyError, ValueError):
        return None
