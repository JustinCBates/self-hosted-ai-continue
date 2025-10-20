# Test Self-Hosted AI Container
# This script tests the deployed AI backend

param(
    [string]$BaseUrl = "http://localhost:8000"
)

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   Testing Self-Hosted AI Backend" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Testing API at: $BaseUrl" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "[Test 1] Health Check..." -ForegroundColor Yellow
try {
    $Response = Invoke-RestMethod -Uri "$BaseUrl/health" -Method Get -TimeoutSec 10
    Write-Host "Success: Health check passed" -ForegroundColor Green
    Write-Host "Response: $($Response | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "Failed: Health check failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Root Endpoint
Write-Host "[Test 2] Root Endpoint..." -ForegroundColor Yellow
try {
    $Response = Invoke-RestMethod -Uri "$BaseUrl/" -Method Get -TimeoutSec 10
    Write-Host "Success: Root endpoint accessible" -ForegroundColor Green
    Write-Host "Response: $($Response | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "Failed: Root endpoint failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Models List
Write-Host "[Test 3] List Models..." -ForegroundColor Yellow
try {
    $Response = Invoke-RestMethod -Uri "$BaseUrl/api/v1/models" -Method Get -TimeoutSec 10
    Write-Host "Success: Models endpoint accessible" -ForegroundColor Green
    Write-Host "Available models:" -ForegroundColor Gray
    $Response.models | ForEach-Object {
        Write-Host "  - $($_.name)" -ForegroundColor White
    }
} catch {
    Write-Host "Failed: Models endpoint failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Chat Completion (if models are loaded)
Write-Host "[Test 4] Chat Completion..." -ForegroundColor Yellow
$ChatRequest = @{
    model = "default"
    messages = @(
        @{
            role = "user"
            content = "Hello, write a simple hello world function in Python"
        }
    )
    max_tokens = 100
} | ConvertTo-Json

try {
    $Response = Invoke-RestMethod -Uri "$BaseUrl/api/v1/chat/completions" -Method Post -Body $ChatRequest -ContentType "application/json" -TimeoutSec 30
    Write-Host "Success: Chat completion works" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Gray
    Write-Host $Response.choices[0].message.content -ForegroundColor White
} catch {
    Write-Host "Warning: Chat completion failed (model may not be loaded yet)" -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host ""

# Test 5: Docker Container Status (if running in container)
Write-Host "[Test 5] Container Status..." -ForegroundColor Yellow
try {
    $ContainerStatus = docker ps --filter "name=self-hosted-ai" --format "{{.Status}}"
    if ($ContainerStatus) {
        Write-Host "Success: Container is running" -ForegroundColor Green
        Write-Host "Status: $ContainerStatus" -ForegroundColor Gray
    } else {
        Write-Host "Info: No container found (may be running directly)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Info: Docker check skipped" -ForegroundColor Gray
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "   TESTING COMPLETE!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  API is accessible at: $BaseUrl" -ForegroundColor White
Write-Host "  Health check: PASSED" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Configure Continue extension to use: $BaseUrl" -ForegroundColor Yellow
Write-Host "  2. View API documentation: ${BaseUrl}/docs" -ForegroundColor Yellow
Write-Host "  3. Monitor logs: docker logs -f self-hosted-ai" -ForegroundColor Yellow
Write-Host ""
