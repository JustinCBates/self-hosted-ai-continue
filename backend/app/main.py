from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse
import time
import uuid
from contextlib import asynccontextmanager

from app.core.config import settings
from app.core.logging import logger
from app.api import chat, health, models
from app.models.manager import ModelManager


# Global model manager instance
model_manager = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifespan."""
    global model_manager
    
    # Startup
    logger.info("Starting self-hosted AI backend...")
    model_manager = ModelManager()
    await model_manager.load_default_model()
    logger.info("Application startup complete")
    
    yield
    
    # Shutdown
    logger.info("Shutting down application...")
    if model_manager:
        await model_manager.cleanup()
    logger.info("Application shutdown complete")


# Create FastAPI app
app = FastAPI(
    title="Self-Hosted AI Backend",
    description="AI backend service for Continue VS Code extension",
    version="1.0.0",
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
    lifespan=lifespan
)

# Add middleware
if settings.ENABLE_CORS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.add_middleware(GZipMiddleware, minimum_size=1000)


@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    """Add request processing time to response headers."""
    start_time = time.time()
    request_id = str(uuid.uuid4())
    
    # Add request ID to request state
    request.state.request_id = request_id
    
    response = await call_next(request)
    
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    response.headers["X-Request-ID"] = request_id
    
    logger.info(
        f"Request processed",
        extra={
            "request_id": request_id,
            "method": request.method,
            "url": str(request.url),
            "process_time": process_time,
            "status_code": response.status_code
        }
    )
    
    return response


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Global exception handler."""
    request_id = getattr(request.state, "request_id", "unknown")
    
    logger.error(
        f"Unhandled exception: {exc}",
        extra={"request_id": request_id},
        exc_info=True
    )
    
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "request_id": request_id,
            "detail": str(exc) if settings.DEBUG else "An unexpected error occurred"
        }
    )


# Dependency to get model manager
async def get_model_manager() -> ModelManager:
    """Get the global model manager instance."""
    if model_manager is None:
        raise HTTPException(status_code=503, detail="Model manager not initialized")
    return model_manager


# Include routers
app.include_router(health.router, prefix="/health", tags=["health"])
app.include_router(chat.router, prefix="/v1", tags=["chat"])
app.include_router(models.router, prefix="/v1", tags=["models"])


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": "Self-Hosted AI Backend for Continue",
        "version": "1.0.0",
        "docs": "/docs" if settings.DEBUG else "Documentation disabled in production"
    }