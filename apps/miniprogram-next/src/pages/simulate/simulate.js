const api = require('../../utils/api');

Page({
  data: {
    slug: '',
    selfId: '',
    mateId: '',
    hamsters: [],
    selfName: '',
    mateName: '',
    loading: true,
    error: '',
    result: null,
  },
  onLoad(query) {
    const slug = query.slug || getApp().globalData.slug;
    this.setData({
      slug,
      selfId: query.self || query.id || '',
      mateId: query.mate || '',
    });
    this.bootstrap();
  },
  async bootstrap() {
    this.setData({ loading: true, error: '' });
    try {
      const res = await api.getCatalog(this.data.slug);
      const data = (res && res.data) || res || {};
      const hamsters = (data.hamsters || [])
        .map((h) => api.normalizePublicHamster(h))
        .filter(Boolean);
      let selfId = this.data.selfId;
      let mateId = this.data.mateId;
      if (!selfId && hamsters[0]) selfId = hamsters[0].hamster_id;
      if (!mateId && hamsters[1]) mateId = hamsters[1].hamster_id;
      const self = hamsters.find((h) => h.hamster_id === selfId);
      const mate = hamsters.find((h) => h.hamster_id === mateId);
      this.setData({
        hamsters,
        selfId,
        mateId,
        selfName: (self && self.public_name) || '',
        mateName: (mate && mate.public_name) || '',
        loading: false,
      });
      if (selfId && mateId) await this.run();
    } catch (err) {
      this.setData({ loading: false, error: err.message || '加载失败' });
    }
  },
  onSelfChange(e) {
    const h = this.data.hamsters[Number(e.detail.value || 0)];
    if (!h) return;
    this.setData({ selfId: h.hamster_id, selfName: h.public_name });
  },
  onMateChange(e) {
    const h = this.data.hamsters[Number(e.detail.value || 0)];
    if (!h) return;
    this.setData({ mateId: h.hamster_id, mateName: h.public_name });
  },
  async run() {
    const { slug, selfId, mateId, selfName, mateName } = this.data;
    if (!selfId || !mateId) {
      wx.showToast({ title: '请选择两只公开仓鼠', icon: 'none' });
      return;
    }
    if (selfId === mateId) {
      wx.showToast({ title: '请选择不同的两只', icon: 'none' });
      return;
    }
    this.setData({ loading: true, error: '', result: null });
    try {
      // Infer sire/dam by sex when possible
      const self = this.data.hamsters.find((h) => h.hamster_id === selfId);
      const mate = this.data.hamsters.find((h) => h.hamster_id === mateId);
      let sireId = selfId;
      let damId = mateId;
      if (self && mate) {
        if (self.sex === 'female' && mate.sex !== 'female') {
          sireId = mateId;
          damId = selfId;
        } else if (mate.sex === 'male' && self.sex !== 'male') {
          sireId = mateId;
          damId = selfId;
        }
      }
      const res = await api.postPublicSimulate(slug, {
        sire_hamster_id: sireId,
        dam_hamster_id: damId,
      });
      const data = (res && res.data) || res || {};
      const outcomes = (data.outcomes || []).map((o) => ({
        ...o,
        percentLabel: `${(Number(o.percent != null ? o.percent : o.probability * 100) || 0).toFixed(1)}%`,
      }));
      this.setData({
        loading: false,
        result: {
          ...data,
          outcomes,
          selfName: data.sire_name || selfName,
          mateName: data.dam_name || mateName,
        },
      });
    } catch (err) {
      this.setData({ loading: false, error: err.message || '模拟失败（需公开档案含表型）' });
    }
  },
  onShareAppMessage() {
    return {
      title: '繁育模拟结果',
      path: `/pages/simulate/simulate?slug=${encodeURIComponent(this.data.slug)}&self=${encodeURIComponent(this.data.selfId)}&mate=${encodeURIComponent(this.data.mateId)}`,
    };
  },
});
