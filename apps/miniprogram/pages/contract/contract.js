const api = require('../../utils/api');
const config = require('../../utils/config');

Page({
  data: {
    token: '',
    loading: false,
    error: '',
    doc: null,
    webUrl: '',
  },
  onLoad(query) {
    if (query.token) {
      this.setData({ token: query.token });
      this.loadDoc(query.token);
    }
  },
  onToken(e) { this.setData({ token: e.detail.value }); },
  async open() {
    const token = (this.data.token || '').trim();
    if (!token) {
      wx.showToast({ title: '请输入 token', icon: 'none' });
      return;
    }
    if (token.startsWith('http')) {
      // Accept full web /d/{token} URLs.
      const m = token.match(/\/d\/([^/?#]+)/);
      if (m) {
        this.setData({ token: decodeURIComponent(m[1]) });
        await this.loadDoc(decodeURIComponent(m[1]));
        return;
      }
      this.setData({ webUrl: token, doc: null });
      return;
    }
    await this.loadDoc(token);
  },
  async loadDoc(token) {
    this.setData({ loading: true, error: '', doc: null });
    const base = getApp().globalData.apiBase || config.API_BASE;
    const webUrl = `${String(base).replace(/\/v1\/?$/, '').replace(/\/$/, '')}/d/${encodeURIComponent(token)}`;
    try {
      const res = await api.getPublicDocument(token);
      const doc = res?.data || res || null;
      this.setData({
        loading: false,
        doc,
        webUrl,
        token,
      });
    } catch (err) {
      this.setData({
        loading: false,
        error: err.message || '无法加载单据',
        webUrl,
        token,
      });
    }
  },
  copyWeb() {
    if (!this.data.webUrl) return;
    wx.setClipboardData({ data: this.data.webUrl });
  },
});
