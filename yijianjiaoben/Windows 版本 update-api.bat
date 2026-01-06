@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ======================================
echo  《》播放器 - 一键修改 API 地址
echo ======================================

:: 1. 检查是否在项目根目录
if not exist "vite.config.js" (
    echo [错误] 未找到 vite.config.js，请在项目根目录运行此脚本！
    pause
    exit /b 1
)

if not exist "api\proxy.js" (
    echo [错误] 未找到 api\proxy.js，请在项目根目录运行此脚本！
    pause
    exit /b 1
)

:: 2. 输入新的 API 地址
set /p new_proxy=请输入本地代理目标地址（如 https://music.163.com/api）：
set /p new_baseurl=请输入服务端转发地址（如 https://music.163.com/api）：
set /p new_testurl=请输入测试接口地址（如 http://localhost:5173 或 https://xxx.vercel.app）：

:: 3. 备份原文件
echo [1/5] 备份原配置文件...
copy "vite.config.js" "vite.config.bak" > nul
copy "api\proxy.js" "api\proxy.bak" > nul
if exist "test-api.bat" copy "test-api.bat" "test-api.bak" > nul

:: 4. 修改 vite.config.js 中的 proxy target
echo [2/5] 修改 vite.config.js 本地代理地址...
powershell -Command "(Get-Content vite.config.js) -replace 'target: ''[^'']*''', 'target: ''!new_proxy!''' | Set-Content vite.config.js"

:: 5. 修改 api/proxy.js 中的 baseUrl
echo [3/5] 修改 api/proxy.js 服务端转发地址...
powershell -Command "(Get-Content api\proxy.js) -replace 'const baseUrl = ''[^'']*''', 'const baseUrl = ''!new_baseurl!''' | Set-Content api\proxy.js"

:: 6. 修改 test-api.bat 中的 BASE_URL（如果存在）
if exist "test-api.bat" (
    echo [4/5] 修改 test-api.bat 测试地址...
    powershell -Command "(Get-Content test-api.bat) -replace 'const BASE_URL = ''[^'']*''', 'const BASE_URL = ''!new_testurl!''' | Set-Content test-api.bat"
)

:: 7. 完成提示
echo [5/5] 所有 API 地址修改完成！
echo - 本地代理地址：!new_proxy!
echo - 服务端转发地址：!new_baseurl!
echo - 测试接口地址：!new_testurl!
echo - 原文件已备份为 .bak 后缀
echo ======================================

pause