# 统一的Flutter安装脚本 (Windows)
# FLUTTER_VERSION 可为：分支名 / tag / commit SHA
# 注意：flutter --version 显示的 3.46.0-1.0.pre-1 不是 git tag，不能直接 clone

$FLUTTER_VERSION = if ($env:FLUTTER_VERSION) { $env:FLUTTER_VERSION } else { "main" }
$FLUTTER_PATH = "$env:GITHUB_WORKSPACE/flutter"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🐦 安装 Flutter" -ForegroundColor Cyan
Write-Host "版本/引用: $FLUTTER_VERSION" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

if ($FLUTTER_VERSION -match '^[0-9a-fA-F]{7,40}$') {
  Write-Host "按 commit 浅克隆: $FLUTTER_VERSION" -ForegroundColor Yellow
  git clone --filter=blob:none --no-checkout https://github.com/flutter/flutter.git $FLUTTER_PATH
  git -C $FLUTTER_PATH fetch --depth 1 origin $FLUTTER_VERSION
  git -C $FLUTTER_PATH checkout FETCH_HEAD
} else {
  Write-Host "按分支/tag 浅克隆: $FLUTTER_VERSION" -ForegroundColor Yellow
  git clone https://github.com/flutter/flutter.git --branch $FLUTTER_VERSION $FLUTTER_PATH --depth 1
}

# 添加到 PATH
Write-Host "添加 Flutter 到 PATH..." -ForegroundColor Yellow
"$FLUTTER_PATH/bin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append

# 验证安装
Write-Host "验证 Flutter 安装..." -ForegroundColor Yellow
& "$FLUTTER_PATH/bin/flutter.bat" --version

Write-Host "✅ Flutter 安装完成！" -ForegroundColor Green
