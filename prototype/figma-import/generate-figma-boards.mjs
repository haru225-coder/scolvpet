import fs from 'node:fs';
import path from 'node:path';

const OUT = path.resolve('prototype/figma-import');
const FONT = "'Noto Sans SC','PingFang SC','Microsoft YaHei',Arial,sans-serif";

const C = {
  canvas: '#ECEAE4',
  base: '#F7F5EF',
  surface: '#FFFFFF',
  subtle: '#EDEAE2',
  depth: '#DCE5E3',
  depthStrong: '#9CB5B1',
  ink: '#1F2928',
  muted: '#6C7774',
  line: '#C8CECB',
  strong: '#87918E',
  accent: '#C77852',
  accentDark: '#9F5737',
  success: '#4F7F68',
  warning: '#B78031',
  danger: '#B6534A',
};

const esc = (value) => String(value)
  .replaceAll('&', '&amp;')
  .replaceAll('<', '&lt;')
  .replaceAll('>', '&gt;')
  .replaceAll('"', '&quot;');

const text = (x, y, value, size = 16, weight = 400, fill = C.ink, anchor = 'start', extra = '') =>
  `<text x="${x}" y="${y}" font-family="${FONT}" font-size="${size}" font-weight="${weight}" fill="${fill}" text-anchor="${anchor}" ${extra}>${esc(value)}</text>`;

const rect = (x, y, w, h, fill = C.surface, stroke = C.line, radius = 16, extra = '') =>
  `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${radius}" fill="${fill}" stroke="${stroke}" ${extra}/>`;

const line = (x1, y1, x2, y2, stroke = C.line, width = 1, extra = '') =>
  `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${stroke}" stroke-width="${width}" ${extra}/>`;

const pill = (x, y, label, tone = 'neutral') => {
  const palette = {
    neutral: [C.subtle, C.muted],
    depth: [C.depth, '#43635F'],
    accent: ['#F2DED4', C.accentDark],
    success: ['#DDEAE3', C.success],
    warning: ['#F3E7CF', C.warning],
    danger: ['#F3DCD9', C.danger],
  }[tone];
  const width = Math.max(54, label.length * 14 + 22);
  return `${rect(x, y, width, 28, palette[0], 'none', 14)}${text(x + width / 2, y + 19, label, 12, 600, palette[1], 'middle')}`;
};

const button = (x, y, w, label, kind = 'primary', id = '') => {
  const cfg = {
    primary: [C.accent, C.accent, '#FFFFFF'],
    secondary: [C.surface, C.strong, C.ink],
    danger: [C.surface, C.danger, C.danger],
    quiet: [C.subtle, C.subtle, C.ink],
  }[kind];
  return `<g${id ? ` id="${id}"` : ''}>${rect(x, y, w, 48, cfg[0], cfg[1], 14)}${text(x + w / 2, y + 31, label, 15, 600, cfg[2], 'middle')}</g>`;
};

const icon = (cx, cy, type = 'dot', stroke = C.ink) => {
  if (type === 'plus') return `<path d="M${cx - 8} ${cy}h16M${cx} ${cy - 8}v16" stroke="${stroke}" stroke-width="2" stroke-linecap="round"/>`;
  if (type === 'chev') return `<path d="M${cx - 3} ${cy - 6}l6 6-6 6" fill="none" stroke="${stroke}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>`;
  if (type === 'check') return `<path d="M${cx - 7} ${cy}l5 5 10-11" fill="none" stroke="${stroke}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>`;
  if (type === 'warn') return `<path d="M${cx} ${cy - 9}l10 18h-20z" fill="none" stroke="${stroke}" stroke-width="2"/><circle cx="${cx}" cy="${cy + 5}" r="1.4" fill="${stroke}"/><path d="M${cx} ${cy - 4}v6" stroke="${stroke}" stroke-width="2"/>`;
  return `<circle cx="${cx}" cy="${cy}" r="5" fill="${stroke}"/>`;
};

const nav = (active) => {
  const items = ['今日', '仓鼠', '笼舍', '繁育', '我的'];
  return `<g id="BottomNav">${rect(16, 758, 358, 70, '#FBFAF7', C.line, 22)}${items.map((item, i) => {
    const x = 51 + i * 71;
    const color = item === active ? C.accentDark : C.muted;
    return `${item === active ? `<rect x="${x - 24}" y="770" width="48" height="28" rx="14" fill="#F2DED4"/>` : ''}<circle cx="${x}" cy="784" r="5" fill="${color}"/>${text(x, 815, item, 11, item === active ? 700 : 500, color, 'middle')}`;
  }).join('')}</g>`;
};

const top = (code, title, subtitle = '', back = false) =>
  `${back ? `${icon(30, 55, 'chev')}<path d="M34 49l-6 6 6 6" fill="none" stroke="${C.ink}" stroke-width="2"/>` : ''}${text(back ? 54 : 24, 54, title, 24, 700)}${text(366, 53, code, 11, 700, C.muted, 'end')}${subtitle ? text(back ? 54 : 24, 77, subtitle, 12, 400, C.muted) : ''}`;

const stat = (x, y, label, value, tone = 'neutral') => {
  const color = tone === 'danger' ? C.danger : tone === 'warning' ? C.warning : tone === 'success' ? C.success : C.ink;
  return `${rect(x, y, 106, 84, C.surface, C.line, 14)}${text(x + 14, y + 28, label, 12, 500, C.muted)}${text(x + 14, y + 61, value, 24, 700, color)}`;
};

const row = (y, title, meta, tone = 'neutral', trailing = '›') => {
  const dotColor = tone === 'danger' ? C.danger : tone === 'warning' ? C.warning : tone === 'success' ? C.success : C.depthStrong;
  return `${rect(18, y, 354, 66, C.surface, C.line, 14)}<circle cx="39" cy="${y + 24}" r="6" fill="${dotColor}"/>${text(54, y + 27, title, 14, 600)}${text(54, y + 49, meta, 11, 400, C.muted)}${text(350, y + 39, trailing, 20, 500, C.muted, 'middle')}`;
};

const field = (y, label, value, error = '') =>
  `${text(24, y, label, 12, 600, C.muted)}${rect(20, y + 10, 350, 50, C.surface, error ? C.danger : C.line, 12)}${text(36, y + 42, value, 15, 500, value.startsWith('请选择') ? C.muted : C.ink)}${error ? text(24, y + 80, error, 11, 500, C.danger) : ''}`;

const timeline = (items, startY = 150) => items.map((item, i) => {
  const y = startY + i * 84;
  return `${line(42, y + 18, 42, y + 102, C.line, 2)}<circle cx="42" cy="${y + 18}" r="8" fill="${i === 0 ? C.accent : C.depthStrong}"/>${text(66, y + 17, item[0], 14, 600)}${text(66, y + 41, item[1], 11, 400, C.muted)}${item[2] ? pill(66, y + 51, item[2], item[3] || 'neutral') : ''}`;
}).join('');

function screenBody(code) {
  switch (code) {
    case 'P01':
      return `${top(code, '登录熊舍管家', '数据属于你，随时可导出')}${rect(42, 116, 306, 126, C.depth, 'none', 26)}${text(195, 165, '熊舍运营中枢', 22, 700, '#43635F', 'middle')}${text(195, 195, '记录 · 繁育 · 谱系 · 备份', 13, 500, '#5F7773', 'middle')}${field(290, '中国大陆手机号', '138 0000 0000')}${rect(24, 378, 18, 18, C.surface, C.strong, 4)}${icon(33, 387, 'check', C.success)}${text(52, 392, '已阅读并同意服务协议与隐私政策', 12, 400, C.muted)}${button(20, 430, 350, '获取验证码', 'primary', 'GO_P02')}${text(195, 510, '首次登录会创建个人熊舍', 12, 400, C.muted, 'middle')}`;
    case 'P02':
      return `${top(code, '输入验证码', '已发送至 138****0000', true)}${text(24, 138, '验证码', 12, 600, C.muted)}${[0,1,2,3,4,5].map((i)=>`${rect(20+i*59,154,48,56,C.surface,C.line,12)}${text(44+i*59,190,i<4?'•':'',24,700,C.ink,'middle')}`).join('')}${text(24, 242, '47 秒后可重新发送', 12, 400, C.muted)}${button(20, 286, 350, '验证并登录', 'primary', 'GO_P03')}${row(376, '验证码错误', '请检查后重试，剩余 4 次', 'danger', '')}`;
    case 'P03':
      return `${top(code, '创建个人熊舍', '首版为单舍主账号', true)}${field(116, '熊舍名称', '雪团熊舍')}${field(210, '运营模式', '家庭繁育与长期养护')}${field(304, '时区', 'Asia/Shanghai')}${field(398, '默认重量单位', '克（g）')}${button(20, 506, 350, '创建熊舍', 'primary', 'GO_P04')}${text(24, 582, '账号隔离', 13, 700)}${text(24, 607, '所有业务数据自动绑定当前 ownerId', 12, 400, C.muted)}`;
    case 'P04':
      return `${top(code, '首次设置', '从已有资料开始，不必从零建档', true)}${text(24, 126, '选择物种规则', 13, 700)}${row(146, '金丝熊基础规则', '21 天孕期 · 21–28 天断奶', 'success', '✓')}${text(24, 248, '选择数据起点', 13, 700)}${rect(18, 270, 354, 110, C.surface, C.accent, 16)}${text(38, 304, '从 CSV 导入', 17, 700)}${text(38, 332, '仓鼠、笼盒、体重模板与预检', 12, 400, C.muted)}${pill(274, 292, '推荐', 'accent')}${row(396, '稍后手工建档', '先进入今日，再逐步录入', 'neutral', '›')}${button(20, 500, 350, '继续', 'primary', 'GO_P05')}`;
    case 'P05':
      return `${top(code, '今天', '7 月 16 日 · 雪团熊舍')}${stat(18, 106, '紧急', '2', 'danger')}${stat(142, 106, '今日任务', '8')}${stat(266, 106, '待清洁', '3', 'warning')}${row(210, '配对已超 15 分钟', '银狐 × 奶油 · 立即分笼', 'danger')}${row(288, 'L-20260712 关键称重', '6 只临时幼崽 · 09:00', 'warning')}${row(366, '预计产仔窗口', '小麦 · 7 月 17–19 日', 'success')}${rect(18, 456, 354, 106, C.depth, 'none', 16)}${text(38, 490, '数据安全', 14, 700, '#43635F')}${text(38, 518, '最近备份：今天 03:12 · 已校验', 12, 500, '#5F7773')}${text(340, 522, '查看', 12, 700, C.accentDark, 'end')}${button(292, 674, 72, '＋记录', 'primary', 'GO_A01')}${nav('今日')}`;
    case 'P06':
      return `${top(code, '任务与日历', '按业务状态自动生成')}${pill(20, 104, '日', 'accent')}${pill(82, 104, '周')}${pill(144, 104, '月')}${rect(18, 150, 354, 72, C.surface, C.line, 14)}${text(38, 180, '7 月 16 日 · 周四', 17, 700)}${text(340, 180, '8 项', 13, 700, C.accentDark, 'end')}${row(236, '09:00 窝仔称重', 'L-20260712 · 6 只', 'warning')}${row(314, '11:30 清洁笼盒', 'R2-L3-04 · 已延期 1 次', 'danger')}${row(392, '18:00 孕期观察', '小麦 · 记录体重与状态', 'success')}${row(470, '21:00 性别复核', 'L-20260620 · 2 只待确认', 'warning')}${nav('今日')}`;
    case 'P07':
      return `${top(code, '待处理中心', '服务端守卫产生的异常与恢复动作')}${pill(20, 104, '全部 5', 'accent')}${pill(98, 104, '繁育 2')}${pill(176, 104, '数量 1')}${pill(254, 104, '数据 2')}${row(154, '分笼超时', '配对 attempt-03 · 必须同时指定双方去向', 'danger')}${row(232, '数量差额 +1', 'L-20260712 · 在养 7 / 身份 6', 'danger')}${row(310, '备份失败', '校验清单生成失败 · 可安全重试', 'warning')}${row(388, '视频转码失败', 'VID-018 · 原文件已保留', 'warning')}${row(466, '体重连续下降', 'PUP-04 · 48h 下降 12%', 'danger')}${nav('今日')}`;
    case 'P08':
      return `${top(code, '仓鼠', '在养 36 · 退役 8')}${rect(18, 96, 354, 48, C.surface, C.line, 14)}${text(44, 126, '搜索编号、名字、花色', 13, 400, C.muted)}${pill(20, 158, '在养', 'accent')}${pill(82, 158, '公 17')}${pill(148, 158, '母 19')}${pill(222, 158, '筛选')}${row(206, 'HS-026 · 小麦', '母 · 奶油 · R1-L2-03', 'success')}${row(284, 'HS-031 · 银狐', '公 · 银狐 · R1-L1-02', 'neutral')}${row(362, 'HS-033 · 黑糖', '母 · 黑色 · 隔离观察', 'warning')}${row(440, 'HS-035 · 云朵', '公 · 长毛 · R2-L1-01', 'neutral')}${button(286, 674, 78, '＋建档', 'primary', 'GO_A02')}${nav('仓鼠')}`;
    case 'P09':
      return `${top(code, 'HS-026 · 小麦', '母 · 奶油 · 在养', true)}${rect(20, 100, 108, 108, C.depth, 'none', 24)}${text(74, 160, '封面', 14, 700, '#5F7773', 'middle')}${text(150, 128, '2025-11-04 出生', 14, 600)}${text(150, 158, '当前笼盒 R1-L2-03', 12, 500, C.muted)}${pill(150, 176, '繁育可用', 'success')}${stat(18, 238, '当前体重', '128g')}${stat(142, 238, '30 日变化', '+4g', 'success')}${stat(266, 238, '媒体', '12')}${row(338, '体重与健康', '最近记录：今天 09:12')}${row(416, '繁育与窝次', '2 次计划 · 1 窝后代')}${row(494, '家谱图', '父母、同窝、共同祖先')}${row(572, '媒体时间线', '图片 10 · 视频 2', 'neutral')}${nav('仓鼠')}`;
    case 'P10':
      return `${top(code, '窝次', '在管 4 · 已关闭 18')}${pill(20, 104, '全部')}${pill(82, 104, '哺乳 2', 'accent')}${pill(162, 104, '待分性 1')}${pill(250, 104, '待个体化 1')}${row(156, 'L-20260712', '小麦 × 银狐 · D4 · 在养 6', 'success')}${row(234, 'L-20260702', '海盐 × 豆包 · D14 · 在养 5', 'warning')}${row(312, 'L-20260620', '糯米 × 可可 · D26 · 待分性', 'warning')}${row(390, 'L-20260608', '奶盖 × 芝麻 · 待个体化 4', 'danger')}${row(468, 'L-20260501', '已关闭 · 个体化 6 / 转出 1')}${nav('仓鼠')}`;
    case 'P11':
      return `${top(code, 'L-20260712', 'D4 · 哺乳中 · 小麦 × 银狐', true)}${stat(18, 104, '出生', '6')}${stat(142, 104, '在养', '6', 'success')}${stat(266, 104, '差额', '0')}${rect(18, 204, 354, 88, C.depth, 'none', 16)}${text(38, 238, '数量账闭合', 15, 700, '#43635F')}${text(38, 266, '初始 +6 · 死亡 0 · 转出 0 · 后补 0', 12, 500, '#5F7773')}${row(310, 'PUP-01 · 11.4g', '较出生 +1.2g · 正常', 'success')}${row(388, 'PUP-02 · 10.8g', '较上次 -0.6g · 待复核', 'warning')}${row(466, 'PUP-03 · 12.1g', '较出生 +1.8g · 正常', 'success')}${button(20, 566, 168, '数量与称重', 'primary', 'GO_A10')}${button(202, 566, 168, '查看全部 6 只', 'secondary')}${nav('仓鼠')}`;
    case 'P12':
      return `${top(code, '家谱图', 'HS-026 · 小麦', true)}${pill(20, 100, '3 代', 'accent')}${pill(84, 100, '关系证据')}${pill(174, 100, '共同祖先')}${line(195, 190, 112, 264, C.depthStrong, 2)}${line(195, 190, 278, 264, C.depthStrong, 2)}${rect(135, 146, 120, 72, C.surface, C.accent, 18)}${text(195, 176, '小麦', 16, 700, C.ink, 'middle')}${text(195, 198, 'HS-026', 11, 500, C.muted, 'middle')}${rect(54, 252, 116, 72, C.surface, C.line, 18)}${text(112, 282, '母 · 奶盖', 14, 700, C.ink, 'middle')}${text(112, 304, '已接受证据', 11, 500, C.success, 'middle')}${rect(220, 252, 116, 72, C.surface, C.line, 18)}${text(278, 282, '父 · 芝麻', 14, 700, C.ink, 'middle')}${text(278, 304, '窝次推断', 11, 500, C.warning, 'middle')}${rect(18, 368, 354, 154, C.surface, C.line, 16)}${text(38, 400, '同窝成员', 14, 700)}${text(38, 432, 'HS-027 云朵　HS-028 栗子', 13, 500)}${text(38, 464, '关系：同一窝次 L-20251104', 11, 400, C.muted)}${text(38, 496, '谱系边由服务端维护，支持证据与纠错', 11, 500, C.accentDark)}${nav('仓鼠')}`;
    case 'P13':
      return `${top(code, '笼舍', 'R1 · 3 层 · 12 笼盒')}${pill(20, 100, 'R1', 'accent')}${pill(78, 100, 'R2')}${pill(136, 100, '全部 24')}${[0,1,2].map((r)=>`${text(22, 176+r*142, `第 ${r+1} 层`, 13, 700, C.muted)}${[0,1,2,3].map((c)=>{const x=20+c*88,y=190+r*142; const occupied=(r+c)%3!==1; const warning=(r===1&&c===2); return `${rect(x,y,76,104,warning?'#F3E7CF':occupied?C.surface:C.subtle,warning?C.warning:C.line,14)}${text(x+12,y+26,`0${c+1}`,13,700)}${text(x+12,y+54,occupied?(warning?'冲突':'在住 1'):'空',11,500,warning?C.warning:C.muted)}${text(x+12,y+78,(r+c)%2?'洁':'待洁',10,500,(r+c)%2?C.success:C.danger)}`;}).join('')}`).join('')}${nav('笼舍')}`;
    case 'P14':
      return `${top(code, 'R1-L2-03', '繁育母带崽笼 · 在用', true)}${stat(18, 104, '住鼠', '1+6')}${stat(142, 104, '温度', '24℃')}${stat(266, 104, '下次清洁', '明天')}${row(208, '当前占用', '小麦 + L-20260712 · 自 7 月 12 日')}${row(286, '用途', 'dam_with_litter · 由服务端状态投影')}${row(364, '设备', '温湿度计 TH-04 · 最后同步 2 分钟前')}${row(442, '下一任务', '关键称重 · 今天 09:00', 'warning')}${button(20, 548, 168, '入住 / 移笼', 'primary', 'GO_A05')}${button(202, 548, 168, '清洁 / 隔离', 'secondary', 'GO_A06')}${nav('笼舍')}`;
    case 'P15':
      return `${top(code, '入住与清洁历史', 'R1-L2-03', true)}${timeline([['小麦与窝次入住','7 月 12 日 03:46 · 产仔确认','当前','success'],['深度清洁完成','7 月 11 日 18:20 · 无异常','已审计'],['小麦进入孕期笼','6 月 26 日 10:10 · 来源 R1-L1-04'],['纠正入住时间','6 月 26 日 10:12 · 原值已保留','纠错','warning'],['银狐离开','6 月 26 日 09:58 · 配对分笼']])}${nav('笼舍')}`;
    case 'P16':
      return `${top(code, '繁育', '状态由动作接口推进')}${pill(20, 100, '全部 7')}${pill(90, 100, '进行中 4', 'accent')}${pill(180, 100, '逾期 2', 'danger')}${text(20, 164, '配对中', 13, 700, C.muted)}${row(180, '银狐 × 小麦', '00:14:36 · 最晚 00:15:00', 'danger')}${text(20, 278, '孕期观察', 13, 700, C.muted)}${row(294, '豆包 × 海盐', '预产 7 月 17–19 日', 'success')}${row(372, '芝麻 × 糯米', '超过预产窗 1 天', 'warning')}${text(20, 470, '窝仔管理', 13, 700, C.muted)}${row(486, 'L-20260712', 'D4 · 在养 6 · 数量闭合', 'success')}${button(272, 674, 92, '＋计划', 'primary')}${nav('繁育')}`;
    case 'P17':
      return `${top(code, '计划 BR-0712', '银狐 × 小麦 · 配对中', true)}${rect(18, 100, 354, 102, C.depth, 'none', 16)}${text(38, 132, '规则快照 v3', 13, 700, '#43635F')}${text(38, 160, '最晚配对 15 分钟 · 预产 16–18 天', 12, 500, '#5F7773')}${text(38, 184, '规则变更不影响本计划', 11, 500, '#5F7773')}${row(220, '父本 · 银狐', 'HS-031 · 可繁育')}${row(298, '母本 · 小麦', 'HS-026 · 可繁育')}${row(376, '近亲检查', '无共同祖先（3 代范围）', 'success')}${row(454, '配对尝试 01', '进行中 · attempt-03', 'warning')}${button(20, 560, 168, '打开配对', 'primary', 'GO_P18')}${button(202, 560, 168, '查看时间线', 'secondary')}${nav('繁育')}`;
    case 'P18':
      return `${top(code, '配对执行', '银狐 × 小麦', true)}${rect(18, 102, 354, 146, '#253230', '#253230', 22)}${text(195, 154, '00:14:36', 42, 700, '#F4F1EA', 'middle')}${text(195, 186, '最晚分笼 00:15:00', 13, 500, '#C8D5D1', 'middle')}${pill(137, 202, '剩余 24 秒', 'danger')}${row(272, '13:58 接触', '双方平静 · 无冲突', 'success')}${row(350, '14:03 追逐', '轻微 · 已停止', 'warning')}${row(428, '14:09 交配观察', '已记录视频 · 可信度高', 'success')}${button(20, 548, 168, '记录观察', 'secondary', 'GO_A08')}${button(202, 548, 168, '立即分笼', 'primary', 'GO_A09')}${nav('繁育')}`;
    case 'P19':
      return `${top(code, '孕期观察', '小麦 · 分笼后 D16', true)}${rect(18, 100, 354, 126, C.depth, 'none', 18)}${text(38, 132, '预计产仔窗口', 13, 600, '#5F7773')}${text(38, 174, '7 月 17 — 7 月 19', 26, 700, '#43635F')}${text(38, 202, '依据：配对完成时间 + 规则快照 v3', 11, 500, '#5F7773')}${stat(18, 248, '当前体重', '136g')}${stat(142, 248, '较基线', '+12g', 'success')}${stat(266, 248, '观察', '5')}${row(352, '今天 08:40', '筑窝明显 · 进食正常', 'success')}${row(430, '昨天 19:10', '体重 +3g · 无异常')}${button(20, 534, 168, '修正基准', 'secondary')}${button(202, 534, 168, '确认产仔', 'primary', 'GO_P20')}${nav('繁育')}`;
    case 'P20':
      return `${top(code, '确认产仔', '一次提交建立窝次与 N 条临时身份', true)}${field(106, '实际产仔时间', '2026-07-16 03:46')}${field(200, '初始活仔 N', '6')}${field(294, '其他结果', '死胎 0 · 其他 0')}${field(388, '母鼠状态与笼盒', '正常 · R1-L2-03')}${rect(20, 490, 350, 72, '#F3E7CF', 'none', 14)}${icon(42, 526, 'warn', C.warning)}${text(62, 518, '服务端原子创建窝次、数量事件', 12, 600, C.warning)}${text(62, 540, '和 6 条 pup_identity；重复提交不重复创建', 11, 500, C.warning)}${button(20, 586, 350, '确认并创建窝次', 'primary', 'GO_P21')}${nav('繁育')}`;
    case 'P21':
      return `${top(code, '窝仔哺乳管理', 'L-20260712 · D4 · 6 只', true)}${rect(18, 100, 354, 82, C.depth, 'none', 16)}${text(38, 134, '在养 6 / 临时身份 6 / 差额 0', 16, 700, '#43635F')}${text(38, 160, '数量账由事件投影，客户端不自行计算', 11, 500, '#5F7773')}${row(202, 'PUP-01 · 11.4g', '正常 · 未个体化', 'success')}${row(280, 'PUP-02 · 10.8g', '掉重 0.6g · 待复核', 'warning')}${row(358, 'PUP-03 · 12.1g', '正常 · 未个体化', 'success')}${row(436, '其余 3 只', '均已完成今日称重')}${button(20, 542, 168, '数量与称重', 'primary', 'GO_A10')}${button(202, 542, 168, '进入断奶分性', 'secondary', 'GO_P22')}${nav('繁育')}`;
    case 'P22':
      return `${top(code, '断奶与分性分笼', '逐只结果 + 全量笼位预检', true)}${pill(20, 102, '待处理 2', 'warning')}${pill(108, 102, '已完成 4', 'success')}${row(154, 'PUP-01 · 公 95%', '目标 R2-L1-01 · 预检通过', 'success')}${row(232, 'PUP-02 · 母 60%', '待复核 · 临时安排 R2-L2-02', 'warning')}${row(310, 'PUP-03 · 公 92%', '目标 R2-L1-01 · 预检通过', 'success')}${row(388, 'PUP-04 · 未知', '必须复核后再个体化', 'danger')}${rect(18, 486, 354, 74, '#F3DCD9', 'none', 14)}${text(38, 518, '存在 1 个阻塞项', 13, 700, C.danger)}${text(38, 542, '服务端将拒绝不完整的 sex-and-separate', 11, 500, C.danger)}${button(20, 584, 350, '打开断奶分性面板', 'primary', 'GO_A11')}${nav('繁育')}`;
    case 'P23':
      return `${top(code, '个体化与数量对账', '服务端计算 eligible set', true)}${rect(18, 100, 354, 90, C.depth, 'none', 16)}${text(38, 132, '符合个体化条件：4 只', 16, 700, '#43635F')}${text(38, 160, '在养 6 · 待复核 2 · 本次转换 4', 12, 500, '#5F7773')}${row(210, 'PUP-01 → HS-041', '公 · R2-L1-01 · 编号可用', 'success')}${row(288, 'PUP-02 → 暂不转换', '性别待复核 · 服务端排除', 'warning')}${row(366, 'PUP-03 → HS-042', '公 · R2-L1-01 · 编号可用', 'success')}${row(444, 'PUP-04 → 暂不转换', '未知性别 · 服务端排除', 'warning')}${button(20, 552, 350, '原子创建 4 条正式个体', 'primary', 'GO_P24')}${text(24, 628, '任一编号/笼位冲突将整体回滚，并返回逐项错误', 11, 500, C.danger)}${nav('繁育')}`;
    case 'P24':
      return `${top(code, '完成与归档摘要', 'BR-0712 · 可归档', true)}${rect(18, 100, 354, 122, '#DDEAE3', 'none', 18)}${icon(48, 148, 'check', C.success)}${text(76, 142, '数量闭合', 18, 700, C.success)}${text(76, 172, '出生 6 = 个体化 4 + 待复核 2', 12, 500, C.success)}${stat(18, 246, '窝次', '1')}${stat(142, 246, '正式个体', '4', 'success')}${stat(266, 246, '待复核', '2', 'warning')}${row(350, '谱系已建立', '父母边 8 · 同窝成员 6', 'success')}${row(428, '任务状态', '已关闭 7 · 保留复核任务 2')}${row(506, '导出归档摘要', 'CSV / JSON · 可从数据中心下载')}${button(20, 606, 350, '完成计划并归档', 'primary')}${nav('繁育')}`;
    case 'P25':
      return `${top(code, '我的', '雪团熊舍 · 单舍主')}${rect(18, 100, 354, 112, C.depth, 'none', 18)}${text(38, 136, '数据中心', 18, 700, '#43635F')}${text(38, 166, '最近备份：今天 03:12 · 已校验', 12, 500, '#5F7773')}${text(38, 192, '导入 · 导出 · 备份 · 用量', 12, 700, C.accentDark)}${stat(18, 234, '活跃个体', '36')}${stat(142, 234, '活跃窝次', '4')}${stat(266, 234, '笼盒', '24')}${stat(18, 334, '媒体', '1.8GB')}${stat(142, 334, '视频', '42m')}${stat(266, 334, '备份', '860MB')}${row(438, '进入数据中心', 'CSV 导入、导出、备份与任务', 'neutral')}${row(516, '物种规则', '当前 v3 · 规则快照可追溯')}${row(594, '媒体与公开分享', '有效 3 · 已撤销 7')}${nav('我的')}`;
    case 'P26':
      return `${top(code, '物种规则', '规则变更不回写历史计划', true)}${rect(18, 100, 354, 122, C.surface, C.accent, 16)}${text(38, 134, '金丝熊 · 私有版本 v3', 16, 700)}${text(38, 162, '复制自系统模板 v5', 12, 500, C.muted)}${text(38, 190, '2026-07-01 生效 · 当前使用中', 12, 600, C.success)}${row(242, '配对上限', '15 分钟 · 超时必须分笼')}${row(320, '孕期范围', '16–18 天 · 可修正基准')}${row(398, '断奶窗口', '21–28 天 · 逐只完成')}${row(476, '掉重提醒', '24h 下降 ≥ 8% · 双通道')}${button(20, 578, 168, '复制新版本', 'primary')}${button(202, 578, 168, '查看历史', 'secondary')}${nav('我的')}`;
    case 'P27':
      return `${top(code, '数据中心', '入口显性、任务可追踪', true)}${pill(20, 100, '导入', 'accent')}${pill(84, 100, '导出')}${pill(148, 100, '备份')}${pill(212, 100, '任务')}${rect(18, 152, 354, 102, C.surface, C.line, 16)}${text(38, 184, 'CSV 导入', 16, 700)}${text(38, 212, '仓鼠 · 笼盒 · 体重', 12, 500, C.muted)}${text(340, 212, '上传', 12, 700, C.accentDark, 'end')}${row(272, 'import-0716-01', '预检完成 · 128 行 · 阻塞 3', 'warning')}${row(350, 'export-0715-02', '全量 JSON · 已完成 · 42MB', 'success')}${row(428, 'backup-0716-01', '今天 03:12 · 已校验 · 860MB', 'success')}${rect(18, 524, 354, 78, C.depth, 'none', 16)}${text(38, 556, '备份与导出可见，不埋入设置', 13, 700, '#43635F')}${text(38, 580, '下载地址短期签名，并按 ownerId 校验', 11, 500, '#5F7773')}${nav('我的')}`;
    case 'P28':
      return `${top(code, '媒体与公开分享', '图片编辑 · 短视频 · 可撤销链接', true)}${stat(18, 102, '媒体空间', '1.8GB')}${stat(142, 102, '视频分钟', '42m')}${stat(266, 102, '有效分享', '3')}${row(206, 'VID-018 转码失败', '原文件已保留 · 点击重试', 'warning')}${row(284, 'HS-026 分享卡片', '有效至 7 月 30 日 · 访问 42', 'success')}${row(362, 'L-20260712 报喜卡', '永久链接 · 访问 118', 'success')}${row(440, 'HS-031 分享卡片', '已撤销 · 边缘缓存最迟 60 秒失效', 'neutral')}${button(20, 548, 168, '上传媒体', 'primary')}${button(202, 548, 168, '创建分享', 'secondary', 'GO_A12')}${nav('我的')}`;
    default:
      return `${top(code, code)}${text(24, 130, '页面内容待补', 16, 600, C.muted)}${nav('今日')}`;
  }
}

const pages = [
  ['P01','初始化','手机号登录'],['P02','初始化','验证码校验'],['P03','初始化','创建个人熊舍'],['P04','初始化','首次设置与迁移选择'],
  ['P05','今日','今日总览'],['P06','今日','任务与日历'],['P07','今日','异常与待处理中心'],
  ['P08','仓鼠','仓鼠列表'],['P09','仓鼠','仓鼠详情'],['P10','仓鼠','窝次列表'],['P11','仓鼠','窝次详情'],['P12','仓鼠','家谱图'],
  ['P13','笼舍','笼架网格'],['P14','笼舍','笼盒详情'],['P15','笼舍','入住与清洁历史'],
  ['P16','繁育','繁育看板'],['P17','繁育','计划详情'],['P18','繁育','配对执行'],['P19','繁育','分笼后与孕期观察'],['P20','繁育','确认产仔'],['P21','繁育','窝仔哺乳管理'],['P22','繁育','断奶与分性分笼'],['P23','繁育','个体化与数量对账'],['P24','繁育','完成与归档摘要'],
  ['P25','我的','我的首页与数据概览'],['P26','我的','物种规则'],['P27','我的','数据中心'],['P28','我的','媒体与公开分享管理'],
];

function mainPagesBoard() {
  const cols = 4;
  const gapX = 90;
  const gapY = 120;
  const cellW = 390;
  const cellH = 844;
  const margin = 100;
  const boardW = margin * 2 + cols * cellW + (cols - 1) * gapX;
  const rows = Math.ceil(pages.length / cols);
  const boardH = 240 + rows * cellH + (rows - 1) * gapY + 120;
  const frames = pages.map(([code, group, name], index) => {
    const col = index % cols;
    const rowIndex = Math.floor(index / cols);
    const x = margin + col * (cellW + gapX);
    const y = 220 + rowIndex * (cellH + gapY);
    return `<svg id="${code} · ${group} · ${name}" x="${x}" y="${y}" width="390" height="844" viewBox="0 0 390 844"><rect width="390" height="844" rx="28" fill="${C.base}" stroke="${C.strong}"/><rect x="10" y="10" width="370" height="824" rx="22" fill="none" stroke="#FFFFFF" opacity="0.7"/>${screenBody(code)}</svg>`;
  }).join('');
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${boardW}" height="${boardH}" viewBox="0 0 ${boardW} ${boardH}"><rect width="${boardW}" height="${boardH}" fill="${C.canvas}"/>${text(100, 92, '01 · MVP 主页面', 42, 700)}${text(100, 132, '28 个移动端页面 · 390 × 844 · 五导航固定：今日 / 仓鼠 / 笼舍 / 繁育 / 我的', 18, 500, C.muted)}${pill(100, 158, 'Console HUD 低保真', 'depth')}${pill(286, 158, 'Base 75%')}${pill(390, 158, 'Depth 20%')}${pill(506, 158, 'Accent ≤ 5%', 'accent')}${frames}</svg>`;
}

const actions = [
  ['A01','快捷记录','称重、健康、任务、清洁、产仔'],
  ['A02','编辑建档','编号、来源、关系与服务端校验'],
  ['A03','批量建档','公共字段与逐只确认'],
  ['A04','媒体编辑','裁剪、旋转、滤镜、标注与封面'],
  ['A05','入住移笼','目标笼盒、用途、时间与冲突'],
  ['A06','清洁隔离','清洁、隔离原因与后续任务'],
  ['A07','近亲检查','共同祖先、路径与规则结果'],
  ['A08','配对观察','行为、媒体、时间与严重度'],
  ['A09','分笼','父母双方去向与原子占用变更'],
  ['A10','数量与称重','事件流水、逐只称重与预警'],
  ['A11','断奶分性','逐只结果、笼位与全量预检'],
  ['A12','分享预览','公开字段、媒体、过期与撤销'],
];

function actionContent(code, title, detail) {
  const commonHeader = `${rect(0, 0, 390, 844, '#2C3432', 'none', 28, 'opacity="0.24"')}${rect(0, 260, 390, 584, C.surface, C.line, 28)}${rect(166, 274, 58, 5, C.line, 'none', 3)}${text(24, 322, `${code} · ${title}`, 22, 700)}${text(24, 350, detail, 12, 400, C.muted)}`;
  const rows = {
    A01: [['记录体重','仓鼠 / 临时幼崽 / 整窝'],['健康记录','症状、检查、媒体与复查'],['完成清洁','笼盒与完成时间'],['确认产仔','进入完整 P20 页面']],
    A02: [['内部编号','ownerId 内唯一'],['来源','本舍出生 / 引入 / 导入'],['关系','父母、窝次与证据'],['当前笼盒','后端校验占用']],
    A03: [['公共字段','来源、出生日期、花色'],['个体行 01','HS-041 · 公'],['个体行 02','HS-042 · 母'],['预检','2 成功 / 0 冲突']],
    A04: [['裁剪','1:1 / 4:3 / 自由'],['旋转与校正','90° · 曝光 · 对比'],['标注','日期、编号与说明'],['派生预览','不覆盖原文件']],
    A05: [['对象','HS-026 小麦'],['原笼盒','R1-L1-04'],['目标笼盒','R1-L2-03'],['冲突预检','容量与时间段通过']],
    A06: [['动作','深度清洁'],['完成时间','2026-07-16 18:20'],['隔离原因','可选 · 关联健康记录'],['后续任务','7 天后复查']],
    A07: [['共同祖先','无（3 代范围）'],['路径','父系 / 母系均未命中'],['规则结果','允许配对'],['规则快照','v3 · 2026-07-01']],
    A08: [['行为','追逐'],['严重度','轻微'],['发生时间','14:03:21'],['媒体','视频 VID-018']],
    A09: [['父本去向','R1-L1-02'],['母本去向','R1-L2-03'],['配对笼释放','PAIR-01'],['原子结果','3 条占用同时提交']],
    A10: [['数量事件','后补发现 +1'],['PUP-01','11.4g · +1.2g'],['PUP-02','10.8g · -0.6g'],['账面投影','在养 7 / 身份 7']],
    A11: [['PUP-01','公 95% · R2-L1-01'],['PUP-02','母 60% · 待复核'],['PUP-03','公 92% · R2-L1-01'],['全量预检','1 个阻塞项']],
    A12: [['公开字段','编号、名字、花色、出生'],['媒体','封面 1 · 图 3 · 视频 1'],['过期时间','2026-07-30'],['撤销策略','边缘缓存最迟 60 秒失效']],
  }[code];
  return `${commonHeader}${rows.map((r,i)=>row(374+i*72,r[0],r[1],i===rows.length-1?'success':'neutral',i===rows.length-1?'✓':'›')).join('')}${button(20, 708, 168, '取消', 'secondary')}${button(202, 708, 168, code==='A12'?'创建分享':'确认提交', 'primary')}`;
}

function actionBoard() {
  const cols = 3;
  const cellW = 390;
  const cellH = 844;
  const gapX = 90;
  const gapY = 120;
  const margin = 100;
  const rows = 4;
  const flowX = margin + cols * cellW + (cols - 1) * gapX + 180;
  const boardW = flowX + 920;
  const boardH = 240 + rows * cellH + (rows - 1) * gapY + 140;
  const frames = actions.map(([code,title,detail], index) => {
    const col = index % cols;
    const rowIndex = Math.floor(index / cols);
    const x = margin + col * (cellW + gapX);
    const y = 220 + rowIndex * (cellH + gapY);
    return `<svg id="${code} · ${title}" x="${x}" y="${y}" width="390" height="844" viewBox="0 0 390 844"><rect width="390" height="844" rx="28" fill="${C.base}" stroke="${C.strong}"/>${top('', '来源页面', '动作面板覆盖层')}${actionContent(code,title,detail)}</svg>`;
  }).join('');
  const flows = [
    ['F01','登录初始化','P01 → P02 → P03 → P04 → P05'],
    ['F02','CSV 初始化迁移','P04 → P27 → 预检 → 正式导入 → P08/P13'],
    ['F03','今日任务闭环','P05 → P06/P07 → 动作面板 → 刷新'],
    ['F04','仓鼠档案','P08 → A02/A03 → P09 → P12'],
    ['F05','笼舍流转','P13/P14 → A05/A06 → P15'],
    ['F06','配对分笼','P16 → P17 → P18 → A08/A09 → P19'],
    ['F07','孕期产仔','P19 → P20 → P21'],
    ['F08','窝仔监护','P21 → A10 → P07/P21'],
    ['F09','分性个体化','P22/A11 → P23 → P24'],
    ['F10','媒体分享备份','P09/P11 → A04/A12 → P25/P27/P28'],
  ].map((f,i)=>{
    const y = 300+i*122;
    return `${rect(flowX,y,820,92,C.surface,C.line,16)}${pill(flowX+20,y+18,f[0],i===5||i===6||i===8?'accent':'depth')}${text(flowX+104,y+40,f[1],16,700)}${text(flowX+20,y+72,f[2],13,500,C.muted)}`;
  }).join('');
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${boardW}" height="${boardH}" viewBox="0 0 ${boardW} ${boardH}"><defs><marker id="arrow" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto"><path d="M0,0 L0,6 L9,3 z" fill="${C.depthStrong}"/></marker></defs><rect width="${boardW}" height="${boardH}" fill="${C.canvas}"/>${text(100,92,'02 · 动作面板与流程',42,700)}${text(100,132,'12 个动作面板 · 10 条端到端流程 · 面板进入后必须有取消/返回路径',18,500,C.muted)}${frames}${text(flowX,238,'主流程连线说明',28,700)}${flows}${rect(flowX,1580,820,278,C.depth,'none',20)}${text(flowX+28,1620,'动作接口状态守卫',18,700,'#43635F')}${text(flowX+28,1660,'客户端提交意图 + Idempotency-Key + version',14,600,'#5F7773')}${text(flowX+28,1694,'服务端计算 eligible set / 目标状态 / 数量差额 / 笼位冲突',14,600,'#5F7773')}${text(flowX+28,1728,'单事务写入领域表、domain_event 与 outbox_message',14,600,'#5F7773')}${text(flowX+28,1762,'重复请求返回首个结果；冲突返回恢复动作，不由客户端重算',14,600,'#5F7773')}${line(flowX+180,1792,flowX+640,1792,C.depthStrong,3,'marker-end="url(#arrow)"')}${text(flowX,1940,'关键演示路径',28,700)}${rect(flowX,1980,820,168,C.surface,C.accent,20)}${text(flowX+30,2022,'繁育闭环',16,700)}${text(flowX+30,2060,'P16 → P17 → P18 → A09 → P19 → P20 → P21 → P22 → P23 → P24',14,600,C.ink)}${text(flowX+30,2094,'验证：数量闭合、N 条身份、N 条正式个体、谱系父母边、可归档',12,500,C.muted)}${text(flowX+30,2124,'转场建议：页面 300ms；动作面板 220ms；确认反馈 120ms，依次进入',12,500,C.accentDark)}</svg>`;
}

function componentCard(x,y,w,h,title,body) {
  return `${rect(x,y,w,h,C.surface,C.line,18)}${text(x+20,y+34,title,15,700)}${text(x+20,y+62,body,12,400,C.muted)}`;
}

function foundationsBoard() {
  const W = 2380, H = 2240;
  const web = `<svg id="WEB-01 · 公开卡片 SSR" x="1180" y="1080" width="1100" height="760" viewBox="0 0 1100 760"><rect width="1100" height="760" rx="28" fill="${C.base}" stroke="${C.strong}"/><rect x="70" y="70" width="960" height="620" rx="30" fill="${C.surface}" stroke="${C.line}"/><rect x="110" y="110" width="380" height="380" rx="30" fill="${C.depth}" stroke="none"/>${text(300,310,'公开封面 / 视频',22,700,'#5F7773','middle')}${text(550,150,'HS-026 · 小麦',34,700)}${pill(550,176,'公开分享','accent')}${text(550,238,'母 · 奶油 · 2025-11-04 出生',16,500,C.muted)}${text(550,292,'来自雪团熊舍',14,600,C.ink)}${line(550,322,970,322,C.line)}${text(550,372,'基础资料',13,700,C.muted)}${text(550,410,'编号 HS-026　花色 奶油　状态 在养',16,500)}${text(550,462,'媒体',13,700,C.muted)}${text(550,500,'图片 3 · 短视频 1',16,500)}${rect(550,548,420,76,'#F3E7CF','none',16)}${text(574,580,'公开链接可随时撤销',14,700,C.warning)}${text(574,608,'撤销后公开 API 立即失效，边缘缓存最迟 60 秒失效',12,500,C.warning)}</svg>`;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}"><rect width="${W}" height="${H}" fill="${C.canvas}"/>${text(100,102,'00 · 基础与组件',46,700)}${text(100,148,'熊舍管家 MVP 低保真原型 · 研发评审基线 · 2026-07-16',20,500,C.muted)}${rect(100,210,980,330,'#253230','#253230',28)}${text(150,278,'养殖运营控制台',18,600,'#C8D5D1')}${text(150,340,'让数量、状态与谱系',44,700,'#F4F1EA')}${text(150,398,'在服务端事实中闭合',44,700,'#F4F1EA')}${text(150,454,'Flutter · REST 动作接口 · PostgreSQL · 审计事件',16,500,'#C8D5D1')}${pill(150,482,'单舍主 ownerId 隔离','accent')}${rect(730,254,280,230,C.depthStrong,'none',34)}${text(870,338,'N',68,700,'#FFFFFF','middle')}${text(870,386,'临时身份 → 正式个体',15,700,'#FFFFFF','middle')}${text(870,422,'数量对账与窝次闭环',13,500,'#EFF5F3','middle')}${text(100,620,'设计声明',26,700)}${componentCard(100,660,300,140,'原型 archetype','Console HUD：高密度养殖运营与状态控制')}${componentCard(420,660,300,140,'色彩比例','Base 75% · Depth 20% · Accent ≤ 5%')}${componentCard(740,660,340,140,'Z-space','L0 环境 · L1 对象 · L2 面板 · L3 控件')}${componentCard(100,820,300,140,'字体','Noto Sans SC · 11 / 12 / 14 / 16 / 24')}${componentCard(420,820,300,140,'动效链','页面 300ms → 面板 220ms → 反馈 120ms')}${componentCard(740,820,340,140,'无障碍','状态文字 + 图形；触控目标 ≥ 44px')}${text(100,1040,'核心组件',26,700)}${button(100,1080,180,'主要动作','primary')}${button(300,1080,180,'次要动作','secondary')}${button(500,1080,180,'危险动作','danger')}${pill(700,1090,'成功','success')}${pill(780,1090,'待处理','warning')}${pill(878,1090,'异常','danger')}${rect(100,1150,300,48,C.surface,C.line,12)}${text(120,1181,'字段值',14,500)}${rect(420,1140,360,68,C.surface,C.line,14)}<circle cx="444" cy="1164" r="6" fill="${C.success}"/>${text(462,1167,'列表行标题',14,600)}${text(462,1188,'辅助说明与状态',11,400,C.muted)}${rect(100,1210,980,460,C.surface,C.line,20)}${text(130,1250,'组件清单与变体',16,700)}${['Button / Primary / Secondary / Danger','Icon Button / Default / Pressed / Disabled','Input / Empty / Filled / Error','Badge / Neutral / Success / Warning / Danger','Card / Summary / Alert / Data Center','List Row / Normal / Selectable / Error','Bottom Nav / 5 items / Active state','Bottom Sheet / Default / Destructive confirm'].map((v,i)=>`${rect(130+(i%2)*440,1280+Math.floor(i/2)*86,410,66,C.base,C.line,14)}${text(150+(i%2)*440,1320+Math.floor(i/2)*86,v,13,600)}`).join('')}${web}${rect(100,1740,980,380,C.depth,'none',22)}${text(132,1782,'原型连线与行为约定',20,700,'#43635F')}${text(132,1824,'1. P01 → P02 → P03 → P04 → P05 为首次启动主路径。',14,600,'#5F7773')}${text(132,1862,'2. 五导航保持今日、仓鼠、笼舍、繁育、我的；动作面板可取消返回。',14,600,'#5F7773')}${text(132,1900,'3. confirm-birth 与 individualize 使用全页面，展示事务和数量结果。',14,600,'#5F7773')}${text(132,1938,'4. 离线仅查看缓存/保存草稿；状态迁移、导入、分享、备份必须在线。',14,600,'#5F7773')}${text(132,1976,'5. WEB-01 由服务端 SSR + Web 交付，匿名访问仅读取有效 share token。',14,600,'#5F7773')}${text(132,2014,'6. 导出、备份、用量在 P25 显性展示，并可从 P27 查看任务。',14,600,'#5F7773')}${text(1180,1940,'验收标记',26,700)}${rect(1180,1990,520,74,C.surface,C.line,14)}<circle cx="1210" cy="2018" r="7" fill="${C.success}"/>${text(1232,2018,'文字无裁切',14,700)}${text(1232,2042,'390 × 844 移动端画框',11,400,C.muted)}${text(1672,2030,'✓',18,700,C.success,'middle')}${rect(1180,2080,520,74,C.surface,C.line,14)}<circle cx="1210" cy="2108" r="7" fill="${C.success}"/>${text(1232,2108,'动作有返回路径',14,700)}${text(1232,2132,'取消、返回、恢复动作均可见',11,400,C.muted)}${text(1672,2120,'✓',18,700,C.success,'middle')}</svg>`;
}

const files = [
  ['00-foundations-components.svg', foundationsBoard()],
  ['01-mvp-main-pages.svg', mainPagesBoard()],
  ['02-action-panels-flows.svg', actionBoard()],
];

for (const [name, content] of files) {
  fs.writeFileSync(path.join(OUT, name), content, 'utf8');
}

console.log(files.map(([name, content]) => `${name}\t${Buffer.byteLength(content)} bytes`).join('\n'));
