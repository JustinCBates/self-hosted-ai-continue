# Deploy Self-Hosted AI with Docker Compose
# This script deploys the full stack with docker-compose

param(
    [switch]$Build,
    [switch]$Down,
    [switch]$Logs
)

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   Deploy Self-Hosted AI Stack" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to project root
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

Write-Host "[Step 1] Checking prerequisites..." -ForegroundColor Yellow

# Check Docker is running
try {
    docker info | Out-Null
    Write-Host "Success: Docker is running" -ForegroundColor Green
} catch {
    Write-Host "Error: Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check docker-compose file exists
if (-not (Test-Path "$ProjectRoot\docker\docker-compose.yml")) {
    Write-Host "Error: docker-compose.yml not found" -ForegroundColor Red
    exit 1
}
Write-Host "Success: docker-compose.yml found" -ForegroundColor Green

# Check if .env exists, create from .env.example if not
if (-not (Test-Path "$ProjectRoot\.env")) {
    if (Test-Path "$ProjectRoot\.env.example") {
        Write-Host "Creating .env from .env.example..." -ForegroundColor Yellow
        Copy-Item "$ProjectRoot\.env.example" "$ProjectRoot\.env"
        Write-Host "Success: .env created" -ForegroundColor Green
    }
}

# Create models directory if it doesn't exist
if (-not (Test-Path "$ProjectRoot\models")) {
    New-Item -ItemType Directory -Path "$ProjectRoot\models" | Out-Null
    Write-Host "Created models directory" -ForegroundColor Green
}

Write-Host ""

# Handle different modes
if ($Down) {
    Write-Host "[Step 2] Stopping services..." -ForegroundColor Yellow
    docker-compose -f docker\docker-compose.yml down
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Success: Services stopped" -ForegroundColor Green
    }
    exit 0
}

if ($Logs) {
    Write-Host "[Step 2] Showing logs..." -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to exit" -ForegroundColor Gray
    Write-Host ""
    docker-compose -f docker\docker-compose.yml logs -f
    exit 0
}

# Deploy services
Write-Host "[Step 2] Deploying services..." -ForegroundColor Yellow

if ($Build) {
    Write-Host "Building images..." -ForegroundColor Cyan
    docker-compose -f docker\docker-compose.yml up --build -d
} else {
    docker-compose -f docker\docker-compose.yml up -d
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "   DEPLOYMENT COMPLETE!" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    
    # Wait for services to be ready
    Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # Check service status
    Write-Host ""
    Write-Host "Service Status:" -ForegroundColor Cyan
    docker-compose -f docker\docker-compose.yml ps
    
    Write-Host ""
    Write-Host "Available Services:" -ForegroundColor Cyan
    Write-Host "  AI Backend:    http://localhost:8000" -ForegroundColor White
    Write-Host "  Health Check:  http://localhost:8000/health" -ForegroundColor White
    Write-Host "  API Docs:      http://localhost:8000/docs" -ForegroundColor White
    Write-Host "  Metrics:       http://localhost:9090" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Useful commands:" -ForegroundColor Cyan
    Write-Host "  View logs:     .\scripts\deploy.ps1 -Logs" -ForegroundColor Yellow
    Write-Host "  Stop all:      .\scripts\deploy.ps1 -Down" -ForegroundColor Yellow
    Write-Host "  Rebuild:       .\scripts\deploy.ps1 -Build" -ForegroundColor Yellow
    Write-Host "  Check status:  docker-compose -f docker\docker-compose.yml ps" -ForegroundColor Yellow
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "Error: Deployment failed" -ForegroundColor Red
    exit 1
}
