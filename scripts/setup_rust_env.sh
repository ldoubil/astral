#!/bin/bash
# 脚本用于确保使用正确的Rust版本

# 检查rustup是否已安装
if ! command -v rustup &> /dev/null
then
    echo "rustup 未安装，正在安装..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# 安装或更新到指定的Rust版本
echo "正在安装 Rust 1.89.0..."
rustup install 1.89.0
rustup default 1.89.0

# 验证版本
echo "当前 Rust 版本:"
rustc --version

# 添加常用的编译目标
echo "正在添加常用编译目标..."
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android

echo "Rust 环境设置完成!"