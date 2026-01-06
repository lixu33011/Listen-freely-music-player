@echo off
chcp 65001 > nul
echo ======================================
echo  网易云音乐播放器 - 项目初始化脚本
echo ======================================

:: 1. 创建项目目录结构
echo [1/6] 创建目录结构...
mkdir music-player-frontend
cd music-player-frontend
mkdir src
mkdir src\api
mkdir src\utils
mkdir src\components
mkdir api

:: 2. 生成 package.json
echo [2/6] 生成 package.json...
(
echo {
echo   "name": "music-player-frontend",
echo   "private": true,
echo   "version": "1.0.0",
echo   "type": "module",
echo   "scripts": {
echo     "dev": "vite",
echo     "build": "vite build",
echo     "preview": "vite preview",
echo     "vercel-build": "npm run build"
echo   },
echo   "dependencies": {
echo     "axios": "^1.4.0",
echo     "vue": "^3.3.4"
echo   },
echo   "devDependencies": {
echo     "@vitejs/plugin-vue": "^4.2.3",
echo     "vite": "^4.4.5"
echo   },
echo   "engines": {
echo     "node": ">=16.x"
echo   }
echo }
) > package.json

:: 3. 生成 vite.config.js
echo [3/6] 生成 vite.config.js...
(
echo import { defineConfig } from 'vite'
echo import vue from '@vitejs/plugin-vue'
echo 
echo export default defineConfig({
echo   plugins: [vue()],
echo   base: '/',
echo   server: {}
echo })
) > vite.config.js

:: 4. 生成 vercel.json
echo [4/6] 生成 vercel.json...
(
echo {
echo   "version": 2,
echo   "builds": [
echo     {
echo       "src": "package.json",
echo       "use": "@vercel/static-build",
echo       "config": {
echo         "distDir": "dist"
echo       }
echo     },
echo     {
echo       "src": "api/**/*.js",
echo       "use": "@vercel/node"
echo     }
echo   ],
echo   "routes": [
echo     {
echo       "src": "/(.*)",
echo       "dest": "/index.html",
echo       "conditions": [
echo         { "mime": "text/html" }
echo       ]
echo     },
echo     {
echo       "src": "/api/(.*)",
echo       "dest": "/api/proxy.js?$1"
echo     }
echo   ],
echo   "headers": [
echo     {
echo       "source": "/api/(.*)",
echo       "headers": [
echo         { "key": "Access-Control-Allow-Origin", "*" },
echo         { "key": "Access-Control-Allow-Methods", "GET,POST,OPTIONS" },
echo         { "key": "Access-Control-Allow-Headers", "Content-Type" }
echo       ]
echo     }
echo   ]
echo }
) > vercel.json

:: 5. 生成 src 目录文件
echo [5/6] 生成 src 目录文件...

:: 5.1 src/utils/request.js
(
echo import axios from 'axios'
echo 
echo const request = axios.create({
echo   baseURL: '/api',
echo   timeout: 5000
echo })
echo 
echo request.interceptors.response.use(
echo   res => res.data,
echo   err => Promise.reject(err)
echo )
echo 
echo export default request
) > src\utils\request.js

:: 5.2 src/api/music.js
(
echo import request from '../utils/request'
echo 
echo // 搜索歌曲
echo export const searchSong = (keywords) => {
echo   return request({
echo     url: '/search',
echo     params: { keywords, type: 1 }
echo   })
echo }
echo 
echo // 获取歌曲播放链接
echo export const getSongUrl = (id) => {
echo   return request({
echo     url: '/song/url',
echo     params: { id }
echo   })
echo }
echo 
echo // 获取歌词
echo export const getLyric = (id) => {
echo   return request({
echo     url: '/lyric',
echo     params: { id }
echo   })
echo }
echo 
echo // 获取歌曲详情（封面）
echo export const getSongDetail = (ids) => {
echo   return request({
echo     url: '/song/detail',
echo     params: { ids }
echo   })
echo }
echo 
echo // 收藏/取消收藏歌曲
echo export const toggleLikeSong = (pid, tracks, op) => {
echo   return request({
echo     url: '/playlist/tracks',
echo     method: 'POST',
echo     params: { op, pid, tracks }
echo   })
echo }
echo 
echo // 获取用户歌单
echo export const getMyLikePlaylist = (uid) => {
echo   return request({
echo     url: '/user/playlist',
echo     params: { uid }
echo   })
echo }
echo 
echo // 获取验证码
echo export const getCaptcha = (phone) => {
echo   return request({
echo     url: '/captcha/sent',
echo     params: { phone }
echo   })
echo }
echo 
echo // 手机号登录
echo export const loginByPhone = (phone, captcha) => {
echo   return request({
echo     url: '/login/cellphone',
echo     params: { phone, captcha }
echo   })
echo }
echo 
echo // 获取当前登录用户信息
echo export const getUserInfo = () => {
echo   return request({
echo     url: '/user/account'
echo   })
echo }
echo 
echo // 检查歌曲是否收藏
echo export const checkIsLiked = async (songId, likePlaylistId) => {
echo   if (!likePlaylistId) return false
echo   const playlistRes = await request({ url: '/playlist/detail', params: { id: likePlaylistId } })
echo   return playlistRes.playlist.tracks.some(track => track.id === songId)
echo }
) > src\api\music.js

:: 5.3 src/App.vue
(
echo ^<template^>
echo   ^<MusicPlayer /^>
echo ^</template^>
echo 
echo ^<script setup^>
echo import MusicPlayer from './components/MusicPlayer.vue'
echo ^</script^>
echo 
echo ^<style scoped^>
echo * {
echo   margin: 0;
echo   padding: 0;
echo   box-sizing: border-box;
echo }
echo 
echo body {
echo   background-color: #f9f9f9;
echo   font-family: Arial, Helvetica, sans-serif;
echo }
echo ^</style^>
) > src\App.vue

:: 5.4 api/proxy.js
(
echo const axios = require('axios');
echo 
echo module.exports = async (req, res) => {
echo   const baseUrl = 'https://music.163.com/api';
echo   const { path, query } = req;
echo 
echo   // 设置跨域响应头
echo   res.setHeader('Access-Control-Allow-Origin', '*');
echo   res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
echo   res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
echo 
echo   if (req.method === 'OPTIONS') {
echo     res.status(200).end();
echo     return;
echo   }
echo 
echo   try {
echo     const response = await axios({
echo       method: req.method,
echo       url: `${baseUrl}${path}`,
echo       params: query,
echo       data: req.body,
echo       headers: {
echo         'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/118.0.0.0 Safari/537.36',
echo         'Referer': 'https://music.163.com/'
echo       }
echo     });
echo     res.status(200).json(response.data);
echo   } catch (error) {
echo     res.status(500).json({ error: 'Proxy request failed', msg: error.message });
echo   }
echo };
) > api\proxy.js

:: 6. 提示复制核心组件
echo [6/6] 请手动将 MusicPlayer.vue 完整代码复制到 src\components\ 目录下！

:: 7. 安装依赖
echo [7/7] 安装项目依赖...
npm install

echo ======================================
echo  项目初始化完成！
echo  启动命令：cd music-player-frontend && npm run dev
echo ======================================
pause