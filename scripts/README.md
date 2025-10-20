# Self-Hosted AI Container - Build and Deployment Scripts

This directory contains PowerShell scripts for building, deploying, and managing the self-hosted AI backend.

## Scripts Overview

### build.ps1
Builds the Docker image for the AI backend.

**Usage:**
```powershell
# Basic build
.\scripts\build.ps1

# Build with specific tag
.\scripts\build.ps1 -Tag "v1.0.0"

# Build without cache (clean build)
.\scripts\build.ps1 -NoCacheParam
```

**What it does:**
- Checks Docker is running
- Verifies Dockerfile and requirements exist
- Builds the Docker image
- Tags the image
- Shows build time and image size

---

### run-container.ps1
Runs a single AI backend container (without docker-compose).

**Usage:**
```powershell
# Run in foreground (interactive)
.\scripts\run-container.ps1

# Run in background (detached)
.\scripts\run-container.ps1 -Detached

# Run on different port
.\scripts\run-container.ps1 -Port 8080

# Run with GPU support
.\scripts\run-container.ps1 -GPU

# Combine options
.\scripts\run-container.ps1 -Detached -Port 8080 -GPU
```

**What it does:**
- Creates .env from .env.example if needed
- Creates models directory
- Mounts volumes for models and .env
- Exposes API on specified port
- Shows useful commands for managing the container

---

### deploy.ps1
Deploys the full stack using docker-compose.

**Usage:**
```powershell
# Deploy services
.\scripts\deploy.ps1

# Build and deploy
.\scripts\deploy.ps1 -Build

# View logs
.\scripts\deploy.ps1 -Logs

# Stop all services
.\scripts\deploy.ps1 -Down
```

**What it does:**
- Deploys AI backend with docker-compose
- Optionally includes nginx and prometheus
- Shows service status
- Displays all available endpoints

---

### test.ps1
Tests the deployed AI backend to verify it's working.

**Usage:**
```powershell
# Test default localhost:8000
.\scripts\test.ps1

# Test different URL
.\scripts\test.ps1 -BaseUrl "http://localhost:8080"
```

**What it does:**
- Tests health endpoint
- Lists available models
- Attempts a chat completion
- Checks container status
- Provides summary and next steps

---

## Quick Start

### Option 1: Simple Container (Recommended for development)

```powershell
# 1. Build the image
.\scripts\build.ps1

# 2. Run the container
.\scripts\run-container.ps1 -Detached

# 3. Test it
.\scripts\test.ps1
```

### Option 2: Full Stack with Docker Compose (Recommended for production)

```powershell
# 1. Deploy everything
.\scripts\deploy.ps1 -Build

# 2. Test it
.\scripts\test.ps1

# 3. View logs
.\scripts\deploy.ps1 -Logs
```

---

## Environment Configuration

Before running, create a `.env` file from `.env.example`:

```powershell
Copy-Item .env.example .env
```

Then edit `.env` to configure:
- Model settings
- API keys (if needed)
- GPU settings
- Logging level

---

## Troubleshooting

### Container won't start
```powershell
# Check Docker is running
docker info

# Check logs
docker logs self-hosted-ai

# Restart Docker Desktop
```

### Port already in use
```powershell
# Use different port
.\scripts\run-container.ps1 -Port 8080

# Or stop existing container
docker stop self-hosted-ai
```

### Build fails
```powershell
# Clean build without cache
.\scripts\build.ps1 -NoCacheParam

# Check Docker has enough resources
docker system df
docker system prune -a
```

### GPU not working
```powershell
# Verify GPU support
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi

# Install NVIDIA Container Toolkit if needed
```

---

## Container Management

### View running containers
```powershell
docker ps
```

### View logs
```powershell
# Follow logs
docker logs -f self-hosted-ai

# Last 100 lines
docker logs --tail 100 self-hosted-ai
```

### Access container shell
```powershell
docker exec -it self-hosted-ai /bin/bash
```

### Stop container
```powershell
docker stop self-hosted-ai
```

### Restart container
```powershell
docker restart self-hosted-ai
```

### Remove container
```powershell
docker rm -f self-hosted-ai
```

---

## Integration with Continue Extension

After deploying, configure Continue to use your self-hosted backend:

1. Open VS Code
2. Open Continue extension settings
3. Set API endpoint: `http://localhost:8000`
4. Configure model (use model name from `/api/v1/models`)

See `../continue-config/` for example configurations.

---

## Performance Optimization

### Enable GPU
```powershell
.\scripts\run-container.ps1 -GPU -Detached
```

### Allocate more resources
Edit Docker Desktop settings:
- Memory: 8+ GB recommended
- CPUs: 4+ cores recommended
- Disk: 20+ GB for models

### Use smaller models
Edit `.env`:
```
DEFAULT_MODEL_NAME=microsoft/DialoGPT-small
```

---

## Monitoring

### Check health
```powershell
curl http://localhost:8000/health
```

### View metrics
```powershell
curl http://localhost:9090/metrics
```

### Check resource usage
```powershell
docker stats self-hosted-ai
```

---

## Updating

### Update to latest code
```powershell
# Pull latest changes
git pull origin main

# Rebuild
.\scripts\build.ps1 -NoCacheParam

# Redeploy
.\scripts\deploy.ps1 -Build
```

---

## Security Notes

- Change default API keys in `.env`
- Don't expose container ports to the internet without authentication
- Use nginx reverse proxy for production
- Enable HTTPS in production
- Set `DEBUG=False` in production

---

## Support

For issues, check:
- Logs: `docker logs self-hosted-ai`
- Documentation: `../docs/`
- GitHub Issues: [repository issues page]

---

Created: October 20, 2025
