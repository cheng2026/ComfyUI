# ComfyUI Startup Script (PowerShell version)
# This script properly handles UTF-8 encoding and provides better error handling

param(
    [switch]$SkipDependencies = $false,
    [int]$Port = 8188
)

# Set UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ComfyUIDir = $ScriptDir

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "           ComfyUI Startup Script v3.0" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Change to ComfyUI directory
Set-Location $ComfyUIDir

# Check if main.py exists
if (-not (Test-Path "main.py")) {
    Write-Host "[ERROR] main.py not found!" -ForegroundColor Red
    Write-Host "Please ensure this script is in the ComfyUI root directory"
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[OK] main.py found" -ForegroundColor Green

# Check if virtual environment exists
$PythonExe = Join-Path $ComfyUIDir "comfyui_clean\Scripts\python.exe"
if (-not (Test-Path $PythonExe)) {
    Write-Host "[ERROR] Virtual environment not found!" -ForegroundColor Red
    Write-Host "Expected: $PythonExe"
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[OK] Virtual environment found" -ForegroundColor Green

# Check if requirements.txt exists
if (-not (Test-Path "requirements.txt")) {
    Write-Host "[ERROR] requirements.txt not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[OK] requirements.txt found" -ForegroundColor Green

# Update dependencies if not skipped
if (-not $SkipDependencies) {
    Write-Host ""
    Write-Host "[INFO] Checking and updating dependencies..." -ForegroundColor Yellow
    Write-Host ""
    
    # Update pip
    Write-Host "Updating pip, setuptools, wheel..." -ForegroundColor Cyan
    & $PythonExe -m pip install --upgrade pip setuptools wheel --quiet 2>null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARNING] pip upgrade had issues, continuing..." -ForegroundColor Yellow
    }
    
    # Install requirements
    Write-Host "Installing requirements..." -ForegroundColor Cyan
    & $PythonExe -m pip install -r requirements.txt --quiet 2>null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARNING] Some dependencies failed, attempting startup..." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "           ComfyUI is starting..." -ForegroundColor Cyan
Write-Host "           URL: http://127.0.0.1:$Port" -ForegroundColor Cyan
Write-Host ""
Write-Host "           Press Ctrl+C to stop the server" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Seconds 2

# Start ComfyUI
& $PythonExe main.py --listen 127.0.0.1 --port $Port --cpu

Write-Host ""
Write-Host "[INFO] Server stopped" -ForegroundColor Green
Read-Host "Press Enter to exit"
