import Taro from '@tarojs/taro'
import { metrics } from '@scolvpet/mp-ui'

/** 三栏 Tab（UI 重组 v3）。顺序与 app.config.ts tabBar.list 必须一致。 */
// 2026-08-04：两栏 Tab。顺序与 app.config.ts tabBar.list 必须一致。
export const TAB_PAGES = ['/pages/population/index', '/pages/trial/index'] as const

/** 不占 Tab 但仍可进的页（旧深链 / 主视窗入口；已迁独立分包，路径不变）。 */
export const OFF_TAB_PAGES = {
  today: '/pages/today/index',
  business: '/pages/business/index'
} as const
export type TabPage = (typeof TAB_PAGES)[number]

/** 自绘底栏选中态同步（各 Tab 页 useDidShow 时 markTabActive）。 */
export const TAB_ACTIVE_EVENT = 'scolvpet:tab-active'

/**
 * 旧深链一律不改路径（既有小程序码 / 分享卡片 / 订阅消息跳转仍可打开），
 * 变的只是入口：从「今日 10 连排」改为三栏 + 主视窗按钮。
 */
export const DOMAIN_HOME = {
  animals: '/packages/animals/index/index',
  litters: '/packages/litters/index/index',
  /** 旧繁育计划入口：产品已改为试配模拟，深链仍指向 breeding 包再 redirect */
  breeding: '/packages/breeding/index/index',
  reminders: '/packages/reminders/index/index',
  crm: '/packages/crm/index/index',
  contracts: '/packages/contracts/index/index',
  finance: '/packages/finance/index/index',
  /** 遗传列表（档案/位点摘要） */
  genetic: '/packages/genetic/index/index',
  /** 试配模拟主路径：选表型 → 看结果 */
  /** 试配已升为 Tab（主包） */
  trial: '/pages/trial/index',
  geneticCreate: '/packages/genetic/create/index',
  /** 遗传档案绑定个体（全量种群选择） */
  geneticBindHamster: '/packages/genetic/bind-hamster/index',
  /** 经营端族谱（需 ?id=） */
  pedigree: '/packages/animals/pedigree/index',
  dataCenter: '/packages/data-center/index/index',
  ai: '/packages/ai/index/index',
  profile: '/packages/profile/index/index'
} as const

/** 统一跳转：Tab 页走 switchTab，其余走 navigateTo（旧代码直接 navigateTo Tab 页会失败）。 */
export function openPage(url: string) {
  const path = url.split('?')[0]
  if ((TAB_PAGES as readonly string[]).includes(path)) {
    void Taro.switchTab({ url: path })
    return
  }
  void Taro.navigateTo({ url })
}

export function openProfile() {
  openPage(DOMAIN_HOME.profile)
}

/** 告诉底栏：当前停在哪个 Tab（path 带或不带前导 / 均可）。 */
export function markTabActive(path: TabPage | string) {
  const normalized = path.startsWith('/') ? path : `/${path}`
  const index = (TAB_PAGES as readonly string[]).indexOf(normalized)
  if (index < 0) return
  try {
    Taro.eventCenter.trigger(TAB_ACTIVE_EVENT, index)
  } catch {
    // 测试桩可能没有 eventCenter
  }
}

/** Tab 页内容底部留白，避免最后一行被底栏挡住。 */
export function tabPageBottomPad(): number {
  return metrics.tabBarHeight + metrics.bottomSafePadding + 28
}

/** 性别 / 状态等英文码 → 短中文（展示用，不改权威字段）。 */
export function humanShortLabel(raw: unknown): string {
  const t = String(raw ?? '').trim()
  if (!t) return ''
  const map: Record<string, string> = {
    male: '公',
    female: '母',
    unknown: '性别未定',
    active: '进行中',
    planned: '计划中',
    draft: '草稿',
    pending: '待处理',
    confirmed: '已确认',
    cancelled: '已取消',
    canceled: '已取消',
    superseded: '已替代',
    snoozed: '已顺延',
    completed: '已完成',
    closed: '已结束',
    expired: '已过期',
    void: '已作废',
    weaned: '已断奶',
    nursing: '哺乳中',
    pregnant: '孕期',
    available: '可售',
    reserved: '已订',
    sold: '已售',
    retired: '退役',
    deceased: '已离世',
    income: '收入',
    expense: '支出',
    mating_observed: '已见配',
    no_mating: '未见配',
    open: '进行中',
    locked: '已锁定',
    succeeded: '成功',
    failed: '失败',
    running: '进行中',
    imported: '已导入',
    valid: '有效',
    invalid: '无效',
    hamster: '个体',
    litter: '窝次',
    enclosure: '笼舍',
    custom: '其他',
    issued: '已签发',
    archived: '已归档',
    revoked: '已撤销',
    pairing: '配对中',
    gestation: '孕期观察',
    ended: '已结束',
    detecting: '识别中',
    mapping: '对应字段',
    preflight: '预检中',
    committing: '提交中',
    executed: '已执行',
    suggested: '建议',
    requires_confirmation: '待确认',
    alive: '存活',
    death: '死亡',
    discovered: '新发现',
    introduced: '引入',
    weight: '体重',
    health: '健康',
    task: '任务',
    reminder: '提醒',
    contract: '合同',
    receipt: '回执',
    contact: '客户',
    reservation: '预订',
    handover: '交付',
    manual: '手记',
    import: '导入',
    info: '一般',
    high: '偏高',
    critical: '紧急',
    low: '偏低',
    normal: '普通',
    urgent: '加急',
    observation: '观察',
    medication: '用药',
    checkup: '体检',
    treatment: '治疗',
    blocked: '受阻',
    pairing_active: '配对中',
    published: '已发布',
    gestation_monitoring: '孕期观察'
  }
  return map[t.toLowerCase()] || map[t] || t
}

/** 数据中心摘要字段 key → 人话标题。 */
export function humanMetricTitle(key: string): string {
  const map: Record<string, string> = {
    hamster_count: '在养只数',
    hamsterCount: '在养只数',
    litter_count: '窝次数',
    litterCount: '窝次数',
    task_open_count: '未完成任务',
    taskOpenCount: '未完成任务',
    customer_count: '客户数',
    customerCount: '客户数',
    reservation_open_count: '进行中预订',
    reservationOpenCount: '进行中预订',
    contract_open_count: '待处理合同',
    contractOpenCount: '待处理合同',
    revenue_month: '本月收入',
    revenueMonth: '本月收入',
    expense_month: '本月支出',
    expenseMonth: '本月支出'
  }
  if (map[key]) return map[key]
  // 不把 snake_case 直接甩给用户
  return key
    .replace(/_/g, ' ')
    .replace(/([a-z])([A-Z])/g, '$1 $2')
    .trim()
}
