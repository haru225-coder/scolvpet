import { render } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { Input } from '@tarojs/components'

import {
  ActionPanel,
  Button,
  Cell,
  Empty,
  FormRow,
  NavBar,
  LargeTitle,
  Section,
  SectionList,
  SegmentedControl,
  Sheet,
  SwipeAction,
  Tag,
  paletteLight,
  paletteDark,
  metrics,
  motion,
  typography
} from './index'

describe('tokens', () => {
  it('palette 与 ios_theme.dart 保持关键值对齐', () => {
    expect(paletteLight.groupedBackground).toBe('#FFF8EF')
    expect(paletteLight.accent).toBe('#D98B55')
    expect(paletteLight.label).toBe('#3A2F29')
    expect(paletteDark.accent).toBe('#E0A070')
    expect(metrics.continuousRadius).toBe(16)
    expect(metrics.rowMinHeight).toBe(48)
    expect(motion.spring).toBe(280)
    expect(typography.bodyLarge.fontSize).toBe(17)
  })
})

describe('mp-ui snapshots', () => {
  it('NavBar 顶部态(小标题隐藏)+ LargeTitle', () => {
    const { asFragment } = render(
      <>
        <NavBar title="今日" scrollTop={0} />
        <LargeTitle title="今日" />
      </>
    )
    expect(asFragment()).toMatchSnapshot()
  })

  it('NavBar 收缩态(含返回与右操作)', () => {
    const { asFragment } = render(
      <NavBar title="个体" scrollTop={80} back right={<Tag tone="accent">3 项</Tag>} />
    )
    expect(asFragment()).toMatchSnapshot()
  })

  it('SectionList + Section + Cell', () => {
    const { asFragment } = render(
      <SectionList>
        <Section header="今日照护" footer="共 2 项">
          <Cell title="喂食 · 全部笼舍" subtitle="每日 20:00" value="待办" chevron />
          <Cell title="体重记录 · 布丁" value="已完成" />
        </Section>
      </SectionList>
    )
    expect(asFragment()).toMatchSnapshot()
  })

  it('FormRow 含错误提示', () => {
    const { asFragment } = render(
      <FormRow label="体重(g)" error="必须是 1–500 的数字">
        <Input defaultValue="abc" />
      </FormRow>
    )
    expect(asFragment()).toMatchSnapshot()
  })

  it('SwipeAction 静止态', () => {
    const { asFragment } = render(
      <SwipeAction actions={[{ text: '归档' }, { text: '删除', danger: true }]}>
        <Cell title="小仓鼠" />
      </SwipeAction>
    )
    expect(asFragment()).toMatchSnapshot()
  })

  it('Sheet 打开态', () => {
    const { asFragment } = render(
      <Sheet open>
        <Cell title="内容" />
      </Sheet>
    )
    expect(asFragment()).toMatchSnapshot()
  })

  it('Sheet 关闭态不渲染', () => {
    const { container } = render(
      <Sheet open={false}>
        <Cell title="内容" />
      </Sheet>
    )
    expect(container.innerHTML).toBe('')
  })

  it('ActionPanel', () => {
    const { asFragment } = render(
      <ActionPanel
        open
        title="对「布丁」执行"
        actions={[{ text: '移笼' }, { text: '删除个体', danger: true }]}
      />
    )
    expect(asFragment()).toMatchSnapshot()
  })

  it('SegmentedControl', () => {
    const { asFragment } = render(
      <SegmentedControl segments={['全部', '待办', '已完成']} value={1} />
    )
    expect(asFragment()).toMatchSnapshot()
  })

  it('Button 三变体与禁用', () => {
    const { asFragment } = render(
      <>
        <Button>保存</Button>
        <Button variant="outlined">次要</Button>
        <Button variant="text">跳过</Button>
        <Button disabled>保存</Button>
      </>
    )
    expect(asFragment()).toMatchSnapshot()
  })

  it('Tag 各语义', () => {
    const { asFragment } = render(
      <>
        <Tag>默认</Tag>
        <Tag tone="accent">品牌</Tag>
        <Tag tone="success">健康</Tag>
        <Tag tone="danger">逾期</Tag>
        <Tag tone="warning">待观察</Tag>
      </>
    )
    expect(asFragment()).toMatchSnapshot()
  })

  it('Empty 空态', () => {
    const { asFragment } = render(
      <Empty title="暂无今日任务" description="今天的照护任务都完成了" actionText="去看看个体" />
    )
    expect(asFragment()).toMatchSnapshot()
  })
})
