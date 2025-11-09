@echo off
REM ComfyUI Startup Script
setlocal enabledelayedexpansion

REM Set UTF-8 code page for better encoding support
chcp 65001 >nul 2>&1

echo.
echo ====================================================
echo            ComfyUI Startup Script
echo ====================================================
echo.

REM Get the ComfyUI directory
set COMFYUI_DIR=%~dp0
echo [INFO] Directory: %COMFYUI_DIR%

REM Change to ComfyUI directory
cd /d "%COMFYUI_DIR%"
if errorlevel 1 (
    echo [ERROR] Failed to change directory
    pause
    exit /b 1
)

REM Check if main.py exists
if not exist "main.py" (
    echo [ERROR] main.py not found!
    echo Please ensure this script is in the ComfyUI root directory
    pause
    exit /b 1
)
echo [OK] main.py found

REM Check if virtual environment exists
set PYTHON_PATH=%COMFYUI_DIR%comfyui_clean\Scripts\python.exe
if not exist "%PYTHON_PATH%" (
    echo [ERROR] Virtual environment not found!
    echo Expected: %PYTHON_PATH%
    echo.
    echo Please create the virtual environment first:
    echo   python -m venv comfyui_clean
    pause
    exit /b 1
)
echo [OK] Virtual environment found

REM Check if requirements.txt exists
if not exist "requirements.txt" (
    echo [WARNING] requirements.txt not found!
    echo Continuing without dependency check...
) else (
    echo [OK] requirements.txt found
)

REM Set virtual environment activation script
set VENV_ACTIVATE=%COMFYUI_DIR%comfyui_clean\Scripts\activate.bat

REM Activate virtual environment
echo.
echo [INFO] Activating virtual environment...
call "%VENV_ACTIVATE%"
if errorlevel 1 (
    echo [ERROR] Failed to activate virtual environment
    pause
    exit /b 1
)

REM Verify Python is accessible
"%PYTHON_PATH%" --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python executable is not accessible
    echo Path: %PYTHON_PATH%
    pause
    exit /b 1
)

REM Optional: Update dependencies
if exist "requirements.txt" (
    echo.
    echo [INFO] Checking dependencies...
    echo.
    
    "%PYTHON_PATH%" -m pip install --upgrade pip setuptools wheel --quiet 2>nul
    if errorlevel 1 (
        echo [WARNING] pip upgrade failed, continuing...
    )
    
    "%PYTHON_PATH%" -m pip install -r requirements.txt --quiet 2>nul
    if errorlevel 1 (
        echo [WARNING] Some dependencies failed to install, attempting startup...
    )
)

echo.
echo ====================================================
echo            ComfyUI is starting...
echo            URL: http://127.0.0.1:8188
echo.
echo            Press Ctrl+C to stop the server
echo ====================================================
echo.

timeout /t 2 /nobreak >nul

REM Ensure we are in the correct directory
cd /d "%COMFYUI_DIR%"
if errorlevel 1 (
    echo [ERROR] Failed to change to ComfyUI directory
    pause
    exit /b 1
)

REM Start ComfyUI with error handling
echo [INFO] Starting ComfyUI server...
echo.
"%PYTHON_PATH%" main.py --listen 127.0.0.1 --port 8188 --cpu
set EXIT_CODE=!ERRORLEVEL!

echo.
if !EXIT_CODE! equ 0 (
    echo [INFO] Server stopped normally
) else (
    echo [ERROR] Server exited with error code: !EXIT_CODE!
    echo.
    echo Please check the error messages above for details.
)
pause
