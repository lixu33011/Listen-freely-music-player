#!/bin/bash
set -e

echo "======================================"
echo " 《梦醒成空》播放器 - 一键修改 API 地址"
echo "======================================"

# 1. 检查是否在项目根目录
if [ ! -f "vite.config.js" ]; then
    echo "[错误] 未找到 vite.config.js，请在项目根目录运行此脚本！"
    exit 1
fi

if [ ! -f "api/proxy.js" ]; then
    echo "[错误] 未找到 api/proxy.js，请在项目根目录运行此脚本！"
    exit 1
fi

# 2. 输入新的 API 地址
read -p "请输入本地代理目标地址（如 https://music.163.com/api）：" new_proxy
read -p "请输入服务端转发地址（如 https://music.163.com/api）：" new_baseurl
read -p "请输入测试接口地址（如 http://localhost:5173 或 https://xxx.vercel.app）：" new_testurl

# 3. 备份原文件
echo "[1/5] 备份原配置文件..."
cp -f "vite.config.js" "vite.config.bak"
cp -f "api/proxy.js" "api/proxy.bak"
if [ -f "test-api.sh" ]; then
    cp -f "test-api.sh" "test-api.bak"
fi

# 4. 修改 vite.config.js 中的 proxy target
echo "[2/5] 修改 vite.config.js 本地代理地址..."
sed -i "" "s/target: '[^']*'/target: '$new_proxy'/g" vite.config.js

# 5. 修改 api/proxy.js 中的 baseUrl
echo "[3/5] 修改 api/proxy.js 服务端转发地址..."
sed -i "" "s/const baseUrl = '[^']*'/const baseUrl = '$new_baseurl'/g" api/proxy.js

# 6. 修改 test-api.sh 中的 BASE_URL（如果存在）
if [ -f "test-api.sh" ]; then
    echo "[4/5] 修改 test-api.sh 测试地址..."
    sed -i "" "s/const BASE_URL = '[^']*'/const BASE_URL = '$new_testurl'/g" test-api.sh
fi

# 7. 完成提示
echo "[5/5] 所有 API 地址修改完成！"
echo "- 本地代理地址：$new_proxy"
echo "- 服务端转发地址：$new_baseurl"
echo "- 测试接口地址：$new_testurl"
echo "- 原文件已备份为 .bak 后缀"
echo "======================================"