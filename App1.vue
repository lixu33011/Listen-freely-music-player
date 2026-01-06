<template>
  <!-- 引入音乐播放器核心组件 -->
  <MusicPlayer />
</template>

<script setup>
// 导入播放器组件
import MusicPlayer from './components/MusicPlayer.vue';
</script>

<style scoped>
/* 全局基础样式重置 */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background-color: #f9f9f9;
  font-family: "Microsoft YaHei", Arial, Helvetica, sans-serif;
  color: #333;
  min-height: 100vh;
}

/* 确保播放器容器自适应页面 */
:deep(.music-player) {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px 10px;
}
</style>