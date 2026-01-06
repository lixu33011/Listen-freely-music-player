const axios = require('axios');

module.exports = async (req, res) => {
  const baseUrl = 'https://mi.330115558.xyz';
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
      url: `${baseUrl}${path}`,
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