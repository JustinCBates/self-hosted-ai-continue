from fastapi import APIRouter, Depends
from app.models.manager import ModelManager
from app.core.logging import logger

router = APIRouter()


@router.get("/")
async def health_check():
    """Basic health check endpoint."""
    return {"status": "healthy", "message": "AI Backend is running"}


@router.get("/ready")
async def readiness_check():
    """Readiness check endpoint."""
    # Add model manager dependency when available
    try:
        # Basic readiness check
        return {
            "status": "ready",
            "message": "AI Backend is ready to serve requests"
        }
    except Exception as e:
        logger.error(f"Readiness check failed: {e}")
        return {
            "status": "not_ready",
            "message": f"AI Backend is not ready: {str(e)}"
        }


@router.get("/live")
async def liveness_check():
    """Liveness check endpoint."""
    return {"status": "alive", "message": "AI Backend is alive"}