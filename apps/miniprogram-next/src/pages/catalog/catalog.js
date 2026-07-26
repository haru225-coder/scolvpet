const api = require('../../utils/api');

Page({
  data: {
    slug: '',
    siteTitle: '',
    hamsters: [],
    loading: true,
    error: '',
  },
  onLoad(query) {
    const entry = api.parseEntryQuery(query || {});
    const slug = entry.slug || getApp().globalData.slug;
    this.setData({ slug });
    if (slug) getApp().saveCustomer({ slug });
    this.reload();
  },
  onPullDownRefresh() {
    this.reload().finally(() => wx.stopPullDownRefresh());
  },
  async reload() {
    if (!this.data.slug) {
      this.setData({ loading: false, error: '缺少熊舍路径' });
      return;
    }
    this.setData({ loading: true, error: '' });
    try {
      let siteTitle = '';
      try {
        const siteRes = await api.getSite(this.data.slug);
        const site = (siteRes && siteRes.data) || siteRes || {};
        siteTitle = site.title || site.name || site.slug || this.data.slug;
      } catch (_) {
        siteTitle = this.data.slug;
      }
      const res = await api.getCatalog(this.data.slug);
      const data = (res && res.data) || res || {};
      const raw = data.hamsters || data.items || [];
      const hamsters = (Array.isArray(raw) ? raw : [])
        .map((item) => api.normalizePublicHamster(item))
        .filter(Boolean);
      getApp().saveCustomer({ siteTitle });
      wx.setNavigationBarTitle({ title: siteTitle || '宝宝目录' });
      this.setData({ hamsters, siteTitle, loading: false });
    } catch (err) {
      this.setData({ loading: false, error: err.message || '加载失败' });
    }
  },
  openDetail(e) {
    const id = e.currentTarget.dataset.id;
    if (!id) {
      wx.showToast({ title: '仓鼠信息无效', icon: 'none' });
      return;
    }
    wx.navigateTo({
      url: `/pages/detail/detail?slug=${encodeURIComponent(this.data.slug)}&id=${encodeURIComponent(id)}`,
    });
  },
  goMy() {
    wx.navigateTo({ url: '/pages/my-reservations/my-reservations' });
  },
  onShareAppMessage() {
    return {
      title: `${this.data.siteTitle || '熊舍'} · 在售宝宝`,
      path: `/pages/catalog/catalog?slug=${encodeURIComponent(this.data.slug)}`,
    };
  },
});
