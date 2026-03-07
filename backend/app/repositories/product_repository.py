from app.db.session import SessionLocal
from app.db.models.user import Product as ProductModel
import uuid


def create_product(request):
    db = SessionLocal()
    try:
        product = ProductModel(
            id=str(uuid.uuid4()),
            name=request.name,
            description=request.description,
            quantity=request.quantity,
        )
        db.add(product)
        db.commit()
        db.refresh(product)
        return product
    except Exception as e:
        print(e)
        db.close()


def get_all_products():
    db = SessionLocal()
    products = db.query(ProductModel).all()
    return products
