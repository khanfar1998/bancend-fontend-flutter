from fastapi import APIRouter, HTTPException, status

from app.core.deps import CurrentUser
from app.core.security import create_access_token, get_password_hash, verify_password
from app.repositories.user_repository import create_user, get_user_by_username
from app.schemas.user import Token, UserCreate, UserLogin, UserResponse

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=UserResponse)
def register(data: UserCreate):
    try:
        user = create_user(
            email=data.email,
            username=data.username,
            hashed_password=get_password_hash(data.password),
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    return UserResponse(
        id=user.id,
        email=user.email,
        username=user.username,
        role=user.role,
        is_active=user.is_active,
    )


@router.post("/login", response_model=Token)
def login(data: UserLogin):
    user = get_user_by_username(data.username)
    if not user or not verify_password(data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
        )
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is disabled",
        )
    access_token = create_access_token(
        sub=user.id,
        username=user.username,
        role=user.role,
    )
    return Token(access_token=access_token, token_type="bearer")


@router.get("/me", response_model=UserResponse)
def me(current_user: CurrentUser):
    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        username=current_user.username,
        role=current_user.role,
        is_active=current_user.is_active,
    )
