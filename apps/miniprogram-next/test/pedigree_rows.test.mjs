import test from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';

// utils/pedigree.js is CommonJS (mini-program runtime); load it the same way.
const require = createRequire(import.meta.url);
const { buildPedigreeRows } = require('../src/utils/pedigree.js');

// Contract fixture: /public/.../pedigree?generations=3 response shape.
const N = (id, name, sex, pub = true) => ({ hamster_id: id, public_name: name, sex, public: pub });
const E = (child, parent, role) => ({ child_hamster_id: child, parent_hamster_id: parent, role });

const FIXTURE = {
  root_hamster_id: 'me',
  root_public_name: '布丁',
  nodes: [
    N('me', '布丁', 'female'),
    N('f', '芝麻', 'male'),
    N('m', '奶茶', 'female'),
    N('ff', '年糕', 'male'),
    N('fm', '', 'female', false), // 未公开:后端不下发 public_name(仅已发布档案名称)
    N('mf', '豆包', 'male'),
    // mm 未登记
    N('fff', '雪球', 'male'), // 曾祖:年糕之父
  ],
  edges: [
    E('me', 'f', 'sire'),
    E('me', 'm', 'dam'),
    E('f', 'ff', 'sire'),
    E('f', 'fm', 'dam'),
    E('m', 'mf', 'sire'),
    E('ff', 'fff', 'sire'),
  ],
};

test('三代行构建:曾祖代仅列已登记,祖代按父系/母系正确标签', () => {
  const rows = buildPedigreeRows(FIXTURE, 'me');
  assert.deepEqual(
    rows.map((r) => r.label),
    ['曾祖代', '祖代', '父母', '当前'],
  );

  const ggp = rows[0].nodes;
  assert.equal(ggp.length, 1);
  assert.equal(ggp[0].role, '年糕之父');
  assert.equal(ggp[0].name, '雪球');

  const gp = rows[1].nodes;
  assert.deepEqual(
    gp.map((n) => n.role),
    ['爷爷', '奶奶', '外公', '外婆'],
  );
  assert.equal(gp[0].name, '年糕');
  assert.equal(gp[1].name, '未公开'); // 已登记但未公开
  assert.equal(gp[2].name, '豆包');
  assert.equal(gp[3].name, '未登记'); // 无边
});

test('tappable:公开且有 id 才可 re-root;未公开/未登记不可点', () => {
  const rows = buildPedigreeRows(FIXTURE, 'me');
  const gp = rows[1].nodes;
  assert.equal(gp[0].tappable, true);
  assert.equal(gp[1].tappable, false); // 未公开
  assert.equal(gp[3].tappable, false); // 未登记
  const me = rows[3].nodes[0];
  assert.equal(me.tappable, true); // 页面层再按 id === 当前根 跳过导航
});

test('无曾祖数据时不出曾祖代行;父母缺边时祖代四空位仍齐', () => {
  const rows = buildPedigreeRows(
    { root_hamster_id: 'x', root_public_name: '独苗', nodes: [N('x', '独苗', 'male')], edges: [] },
    'x',
  );
  assert.deepEqual(
    rows.map((r) => r.label),
    ['祖代', '父母', '当前'],
  );
  assert.deepEqual(
    rows[0].nodes.map((n) => n.name),
    ['未登记', '未登记', '未登记', '未登记'],
  );
  assert.equal(rows[2].nodes[0].name, '独苗');
});
