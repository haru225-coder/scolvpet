const api = require('../../utils/api');
const wechatLogin = require('../../utils/wechat_login');

function hamsterIdOf(item) {
  if (!item || typeof item !== 'object') return '';
  return String(item.hamster_id || item.id || '').trim();
}

Page({
  data: {
    slug: '',
    hamsterId: '',
    hamster: null,
    mates: [],
    mateId: '',
    name: '',
    phone: '',
    wechat: '',
    notes: '',
    code: '',
    verificationId: '',
    customerToken: '',
    busy: false,
    authorizingPhone: false,
    showSmsFallback: false,
    phoneAuthorizationMessage: '',
    codeCountdown: 0,
    reservable: true,
  },
  _timer: null,
  onLoad(query) {
    const app = getApp();
    const entry = api.parseEntryQuery(query || {});
    this.setData({
      slug: entry.slug || query.slug || app.globalData.slug,
      hamsterId: entry.hamsterId || query.id || '',
      phone: app.globalData.phone || '',
      wechat: app.globalData.wechat || '',
      customerToken: app.globalData.customerToken || '',
    });
    this.loadCatalogItem();
  },
  onShow() {
    // 静默登录在 onLoad 之后才完成时，回来同步 token（wxml 据此隐藏验证码区块）。
    const app = getApp();
    if (!this.data.customerToken && app.globalData.customerToken) {
      this.setData({
        customerToken: app.globalData.customerToken,
        phone: this.data.phone || app.globalData.phone || '',
      });
    }
  },
  onUnload() {
    if (this._timer) clearInterval(this._timer);
  },
  async loadCatalogItem() {
    try {
      const res = await api.getCatalog(this.data.slug);
      const data = (res && res.data) || res || {};
      const hamsters = (data.hamsters || data.items || [])
        .map((h) => api.normalizePublicHamster(h))
        .filter(Boolean);
      const hamster =
        hamsters.find((h) => hamsterIdOf(h) === this.data.hamsterId) || {
          hamster_id: this.data.hamsterId,
          public_name: '仓鼠',
          reservable: false,
          traits: [],
        };
      const mates = hamsters.filter((h) => h.hamster_id !== hamster.hamster_id);
      this.setData({
        hamster,
        hamsterId: hamsterIdOf(hamster) || this.data.hamsterId,
        reservable: hamster.reservable !== false,
        mates,
        mateId: mates[0] ? mates[0].hamster_id : '',
      });
      wx.setNavigationBarTitle({ title: hamster.public_name || '宝宝详情' });
    } catch (err) {
      this.setData({
        hamster: { hamster_id: this.data.hamsterId, public_name: '仓鼠', reservable: false, traits: [] },
        reservable: false,
      });
    }
  },
  onName(e) {
    this.setData({ name: e.detail.value });
  },
  onPhone(e) {
    this.setData({ phone: e.detail.value });
  },
  onWechat(e) {
    this.setData({ wechat: e.detail.value });
  },
  onNotes(e) {
    this.setData({ notes: e.detail.value });
  },
  onCode(e) {
    this.setData({ code: e.detail.value });
  },
  async authorizeAndSubmit(e) {
    if (this.data.busy || this.data.authorizingPhone) return;
    const phoneCode = e && e.detail && e.detail.code;
    if (!phoneCode) {
      this.setData({
        showSmsFallback: true,
        phoneAuthorizationMessage: '未获得手机号，无法确认预约，请使用短信验证',
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
        customerToken: app.globalData.customerToken || '',
        phone: app.globalData.phone || '',
        showSmsFallback: false,
        phoneAuthorizationMessage: '',
      });
      await this.submit();
    } catch (err) {
      this.setData({ phoneAuthorizationMessage: err.message || '微信手机号授权失败，请重新授权' });
    } finally {
      this.setData({ authorizingPhone: false });
    }
  },
  onMateChange(e) {
    const idx = Number(e.detail.value || 0);
    const mate = this.data.mates[idx];
    this.setData({ mateId: mate ? mate.hamster_id : '' });
  },
  openPedigree() {
    const { slug, hamsterId } = this.data;
    wx.navigateTo({
      url: `/pages/pedigree/pedigree?slug=${encodeURIComponent(slug)}&id=${encodeURIComponent(hamsterId)}`,
    });
  },
  openSimulate() {
    const { slug, hamsterId, mateId } = this.data;
    let url = `/pages/simulate/simulate?slug=${encodeURIComponent(slug)}&self=${encodeURIComponent(hamsterId)}`;
    if (mateId) url += `&mate=${encodeURIComponent(mateId)}`;
    wx.navigateTo({ url });
  },
  async sendCode() {
    // Guard must read the same field the countdown writes, or resend is never
    // actually blocked and every tap costs a real SMS once the provider is live.
    if (this.data.codeCountdown > 0) return;
    const phone = normalizePhone(this.data.phone);
    if (!phone) {
      wx.showToast({ title: '请先填有效手机号', icon: 'none' });
      return;
    }
    try {
      const res = await api.sendCustomerCode(phone);
      const verificationId = res?.data?.verification_id || res?.verification_id || '';
      this.setData({ verificationId, phone, codeCountdown: 60 });
      getApp().saveCustomer({ phone });
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
  async ensureCustomerSession() {
    const phone = normalizePhone(this.data.phone);
    const app = getApp();
    if (
      this.data.customerToken &&
      app.globalData.phone &&
      normalizePhone(app.globalData.phone) === phone
    ) {
      return this.data.customerToken;
    }
    if (this.data.customerToken && normalizePhone(app.globalData.phone) !== phone) {
      try {
        await api.logoutCustomer(this.data.customerToken);
      } catch (_) {
        // best-effort
      }
      this.setData({ customerToken: '' });
      app.saveCustomer({ customerToken: '' });
    }
    const code = (this.data.code || '').trim();
    const verificationId = this.data.verificationId;
    if (!phone || !code || !verificationId) {
      throw new Error('请先获取并填写短信验证码');
    }
    // 短信是微信手机号授权不可用时的独立后备路径：只创建 Customer
    // Session，绝不读取或消费 wx.login 的一次性 ticket。
    const res = await api.createCustomerSession({
      phone,
      verification_id: verificationId,
      code,
    });
    const token = res?.data?.access_token || res?.access_token || '';
    if (!token) throw new Error('登录失败，请重试');
    this.setData({ customerToken: token, phone });
    app.saveCustomer({ phone, customerToken: token });
    return token;
  },
  async submit() {
    if (this.data.busy) return;
    if (!this.data.reservable) {
      wx.showToast({ title: '当前不可预订', icon: 'none' });
      return;
    }
    const name = (this.data.name || '').trim();
    const phone = normalizePhone(this.data.phone);
    const wechat = (this.data.wechat || '').trim();
    const hamsterId = (this.data.hamsterId || '').trim();
    if (!hamsterId) {
      wx.showToast({ title: '仓鼠 ID 无效', icon: 'none' });
      return;
    }
    if (!name) {
      wx.showToast({ title: '请填写称呼', icon: 'none' });
      return;
    }
    if (!this.data.customerToken && !this.data.showSmsFallback) {
      wx.showToast({ title: '请先授权微信手机号', icon: 'none' });
      return;
    }
    if (!phone) {
      wx.showToast({ title: '预订需验证手机号', icon: 'none' });
      return;
    }
    this.setData({ busy: true });
    try {
      const token = await this.ensureCustomerSession();
      const res = await api.createReservation(
        this.data.slug,
        {
          hamster_id: hamsterId,
          name,
          phone,
          wechat,
          notes: (this.data.notes || '').trim(),
        },
        token,
      );
      getApp().saveCustomer({ phone, wechat, slug: this.data.slug, customerToken: token });
      const reservationId = (res && res.data && res.data.reservation_id) || '';
      wx.showModal({
        title: '预订已提交',
        content: reservationId
          ? `预订号 ${reservationId}，宠舍确认前将为你保留约 30 分钟。`
          : '宠舍确认前将为你保留约 30 分钟。',
        showCancel: false,
        success: () => wx.navigateTo({ url: '/pages/my-reservations/my-reservations' }),
      });
    } catch (err) {
      wx.showToast({ title: err.message || '预订失败', icon: 'none' });
    } finally {
      this.setData({ busy: false });
    }
  },
  onShareAppMessage() {
    const h = this.data.hamster || {};
    return {
      title: `${h.public_name || '金丝熊'} · 血统与预订`,
      path: `/pages/detail/detail?slug=${encodeURIComponent(this.data.slug)}&id=${encodeURIComponent(this.data.hamsterId)}`,
    };
  },
});

function normalizePhone(value) {
  const raw = String(value || '').replace(/\s+/g, '');
  if (/^\+86[1][3-9]\d{9}$/.test(raw)) return raw;
  if (/^1[3-9]\d{9}$/.test(raw)) return `+86${raw}`;
  return '';
}
