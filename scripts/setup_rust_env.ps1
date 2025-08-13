# 脚本用于确保使用正确的Rust版本

# 检查rustup是否已安装
if (!(Get-Command rustup -ErrorAction SilentlyContinue)) {
    Write-Host "rustup 未安装，正在安装..."
    # 在GitHub Actions环境中，Rust应该已经通过dtolnay/rust-toolchain安装
    # 这里我们只需确保使用正确的版本
}

# 安装或更新到指定的Rust版本
Write-Host "正在设置 Rust 1.89.0..."
rustup toolchain install 1.89.0
rustup default 1.89.0

# 验证版本
Write-Host "当前 Rust 版本:"
rustc --version

# 添加常用的编译目标
Write-Host "正在添加常用编译目标..."
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android
rustup target add x86_64-pc-windows-msvc

Write-Host "Rust 环境设置完成!"