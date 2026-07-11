# 统一的Flutter安装脚本 (Windows)
# FLUTTER_VERSION 可为分支名（如 main）或版本 tag（如 3.46.0-1.0.pre-1）

$FLUTTER_VERSION = if ($env:FLUTTER_VERSION) { $env:FLUTTER_VERSION } else { "main" }
$FLUTTER_PATH = "$env:GITHUB_WORKSPACE/flutter"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🐦 安装 Flutter" -ForegroundColor Cyan
Write-Host "版本: $FLUTTER_VERSION" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 克隆 Flutter 仓库
Write-Host "正在克隆 Flutter $FLUTTER_VERSION 分支..." -ForegroundColor Yellow
git clone https://github.com/flutter/flutter.git --branch $FLUTTER_VERSION $FLUTTER_PATH --depth 1

# 添加到 PATH
Write-Host "添加 Flutter 到 PATH..." -ForegroundColor Yellow
"$FLUTTER_PATH/bin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append

# 验证安装
Write-Host "验证 Flutter 安装..." -ForegroundColor Yellow
& "$FLUTTER_PATH/bin/flutter.bat" --version

Write-Host "✅ Flutter 安装完成！" -ForegroundColor Green
