const api = require('../../utils/api');
// genetics-copy 是 TS 模块，C 端原生页用内联展示层（与 genetics-copy.ts 文案对齐）
function formatGeneticsPercent(probability) {
  const p = Math.min(1, Math.max(0, Number(probability) || 0));
  return `${Math.round(p * 100)}%`;
}
function formatAboutNInM(probability) {
  const p = Math.min(1, Math.max(0, Number(probability) || 0));
  if (p <= 0) return '约不会出现';
  if (p >= 0.999) return '约每只都会';
  for (let n = 2; n <= 12; n += 1) {
    const m = Math.round(p * n);
    if (m >= 1 && Math.abs(m / n - p) <= 0.03) return `约 ${n} 只里 ${m} 只`;
  }
  return `约 4 只里 ${Math.min(4, Math.max(1, Math.round(p * 4)))} 只`;
}
function buildConclusionLine(outcomes) {
  const list = outcomes || [];
  if (!list.length) return '能配，但有 1 项资料缺失，结果只能算参考';
  const kinds = new Set(list.map((o) => o.phenotype || o.phenotypeLabel || '')).size;
  const top = [...list].sort((a, b) => Number(b.probability || b.percent || 0) - Number(a.probability || a.percent || 0))[0];
  const label = (top && (top.phenotype || top.phenotypeLabel)) || '';
  if (kinds <= 1 && label) return `这一配没问题，宝宝大概率是「${label}」`;
  return `这一配能配，会出 ${kinds} 种毛色`;
}

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
      const outcomes = (data.outcomes || []).map((o) => {
        const p = Number(o.percent != null ? o.percent / 100 : o.probability) || 0;
        return {
          ...o,
          displayName: o.phenotype || o.phenotypeLabel || '没登记',
          percentLabel: formatGeneticsPercent(p),
          aboutLabel: formatAboutNInM(p),
        };
      });
      this.setData({
        loading: false,
        result: {
          ...data,
          outcomes,
          conclusionLine: buildConclusionLine(outcomes),
          selfName: data.sire_name || selfName,
          mateName: data.dam_name || mateName,
        },
      });
    } catch (err) {
      this.setData({ loading: false, error: err.message || '资料不足，算不准（需公开档案含表型）' });
    }
  },
  onShareAppMessage() {
    return {
      title: '这两只会生出什么',
      path: `/pages/simulate/simulate?slug=${encodeURIComponent(this.data.slug)}&self=${encodeURIComponent(this.data.selfId)}&mate=${encodeURIComponent(this.data.mateId)}`,
    };
  },
});
