# Build Self-Hosted AI Container
# This script builds the Docker image for the AI backend

param(
    [string]$Tag = "latest",
    [switch]$NoCacheParam
)

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   Building Self-Hosted AI Container" -ForegroundColor Cyan
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

# Check Dockerfile exists
if (-not (Test-Path "$ProjectRoot\docker\Dockerfile")) {
    Write-Host "Error: Dockerfile not found at docker\Dockerfile" -ForegroundColor Red
    exit 1
}
Write-Host "Success: Dockerfile found" -ForegroundColor Green

# Check requirements.txt exists
if (-not (Test-Path "$ProjectRoot\requirements.txt")) {
    Write-Host "Error: requirements.txt not found" -ForegroundColor Red
    exit 1
}
Write-Host "Success: requirements.txt found" -ForegroundColor Green

Write-Host ""
Write-Host "[Step 2] Building Docker image..." -ForegroundColor Yellow
Write-Host "Image name: self-hosted-ai-continue:$Tag" -ForegroundColor Cyan

# Build command
$BuildCmd = "docker build -f docker/Dockerfile -t self-hosted-ai-continue:$Tag"
if ($NoCacheParam) {
    $BuildCmd += " --no-cache"
}
$BuildCmd += " ."

Write-Host "Command: $BuildCmd" -ForegroundColor Gray
Write-Host ""

# Execute build
$BuildStart = Get-Date
Invoke-Expression $BuildCmd

if ($LASTEXITCODE -eq 0) {
    $BuildEnd = Get-Date
    $BuildDuration = ($BuildEnd - $BuildStart).TotalSeconds
    
    Write-Host ""
    Write-Host "Success: Image built successfully in $([math]::Round($BuildDuration, 2)) seconds" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "[Step 3] Verifying image..." -ForegroundColor Yellow
    $ImageInfo = docker images self-hosted-ai-continue:$Tag --format "{{.Repository}}:{{.Tag}} - {{.Size}}"
    Write-Host "Image: $ImageInfo" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "   BUILD COMPLETE!" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Run the container:" -ForegroundColor Yellow
    Write-Host "     .\scripts\run-container.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Or use docker-compose:" -ForegroundColor Yellow
    Write-Host "     .\scripts\deploy.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "  3. Test the API:" -ForegroundColor Yellow
    Write-Host "     curl http://localhost:8000/health" -ForegroundColor White
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "Error: Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit 1
}
