@echo off
title ComfyUI Launcher
echo ====================================
echo         ComfyUI One-Click Start
echo ====================================
echo.

echo [1/3] Switching to ComfyUI directory...
cd /d "E:\ComfyUI"
if not exist "E:\ComfyUI" (
    echo ERROR: ComfyUI directory does not exist!
    pause
    exit /b 1
)

echo [2/3] Activating virtual environment...
if not exist "comfyui_clean\Scripts\activate.bat" (
    echo ERROR: Virtual environment does not exist!
    pause
    exit /b 1
)

call "comfyui_clean\Scripts\activate.bat"

echo [3/3] Starting ComfyUI...
echo.
echo ComfyUI is starting, please wait...
echo Browser will open automatically when ready
echo Access URL: http://127.0.0.1:8188
echo.
echo Press Ctrl+C to stop the server
echo ====================================
echo.

python main.py --cpu --auto-launch

echo.
echo ComfyUI has stopped running
pause