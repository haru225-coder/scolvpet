const config = require('./utils/config');
const api = require('./utils/api');
const wechatLogin = require('./utils/wechat_login');

App({
  globalData: {
    apiBase: config.API_BASE,
    slug: '',
    phone: '',
    wechat: '',
    customerToken: '',
    siteTitle: '',
    // In-memory only (never persisted): one-shot bind ticket from wechat-sessions.
    wechatTicket: '',
    wechatTicketObtainedAt: 0,
  },
  onLaunch(options) {
    config.assertRuntimeConfig();
    try {
      const stored = wx.getStorageSync('scolvpet_customer') || {};
      if (stored.phone) this.globalData.phone = stored.phone;
      if (stored.wechat) this.globalData.wechat = stored.wechat;
      if (stored.slug) this.globalData.slug = stored.slug;
      if (stored.customerToken) this.globalData.customerToken = stored.customerToken;
      if (stored.siteTitle) this.globalData.siteTitle = stored.siteTitle;
    } catch (_) {
      // ignore
    }
    // Deep link from 小程序码 / share query
    const entry = api.parseEntryQuery((options && options.query) || {});
    if (entry.slug) {
      this.globalData.slug = entry.slug;
      try {
        this.saveCustomer({ slug: entry.slug });
      } catch (_) {
        // ignore
      }
    }
    this._launchEntry = entry;
    // P2-3 静默微信登录：有缓存 token 维持现状；任何失败都无感降级到短信流程。
    this._silentLoginPromise = this.silentWechatLogin();
  },
  silentWechatLogin() {
    if (this.globalData.customerToken) {
      return Promise.resolve({ state: 'session', cached: true });
    }
    return wechatLogin.performSilentLogin({
      wxLogin: () =>
        new Promise((resolve) => {
          wx.login({
            success: (res) => resolve((res && res.code) || ''),
            fail: () => resolve(''),
          });
        }),
      createSession: (jsCode) => api.createWechatSession(jsCode),
      onToken: ({ token, phone }) => {
        const partial = { customerToken: token };
        if (phone) partial.phone = phone;
        this.saveCustomer(partial);
      },
      onTicket: ({ ticket, obtainedAt }) => {
        this.globalData.wechatTicket = ticket;
        this.globalData.wechatTicketObtainedAt = obtainedAt;
      },
    });
  },
  saveCustomer(partial) {
    const next = {
      phone: this.globalData.phone,
      wechat: this.globalData.wechat,
      slug: this.globalData.slug,
      customerToken: this.globalData.customerToken,
      siteTitle: this.globalData.siteTitle,
      ...partial,
    };
    this.globalData.phone = next.phone || '';
    this.globalData.wechat = next.wechat || '';
    this.globalData.slug = next.slug || '';
    this.globalData.customerToken = next.customerToken || '';
    this.globalData.siteTitle = next.siteTitle || '';
    wx.setStorageSync('scolvpet_customer', next);
  },
});
