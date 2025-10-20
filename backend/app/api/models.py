from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any
from app.models.manager import ModelManager
from app.core.logging import logger

router = APIRouter()


class ModelInfo(BaseModel):
    """Model information model."""
    id: str
    object: str = "model"
    created: int
    owned_by: str = "self-hosted"
    permission: List[Dict[str, Any]] = []


class ModelsResponse(BaseModel):
    """Models list response."""
    object: str = "list"
    data: List[ModelInfo]


@router.get("/models", response_model=ModelsResponse)
async def list_models(model_manager: ModelManager = Depends()):
    """List available models."""
    try:
        available_models = await model_manager.get_available_models()
        
        model_list = [
            ModelInfo(
                id=model_name,
                created=0,  # You could store actual creation times
                owned_by="self-hosted"
            )
            for model_name in available_models
        ]
        
        return ModelsResponse(data=model_list)
    
    except Exception as e:
        logger.error(f"Error listing models: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/models/{model_id}", response_model=ModelInfo)
async def get_model(model_id: str, model_manager: ModelManager = Depends()):
    """Get information about a specific model."""
    try:
        available_models = await model_manager.get_available_models()
        
        if model_id not in available_models:
            raise HTTPException(status_code=404, detail=f"Model {model_id} not found")
        
        return ModelInfo(
            id=model_id,
            created=0,
            owned_by="self-hosted"
        )
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting model {model_id}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))