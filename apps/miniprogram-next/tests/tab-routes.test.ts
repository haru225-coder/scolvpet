import { describe, expect, it } from 'vitest'

import {
  humanMetricTitle,
  humanShortLabel,
  TAB_PAGES,
  tabPageBottomPad
} from '../src/utils/tab-routes'

describe('tab-routes 人话与底栏辅助', () => {
  it('两栏路径固定（种群 / 试配）', () => {
    expect(TAB_PAGES).toEqual([
      '/pages/population/index',
      '/pages/trial/index'
    ])
  })

  it('性别状态短标签', () => {
    expect(humanShortLabel('male')).toBe('公')
    expect(humanShortLabel('female')).toBe('母')
    expect(humanShortLabel('weaned')).toBe('已断奶')
    expect(humanShortLabel('draft')).toBe('草稿')
    expect(humanShortLabel('expense')).toBe('支出')
    expect(humanShortLabel('issued')).toBe('已签发')
    expect(humanShortLabel('pairing')).toBe('配对中')
    expect(humanShortLabel('蜜波利')).toBe('蜜波利')
  })

  it('数据摘要字段不直接甩英文 key', () => {
    expect(humanMetricTitle('hamster_count')).toBe('在养只数')
    expect(humanMetricTitle('customerCount')).toBe('客户数')
  })

  it('Tab 页底部留白大于底栏高度', () => {
    expect(tabPageBottomPad()).toBeGreaterThan(64)
  })
})
