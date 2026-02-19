from fastapi import APIRouter, HTTPException, status

from app.core.deps import AdminUser
from app.core.security import get_password_hash
from app.repositories.user_repository import (
    create_user,
    delete_user,
    get_user_by_id,
    list_users,
    update_user,
)
from app.schemas.user import Role, UserCreate, UserResponse, UserUpdate

router = APIRouter(prefix="/admin/users", tags=["admin-users"])


@router.get("", response_model=list[UserResponse])
def list_users_route(_admin: AdminUser):
    users = list_users()
    return [
        UserResponse(
            id=u.id,
            email=u.email,
            username=u.username,
            role=u.role,
            is_active=u.is_active,
        )
        for u in users
    ]


@router.get("/{user_id}", response_model=UserResponse)
def get_user_route(user_id: str, _admin: AdminUser):
    user = get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return UserResponse(
        id=user.id,
        email=user.email,
        username=user.username,
        role=user.role,
        is_active=user.is_active,
    )


@router.post("", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def create_user_route(data: UserCreate, _admin: AdminUser):
    try:
        user = create_user(
            email=data.email,
            username=data.username,
            hashed_password=get_password_hash(data.password),
            role=Role.user,
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


@router.patch("/{user_id}", response_model=UserResponse)
def update_user_route(user_id: str, data: UserUpdate, _admin: AdminUser):
    user = get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    kwargs = data.model_dump(exclude_unset=True)
    if "password" in kwargs and kwargs["password"]:
        kwargs["hashed_password"] = get_password_hash(kwargs.pop("password"))
    updated = update_user(user_id, **kwargs)
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return UserResponse(
        id=updated.id,
        email=updated.email,
        username=updated.username,
        role=updated.role,
        is_active=updated.is_active,
    )


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user_route(user_id: str, _admin: AdminUser):
    if not delete_user(user_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
