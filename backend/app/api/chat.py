from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from pydantic import BaseModel
from typing import List, Optional, Dict, Any, AsyncGenerator
from app.models.manager import ModelManager
from app.core.logging import logger
import asyncio
import time
import uuid

router = APIRouter()


class ChatMessage(BaseModel):
    """Chat message model."""
    role: str  # "system", "user", "assistant"
    content: str


class ChatCompletionRequest(BaseModel):
    """Chat completion request model."""
    model: str
    messages: List[ChatMessage]
    max_tokens: Optional[int] = 2048
    temperature: Optional[float] = 0.7
    top_p: Optional[float] = 0.9
    stream: Optional[bool] = False
    stop: Optional[List[str]] = None


class ChatCompletionChoice(BaseModel):
    """Chat completion choice model."""
    index: int
    message: ChatMessage
    finish_reason: str


class ChatCompletionResponse(BaseModel):
    """Chat completion response model."""
    id: str
    object: str = "chat.completion"
    created: int
    model: str
    choices: List[ChatCompletionChoice]
    usage: Dict[str, Any]


class ChatCompletionStreamChoice(BaseModel):
    """Streaming chat completion choice model."""
    index: int
    delta: Dict[str, Any]
    finish_reason: Optional[str] = None


class ChatCompletionStreamResponse(BaseModel):
    """Streaming chat completion response model."""
    id: str
    object: str = "chat.completion.chunk"
    created: int
    model: str
    choices: List[ChatCompletionStreamChoice]


@router.post("/chat/completions")
async def create_chat_completion(
    request: ChatCompletionRequest,
    model_manager: ModelManager = Depends()
):
    """Create a chat completion."""
    try:
        # Validate model
        if not await model_manager.is_model_loaded(request.model):
            await model_manager.load_model(request.model)
        
        # Generate response
        if request.stream:
            return await stream_chat_completion(request, model_manager)
        else:
            return await generate_chat_completion(request, model_manager)
    
    except Exception as e:
        logger.error(f"Error in chat completion: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


async def generate_chat_completion(
    request: ChatCompletionRequest,
    model_manager: ModelManager
) -> ChatCompletionResponse:
    """Generate a non-streaming chat completion."""
    start_time = time.time()
    completion_id = f"chatcmpl-{uuid.uuid4().hex[:24]}"
    
    # Convert messages to prompt
    prompt = format_messages_to_prompt(request.messages)
    
    # Generate response
    response_text = await model_manager.generate_response(
        prompt=prompt,
        model_name=request.model,
        max_tokens=request.max_tokens,
        temperature=request.temperature,
        top_p=request.top_p,
        stop_sequences=request.stop
    )
    
    # Create response
    return ChatCompletionResponse(
        id=completion_id,
        created=int(start_time),
        model=request.model,
        choices=[
            ChatCompletionChoice(
                index=0,
                message=ChatMessage(role="assistant", content=response_text),
                finish_reason="stop"
            )
        ],
        usage={
            "prompt_tokens": len(prompt.split()),  # Rough estimate
            "completion_tokens": len(response_text.split()),  # Rough estimate
            "total_tokens": len(prompt.split()) + len(response_text.split())
        }
    )


async def stream_chat_completion(
    request: ChatCompletionRequest,
    model_manager: ModelManager
):
    """Generate a streaming chat completion."""
    # Implementation for streaming would go here
    # For now, return a simple non-streaming response
    response = await generate_chat_completion(request, model_manager)
    return response


def format_messages_to_prompt(messages: List[ChatMessage]) -> str:
    """Format chat messages into a prompt string."""
    formatted_parts = []
    
    for message in messages:
        if message.role == "system":
            formatted_parts.append(f"System: {message.content}")
        elif message.role == "user":
            formatted_parts.append(f"Human: {message.content}")
        elif message.role == "assistant":
            formatted_parts.append(f"Assistant: {message.content}")
    
    # Add assistant prompt at the end
    formatted_parts.append("Assistant:")
    
    return "\n".join(formatted_parts)