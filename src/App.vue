<template>
  <div class="app-container" :class="theme">
    <!-- 主题切换按钮 -->
    <div class="theme-switch">
      <button @click="switchTheme('light')" :class="{ active: theme === 'light' }">亮色</button>
      <button @click="switchTheme('dark')" :class="{ active: theme === 'dark' }">暗色</button>
      <button @click="switchTheme('auto')" :class="{ active: theme === 'auto' }">跟随系统</button>
    </div>
    <!-- 引入音乐播放器核心组件 -->
    <MusicPlayer />
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue';
import MusicPlayer from './components/MusicPlayer.vue';

// 定义主题状态：light(亮色) / dark(暗色) / auto(跟随系统)
const theme = ref('auto');

// 监听系统主题变化
const systemThemeMedia = window.matchMedia('(prefers-color-scheme: dark)');

// 切换主题方法
const switchTheme = (newTheme) => {
  theme.value = newTheme;
  // 保存主题到本地存储，下次打开自动恢复
  localStorage.setItem('music-player-theme', newTheme);
};

// 初始化主题：优先读取本地存储，没有则跟随系统
onMounted(() => {
  const savedTheme = localStorage.getItem('music-player-theme');
  if (savedTheme) {
    theme.value = savedTheme;
  } else {
    theme.value = 'auto';
  }
  // 监听系统主题变化（仅 auto 模式生效）
  systemThemeMedia.addEventListener('change', updateThemeClass);
  updateThemeClass();
});

// 更新页面主题类名
const updateThemeClass = () => {
  const root = document.documentElement;
  root.classList.remove('light-theme', 'dark-theme');
  if (theme.value === 'dark') {
    root.classList.add('dark-theme');
  } else if (theme.value === 'light') {
    root.classList.add('light-theme');
  } else {
    // auto 模式：跟随系统
    root.classList.add(systemThemeMedia.matches ? 'dark-theme' : 'light-theme');
  }
};

// 监听主题变化，自动更新样式
watch(theme, updateThemeClass);
</script>

<style scoped>
/* 全局基础样式重置 */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  transition: background-color 0.3s ease, color 0.3s ease, border-color 0.3s ease;
}

.app-container {
  min-height: 100vh;
}

/* 主题切换按钮样式 */
.theme-switch {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 999;
  display: flex;
  gap: 8px;
  padding: 8px;
  border-radius: 8px;
  background-color: var(--bg-color-secondary);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.theme-switch button {
  padding: 4px 12px;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  background-color: var(--bg-color);
  color: var(--text-color);
  cursor: pointer;
  font-size: 14px;
}

.theme-switch button.active {
  background-color: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

/* 定义亮色主题变量 */
:root.light-theme {
  --bg-color: #ffffff;
  --bg-color-secondary: #f5f5f5;
  --text-color: #333333;
  --border-color: #e0e0e0;
  --primary-color: #e74c3c;
  --hover-color: #f9f9f9;
}

/* 定义暗色主题变量 */
:root.dark-theme {
  --bg-color: #1a1a1a;
  --bg-color-secondary: #2d2d2d;
  --text-color: #f0f0f0;
  --border-color: #444444;
  --primary-color: #ff6b6b;
  --hover-color: #333333;
}

/* 全局样式穿透：让子组件使用主题变量 */
:deep(body) {
  background-color: var(--bg-color);
  color: var(--text-color);
  font-family: "Microsoft YaHei", Arial, Helvetica, sans-serif;
}

:deep(.music-player) {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px 10px;
}

/* 子组件样式适配（穿透到 MusicPlayer.vue） */
:deep(.modal-content) {
  background-color: var(--bg-color);
  border-color: var(--border-color);
}

:deep(.song-item:hover), :deep(.play-item:hover) {
  background-color: var(--hover-color);
}

:deep(.play-item.active) {
  background-color: var(--primary-color);
  color: white;
}

:deep(.control-bar button) {
  background-color: var(--bg-color);
  border-color: var(--border-color);
  color: var(--text-color);
}
</style>