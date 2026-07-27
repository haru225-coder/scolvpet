import { fireEvent, render, screen } from '@testing-library/react'
import { beforeEach, describe, expect, it } from 'vitest'

import { recorded } from './stubs/taro'
import TodayPage from '../src/pages/today'
import LoginPage from '../src/pages/login'
import AnimalsSamplePage from '../src/packages/animals/index'

// 功能收口(docs/33 M0-6 追加):真机 Gate 只评手感,页内所有可点元素
// 的行为在此闭环——不允许出现"点了没反应"。

beforeEach(() => recorded.reset())

describe('今日页交互', () => {
  it('筛选分段切换列表', () => {
    render(<TodayPage />)
    expect(screen.getByText('喂食 · 全部笼舍')).toBeTruthy()
    // 「已完成」同时是分段项与状态 Tag,取分段(DOM 先渲染)
    fireEvent.click(screen.getAllByText('已完成')[0])
    expect(screen.queryByText('喂食 · 全部笼舍')).toBeNull()
    expect(screen.getByText('体重记录 · 布丁')).toBeTruthy()
    fireEvent.click(screen.getByText('待办'))
    expect(screen.queryByText('体重记录 · 布丁')).toBeNull()
  })

  it('左滑「完成」把任务置为已完成并 toast', () => {
    render(<TodayPage />)
    fireEvent.click(screen.getAllByText('完成')[0])
    expect(recorded.toasts[0]).toContain('已完成:喂食')
    fireEvent.click(screen.getAllByText('已完成')[0])
    expect(screen.getByText('喂食 · 全部笼舍')).toBeTruthy()
  })

  it('「跳过」开面板;「跳过一次」置为已跳过', () => {
    render(<TodayPage />)
    fireEvent.click(screen.getAllByText('跳过')[0])
    expect(screen.getByText('跳过这项任务?')).toBeTruthy()
    fireEvent.click(screen.getByText('跳过一次'))
    expect(recorded.toasts).toContain('已跳过一次')
    expect(screen.queryByText('跳过这项任务?')).toBeNull()
    expect(screen.getAllByText('已跳过').length).toBeGreaterThan(0)
  })

  it('「顺延到明天」只 toast 不改状态', () => {
    render(<TodayPage />)
    fireEvent.click(screen.getAllByText('跳过')[0])
    fireEvent.click(screen.getByText('顺延到明天'))
    expect(recorded.toasts).toContain('已顺延到明天(示例)')
    expect(screen.queryByText('已跳过')).toBeNull()
  })

  it('任务行点击提示 M1;快捷入口发起导航', () => {
    render(<TodayPage />)
    fireEvent.click(screen.getByText('喂食 · 全部笼舍'))
    expect(recorded.toasts).toContain('任务详情 M1 开放')
    fireEvent.click(screen.getByText('个体列表(分包样例)'))
    fireEvent.click(screen.getByText('B 端登录(M1 接线)'))
    expect(recorded.navigations).toEqual([
      '/packages/animals/index/index',
      '/pages/login/index'
    ])
  })

})

describe('个体页交互', () => {
  it('返回箭头触发 navigateBack;行点击提示 M1', () => {
    render(<AnimalsSamplePage />)
    fireEvent.click(screen.getByText('‹'))
    expect(recorded.backs).toBe(1)
    fireEvent.click(screen.getByText('布丁 ♀'))
    expect(recorded.toasts).toContain('布丁 的档案 M1 开放')
  })
})

describe('登录页交互', () => {
  it('手机号 11 位 + 验证码 6 位才启用登录;点击有响应', () => {
    const { container } = render(<LoginPage />)
    const inputs = container.querySelectorAll('input')
    const loginBtn = screen.getByText('登录')

    fireEvent.click(loginBtn)
    expect(recorded.toasts).toHaveLength(0) // disabled 状态不触发

    fireEvent.input(inputs[0], { target: { value: '13800138000' } })
    fireEvent.input(inputs[1], { target: { value: '123456' } })
    fireEvent.click(screen.getByText('登录'))
    expect(recorded.toasts).toContain('示例版式:登录接线在 M1')
  })

  it('获取验证码不静默:提示 M1 接入', () => {
    render(<LoginPage />)
    fireEvent.click(screen.getByText('获取验证码'))
    expect(recorded.toasts).toContain('短信通道 M1 接入')
  })
})
