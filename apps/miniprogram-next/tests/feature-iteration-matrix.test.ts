import fs from 'node:fs'
import path from 'node:path'
import { describe, expect, it } from 'vitest'

import { readDeclaredRoutes } from './support/declared-routes'

type FeatureIterationRow = {
  route: string
  domain: 'B 登录' | 'B 今日' | 'B 种群' | 'B 经营' | 'B 我的' | 'C 公开交易' | '个体' | '窝次' | '繁育' | '提醒' | 'CRM' | '合同' | '财务' | '遗传' | '数据中心' | 'AI'
  criticalFlow: string
  testFile: string
  deviceEvidence: string
}

const evidencePath = 'docs/evidence/miniprogram-full-iteration/README.md'

const featureIterationRows: FeatureIterationRow[] = [
  { route: 'pages/login/index', domain: 'B 登录', criticalFlow: '微信登录、手机号绑定与会话恢复', testFile: 'tests/pages.test.tsx', deviceEvidence: evidencePath },
  { route: 'pages/today/index', domain: 'B 今日', criticalFlow: '今日任务读取、完成、延期与刷新', testFile: 'tests/pages.test.tsx', deviceEvidence: evidencePath },
  { route: 'pages/population/index', domain: 'B 种群', criticalFlow: '窝次/个体横滑入口与种群工具', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'pages/business/index', domain: 'B 经营', criticalFlow: '客户与经营入口主视窗', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'pages/index/index', domain: 'C 公开交易', criticalFlow: '熊舍 slug 入口与深链', testFile: 'test/wechat_flow.test.mjs', deviceEvidence: evidencePath },
  { route: 'pages/catalog/catalog', domain: 'C 公开交易', criticalFlow: '公开个体目录与空态', testFile: 'test/wechat_flow.test.mjs', deviceEvidence: evidencePath },
  { route: 'pages/detail/detail', domain: 'C 公开交易', criticalFlow: '公开详情与预订提交', testFile: 'test/wechat_flow.test.mjs', deviceEvidence: evidencePath },
  { route: 'pages/pedigree/pedigree', domain: 'C 公开交易', criticalFlow: '三代血统与公开限制', testFile: 'test/pedigree_rows.test.mjs', deviceEvidence: evidencePath },
  { route: 'pages/simulate/simulate', domain: 'C 公开交易', criticalFlow: '遗传模拟提交与结果', testFile: 'test/wechat_flow.test.mjs', deviceEvidence: evidencePath },
  { route: 'pages/my-reservations/my-reservations', domain: 'C 公开交易', criticalFlow: '客户会话与预订状态', testFile: 'test/wechat_flow.test.mjs', deviceEvidence: evidencePath },
  { route: 'pages/contract/contract', domain: 'C 公开交易', criticalFlow: '合同 token 只读与过期处理', testFile: 'test/contract_fixture.test.mjs', deviceEvidence: evidencePath },
  { route: 'packages/animals/index/index', domain: '个体', criticalFlow: '检索、空态与详情入口', testFile: 'tests/pages.test.tsx', deviceEvidence: evidencePath },
  { route: 'packages/animals/detail/index', domain: '个体', criticalFlow: '档案、快录、头像与离线快照', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/animals/create/index', domain: '个体', criticalFlow: '单个个体创建', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/animals/batch-create/index', domain: '个体', criticalFlow: '批量个体创建', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/litters/index/index', domain: '窝次', criticalFlow: '窝次看板与空态', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/litters/detail/index', domain: '窝次', criticalFlow: '数量调整、个体化与断奶', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/breeding/index/index', domain: '繁育', criticalFlow: '繁育计划列表', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/breeding/create/index', domain: '繁育', criticalFlow: '繁育计划创建', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/breeding/detail/index', domain: '繁育', criticalFlow: '状态推进与观察记录', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/reminders/index/index', domain: '提醒', criticalFlow: '提醒列表与创建入口', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/reminders/create/index', domain: '提醒', criticalFlow: '提醒创建', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/reminders/calendar/index', domain: '提醒', criticalFlow: '日历聚合与订阅入口', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/reminders/subscriptions/index', domain: '提醒', criticalFlow: '订阅模板与授权同步', testFile: 'tests/subscriptions.test.tsx', deviceEvidence: evidencePath },
  { route: 'packages/crm/index/index', domain: 'CRM', criticalFlow: '客户列表与详情入口', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/crm/create/index', domain: 'CRM', criticalFlow: '客户创建与幂等提交', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/crm/detail/index', domain: 'CRM', criticalFlow: '预订、交付与状态动作', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/contracts/index/index', domain: '合同', criticalFlow: '合同与回执列表', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/contracts/create/index', domain: '合同', criticalFlow: '合同/回执创建与签发', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/contracts/detail/index', domain: '合同', criticalFlow: '状态动作、冲突与 PDF', testFile: 'tests/contracts-detail.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/contracts/templates/index', domain: '合同', criticalFlow: '模板管理', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/finance/index/index', domain: '财务', criticalFlow: '收支汇总与分类入口', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/finance/create/index', domain: '财务', criticalFlow: '收支创建与幂等提交', testFile: 'tests/finance-create.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/finance/categories/index', domain: '财务', criticalFlow: '分类创建与刷新', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/genetic/index/index', domain: '遗传', criticalFlow: '遗传工作台入口', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/genetic/create/index', domain: '遗传', criticalFlow: '档案、模拟、反馈与摘要', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/data-center/index/index', domain: '数据中心', criticalFlow: '汇总与操作入口', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/data-center/actions/index', domain: '数据中心', criticalFlow: '导入、导出、备份与重试', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/ai/index/index', domain: 'AI', criticalFlow: '问答、动作确认与业务深链', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath },
  { route: 'packages/profile/index/index', domain: 'B 我的', criticalFlow: '工具入口、订阅与退出登录', testFile: 'tests/migration-surface.test.ts', deviceEvidence: evidencePath }
]

const projectRoot = path.resolve(__dirname, '..')

describe('小程序全功能迭代覆盖矩阵', () => {
  it('已声明路由均有领域、关键路径、自动化测试和真机证据位置', () => {
    const declaredRoutes = readDeclaredRoutes(path.join(projectRoot, 'src/app.config.ts'))
    const matrixRoutes = featureIterationRows.map((row) => row.route)

    expect(declaredRoutes).toHaveLength(40)
    expect(new Set(matrixRoutes).size).toBe(40)
    expect([...matrixRoutes].sort()).toEqual([...declaredRoutes].sort())

    for (const row of featureIterationRows) {
      expect(row.domain).not.toBe('')
      expect(row.criticalFlow).not.toBe('')
      expect(fs.existsSync(path.join(projectRoot, row.testFile)), `${row.route} missing ${row.testFile}`).toBe(true)
      expect(row.deviceEvidence).toBe(evidencePath)
    }
  })
})
