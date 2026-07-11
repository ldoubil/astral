#!/bin/bash
# 统一的Flutter安装脚本 (Linux/macOS)
# FLUTTER_VERSION 可为：
#   - 分支名（如 main）
#   - 正式/beta tag（如 3.46.0-0.3.pre）
#   - commit SHA（如 cec88b6b47bd65d21ff643ea5dc3f306bc49af66）
# 注意：flutter --version 显示的 3.46.0-1.0.pre-1 不是 git tag，不能直接 clone

set -e

FLUTTER_VERSION="${FLUTTER_VERSION:-main}"
FLUTTER_PATH="${HOME}/flutter"

echo "=========================================="
echo "🐦 安装 Flutter"
echo "版本/引用: $FLUTTER_VERSION"
echo "=========================================="

if [[ "$FLUTTER_VERSION" =~ ^[0-9a-fA-F]{7,40}$ ]]; then
  echo "按 commit 浅克隆: $FLUTTER_VERSION"
  git clone --filter=blob:none --no-checkout https://github.com/flutter/flutter.git "$FLUTTER_PATH"
  git -C "$FLUTTER_PATH" fetch --depth 1 origin "$FLUTTER_VERSION"
  git -C "$FLUTTER_PATH" checkout FETCH_HEAD
else
  echo "按分支/tag 浅克隆: $FLUTTER_VERSION"
  git clone https://github.com/flutter/flutter.git --branch "$FLUTTER_VERSION" "$FLUTTER_PATH" --depth 1
fi

# 添加到 PATH
echo "$FLUTTER_PATH/bin" >> $GITHUB_PATH
export PATH="$FLUTTER_PATH/bin:$PATH"

# 授予执行权限
chmod +x "$FLUTTER_PATH/bin/flutter"

# 验证安装
echo "验证 Flutter 安装..."
flutter --version
echo "✅ Flutter 安装完成！"
