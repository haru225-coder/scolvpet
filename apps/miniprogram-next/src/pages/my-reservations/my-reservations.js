const api = require('../../utils/api');
const wechatLogin = require('../../utils/wechat_login');

const STATUS_LABEL = {
  held: '待确认（已锁定）',
  confirmed: '已确认',
  cancelled: '已取消',
  handed_over: '已交付',
};

Page({
  data: {
    phone: '',
    code: '',
    verificationId: '',
    token: '',
    items: [],
    loading: false,
    error: '',
    codeCountdown: 0,
    authorizingPhone: false,
    showSmsFallback: false,
    phoneAuthorizationMessage: '',
  },
  _timer: null,
  onUnload() {
    if (this._timer) clearInterval(this._timer);
  },
  onShow() {
    const app = getApp();
    this.setData({
      phone: app.globalData.phone || '',
      token: app.globalData.customerToken || '',
    });
    if (this.data.token) this.loadList();
  },
  onPhone(e) { this.setData({ phone: e.detail.value }); },
  onCode(e) { this.setData({ code: e.detail.value }); },
  async authorizeAndLoad(e) {
    if (this.data.loading || this.data.authorizingPhone) return;
    const phoneCode = e && e.detail && e.detail.code;
    if (!phoneCode) {
      this.setData({
        showSmsFallback: true,
        phoneAuthorizationMessage: '未获得手机号，请使用短信验证',
      });
      return;
    }
    this.setData({ authorizingPhone: true, phoneAuthorizationMessage: '' });
    try {
      const result = await getApp().authorizeCustomerPhone(phoneCode);
      if (!result || !result.ok) {
        const state = wechatLogin.resolvePhoneAuthorizationState(result || {});
        this.setData({
          showSmsFallback: state.showSmsFallback,
          phoneAuthorizationMessage: state.message,
        });
        return;
      }
      const app = getApp();
      this.setData({
        token: app.globalData.customerToken || '',
        phone: app.globalData.phone || '',
        showSmsFallback: false,
        phoneAuthorizationMessage: '',
      });
      await this.loadList();
    } catch (err) {
      this.setData({ phoneAuthorizationMessage: err.message || '微信手机号授权失败，请重新授权' });
    } finally {
      this.setData({ authorizingPhone: false });
    }
  },
  async sendCode() {
    // Same 60s resend guard as the detail page — every tap past the guard
    // costs a real SMS once the provider is live.
    if (this.data.codeCountdown > 0) return;
    const phone = normalizePhone(this.data.phone);
    if (!phone) {
      wx.showToast({ title: '手机号无效', icon: 'none' });
      return;
    }
    try {
      const res = await api.sendCustomerCode(phone);
      this.setData({
        verificationId: res?.data?.verification_id || '',
        phone,
        codeCountdown: 60,
      });
      wx.showToast({ title: '验证码已发送', icon: 'none' });
      if (this._timer) clearInterval(this._timer);
      this._timer = setInterval(() => {
        const n = this.data.codeCountdown - 1;
        if (n <= 0) {
          clearInterval(this._timer);
          this._timer = null;
          this.setData({ codeCountdown: 0 });
        } else {
          this.setData({ codeCountdown: n });
        }
      }, 1000);
    } catch (err) {
      wx.showToast({ title: err.message || '发送失败', icon: 'none' });
    }
  },
  async loginAndLoad() {
    try {
      const app = getApp();
      let token = this.data.token;
      const phone = normalizePhone(this.data.phone);
      const sessionPhone = normalizePhone(app.globalData.phone || '');
      // If UI phone differs from token phone, force re-auth (no identity illusion).
      if (token && phone && sessionPhone && sessionPhone !== phone) {
        try {
          await api.logoutCustomer(token);
        } catch (_) {
          // best-effort
        }
        token = '';
        this.setData({ token: '', items: [] });
        app.saveCustomer({ customerToken: '' });
      }
      if (!token) {
        if (!this.data.showSmsFallback) {
          wx.showToast({ title: '请先授权微信手机号', icon: 'none' });
          return;
        }
        if (!phone) {
          wx.showToast({ title: '请输入有效手机号', icon: 'none' });
          return;
        }
        const code = (this.data.code || '').trim();
        if (!code || !this.data.verificationId) {
          wx.showToast({ title: '请先完成验证码', icon: 'none' });
          return;
        }
        // 短信备用路径不读取或消费一次性微信 ticket。
        const res = await api.createCustomerSession({
          phone,
          verification_id: this.data.verificationId,
          code,
        });
        token = res?.data?.access_token || '';
        if (!token) throw new Error('登录失败');
        this.setData({ token, phone });
        app.saveCustomer({ phone, customerToken: token });
      }
      await this.loadList();
    } catch (err) {
      this.setData({ error: err.message || '加载失败' });
    }
  },
  async loadList() {
    this.setData({ loading: true, error: '' });
    try {
      const res = await api.listMyReservations(this.data.token);
      const raw = res?.data || [];
      const items = (Array.isArray(raw) ? raw : []).map((item) => ({
        ...item,
        status_label: STATUS_LABEL[item.status] || item.status,
      }));
      this.setData({ items, loading: false });
    } catch (err) {
      const unauthorized = Number(err && err.statusCode) === 401;
      this.setData({
        loading: false,
        error: err.message || '加载失败',
        ...(unauthorized ? { token: '' } : {}),
      });
      if (unauthorized) getApp().saveCustomer({ customerToken: '' });
    }
  },
  async logout() {
    const token = this.data.token;
    if (token) {
      try {
        await api.logoutCustomer(token);
      } catch (_) {
        // still clear local
      }
    }
    this.setData({ token: '', items: [], verificationId: '', code: '' });
    getApp().saveCustomer({ customerToken: '' });
    wx.showToast({ title: '已退出', icon: 'none' });
  },
  async cancelOne(e) {
    const id = e.currentTarget.dataset.id;
    try {
      await api.cancelMyReservation(id, this.data.token);
      wx.showToast({ title: '已取消', icon: 'none' });
      await this.loadList();
    } catch (err) {
      wx.showToast({ title: err.message || '取消失败', icon: 'none' });
    }
  },
  openDoc(e) {
    const token = e.currentTarget.dataset.token;
    if (!token) return;
    wx.navigateTo({
      url: `/pages/contract/contract?token=${encodeURIComponent(token)}`,
    });
  },
});

function normalizePhone(value) {
  const raw = String(value || '').replace(/\s+/g, '');
  if (/^\+86[1][3-9]\d{9}$/.test(raw)) return raw;
  if (/^1[3-9]\d{9}$/.test(raw)) return `+86${raw}`;
  return '';
}
