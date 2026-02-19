from enum import Enum
from typing import Optional

from pydantic import BaseModel, EmailStr


class Role(str, Enum):
    user = "user"
    admin = "admin"


class UserInDB(BaseModel):
    id: str
    email: str
    username: str
    hashed_password: str
    role: Role = Role.user
    is_active: bool = True



#request
class UserCreate(BaseModel):
    email: EmailStr
    username: str
    password: str


class UserLogin(BaseModel):
    username: str
    password: str


class UserResponse(BaseModel):
    id: str
    email: str
    username: str
    role: Role
    is_active: bool

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    password: Optional[str] = None
    role: Optional[Role] = None
    is_active: Optional[bool] = None


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenPayload(BaseModel):
    sub: str
    username: str
    role: Role
    exp: Optional[int] = None
