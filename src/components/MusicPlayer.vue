<template>
  <div class="Listen freely-music-player">
    <h2>Listen freely音乐播放器</h2>

    <!-- 登录状态 -->
    <div class="login-status">
      <span v-if="isLogin">欢迎，{{ userInfo.nickname }}</span>
      <button v-else @click="showLoginModal = true">手机号登录</button>
      <button v-if="isLogin" @click="handleLogout">退出登录</button>
    </div>

    <!-- 登录弹窗 -->
    <div class="modal-mask" v-if="showLoginModal">
      <div class="modal-content">
        <h3>手机号登录</h3>
        <div class="form-item">
          <input 
            v-model="loginForm.phone" 
            type="tel" 
            placeholder="请输入手机号"
            maxlength="11"
          />
        </div>
        <div class="form-item">
          <input 
            v-model="loginForm.captcha" 
            type="text" 
            placeholder="请输入验证码"
            maxlength="6"
          />
          <button 
            class="captcha-btn" 
            @click="sendCaptcha"
            :disabled="captchaDisabled"
          >
            {{ captchaText }}
          </button>
        </div>
        <div class="form-btn">
          <button @click="handleLogin">登录</button>
          <button @click="showLoginModal = false">取消</button>
        </div>
      </div>
    </div>

    <!-- 搜索框 -->
    <div class="search-box">
      <input v-model="keywords" placeholder="输入歌曲名搜索" />
      <button @click="handleSearch">搜索</button>
    </div>

    <div class="player-content">
      <!-- 搜索结果列表 -->
      <div class="song-list">
        <div 
          class="song-item" 
          v-for="item in songList" 
          :key="item.id"
          @click="handlePlay(item.id)"
          @dblclick="addToPlayList(item)"
        >
          {{ item.name }} - {{ item.ar[0].name }}
          <span class="add-icon" @click.stop="addToPlayList(item)">+</span>
          <span 
            class="like-icon" 
            :class="{ liked: isLikedMap[item.id] }"
            @click.stop="toggleLike(item.id)"
          >♡</span>
        </div>
      </div>

      <!-- 播放列表 -->
      <div class="play-list">
        <div class="play-list-header">
          <span>播放列表 ({{ playList.length }})</span>
          <button @click="clearPlayList">清空</button>
        </div>
        <div class="play-list-content">
          <div 
            class="play-item" 
            v-for="(item, index) in playList" 
            :key="item.id"
            :class="{ active: currentPlayIndex === index }"
            @click="playByIndex(index)"
          >
            {{ item.name }} - {{ item.ar[0].name }}
            <span class="del-icon" @click.stop="delFromPlayList(index)">×</span>
            <span 
              class="like-icon" 
              :class="{ liked: isLikedMap[item.id] }"
              @click.stop="toggleLike(item.id)"
            >♡</span>
          </div>
        </div>
      </div>

      <!-- 封面+歌词区域（背景图） -->
      <div 
        class="lyric-cover-container"
        :data-cover="currentCover"
      >
        <div class="song-cover">
          <img 
            :src="currentCover" 
            alt="封面" 
            class="cover-img"
            v-if="currentCover"
          />
          <div class="cover-placeholder" v-else>暂无封面</div>
          <span 
            class="current-like-icon"
            :class="{ liked: isLikedMap[currentSongId] }"
            @click.stop="toggleLike(currentSongId)"
            v-if="currentSongId !== -1"
          >♡</span>
        </div>
        <div class="lyric-container" ref="lyricRef">
          <div class="lyric-wrapper">
            <div 
              class="lyric-line" 
              v-for="(line, index) in lyricList" 
              :key="index"
              :class="{ active: currentLyricIndex === index }"
            >
              {{ line.txt }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 播放控制栏 -->
    <div class="control-bar">
      <button @click="playPrev" :disabled="playList.length === 0">上一首</button>
      <button @click="togglePlayPause" :disabled="playList.length === 0">
        {{ isPlaying ? '暂停' : '播放' }}
      </button>
      <button @click="playNext" :disabled="playList.length === 0">下一首</button>
    </div>

    <!-- 音频控件 -->
    <audio 
      ref="audioRef" 
      class="audio-player"
      @timeupdate="handleTimeUpdate"
      @ended="handlePlayEnded"
      @play="isPlaying = true"
      @pause="isPlaying = false"
    />
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue';
import { 
  searchSong, getSongUrl, getLyric, getSongDetail,
  toggleLikeSong, getMyLikePlaylist, checkIsLiked,
  getCaptcha, loginByPhone, getUserInfo
} from '../api/music';

// 登录相关
const isLogin = ref(false);
const userInfo = ref({});
const showLoginModal = ref(false);
const loginForm = ref({ phone: '', captcha: '' });
const captchaDisabled = ref(false);
const captchaText = ref('获取验证码');
const likePlaylistId = ref(0);

// 搜索播放相关
const keywords = ref('');
const songList = ref([]);
const audioRef = ref(null);
const isPlaying = ref(false);
const currentSongId = ref(-1);
const currentCover = ref('');
const lyricRef = ref(null);
const lyricList = ref([]);
const currentLyricIndex = ref(-1);
const playList = ref([]);
const currentPlayIndex = ref(-1);
const isLikedMap = ref({});

// 发送验证码
const sendCaptcha = async () => {
  if (!/^1[3-9]\d{9}$/.test(loginForm.value.phone)) {
    alert('请输入正确的手机号');
    return;
  }
  try {
    await getCaptcha(loginForm.value.phone);
    alert('验证码已发送');
    captchaDisabled.value = true;
    captchaText.value = '60s 后重新获取';
    let count = 60;
    const timer = setInterval(() => {
      count--;
      captchaText.value = `${count}s 后重新获取`;
      if (count <= 0) {
        clearInterval(timer);
        captchaDisabled.value = false;
        captchaText.value = '获取验证码';
      }
    }, 1000);
  } catch (err) {
    alert('发送失败：' + err.message);
  }
};

// 登录
const handleLogin = async () => {
  if (!loginForm.value.phone || !loginForm.value.captcha) {
    alert('请填写手机号和验证码');
    return;
  }
  try {
    await loginByPhone(loginForm.value.phone, loginForm.value.captcha);
    const userRes = await getUserInfo();
    userInfo.value = userRes.profile;
    isLogin.value = true;
    showLoginModal.value = false;
    // 获取喜欢的歌单
    const playlistRes = await getMyLikePlaylist(userInfo.value.userId);
    const likePlaylist = playlistRes.playlist.find(item => item.specialType === 5);
    if (likePlaylist) likePlaylistId.value = likePlaylist.id;
    // 刷新收藏状态
    playList.value.forEach(item => {
      checkIsLiked(item.id, likePlaylistId.value).then(liked => {
        isLikedMap.value[item.id] = liked;
      });
    });
    alert('登录成功！');
  } catch (err) {
    alert('登录失败：' + err.message);
  }
};

// 退出登录
const handleLogout = () => {
  isLogin.value = false;
  userInfo.value = {};
  likePlaylistId.value = 0;
  isLikedMap.value = {};
  alert('已退出登录');
};

// 搜索歌曲
const handleSearch = async () => {
  if (!keywords.value) return;
  const res = await searchSong(keywords.value);
  songList.value = res.result.songs;
  // 检查收藏状态
  if (isLogin.value && likePlaylistId.value) {
    for (const song of songList.value) {
      isLikedMap.value[song.id] = await checkIsLiked(song.id, likePlaylistId.value);
    }
  }
};

// 播放歌曲
const handlePlay = async (id) => {
  const targetSong = songList.value.find(item => item.id === id);
  if (!targetSong) return;
  addToPlayList(targetSong, true);
};

// 添加到播放列表
const addToPlayList = (song, isPlayImmediately = false) => {
  const isExist = playList.value.some(item => item.id === song.id);
  if (!isExist) {
    playList.value.push(song);
    // 检查收藏状态
    if (isLogin.value && likePlaylistId.value) {
      checkIsLiked(song.id, likePlaylistId.value).then(liked => {
        isLikedMap.value[song.id] = liked;
      });
    } else {
      isLikedMap.value[song.id] = false;
    }
  }
  if (isPlayImmediately) {
    const index = playList.value.findIndex(item => item.id === song.id);
    playByIndex(index);
  }
};

// 删除歌曲
const delFromPlayList = (index) => {
  if (index === currentPlayIndex.value) {
    audioRef.value.pause();
    currentSongId.value = -1;
    currentCover.value = '';
    lyricList.value = [];
    currentLyricIndex.value = -1;
    isPlaying.value = false;
  }
  playList.value.splice(index, 1);
  if (index < currentPlayIndex.value) {
    currentPlayIndex.value -= 1;
  }
};

// 清空播放列表
const clearPlayList = () => {
  audioRef.value.pause();
  playList.value = [];
  currentPlayIndex.value = -1;
  currentSongId.value = -1;
  currentCover.value = '';
  lyricList.value = [];
  currentLyricIndex.value = -1;
  isPlaying.value = false;
};

// 按索引播放
const playByIndex = async (index) => {
  if (index < 0 || index >= playList.value.length) return;
  const song = playList.value[index];
  currentPlayIndex.value = index;
  currentSongId.value = song.id;

  // 获取播放链接
  try {
    const urlRes = await getSongUrl(song.id);
    const playUrl = urlRes.data[0].url;
    if (!playUrl) {
      alert('该歌曲暂无播放权限，请登录后重试');
      return;
    }
    audioRef.value.src = playUrl;
    await audioRef.value.play();
  } catch (err) {
    alert('播放失败：' + err.message);
    return;
  }

  // 获取歌词
  const lyricRes = await getLyric(song.id);
  parseLyric(lyricRes.lrc?.lyric || '暂无歌词');

  // 获取封面
  const detailRes = await getSongDetail(song.id);
  currentCover.value = detailRes.songs[0].al.picUrl;
};

// 上一首
const playPrev = () => {
  if (playList.value.length === 0) return;
  let index = currentPlayIndex.value - 1;
  index = index < 0 ? playList.value.length - 1 : index;
  playByIndex(index);
};

// 下一首
const playNext = () => {
  if (playList.value.length === 0) return;
  let index = currentPlayIndex.value + 1;
  index = index >= playList.value.length ? 0 : index;
  playByIndex(index);
};

// 播放暂停切换
const togglePlayPause = () => {
  if (!audioRef.value.src) return;
  if (isPlaying.value) {
    audioRef.value.pause();
  } else {
    audioRef.value.play();
  }
};

// 播放结束切下一首
const handlePlayEnded = () => {
  playNext();
};

// 解析歌词
const parseLyric = (lyricStr) => {
  const lineReg = /\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)/g;
  const lyricArr = [];
  let match;
  while ((match = lineReg.exec(lyricStr)) !== null) {
    const [, min, sec, ms, txt] = match;
    const time = Number(min) * 60 * 1000 + Number(sec) * 1000 + Number(ms.padEnd(3, '0'));
    txt && lyricArr.push({ time, txt });
  }
  lyricList.value = lyricArr.length > 0 ? lyricArr : [{ time: 0, txt: '暂无歌词' }];
  currentLyricIndex.value = -1;
};

// 歌词同步
const handleTimeUpdate = () => {
  if (!lyricList.value.length) return;
  const currentTime = audioRef.value.currentTime * 1000;
  for (let i = 0; i < lyricList.value.length; i++) {
    const line = lyricList.value[i];
    const nextLineTime = lyricList.value[i + 1]?.time || Infinity;
    if (currentTime >= line.time && currentTime < nextLineTime) {
      if (currentLyricIndex.value !== i) {
        currentLyricIndex.value = i;
        scrollToCurrentLyric();
      }
      break;
    }
  }
};

// 歌词滚动
const scrollToCurrentLyric = () => {
  const lyricWrapper = lyricRef.value?.querySelector('.lyric-wrapper');
  const activeLine = lyricRef.value?.querySelector('.lyric-line.active');
  if (lyricWrapper && activeLine) {
    const top = activeLine.offsetTop - lyricWrapper.offsetHeight / 2;
    lyricWrapper.scrollTo({ top, behavior: 'smooth' });
  }
};

// 收藏/取消收藏
const toggleLike = async (songId) => {
  if (!isLogin.value) {
    showLoginModal.value = true;
    return;
  }
  if (!likePlaylistId.value) {
    alert('未找到“我喜欢的音乐”歌单');
    return;
  }
  const currentLiked = isLikedMap.value[songId];
  try {
    await toggleLikeSong(likePlaylistId.value, songId, currentLiked ? 'del' : 'add');
    isLikedMap.value[songId] = !currentLiked;
    alert(currentLiked ? '已取消收藏' : '已添加到我喜欢的音乐');
  } catch (err) {
    alert('收藏操作失败：' + err.message);
  }
};

// 初始化检查登录状态
onMounted(() => {
  getUserInfo().then(res => {
    isLogin.value = true;
    userInfo.value = res.profile;
    getMyLikePlaylist(userInfo.value.userId).then(playlistRes => {
      const likePlaylist = playlistRes.playlist.find(item => item.specialType === 5);
      if (likePlaylist) likePlaylistId.value = likePlaylist.id;
    });
  }).catch(() => {
    console.log('未登录或登录过期');
  });
});

// 监听播放列表长度变化
watch(playList, () => {
  if (currentPlayIndex.value >= playList.value.length && playList.value.length > 0) {
    currentPlayIndex.value = 0;
    playByIndex(0);
  }
});
</script>

<style scoped>
.music-player {
  width: 1200px;
  margin: 50px auto;
  text-align: center;
  font-family: "Microsoft YaHei", sans-serif;
}

.login-status {
  text-align: right;
  margin-bottom: 10px;
}

.login-status button {
  padding: 4px 12px;
  margin-left: 10px;
  cursor: pointer;
  border: 1px solid #ccc;
  border-radius: 4px;
  background: #fff;
}

.modal-mask {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999;
}

.modal-content {
  width: 350px;
  padding: 20px;
  background: #fff;
  border-radius: 8px;
  text-align: center;
}

.form-item {
  margin: 15px 0;
  display: flex;
  gap: 10px;
  justify-content: center;
  align-items: center;
}

.form-item input {
  padding: 8px;
  width: 200px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.captcha-btn {
  padding: 8px 12px;
  cursor: pointer;
  background: #2ecc71;
  color: #fff;
  border: none;
  border-radius: 4px;
}

.captcha-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.form-btn {
  margin-top: 20px;
  display: flex;
  gap: 10px;
  justify-content: center;
}

.form-btn button {
  padding: 8px 20px;
  cursor: pointer;
  border: 1px solid #ccc;
  border-radius: 4px;
  background: #fff;
}

.search-box {
  margin: 20px 0;
}

.search-box input {
  width: 300px;
  padding: 8px;
  border: 1px solid #ccc;
  border-radius: 4px 0 0 4px;
}

.search-box button {
  padding: 8px 12px;
  cursor: pointer;
  border: 1px solid #ccc;
  border-left: none;
  border-radius: 0 4px 4px 0;
  background: #f5f5f5;
}

.player-content {
  display: flex;
  gap: 20px;
  height: 400px;
  margin: 20px 0;
}

.song-list, .play-list {
  width: 280px;
  border: 1px solid #eee;
  border-radius: 8px;
  padding: 10px;
  overflow: hidden;
}

.song-list {
  overflow-y: auto;
}

.play-list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
  padding-bottom: 5px;
  border-bottom: 1px dashed #eee;
}

.play-list-header button {
  font-size: 12px;
  padding: 2px 8px;
  cursor: pointer;
  border: none;
  background: transparent;
  color: #ff4444;
}

.play-list-content {
  height: calc(100% - 30px);
  overflow-y: auto;
}

.song-item, .play-item {
  padding: 8px 10px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-radius: 4px;
  margin-bottom: 5px;
}

.song-item:hover, .play-item:hover {
  background-color: #f5f5f5;
}

.play-item.active {
  background-color: #e3f2fd;
  color: #1976d2;
  font-weight: bold;
}

.add-icon, .del-icon, .like-icon {
  color: #999;
  cursor: pointer;
  font-size: 14px;
  padding: 2px 5px;
}

.add-icon:hover {
  color: #2ecc71;
}

.del-icon:hover {
  color: #e74c3c;
}

.like-icon.liked {
  color: #e74c3c;
}

.lyric-cover-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 15px;
  border: 1px solid #eee;
  border-radius: 8px;
  padding: 10px;
  position: relative;
  z-index: 1;
}

.lyric-cover-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: url('');
  background-size: cover;
  background-position: center;
  opacity: 0.2;
  z-index: -1;
}

.lyric-cover-container[data-cover]::before {
  background-image: v-bind('`url(${currentCover})`');
}

.song-cover {
  height: 180px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  z-index: 2;
}

.cover-img {
  width: 180px;
  height: 180px;
  border-radius: 8px;
  object-fit: cover;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.cover-placeholder {
  width: 180px;
  height: 180px;
  line-height: 180px;
  border: 1px dashed #ccc;
  border-radius: 8px;
  color: #999;
}

.current-like-icon {
  position: absolute;
  bottom: 10px;
  right: 10px;
  font-size: 24px;
  color: #999;
  cursor: pointer;
  z-index: 3;
}

.current-like-icon.liked {
  color: #e74c3c;
}

.lyric-container {
  flex: 1;
  overflow: hidden;
  position: relative;
  z-index: 2;
}

.lyric-wrapper {
  height: 100%;
  overflow-y: auto;
  text-align: center;
}

.lyric-line {
  padding: 8px 0;
  font-size: 16px;
  color: #333;
  text-shadow: 0 0 3px rgba(255,255,255,0.8);
}

.lyric-line.active {
  color: #e74c3c;
  font-weight: bold;
  text-shadow: 0 0 5px rgba(255,255,255,1);
}

.control-bar {
  margin: 10px 0;
}

.control-bar button {
  padding: 8px 16px;
  margin: 0 5px;
  cursor: pointer;
  border: 1px solid #ccc;
  border-radius: 4px;
  background: #fff;
}

.control-bar button:disabled {
  background: #f5f5f5;
  color: #999;
  cursor: not-allowed;
}

.audio-player {
  width: 100%;
  margin-top: 10px;
}
</style>