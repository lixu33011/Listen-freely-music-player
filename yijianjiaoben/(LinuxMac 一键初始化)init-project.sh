#!/bin/bash
set -e
echo "======================================"
echo "  网易云音乐播放器 - 项目初始化脚本"
echo "======================================"

# 1. 创建项目目录结构
echo "[1/6] 创建目录结构..."
mkdir -p music-player-frontend/src/{api,utils,components}
mkdir -p music-player-frontend/api
cd music-player-frontend

# 2. 生成 package.json
echo "[2/6] 生成 package.json..."
cat > package.json << EOF
{
  "name": "music-player-frontend",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "vercel-build": "npm run build"
  },
  "dependencies": {
    "axios": "^1.4.0",
    "vue": "^3.3.4"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.2.3",
    "vite": "^4.4.5"
  },
  "engines": {
    "node": ">=16.x"
  }
}
EOF

# 3. 生成 vite.config.js
echo "[3/6] 生成 vite.config.js..."
cat > vite.config.js << EOF
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  base: '/',
  server: {}
})
EOF

# 4. 生成 vercel.json
echo "[4/6] 生成 vercel.json..."
cat > vercel.json << EOF
{
  "version": 2,
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "dist"
      }
    },
    {
      "src": "api/**/*.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.html",
      "conditions": [
        { "mime": "text/html" }
      ]
    },
    {
      "src": "/api/(.*)",
      "dest": "/api/proxy.js?$1"
    }
  ],
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        { "key": "Access-Control-Allow-Origin", "*" },
        { "key": "Access-Control-Allow-Methods", "GET,POST,OPTIONS" },
        { "key": "Access-Control-Allow-Headers", "Content-Type" }
      ]
    }
  ]
}
EOF

# 5. 生成 src 目录文件
echo "[5/6] 生成 src 目录文件..."

# 5.1 src/utils/request.js
cat > src/utils/request.js << EOF
import axios from 'axios'

const request = axios.create({
  baseURL: '/api',
  timeout: 5000
})

request.interceptors.response.use(
  res => res.data,
  err => Promise.reject(err)
)

export default request
EOF

# 5.2 src/api/music.js
cat > src/api/music.js << EOF
import request from '../utils/request'

// 搜索歌曲
export const searchSong = (keywords) => {
  return request({
    url: '/search',
    params: { keywords, type: 1 }
  })
}

// 获取歌曲播放链接
export const getSongUrl = (id) => {
  return request({
    url: '/song/url',
    params: { id }
  })
}

// 获取歌词
export const getLyric = (id) => {
  return request({
    url: '/lyric',
    params: { id }
  })
}

// 获取歌曲详情（封面）
export const getSongDetail = (ids) => {
  return request({
    url: '/song/detail',
    params: { ids }
  })
}

// 收藏/取消收藏歌曲
export const toggleLikeSong = (pid, tracks, op) => {
  return request({
    url: '/playlist/tracks',
    method: 'POST',
    params: { op, pid, tracks }
  })
}

// 获取用户歌单
export const getMyLikePlaylist = (uid) => {
  return request({
    url: '/user/playlist',
    params: { uid }
  })
}

// 获取验证码
export const getCaptcha = (phone) => {
  return request({
    url: '/captcha/sent',
    params: { phone }
  })
}

// 手机号登录
export const loginByPhone = (phone, captcha) => {
  return request({
    url: '/login/cellphone',
    params: { phone, captcha }
  })
}

// 获取当前登录用户信息
export const getUserInfo = () => {
  return request({
    url: '/user/account'
  })
}

// 检查歌曲是否收藏
export const checkIsLiked = async (songId, likePlaylistId) => {
  if (!likePlaylistId) return false
  const playlistRes = await request({ url: '/playlist/detail', params: { id: likePlaylistId } })
  return playlistRes.playlist.tracks.some(track => track.id === songId)
}
EOF

# 5.3 src/App.vue
cat > src/App.vue << EOF
<template>
  <MusicPlayer />
</template>

<script setup>
import MusicPlayer from './components/MusicPlayer.vue'
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background-color: #f9f9f9;
  font-family: Arial, Helvetica, sans-serif;
}
</style>
EOF

# 5.4 api/proxy.js
cat > api/proxy.js << EOF
const axios = require('axios');

module.exports = async (req, res) => {
  const baseUrl = 'https://music.163.com/api';
  const { path, query } = req;

  // 设置跨域响应头
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    const response = await axios({
      method: req.method,
      url: \`\${baseUrl}\${path}\`,
      params: query,
      data: req.body,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/118.0.0.0 Safari/537.36',
        'Referer': 'https://music.163.com/'
      }
    });
    res.status(200).json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Proxy request failed', msg: error.message });
  }
};
EOF

# 6. 提示复制核心组件
echo "[6/6] 请手动将 MusicPlayer.vue 完整代码复制到 src/components/ 目录下！"

# 7. 安装依赖
echo "[7/7] 安装项目依赖..."
npm install

echo "======================================"
echo "  项目初始化完成！"
echo "  启动命令：cd music-player-frontend && npm run dev"
echo "======================================"