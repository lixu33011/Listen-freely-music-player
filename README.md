音乐播放器 本地 & Vercel 部署教程

一、 前置准备

安装工具

安装 Node.js（版本 ≥16.x），安装时勾选 Add to PATH

注册 Vercel 账号（邮箱 / 手机号均可）

Linux/Mac 系统需确保 Git 已安装（可选，用于仓库部署）

获取项目文件

将项目完整文件包解压到本地，得到 music-player-frontend 目录

确认目录内包含核心代码、脚本文件、配置文件

二、 本地部署步骤（开发调试）

步骤 1：初始化项目

打开终端（Windows 用 CMD/PowerShell，Linux/Mac 用终端）

进入项目根目录

bash cd 你的文件路径/music-player-frontend 安装项目依赖 bash npm install 等待终端显示 added xxx packages 即安装成功 步骤 2：切换到本地开发环境 Windows 系统：双击根目录下的 switch-env.bat，输入 1 后回车 Linux/Mac 系统：终端执行以下命令 bash chmod +x switch-env.sh ./switch-env.sh

输入 1 后回车
看到 环境切换完成！当前为【本地开发环境】 提示即可
步骤 3：启动本地服务
在项目根目录执行启动命令
bash
npm run dev
终端会输出本地访问地址，默认是 http://localhost:5173
打开浏览器访问该地址，即可使用播放器功能（搜索、播放、收藏）
步骤 4：本地接口测试（可选）
保持本地服务运行，新开一个终端窗口
Windows 系统：双击根目录下的 test-api.bat
Linux/Mac 系统：终端执行以下命令
bash
chmod +x test-api.sh
./test-api.sh

终端输出 ✅ 代表接口正常，⚠️ 代表部分功能需登录，❌ 代表接口异常

三、 Vercel 部署步骤（线上发布）

方式 1：使用 Vercel CLI 部署（推荐）

步骤 1：安装 Vercel CLI

在终端执行全局安装命令

[bash
npm install -g vercel
步骤 2：切换到线上部署环境
Windows 系统：双击 switch-env.bat，输入 2 后回车
Linux/Mac 系统：终端执行 ./switch-env.sh，输入 2 后回车
提示 当前为【Vercel 线上环境】 即切换成功
步骤 3：登录 Vercel 账号
终端执行登录命令
bash
vercel login]
选择登录方式（推荐邮箱），按照提示在浏览器完成验证
登录成功后终端会显示你的账号信息

步骤 4：一键部署项目

确保在项目根目录，执行部署命令
bash
vercel --prod
首次部署时按提示选择配置：
Set up and deploy? → 输入 y
Which scope? → 选择你的账号
Link to existing project? → 输入 n
Project name → 输入自定义名称或直接回车
Root directory → 直接回车（默认根目录）
等待部署完成，终端会输出线上访问地址（格式：https://项目名.vercel.app）
打开该地址，即可在公网访问你的播放器
方式 2：使用 GitHub 仓库部署（适合持续更新）
步骤 1：上传项目到 GitHub
在 GitHub 新建一个公开仓库（如 dream-music-player）
本地项目根目录执行 Git 命令
bash
git init
git add .
git commit -m "init music player"
git remote add origin https://github.com/你的账号/仓库名.git
git push -u origin main
步骤 2：Vercel 关联仓库部署
登录 Vercel 官网，点击右上角 New Project
选择 Import Git Repository，找到你上传的仓库并点击 Import
配置部署选项：
Framework Preset → 选择 Vue.js
Root Directory → 留空
点击 Deploy 开始部署

部署完成后，Vercel 会自动生成线上访问地址
四、 常见问题排查

本地启动报错：Cannot find module 'axios' → 重新执行 npm install，确保依赖安装完整

Vercel 部署后接口 404 → 检查 vercel.json 的 routes 配置，确保 /api 路径指向 api/proxy.js 播放链接获取失败（⚠️ 提示）

→ 部分歌曲需登录网易云账号，在播放器页面完成手机号登录即可 Linux/Mac 脚本提示「权限不足」

→ 执行命令给脚本添加权限：chmod +x 脚本名.sh 跨域错误（CORS）

→ 本地部署检查 vite.config.js 的 proxy 配置；线上部署检查 vercel.json 的跨域 headers 配置
前端 API 地址如何修改

2026 年 1 月 6 日•内容由 AI 生成，不能完全保障真实 这个前端api地址修改在什么地方

前端 API 地址的修改位置，分两种场景，对应不同的配置文件，具体如下：

一、 本地开发环境（用 vite.config.js 代理） 如果是本地运行 npm run dev 测试，API 地址是通过 vite.config.js 的 proxy 配置转发的。修改位置：项目根目录的 vite.config.js 文件

javascript
export default defineConfig({
  plugins: [vue()],
  base: '/',
  server: {
    proxy: {
      // 这里的 target 就是实际要请求的网易云 API 地址
      '/api': {
        target: 'https://music.163.com/api', // 改这里！
        changeOrigin: true,
        rewrite: path => path.replace(/^\/api/, '')
      }
    }
  }
})

二、 Vercel 部署环境（用服务端函数代理）

部署到 Vercel 后，前端请求的是 Vercel 的服务端函数 api/proxy.js，不需要改前端代码， 只需要修改 proxy.js 里的源地址：修改位置：项目根目录 api/proxy.js 文件

**javascript
module.exports = async (req, res) => {
  // 这里的 baseUrl 是转发的目标地址
  const baseUrl = 'https://music.163.com/api'; // 改这里！
  // ... 其他代码
}**

三、 接口测试脚本的地址修改

[你之前要的 test-api.bat/sh 测试脚本，API 地址在临时生成的 test-temp.js 里：
javascript
// 测试地址（本地/Vercel 二选一）
const BASE_URL = 'http://localhost:5173'; // 本地测试用这个
// const BASE_URL = 'https://你的vercel域名'; // 部署后测试用这个]`
