**音乐播放器 脚本使用说明文档 **

本文档涵盖项目所有脚本的 用途、适用系统、执行步骤、注意事项，帮助快速完成环境切换、接口测试、项目部署等操作。 脚本名称 用途 适用系统

switch-env.bat/sh 一键切换本地 / Vercel 部署环境 Windows/Linux/Mac

test-api.bat/sh 验证搜索、播放、歌词等核心接口 Windows/Linux/Mac switch-test-url.bat/sh 快速修改测试脚本的 API 地址 Windows/Linux/Mac

vercel-deploy.bat/sh 一键完成 Vercel 线上部署 Windows/Linux/Mac

init-project.bat/sh 自动创建项目目录和基础配置 Windows/Linux/Mac

一、 通用前置要求

已安装 Node.js 16.x 及以上版本（安装时勾选 Add to PATH）。

所有脚本需放在 项目根目录 执行，不可单独移动到其他文件夹。

Linux/Mac 系统需先给脚本添加可执行权限，命令：

bash

chmod +x 脚本名.sh

二、 分脚本详细使用说明

    环境切换脚本 switch-env.bat/sh

用途

自动修改 vite.config.js，切换本地开发环境（开启 API 代理）和 Vercel 线上环境（关闭代理，使用服务端函数）。

执行步骤

Windows 系统

双击根目录下的 switch-env.bat。

终端弹出后，输入 1 切换本地环境，输入 2 切换线上环境，按回车确认。 看到 环境切换完成 提示即表示成功。

Linux/Mac 系统

打开终端，进入项目根目录。

执行命令：./switch-env.sh。

输入 1 或 2 按回车，等待提示完成。

注意事项

脚本会直接覆盖 vite.config.js，若该文件有自定义配置，需先备份。

切换环境后，需重启本地服务（npm run dev）才能生效。

    接口测试脚本 test-api.bat/sh

用途

自动检测 Node.js、Axios 依赖，验证播放器核心接口是否正常，包括：基础连通性、搜索歌曲、获取播放链接、获取歌词。

执行步骤

Windows 系统

确保本地服务已启动（npm run dev），或 Vercel 已部署成功。

双击 test-api.bat，脚本会自动检查环境和依赖。

终端输出 ✅ 代表接口正常，⚠️ 代表部分功能需登录，❌ 代表接口异常。

Linux/Mac 系统

启动本地服务或确认 Vercel 地址可访问。

终端执行命令：./test-api.sh。

查看终端输出结果。

注意事项

首次执行会自动安装 Axios 依赖，需保持网络畅通。

测试 Vercel 环境时，需先修改脚本内的 BASE_URL 为线上域名（参考「测试地址替换脚本」）。

播放链接获取失败（⚠️）属于正常现象，部分歌曲需登录网易云账号后才能播放。

    测试地址替换脚本 switch-test-url.bat/sh

用途

无需手动修改 test-api.bat/sh 代码，快速切换测试地址（本地 http://localhost:5173 或 Vercel 线上域名）。

执行步骤

Windows 系统

双击 switch-test-url.bat。

终端提示输入测试地址，例如输入 https://dream-music.vercel.app，按回车。

看到地址更新成功提示即可。

Linux/Mac 系统

终端执行命令：./switch-test-url.sh。

输入测试地址，按回车确认。

注意事项

输入地址时不要带引号，直接输入完整 URL（如 http://localhost:5173）。

该脚本仅修改测试脚本的地址，不影响项目实际运行的 API 配置。

    Vercel 一键部署脚本 vercel-deploy.bat/sh

用途

自动完成 Vercel CLI 安装、账号登录、环境切换、项目部署，无需手动执行多条命令。

执行步骤

Windows 系统

双击 vercel-deploy.bat，脚本会先检查 Node.js 环境。

自动安装 Vercel CLI，然后弹出登录提示（建议选择邮箱登录） 。

登录成功后，脚本会自动切换到线上环境，开始部署。

部署完成后，终端会输出线上访问地址（格式：https://xxx.vercel.app）。

Linux/Mac 系统

终端执行命令：./vercel-deploy.sh。

按照提示完成 Vercel 登录，等待部署完成。

注意事项

首次登录 Vercel 需要在浏览器中完成验证，需保持网络畅通。

若已安装 Vercel CLI，脚本会跳过安装步骤；若版本过旧，建议手动更新：npm update -g vercel。

部署时若提示选择项目，直接按回车使用默认设置即可。

    项目一键初始化脚本 init-project.bat/sh

用途

自动创建项目目录结构、生成基础配置文件（package.json/vite.config.js/vercel.json），并安装依赖，无需手动创建文件。

执行步骤

Windows 系统

新建一个空文件夹，将 init-project.bat 放入该文件夹。

双击脚本，自动创建 music-player-frontend 项目目录。

等待依赖安装完成，终端提示 项目初始化完成 即可。

Linux/Mac 系统

新建空文件夹，将 init-project.sh 放入该文件夹。

终端进入该文件夹，执行命令：chmod +x init-project.sh && ./init-project.sh。

等待目录创建和依赖安装完成。

注意事项

脚本执行完成后，需手动将核心代码（如 MusicPlayer.vue/api/proxy.js）复制到对应目录。

依赖安装时间取决于网络速度，若安装失败，可进入项目目录手动执行 npm install。

三、 常见问题解决

脚本执行提示「权限不足」（Linux/Mac）→ 执行命令给脚本添加可执行权限：chmod +x 脚本名.sh

Vercel 部署后接口 404→ 检查 vercel.json 的 routes 配置是否正确，确保 /api 路径指向 api/proxy.js

本地测试提示「连接拒绝」→ 确保本地服务已启动（npm run dev），且测试地址为 http://localhost:5173

依赖安装失败→ 切换 npm 镜像源：npm config set registry https://registry.npmmirror.com，然后重新执行脚本
邀请
客
服
