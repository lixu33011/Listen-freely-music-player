import request from '../utils/request';

// 搜索歌曲
export const searchSong = (keywords) => {
  return request({
    url: '/search',
    params: { keywords, type: 1 }
  });
};

// 获取歌曲播放链接
export const getSongUrl = (id) => {
  return request({
    url: '/song/url',
    params: { id }
  });
};

// 获取歌词
export const getLyric = (id) => {
  return request({
    url: '/lyric',
    params: { id }
  });
};

// 获取歌曲详情（封面）
export const getSongDetail = (ids) => {
  return request({
    url: '/song/detail',
    params: { ids }
  });
};

// 收藏/取消收藏歌曲
export const toggleLikeSong = (pid, tracks, op) => {
  return request({
    url: '/playlist/tracks',
    method: 'POST',
    params: { op, pid, tracks }
  });
};

// 获取用户歌单
export const getMyLikePlaylist = (uid) => {
  return request({
    url: '/user/playlist',
    params: { uid }
  });
};

// 获取验证码
export const getCaptcha = (phone) => {
  return request({
    url: '/captcha/sent',
    params: { phone }
  });
};

// 手机号登录
export const loginByPhone = (phone, captcha) => {
  return request({
    url: '/login/cellphone',
    params: { phone, captcha }
  });
};

// 获取当前登录用户信息
export const getUserInfo = () => {
  return request({
    url: '/user/account'
  });
};

// 检查歌曲是否收藏
export const checkIsLiked = async (songId, likePlaylistId) => {
  if (!likePlaylistId) return false;
  const playlistRes = await request({ url: '/playlist/detail', params: { id: likePlaylistId } });
  return playlistRes.playlist.tracks.some(track => track.id === songId);
};