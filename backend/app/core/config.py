from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    secret_key: str = "81f100fa15c1c3688b117564eeb6b74ebc2a68da7900b6fd00d7074efaadf099"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60
    database_url: str = "sqlite:///./app.db"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
