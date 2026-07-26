const api = require('../../utils/api');

Page({
  data: {
    slug: '',
    hamsterId: '',
    title: '',
    note: '',
    loading: true,
    error: '',
    generations: [],
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
      const nodes = data.nodes || [];
      const edges = data.edges || [];
      const byId = {};
      nodes.forEach((n) => {
        byId[n.hamster_id] = n;
      });
      const rootId = data.root_hamster_id || this.data.hamsterId;
      // Build simple generation lists: root, parents, grandparents
      const parents = edges.filter((e) => e.child_hamster_id === rootId);
      const sire = parents.find((e) => e.role === 'sire');
      const dam = parents.find((e) => e.role === 'dam');
      const sireId = sire && sire.parent_hamster_id;
      const damId = dam && dam.parent_hamster_id;
      const gpOf = (childId) => {
        const pe = edges.filter((e) => e.child_hamster_id === childId);
        const ps = pe.find((e) => e.role === 'sire');
        const pd = pe.find((e) => e.role === 'dam');
        return [
          nodeCard(byId[ps && ps.parent_hamster_id], '爷爷/外公系'),
          nodeCard(byId[pd && pd.parent_hamster_id], '奶奶/外婆系'),
        ];
      };
      const rows = [
        {
          label: '祖代',
          nodes: [
            ...(sireId ? gpOf(sireId) : [emptyCard('爷爷'), emptyCard('奶奶')]),
            ...(damId ? gpOf(damId) : [emptyCard('外公'), emptyCard('外婆')]),
          ],
        },
        {
          label: '父母',
          nodes: [
            nodeCard(byId[sireId], '父本'),
            nodeCard(byId[damId], '母本'),
          ],
        },
        {
          label: '当前',
          nodes: [nodeCard(byId[rootId] || { public_name: data.root_public_name, public: true }, '本人')],
        },
      ];
      this.setData({
        loading: false,
        title: data.root_public_name || '血统档案',
        note: data.note || '',
        rows,
      });
      wx.setNavigationBarTitle({ title: '血统 · ' + (data.root_public_name || '') });
    } catch (err) {
      this.setData({ loading: false, error: err.message || '血统加载失败' });
    }
  },
  onShareAppMessage() {
    return {
      title: `${this.data.title || '血统'} · 专业谱系`,
      path: `/pages/pedigree/pedigree?slug=${encodeURIComponent(this.data.slug)}&id=${encodeURIComponent(this.data.hamsterId)}`,
    };
  },
});

function nodeCard(n, role) {
  if (!n) return emptyCard(role);
  return {
    role,
    name: n.public_name || '未公开',
    sex: n.sex || '',
    public: n.public === true,
    id: n.hamster_id || '',
  };
}

function emptyCard(role) {
  return { role, name: '未登记', sex: '', public: false, id: '' };
}
