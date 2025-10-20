from pydantic import BaseSettings, Field
from typing import Optional
import os


class Settings(BaseSettings):
    """Application settings."""
    
    # Environment
    DEBUG: bool = Field(default=False, env="DEBUG")
    LOG_LEVEL: str = Field(default="INFO", env="LOG_LEVEL")
    
    # API Configuration
    API_HOST: str = Field(default="0.0.0.0", env="API_HOST")
    API_PORT: int = Field(default=8000, env="API_PORT")
    API_PREFIX: str = Field(default="/api/v1", env="API_PREFIX")
    
    # Model Configuration
    DEFAULT_MODEL_NAME: str = Field(default="microsoft/DialoGPT-medium", env="DEFAULT_MODEL_NAME")
    MODEL_CACHE_DIR: str = Field(default="./models", env="MODEL_CACHE_DIR")
    MAX_TOKENS: int = Field(default=2048, env="MAX_TOKENS")
    TEMPERATURE: float = Field(default=0.7, env="TEMPERATURE")
    TOP_P: float = Field(default=0.9, env="TOP_P")
    
    # Server Configuration
    MAX_CONCURRENT_REQUESTS: int = Field(default=10, env="MAX_CONCURRENT_REQUESTS")
    REQUEST_TIMEOUT: int = Field(default=300, env="REQUEST_TIMEOUT")
    ENABLE_CORS: bool = Field(default=True, env="ENABLE_CORS")
    
    # Authentication
    API_KEY: Optional[str] = Field(default=None, env="API_KEY")
    ENABLE_AUTH: bool = Field(default=False, env="ENABLE_AUTH")
    
    # Monitoring
    ENABLE_METRICS: bool = Field(default=True, env="ENABLE_METRICS")
    METRICS_PORT: int = Field(default=9090, env="METRICS_PORT")
    
    # GPU Configuration
    USE_GPU: bool = Field(default=False, env="USE_GPU")
    GPU_MEMORY_FRACTION: float = Field(default=0.8, env="GPU_MEMORY_FRACTION")
    
    class Config:
        env_file = ".env"
        case_sensitive = True


# Global settings instance
settings = Settings()