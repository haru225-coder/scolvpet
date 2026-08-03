const api = require('../../utils/api');
const config = require('../../utils/config');

function resolveDefaultSlug() {
  const fromConfig = (config && config.DEFAULT_PUBLIC_SLUG) || '';
  return String(fromConfig || 'demo').trim();
}

Page({
  data: {
    slug: '',
    phone: '',
    wechat: '',
    autoEntering: false,
    hint: '扫宠舍小程序码可自动进入；也可点下方进入示例熊舍。',
  },
  onLoad(query) {
    const app = getApp();
    const entry = api.parseEntryQuery(query || {});
    const launch = app._launchEntry || {};
    // 场景值 / 启动参数优先；都没有则用配置兜底，避免审核员面对空 slug 表单。
    const slug =
      entry.slug || launch.slug || app.globalData.slug || resolveDefaultSlug();
    const hamsterId = entry.hamsterId || launch.hamsterId || '';
    const fromScene = !!(entry.slug || launch.slug || hamsterId);
    this.setData({
      slug,
      phone: app.globalData.phone || '',
      wechat: app.globalData.wechat || '',
    });
    // 有场景值或已解析到 slug：自动进目录（含默认 demo 兜底）
    if (slug && (fromScene || !entry.slug)) {
      // 无场景值时仍预填默认 slug，但不强制 redirect——让用户看见「进入熊舍」主按钮
      if (fromScene) {
        app.saveCustomer({ slug });
        this.setData({ autoEntering: true });
        if (hamsterId) {
          wx.redirectTo({
            url: `/pages/detail/detail?slug=${encodeURIComponent(slug)}&id=${encodeURIComponent(hamsterId)}`,
          });
        } else {
          wx.redirectTo({
            url: `/pages/catalog/catalog?slug=${encodeURIComponent(slug)}`,
          });
        }
      }
    }
  },
  onShow() {
    if (this.data.autoEntering) return;
    const app = getApp();
    this.setData({
      slug: app.globalData.slug || this.data.slug || resolveDefaultSlug(),
      phone: app.globalData.phone || '',
      wechat: app.globalData.wechat || '',
    });
  },
  onSlug(e) {
    this.setData({ slug: (e.detail.value || '').trim() });
  },
  onPhone(e) {
    this.setData({ phone: (e.detail.value || '').trim() });
  },
  onWechat(e) {
    this.setData({ wechat: (e.detail.value || '').trim() });
  },
  enterCatalog() {
    const slug = (this.data.slug || '').trim() || resolveDefaultSlug();
    if (!slug) {
      wx.showToast({ title: '请输入熊舍路径', icon: 'none' });
      return;
    }
    getApp().saveCustomer({
      slug,
      phone: this.data.phone,
      wechat: this.data.wechat,
    });
    wx.navigateTo({ url: `/pages/catalog/catalog?slug=${encodeURIComponent(slug)}` });
  },
  goMy() {
    wx.navigateTo({ url: '/pages/my-reservations/my-reservations' });
  },
  onShareAppMessage() {
    const slug = this.data.slug || getApp().globalData.slug || '';
    return {
      title: '来看看我们的金丝熊宝宝',
      path: slug ? `/pages/index/index?slug=${encodeURIComponent(slug)}` : '/pages/index/index',
    };
  },
});
