// 公开谱系行构建(自 pages/pedigree 抽出,便于单测)。
// 输入:GET /public/sites/{slug}/hamsters/{id}/pedigree 的 data(nodes/edges);
// 输出:自上而下 [曾祖代?][祖代][父母][当前] 的行数组,卡片含
// tappable(公开且有 id 的祖先可 re-root 浏览)。

function nodeCard(n, role) {
  if (!n) return emptyCard(role);
  return {
    role,
    name: n.public_name || '未公开',
    sex: n.sex || '',
    public: n.public === true,
    id: n.hamster_id || '',
    tappable: n.public === true && !!n.hamster_id,
  };
}

function emptyCard(role) {
  return { role, name: '没登记', sex: '', public: false, id: '', tappable: false };
}

function buildPedigreeRows(data, fallbackRootId) {
  const nodes = (data && data.nodes) || [];
  const edges = (data && data.edges) || [];
  const byId = {};
  nodes.forEach((n) => {
    byId[n.hamster_id] = n;
  });
  const rootId = (data && data.root_hamster_id) || fallbackRootId;

  const parentsOf = (childId) => {
    const pe = edges.filter((e) => e.child_hamster_id === childId);
    const s = pe.find((e) => e.role === 'sire');
    const d = pe.find((e) => e.role === 'dam');
    return {
      sireId: (s && s.parent_hamster_id) || '',
      damId: (d && d.parent_hamster_id) || '',
    };
  };

  const { sireId, damId } = parentsOf(rootId);

  // 祖代:父系 → 爷爷/奶奶,母系 → 外公/外婆(旧版两系共用一组标签,已修)
  const gp = [];
  if (sireId) {
    const p = parentsOf(sireId);
    gp.push(nodeCard(byId[p.sireId], '爷爷'), nodeCard(byId[p.damId], '奶奶'));
  } else {
    gp.push(emptyCard('爷爷'), emptyCard('奶奶'));
  }
  if (damId) {
    const p = parentsOf(damId);
    gp.push(nodeCard(byId[p.sireId], '外公'), nodeCard(byId[p.damId], '外婆'));
  } else {
    gp.push(emptyCard('外公'), emptyCard('外婆'));
  }

  // 曾祖代:只列已登记的(8 个空位没有信息量),角色标注 "{祖辈名}之父/之母"
  const ggp = [];
  gp.forEach((g) => {
    if (!g.id) return;
    const p = parentsOf(g.id);
    if (p.sireId && byId[p.sireId]) ggp.push(nodeCard(byId[p.sireId], `${g.name}之父`));
    if (p.damId && byId[p.damId]) ggp.push(nodeCard(byId[p.damId], `${g.name}之母`));
  });

  const rows = [];
  if (ggp.length) rows.push({ label: '曾祖代', nodes: ggp });
  rows.push({ label: '祖代', nodes: gp });
  rows.push({
    label: '父母',
    nodes: [nodeCard(byId[sireId], '爸爸'), nodeCard(byId[damId], '妈妈')],
  });
  rows.push({
    label: '当前',
    nodes: [
      nodeCard(byId[rootId] || { public_name: data && data.root_public_name, public: true }, '这只'),
    ],
  });
  return rows;
}

module.exports = { buildPedigreeRows };
