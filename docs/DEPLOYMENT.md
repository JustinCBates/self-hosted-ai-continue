# Deployment Guide

This guide covers various deployment options for the Self-Hosted AI Backend.

## Local Development

### Prerequisites
- Python 3.11+
- 8GB+ RAM recommended
- GPU with 4GB+ VRAM (optional)

### Setup
```bash
# Clone repository
git clone <your-repo>
cd self-hosted-ai-continue

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Start development server
npm run dev
```

## Docker Deployment

### Single Container

```bash
# Build image
docker build -f docker/Dockerfile -t self-hosted-ai .

# Run container
docker run -d \
  --name ai-backend \
  -p 8000:8000 \
  -v $(pwd)/models:/app/models \
  -v $(pwd)/.env:/app/.env \
  self-hosted-ai
```

### Docker Compose

```bash
# Start all services
docker-compose -f docker/docker-compose.yml up -d

# View logs
docker-compose logs -f ai-backend

# Stop services
docker-compose down
```

## Production Deployment

### System Requirements

**Minimum:**
- 4 CPU cores
- 8GB RAM
- 50GB storage
- Ubuntu 20.04+ or equivalent

**Recommended:**
- 8+ CPU cores
- 16GB+ RAM
- GPU with 8GB+ VRAM
- 100GB+ SSD storage

### Production Setup

1. **Prepare Server**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

2. **Deploy Application**
```bash
# Clone repository
git clone <your-repo>
cd self-hosted-ai-continue

# Configure production environment
cp .env.example .env
nano .env  # Set production values

# Start services
docker-compose -f docker/docker-compose.yml up -d
```

3. **Production Environment Variables**
```env
DEBUG=False
LOG_LEVEL=INFO
USE_GPU=True
ENABLE_METRICS=True
API_KEY=your-secure-api-key-here
ENABLE_AUTH=True
```

## Cloud Deployment

### AWS EC2

1. **Launch Instance**
   - Instance type: `g4dn.xlarge` (for GPU) or `m5.large` (CPU only)
   - AMI: Ubuntu 20.04 LTS
   - Security Group: Allow ports 22, 80, 8000

2. **Setup**
```bash
# Connect to instance
ssh -i your-key.pem ubuntu@your-instance-ip

# Install dependencies
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker ubuntu

# Deploy application
git clone <your-repo>
cd self-hosted-ai-continue
# Configure and start as above
```

### Google Cloud Platform

1. **Create VM Instance**
```bash
gcloud compute instances create ai-backend \
  --zone=us-central1-a \
  --machine-type=n1-standard-4 \
  --accelerator=type=nvidia-tesla-t4,count=1 \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=100GB \
  --tags=http-server
```

2. **Setup GPU Support**
```bash
# Install NVIDIA drivers
sudo apt update
sudo apt install -y nvidia-driver-470
sudo reboot

# Install NVIDIA Docker
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt update && sudo apt install -y nvidia-docker2
sudo systemctl restart docker
```

### Azure Container Instances

```bash
# Create resource group
az group create --name ai-backend-rg --location eastus

# Deploy container
az container create \
  --resource-group ai-backend-rg \
  --name ai-backend \
  --image your-registry/self-hosted-ai:latest \
  --cpu 4 \
  --memory 8 \
  --ports 8000 \
  --environment-variables DEBUG=False USE_GPU=False
```

## Load Balancing

### Nginx Configuration

```nginx
upstream ai_backend {
    server localhost:8000;
    server localhost:8001;  # Additional instances
}

server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://ai_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
}
```

### Multiple Instances

```bash
# Start multiple backend instances
docker run -d --name ai-backend-1 -p 8000:8000 self-hosted-ai
docker run -d --name ai-backend-2 -p 8001:8000 self-hosted-ai
docker run -d --name ai-backend-3 -p 8002:8000 self-hosted-ai
```

## Monitoring

### Health Checks

```bash
# Basic health check
curl http://localhost:8000/health

# Readiness check
curl http://localhost:8000/health/ready

# Metrics (if enabled)
curl http://localhost:9090/metrics
```

### Prometheus Configuration

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'ai-backend'
    static_configs:
      - targets: ['localhost:9090']
    scrape_interval: 10s
    metrics_path: /metrics
```

## Security

### Firewall Rules

```bash
# Allow only necessary ports
sudo ufw enable
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 8000/tcp  # API (internal only)
```

### SSL/TLS

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo crontab -e
0 12 * * * /usr/bin/certbot renew --quiet
```

## Backup and Recovery

### Model Backup

```bash
# Backup models directory
tar -czf models-backup-$(date +%Y%m%d).tar.gz models/

# Upload to cloud storage
aws s3 cp models-backup-*.tar.gz s3://your-backup-bucket/
```

### Configuration Backup

```bash
# Backup configuration
cp .env .env.backup
cp docker/docker-compose.yml docker-compose.yml.backup
```

## Troubleshooting

### Common Issues

1. **Out of Memory**
   - Reduce model size
   - Increase swap space
   - Use GPU offloading

2. **Slow Startup**
   - Pre-download models
   - Use faster storage
   - Increase timeout values

3. **Connection Issues**
   - Check firewall rules
   - Verify port binding
   - Test with curl

### Logs

```bash
# View Docker logs
docker logs ai-backend

# View system logs
sudo journalctl -u docker.service

# View application logs
tail -f logs/app.log
```