from fastapi import APIRouter, HTTPException, status
from app.schemas.product import ProductCreate
from app.repositories.product_repository import create_product, get_all_products

router = APIRouter(prefix='/product', tags=['product'])


@router.post('/', status_code=status.HTTP_201_CREATED)
async def route_create_product(request: ProductCreate):
    print(1212)
    return create_product(request)


@router.get('/', )
async def route_get_all_products():
    return get_all_products()
