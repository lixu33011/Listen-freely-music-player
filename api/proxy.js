// api/proxy.js
module.exports = async (req, res) => {
  // 允许跨域（与 vercel.json 的 headers 配置呼应）
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // 处理 OPTIONS 预检请求
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // 解析 URL 路径参数（对应 /api/xxx 中的 xxx）
  const { pathname } = new URL(req.url, `http://${req.headers.host}`);
  const pathSegments = pathname.replace(/^\/api\//, '').split('/');
  const resource = pathSegments[0] || 'default';

  try {
    // 根据不同的路径逻辑处理请求
    switch (resource) {
      case 'hello':
        return res.status(200).json({ message: 'Hello from proxy API!' });
      case 'data':
        return res.status(200).json({ data: 'Sample proxy data' });
      default:
        return res.status(404).json({ error: 'Resource not found' });
    }
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};
