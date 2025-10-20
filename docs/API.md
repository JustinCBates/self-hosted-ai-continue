# API Documentation

## Overview

The Self-Hosted AI Backend provides OpenAI-compatible API endpoints for chat completions and model management.

## Base URL

```
http://localhost:8000
```

## Authentication

Authentication is optional and controlled by the `ENABLE_AUTH` environment variable.

When enabled, include the API key in the Authorization header:
```
Authorization: Bearer your-api-key-here
```

## Endpoints

### Chat Completions

Create a chat completion response.

**Endpoint:** `POST /v1/chat/completions`

**Request Body:**
```json
{
  "model": "microsoft/DialoGPT-medium",
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant."
    },
    {
      "role": "user", 
      "content": "Hello, how are you?"
    }
  ],
  "max_tokens": 150,
  "temperature": 0.7,
  "top_p": 0.9,
  "stream": false,
  "stop": ["Human:", "Assistant:"]
}
```

**Response:**
```json
{
  "id": "chatcmpl-abc123",
  "object": "chat.completion",
  "created": 1677652288,
  "model": "microsoft/DialoGPT-medium",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Hello! I'm doing well, thank you for asking. How can I help you today?"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 18,
    "total_tokens": 30
  }
}
```

### List Models

Get a list of available models.

**Endpoint:** `GET /v1/models`

**Response:**
```json
{
  "object": "list",
  "data": [
    {
      "id": "microsoft/DialoGPT-medium",
      "object": "model",
      "created": 0,
      "owned_by": "self-hosted"
    }
  ]
}
```

### Get Model

Get information about a specific model.

**Endpoint:** `GET /v1/models/{model_id}`

**Response:**
```json
{
  "id": "microsoft/DialoGPT-medium",
  "object": "model", 
  "created": 0,
  "owned_by": "self-hosted"
}
```

### Health Check

Basic health check endpoint.

**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "healthy",
  "message": "AI Backend is running"
}
```

### Readiness Check

Check if the service is ready to handle requests.

**Endpoint:** `GET /health/ready`

**Response:**
```json
{
  "status": "ready",
  "message": "AI Backend is ready to serve requests"
}
```

### Liveness Check

Check if the service is alive.

**Endpoint:** `GET /health/live`

**Response:**
```json
{
  "status": "alive",
  "message": "AI Backend is alive"
}
```

## Error Responses

All endpoints return structured error responses:

```json
{
  "error": "Error type",
  "detail": "Detailed error message",
  "request_id": "unique-request-id"
}
```

Common HTTP status codes:
- `400`: Bad Request - Invalid input
- `401`: Unauthorized - Invalid API key
- `404`: Not Found - Model or endpoint not found
- `500`: Internal Server Error - Server error
- `503`: Service Unavailable - Model not loaded

## Rate Limiting

The API includes built-in concurrency limiting controlled by `MAX_CONCURRENT_REQUESTS` (default: 10).

## Request Headers

All endpoints support these optional headers:
- `Authorization`: Bearer token for authentication
- `Content-Type`: `application/json`
- `Accept`: `application/json`

## Response Headers

All responses include:
- `X-Process-Time`: Request processing time in seconds
- `X-Request-ID`: Unique request identifier
- `Content-Type`: `application/json`