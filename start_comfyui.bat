@echo off
title ComfyUI 启动器
echo ====================================
echo          ComfyUI 一键启动
echo ====================================
echo.

echo [1/3] 切换到ComfyUI目录...
cd /d "E:\ComfyUI"
if not exist "E:\ComfyUI" (
    echo 错误：ComfyUI目录不存在！
    pause
    exit /b 1
)

echo [2/3] 激活虚拟环境...
if not exist "comfyui_clean\Scripts\Activate.ps1" (
    echo 错误：虚拟环境不存在！
    pause
    exit /b 1
)

call "comfyui_clean\Scripts\activate.bat"

echo [3/3] 启动ComfyUI...
echo.
echo ComfyUI正在启动，请稍候...
echo 启动完成后将自动打开浏览器
echo 访问地址：http://127.0.0.1:8188
echo.
echo 按 Ctrl+C 可停止服务器
echo ====================================
echo.

python main.py --cpu --auto-launch

echo.
echo ComfyUI已停止运行
pause