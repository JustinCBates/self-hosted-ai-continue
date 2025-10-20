# Self-Hosted AI for Continue

A complete self-hosted AI backend designed to work seamlessly with the Continue VS Code extension, providing AI-powered code assistance without relying on external APIs.

## 🚀 Features

- **FastAPI Backend**: High-performance Python API server
- **Multiple Model Support**: Load and serve various open-source LLMs
- **Continue Integration**: Drop-in replacement for OpenAI API
- **Docker Support**: Easy deployment with containerization
- **GPU Acceleration**: Optional CUDA support for faster inference
- **Extensible Architecture**: Easy to add new models and features
- **Comprehensive Logging**: Detailed logging with Loguru
- **Health Monitoring**: Built-in health checks and metrics

## 📋 Prerequisites

- Python 3.11+
- pip or conda
- Docker (optional, for containerized deployment)
- CUDA-compatible GPU (optional, for GPU acceleration)
- VS Code with Continue extension

## 🏗️ Architecture

```
├── backend/                 # FastAPI backend application
│   ├── app/
│   │   ├── api/            # API endpoints
│   │   ├── core/           # Core configuration and logging
│   │   ├── models/         # Model management
│   │   └── main.py         # Application entry point
├── continue-config/        # Continue extension configuration
├── docker/                 # Docker configuration files
├── docs/                   # Additional documentation
└── tests/                  # Test suite
```

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd self-hosted-ai-continue
cp .env.example .env
```

### 2. Install Dependencies

#### Using pip:
```bash
pip install -r requirements.txt
```

#### Using conda:
```bash
conda create -n ai-backend python=3.11
conda activate ai-backend
pip install -r requirements.txt
```

### 3. Configure Environment

Edit `.env` file with your preferences:

```env
DEBUG=True
DEFAULT_MODEL_NAME=microsoft/DialoGPT-medium
USE_GPU=False  # Set to True if you have CUDA GPU
API_PORT=8000
```

### 4. Start the Backend

#### Development mode:
```bash
npm run dev
```

#### Production mode:
```bash
npm start
```

The API will be available at `http://localhost:8000`

### 5. Configure Continue Extension

1. Install the Continue extension in VS Code
2. Copy `continue-config/config.json` to your Continue config directory:
   - **Windows**: `%USERPROFILE%\\.continue\\config.json`
   - **macOS/Linux**: `~/.continue/config.json`
3. Update the API key and base URL if needed

### 6. Start Coding!

- Press `Ctrl+I` (or `Cmd+I` on Mac) to open Continue chat
- Select code and ask questions
- Use slash commands like `/edit`, `/comment`, `/test`

## 🐳 Docker Deployment

### Quick Start with Docker

```bash
# Build the image
npm run docker:build

# Run the container
npm run docker:run
```

### Using Docker Compose

```bash
# Start all services
npm run docker:compose

# Or manually:
docker-compose -f docker/docker-compose.yml up -d
```

This will start:
- AI Backend on port 8000
- Metrics endpoint on port 9090
- Optional Nginx reverse proxy on port 80

## ⚙️ Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DEBUG` | `False` | Enable debug mode |
| `API_PORT` | `8000` | API server port |
| `DEFAULT_MODEL_NAME` | `microsoft/DialoGPT-medium` | Default model to load |
| `USE_GPU` | `False` | Enable GPU acceleration |
| `MAX_TOKENS` | `2048` | Maximum tokens per response |
| `TEMPERATURE` | `0.7` | Model temperature |
| `ENABLE_AUTH` | `False` | Enable API key authentication |

### Supported Models

The backend supports most Hugging Face models compatible with:
- `AutoModelForCausalLM` (GPT-style models)
- `AutoModelForSeq2SeqLM` (T5-style models)

Popular choices:
- `microsoft/DialoGPT-medium` (Default, good for chat)
- `microsoft/CodeGPT-small-py` (Code-focused)
- `facebook/blenderbot-400M-distill` (Conversational)
- `google/flan-t5-base` (Instruction-following)

## 🔧 API Endpoints

### Chat Completions
```
POST /v1/chat/completions
```

Compatible with OpenAI API format:
```json
{
  "model": "microsoft/DialoGPT-medium",
  "messages": [
    {"role": "user", "content": "Hello!"}
  ],
  "max_tokens": 150,
  "temperature": 0.7
}
```

### List Models
```
GET /v1/models
```

### Health Check
```
GET /health
```

## 🧪 Testing

Run the test suite:

```bash
npm test
```

For development with auto-reload:
```bash
cd backend
python -m pytest tests/ -v --watch
```

## 📝 Development

### Code Style

The project follows these conventions:
- Python: PEP 8, Black formatting, type hints
- API: RESTful design, proper HTTP status codes
- Logging: Structured logging with Loguru
- Testing: pytest with comprehensive coverage

### Adding New Models

1. Update `DEFAULT_MODEL_NAME` in `.env`
2. Ensure the model is compatible with `transformers` library
3. Test loading with: `POST /v1/models`

### Custom Endpoints

Add new endpoints in `backend/app/api/` directory:

```python
from fastapi import APIRouter

router = APIRouter()

@router.get("/custom")
async def custom_endpoint():
    return {"message": "Custom endpoint"}
```

## 🔍 Monitoring

### Health Checks

- `/health` - Basic health check
- `/health/ready` - Readiness probe
- `/health/live` - Liveness probe

### Metrics

When `ENABLE_METRICS=True`:
- Prometheus metrics on port 9090
- Request duration, count, and error rates
- Model performance metrics

### Logging

Logs are output to:
- Console (always)
- `logs/app.log` (production mode)

Log levels: DEBUG, INFO, WARNING, ERROR, CRITICAL

## 🚨 Troubleshooting

### Common Issues

**Model Loading Fails**
- Check internet connection for model download
- Verify model name exists on Hugging Face
- Ensure sufficient disk space in `MODEL_CACHE_DIR`

**GPU Out of Memory**
- Reduce `GPU_MEMORY_FRACTION`
- Use smaller model
- Enable gradient checkpointing

**Continue Extension Not Connecting**
- Verify backend is running on correct port
- Check Continue config.json API base URL
- Ensure CORS is enabled (`ENABLE_CORS=True`)

**Slow Response Times**
- Enable GPU acceleration if available
- Use smaller models for faster inference
- Adjust `MAX_TOKENS` parameter

### Debug Mode

Enable debug mode for detailed logging:
```env
DEBUG=True
LOG_LEVEL=DEBUG
```

## 📄 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

## 📚 Additional Resources

- [Continue Extension Documentation](https://docs.continue.dev/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Hugging Face Transformers](https://huggingface.co/docs/transformers/)
- [Docker Documentation](https://docs.docker.com/)

## 🆘 Support

For issues and questions:
- Check the troubleshooting section above
- Review logs in debug mode
- Open an issue with detailed error information