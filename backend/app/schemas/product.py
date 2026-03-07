from pydantic import BaseModel, EmailStr


class ProductCreate(BaseModel):
    name: str
    description: str
    quantity: int
