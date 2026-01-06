#!/bin/bash
set -e
echo "======================================"
echo "  网易云音乐播放器 - Vercel 一键部署"
echo "======================================"

# 1. 检查 Node.js 是否安装
if ! command -v node &> /dev/null
then
    echo "[错误] 未检测到 Node.js，请先安装 Node.js 16+ 版本"
    exit 1
fi
echo "[1/5] Node.js 环境检测通过"

# 2. 安装/更新 Vercel CLI
echo "[2/5] 安装/更新 Vercel CLI..."
npm install -g vercel

# 3. 登录 Vercel（未登录时自动触发浏览器登录）
echo "[3/5] 登录 Vercel 账号（未登录将自动打开浏览器）"
vercel login

# 4. 构建前端项目
echo "[4/5] 构建前端生产环境包..."
npm run build

# 5. 部署到 Vercel 生产环境
echo "[5/5] 发布到 Vercel 生产环境..."
vercel --prod

echo "======================================"
echo "  部署完成！"
echo "  访问地址会在终端输出，可在 Vercel Dashboard 查看"
echo "======================================"