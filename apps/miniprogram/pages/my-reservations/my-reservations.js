const api = require('../../utils/api');

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
      const phone = normalizePhone(this.data.phone);
      if (!phone) {
        wx.showToast({ title: '请输入有效手机号', icon: 'none' });
        return;
      }
      const app = getApp();
      let token = this.data.token;
      const sessionPhone = normalizePhone(app.globalData.phone || '');
      // If UI phone differs from token phone, force re-auth (no identity illusion).
      if (token && sessionPhone && sessionPhone !== phone) {
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
        const code = (this.data.code || '').trim();
        if (!code || !this.data.verificationId) {
          wx.showToast({ title: '请先完成验证码', icon: 'none' });
          return;
        }
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
      this.setData({ loading: false, error: err.message || '加载失败', token: '' });
      getApp().saveCustomer({ customerToken: '' });
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
