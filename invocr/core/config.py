from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "invocr"
    debug: bool = False
    # Gemini
    gemini_api_key: str = ""
    gemini_model: str = "gemini-2.0-flash"
    max_file_size_mb: int = 10

    class Config:
        env_file = ".env"


settings = Settings()
