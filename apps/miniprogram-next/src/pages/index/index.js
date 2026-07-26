const api = require('../../utils/api');

Page({
  data: {
    slug: '',
    phone: '',
    wechat: '',
    autoEntering: false,
    hint: '扫宠舍小程序码可自动进入；也可手动输入公开路径。',
  },
  onLoad(query) {
    const app = getApp();
    const entry = api.parseEntryQuery(query || {});
    const launch = app._launchEntry || {};
    const slug = entry.slug || launch.slug || app.globalData.slug || '';
    const hamsterId = entry.hamsterId || launch.hamsterId || '';
    this.setData({
      slug,
      phone: app.globalData.phone || '',
      wechat: app.globalData.wechat || '',
    });
    if (slug) {
      app.saveCustomer({ slug });
      // Direct entry: go catalog or detail
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
  },
  onShow() {
    if (this.data.autoEntering) return;
    const app = getApp();
    this.setData({
      slug: app.globalData.slug || this.data.slug || '',
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
    const slug = this.data.slug.trim();
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
