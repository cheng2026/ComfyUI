# ComfyUI 启动修复脚本
# 禁用有问题的自定义节点

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ComfyUI 启动修复脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$customNodesPath = "E:\ComfyUI\custom_nodes"

# 定义有问题的节点
$problematicNodes = @(
    "ComfyUI-Easy-Use",
    "ComfyUI-PMRF",
    "my-comfyui-nodes"
)

Write-Host "[1] 正在禁用有问题的自定义节点..."
Write-Host ""

foreach ($node in $problematicNodes) {
    $nodePath = Join-Path $customNodesPath $node
    $disabledPath = "$nodePath.disabled"
    
    if (Test-Path $nodePath -PathType Directory) {
        if (-not (Test-Path $disabledPath)) {
            Rename-Item -Path $nodePath -NewName "$node.disabled" -Force
            Write-Host "✓ 已禁用: $node" -ForegroundColor Green
        } else {
            Write-Host "⚠ 已禁用过: $node" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠ 未找到: $node" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[2] 正在更新依赖..."
Write-Host ""

# 获取虚拟环境的Python
$pythonExe = "E:\ComfyUI\comfyui_clean\Scripts\python.exe"

if (Test-Path $pythonExe) {
    # 更新pip
    Write-Host "更新 pip..." -ForegroundColor Cyan
    & $pythonExe -m pip install --upgrade pip setuptools wheel -q
    
    # 更新requirements
    Write-Host "更新依赖..." -ForegroundColor Cyan
    Set-Location "E:\ComfyUI"
    & $pythonExe -m pip install -r requirements.txt -q
    
    Write-Host "✓ 依赖更新完成" -ForegroundColor Green
} else {
    Write-Host "❌ 找不到虚拟环境!" -ForegroundColor Red
    Exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  修复完成！现在可以运行 run_comfyui.bat" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Read-Host "按 Enter 键退出"