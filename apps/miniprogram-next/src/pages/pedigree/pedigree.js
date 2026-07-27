const api = require('../../utils/api');
const { buildPedigreeRows } = require('../../utils/pedigree');

Page({
  data: {
    slug: '',
    hamsterId: '',
    title: '',
    note: '',
    loading: true,
    error: '',
    rows: [],
  },
  onLoad(query) {
    const entry = api.parseEntryQuery(query || {});
    this.setData({
      slug: entry.slug || query.slug || getApp().globalData.slug,
      hamsterId: entry.hamsterId || query.id || '',
    });
    this.reload();
  },
  async reload() {
    this.setData({ loading: true, error: '' });
    try {
      const res = await api.getPublicPedigree(this.data.slug, this.data.hamsterId, 3);
      const data = (res && res.data) || res || {};
      this.setData({
        loading: false,
        title: data.root_public_name || '血统档案',
        note: data.note || '',
        rows: buildPedigreeRows(data, this.data.hamsterId),
      });
      wx.setNavigationBarTitle({ title: '血统 · ' + (data.root_public_name || '') });
    } catch (err) {
      this.setData({ loading: false, error: err.message || '血统加载失败' });
    }
  },
  // 公开祖先可点:以该祖先为根重新浏览谱系(navigateTo 保留返回栈)
  onNode(e) {
    const { id, tappable } = e.currentTarget.dataset;
    if (!tappable || !id || id === this.data.hamsterId) return;
    wx.navigateTo({
      url: `/pages/pedigree/pedigree?slug=${encodeURIComponent(this.data.slug)}&id=${encodeURIComponent(id)}`,
    });
  },
  onShareAppMessage() {
    return {
      title: `${this.data.title || '血统'} · 专业谱系`,
      path: `/pages/pedigree/pedigree?slug=${encodeURIComponent(this.data.slug)}&id=${encodeURIComponent(this.data.hamsterId)}`,
    };
  },
});
