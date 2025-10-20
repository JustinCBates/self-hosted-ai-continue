# Self-Hosted AI Container - Deployment Guide

## 🎯 Overview

This guide walks you through building and deploying your self-hosted AI backend container for the Continue VS Code extension.

**What you're deploying:**
- FastAPI backend API server
- HuggingFace transformer models
- OpenAI-compatible API endpoints
- Health monitoring and metrics

**NOT a DevContainer** - This is a production container that runs your AI backend service.

---

## 📦 What Was Created

### Build Scripts (in `scripts/` directory)

1. **build.ps1** - Builds the Docker image
2. **run-container.ps1** - Runs a single container
3. **deploy.ps1** - Deploys with docker-compose
4. **test.ps1** - Tests the deployment

All scripts are PowerShell with execution policy bypass support.

---

## 🚀 Quick Start (3 Steps)

### Step 1: Build the Image

```powershell
cd d:\Repos\self-hosted-ai-continue
PowerShell -ExecutionPolicy Bypass -File .\scripts\build.ps1
```

**This will:**
- ✅ Check Docker is running
- ✅ Build image from `docker/Dockerfile`
- ✅ Tag as `self-hosted-ai-continue:latest`
- ✅ Show image size and build time

**Expected time:** 3-5 minutes (first build)

---

### Step 2: Run the Container

```powershell
PowerShell -ExecutionPolicy Bypass -File .\scripts\run-container.ps1 -Detached
```

**This will:**
- ✅ Create `.env` from `.env.example`
- ✅ Create `models/` directory for model cache
- ✅ Mount volumes for persistence
- ✅ Start container in background
- ✅ Expose API on port 8000

**Container name:** `self-hosted-ai`

---

### Step 3: Test It

```powershell
PowerShell -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

**This will:**
- ✅ Test health endpoint
- ✅ List available models
- ✅ Try a chat completion
- ✅ Show container status

---

## 🔧 Configuration

### Environment Variables (.env)

Key settings in `.env`:

```bash
# Model to load on startup
DEFAULT_MODEL_NAME=microsoft/DialoGPT-medium

# Where models are cached
MODEL_CACHE_DIR=./models

# API settings
API_PORT=8000
MAX_TOKENS=2048
TEMPERATURE=0.7

# GPU (if available)
USE_GPU=False
```

### Available Models

Small models (good for testing):
- `microsoft/DialoGPT-small` - 117MB
- `microsoft/DialoGPT-medium` - 345MB

Larger models (better quality):
- `microsoft/DialoGPT-large` - 775MB
- `gpt2` - 548MB
- `gpt2-medium` - 1.5GB

Code models (for Continue):
- `Salesforce/codegen-350M-mono` - 350MB
- `Salesforce/codegen-2B-mono` - 2GB
- `bigcode/tiny_starcoder_py` - 165MB

---

## 📊 Container Architecture

```
┌─────────────────────────────────────────┐
│  Docker Container                       │
│  (self-hosted-ai-continue:latest)       │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  FastAPI Application              │  │
│  │  Port: 8000                       │  │
│  │  - /health                        │  │
│  │  - /api/v1/chat/completions       │  │
│  │  - /api/v1/models                 │  │
│  │  - /docs (Swagger)                │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  Model Manager                    │  │
│  │  - Loads HuggingFace models       │  │
│  │  - Handles inference              │  │
│  │  - Caches models                  │  │
│  └───────────────────────────────────┘  │
│                                         │
│  Volumes:                               │
│  - ./models:/app/models (cache)         │
│  - ./.env:/app/.env (config)            │
└─────────────────────────────────────────┘
         │
         ↓
    Port 8000
         │
         ↓
  ┌──────────────┐
  │  Continue    │
  │  Extension   │
  └──────────────┘
```

---

## 🎮 Usage Examples

### Option 1: Simple Container (Development)

```powershell
# Build
.\scripts\build.ps1

# Run in foreground (see logs)
.\scripts\run-container.ps1

# Or run in background
.\scripts\run-container.ps1 -Detached

# Test
.\scripts\test.ps1

# View logs
docker logs -f self-hosted-ai

# Stop
docker stop self-hosted-ai
```

### Option 2: Docker Compose (Production)

```powershell
# Deploy full stack
.\scripts\deploy.ps1 -Build

# View logs
.\scripts\deploy.ps1 -Logs

# Stop everything
.\scripts\deploy.ps1 -Down
```

### Option 3: GPU Acceleration

```powershell
# Build
.\scripts\build.ps1

# Run with GPU
.\scripts\run-container.ps1 -GPU -Detached

# Verify GPU is detected
docker exec self-hosted-ai nvidia-smi
```

---

## 🔌 Continue Extension Integration

### Step 1: Start the Backend

```powershell
.\scripts\run-container.ps1 -Detached
```

### Step 2: Configure Continue

1. Open VS Code
2. Install Continue extension (if not installed)
3. Open Continue settings (Ctrl+Shift+P → "Continue: Open Settings")
4. Add custom model:

```json
{
  "models": [
    {
      "title": "Self-Hosted",
      "provider": "openai",
      "model": "default",
      "apiBase": "http://localhost:8000/api/v1",
      "apiKey": "not-needed"
    }
  ]
}
```

### Step 3: Test in Continue

- Open Continue chat (Ctrl+L)
- Select "Self-Hosted" model
- Ask a coding question
- Watch logs: `docker logs -f self-hosted-ai`

---

## 📝 API Endpoints

Once running, access these endpoints:

| Endpoint | Description | Method |
|----------|-------------|--------|
| `http://localhost:8000/` | API info | GET |
| `http://localhost:8000/health` | Health check | GET |
| `http://localhost:8000/docs` | Swagger UI | GET |
| `http://localhost:8000/api/v1/models` | List models | GET |
| `http://localhost:8000/api/v1/chat/completions` | Chat completion | POST |

### Example API Call

```powershell
$body = @{
    model = "default"
    messages = @(
        @{
            role = "user"
            content = "Write a Python hello world"
        }
    )
} | ConvertTo-Json

Invoke-RestMethod -Uri http://localhost:8000/api/v1/chat/completions `
    -Method Post `
    -Body $body `
    -ContentType "application/json"
```

---

## 🐛 Troubleshooting

### Build Issues

**Problem:** Docker build fails

**Solution:**
```powershell
# Check Docker is running
docker info

# Clean build
.\scripts\build.ps1 -NoCacheParam

# Free up space
docker system prune -a
```

**Problem:** Out of disk space

**Solution:**
```powershell
# Check space
docker system df

# Clean up
docker system prune -a --volumes

# Verify WSL disk expansion
Get-Item "$env:LOCALAPPDATA\Docker\wsl\data\ext4.vhdx" | 
    Select-Object @{Name='SizeGB';Expression={[math]::Round($_.Length / 1GB, 2)}}
```

---

### Runtime Issues

**Problem:** Container won't start

**Solution:**
```powershell
# Check logs
docker logs self-hosted-ai

# Check if port 8000 is in use
netstat -ano | findstr :8000

# Run on different port
.\scripts\run-container.ps1 -Port 8080 -Detached
```

**Problem:** Model download fails

**Solution:**
```powershell
# Check models directory exists
ls .\models

# Check internet connectivity
Test-NetConnection huggingface.co -Port 443

# Try smaller model first
# Edit .env: DEFAULT_MODEL_NAME=microsoft/DialoGPT-small
```

**Problem:** Out of memory

**Solution:**
```powershell
# Check Docker memory limit
docker info | Select-String Memory

# Increase in Docker Desktop settings (8GB+)
# Or use smaller model in .env
```

---

### Continue Extension Issues

**Problem:** Continue can't connect

**Solution:**
```powershell
# Test API manually
curl http://localhost:8000/health

# Check container is running
docker ps | findstr self-hosted-ai

# Check Continue config
# apiBase should be: http://localhost:8000/api/v1
```

**Problem:** Slow responses

**Solution:**
1. Use smaller model
2. Enable GPU if available
3. Increase Docker CPU/memory allocation
4. Check Docker stats: `docker stats self-hosted-ai`

---

## 📈 Monitoring

### View Container Logs

```powershell
# Follow logs
docker logs -f self-hosted-ai

# Last 100 lines
docker logs --tail 100 self-hosted-ai

# Logs with timestamps
docker logs -t self-hosted-ai
```

### Check Resource Usage

```powershell
# Real-time stats
docker stats self-hosted-ai

# Check health
curl http://localhost:8000/health
```

### Access Container Shell

```powershell
# Bash shell
docker exec -it self-hosted-ai /bin/bash

# Check Python environment
docker exec self-hosted-ai pip list

# Check models directory
docker exec self-hosted-ai ls -lh /app/models
```

---

## 🔄 Updates and Maintenance

### Update Code

```powershell
# Pull latest code
cd d:\Repos\self-hosted-ai-continue
git pull origin main

# Rebuild image
.\scripts\build.ps1 -NoCacheParam

# Stop old container
docker stop self-hosted-ai
docker rm self-hosted-ai

# Start new container
.\scripts\run-container.ps1 -Detached
```

### Clean Up Old Images

```powershell
# List images
docker images | findstr self-hosted-ai

# Remove old images
docker image prune -a

# Remove specific image
docker rmi self-hosted-ai-continue:old-tag
```

### Backup Models

```powershell
# Models are in ./models directory
# Backup entire directory
Copy-Item -Recurse .\models D:\Backups\ai-models-$(Get-Date -Format 'yyyy-MM-dd')

# Or just backup specific model
Copy-Item -Recurse ".\models\microsoft--DialoGPT-medium" D:\Backups\
```

---

## 🎯 Performance Tips

### 1. Use Appropriate Model Size

- **Small models** (< 500MB): Fast, good for development
- **Medium models** (500MB-2GB): Balanced performance
- **Large models** (> 2GB): Better quality, slower

### 2. Enable GPU

```powershell
# Edit .env
USE_GPU=True

# Run with GPU
.\scripts\run-container.ps1 -GPU -Detached
```

### 3. Increase Docker Resources

Docker Desktop Settings:
- **Memory**: 8GB minimum, 16GB recommended
- **CPUs**: 4 cores minimum, 8 recommended
- **Disk**: 50GB+ for models

### 4. Model Caching

First run downloads models (slow).
Subsequent runs use cache (fast).

Cache location: `./models/` (persisted via volume)

---

## 🔒 Security Considerations

### Production Deployment

1. **Enable Authentication**
   ```bash
   # In .env
   ENABLE_AUTH=True
   API_KEY=your-secure-key-here
   ```

2. **Disable Debug Mode**
   ```bash
   DEBUG=False
   ```

3. **Use Reverse Proxy** (nginx)
   - SSL/TLS encryption
   - Rate limiting
   - Access control

4. **Network Security**
   - Don't expose port 8000 to internet directly
   - Use firewall rules
   - Consider VPN for remote access

---

## 📚 Next Steps

1. ✅ **Build complete** → Image ready
2. ✅ **Container running** → API accessible
3. ✅ **Tests passing** → Backend working
4. 🎯 **Configure Continue** → VS Code integration
5. 🎯 **Try different models** → Optimize for your needs
6. 🎯 **Monitor performance** → Check logs and metrics
7. 🎯 **Deploy to production** → Use docker-compose

---

## 📞 Support

- **Logs**: `docker logs self-hosted-ai`
- **Scripts**: See `scripts/README.md`
- **API Docs**: http://localhost:8000/docs
- **GitHub**: Check repository issues

---

**Created**: October 20, 2025  
**Repository**: self-hosted-ai-continue  
**Container**: Production-ready standalone container (NOT DevContainer)
