# Run Self-Hosted AI Container
# This script runs a single container (no docker-compose)

param(
    [string]$Tag = "latest",
    [int]$Port = 8000,
    [switch]$Detached,
    [switch]$GPU
)

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   Running Self-Hosted AI Container" -ForegroundColor Cyan
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

# Check image exists
$ImageExists = docker images -q self-hosted-ai-continue:$Tag
if (-not $ImageExists) {
    Write-Host "Error: Image self-hosted-ai-continue:$Tag not found" -ForegroundColor Red
    Write-Host "Run .\scripts\build.ps1 first to build the image" -ForegroundColor Yellow
    exit 1
}
Write-Host "Success: Image found" -ForegroundColor Green

# Check if .env exists, create from .env.example if not
if (-not (Test-Path "$ProjectRoot\.env")) {
    if (Test-Path "$ProjectRoot\.env.example") {
        Write-Host "Creating .env from .env.example..." -ForegroundColor Yellow
        Copy-Item "$ProjectRoot\.env.example" "$ProjectRoot\.env"
        Write-Host "Success: .env created" -ForegroundColor Green
    } else {
        Write-Host "Warning: No .env file found" -ForegroundColor Yellow
    }
} else {
    Write-Host "Success: .env file found" -ForegroundColor Green
}

# Create models directory if it doesn't exist
if (-not (Test-Path "$ProjectRoot\models")) {
    New-Item -ItemType Directory -Path "$ProjectRoot\models" | Out-Null
    Write-Host "Created models directory" -ForegroundColor Green
}

Write-Host ""
Write-Host "[Step 2] Starting container..." -ForegroundColor Yellow

# Build run command
$RunCmd = "docker run --name self-hosted-ai"

# Detached mode
if ($Detached) {
    $RunCmd += " -d"
    Write-Host "Mode: Detached (background)" -ForegroundColor Cyan
} else {
    $RunCmd += " --rm"
    Write-Host "Mode: Interactive (foreground)" -ForegroundColor Cyan
}

# Port mapping
$RunCmd += " -p ${Port}:8000"
Write-Host "Port: $Port -> 8000" -ForegroundColor Cyan

# GPU support
if ($GPU) {
    $RunCmd += " --gpus all"
    Write-Host "GPU: Enabled" -ForegroundColor Cyan
} else {
    Write-Host "GPU: Disabled" -ForegroundColor Cyan
}

# Volume mounts
$RunCmd += " -v `"${ProjectRoot}\models:/app/models`""
if (Test-Path "$ProjectRoot\.env") {
    $RunCmd += " -v `"${ProjectRoot}\.env:/app/.env`""
}

# Environment variables
$RunCmd += " -e USE_GPU=$($GPU.IsPresent)"

# Image
$RunCmd += " self-hosted-ai-continue:$Tag"

Write-Host ""
Write-Host "Command: $RunCmd" -ForegroundColor Gray
Write-Host ""

# Stop existing container if running
$ExistingContainer = docker ps -aq -f name=self-hosted-ai
if ($ExistingContainer) {
    Write-Host "Stopping existing container..." -ForegroundColor Yellow
    docker stop self-hosted-ai | Out-Null
    docker rm self-hosted-ai | Out-Null
}

# Run container
Invoke-Expression $RunCmd

if ($LASTEXITCODE -eq 0 -and $Detached) {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "   CONTAINER STARTED!" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    
    # Wait for health check
    Write-Host "Waiting for container to be healthy..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    $HealthCheck = docker inspect --format='{{.State.Health.Status}}' self-hosted-ai 2>$null
    if ($HealthCheck) {
        Write-Host "Health status: $HealthCheck" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "Container is running:" -ForegroundColor Cyan
    Write-Host "  API endpoint: http://localhost:$Port" -ForegroundColor White
    Write-Host "  Health check: http://localhost:${Port}/health" -ForegroundColor White
    Write-Host "  Documentation: http://localhost:${Port}/docs" -ForegroundColor White
    Write-Host ""
    Write-Host "Useful commands:" -ForegroundColor Cyan
    Write-Host "  View logs:    docker logs -f self-hosted-ai" -ForegroundColor Yellow
    Write-Host "  Stop:         docker stop self-hosted-ai" -ForegroundColor Yellow
    Write-Host "  Restart:      docker restart self-hosted-ai" -ForegroundColor Yellow
    Write-Host "  Shell:        docker exec -it self-hosted-ai /bin/bash" -ForegroundColor Yellow
    Write-Host ""
} elseif ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Error: Container failed to start" -ForegroundColor Red
    exit 1
}
