import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { recorded } from './stubs/taro'
import { defaultApi } from '../src/api/client'
import { saveBreederSession } from '../src/auth/session'
import TodayPage, { sortTasksForToday } from '../src/pages/today'
import LoginPage from '../src/pages/login'
import AnimalsPage from '../src/packages/animals/index'

// M1 起页面以真实 B 端会话为入口；没有会话时必须明确引导登录，不能再渲染静态样例数据。
beforeEach(() => recorded.reset())

describe('B 端未登录态', () => {
  it('今日页显示登录引导并可跳转', () => {
    render(<TodayPage />)
    expect(screen.getByText('请先登录经营账号')).toBeTruthy()
    fireEvent.click(screen.getByText('请先登录经营账号'))
    expect(recorded.navigations).toContain('/pages/login/index')
  })

  it('个体页不显示静态样例数据', () => {
    render(<AnimalsPage />)
    expect(screen.getByText('请先登录经营账号')).toBeTruthy()
    expect(screen.queryByText('布丁 ♀')).toBeNull()
  })

  it('今日没有任务时显示空态主视窗，不再堆经营入口', async () => {
    saveBreederSession({
      accessToken: 'at_test',
      refreshToken: 'rt_test',
      expiresAt: Date.now() + 3600_000,
      memberRole: 'owner',
      capabilities: []
    })
    const listTasks = vi.spyOn(defaultApi, 'listTasks').mockResolvedValue({ data: [] } as never)
    render(<TodayPage />)
    await waitFor(() => expect(screen.getByText('今天没有待办')).toBeTruthy())
    // 已联网空态：副文案标明「不是离线」；不再叠第二层 Empty
    expect(screen.getByText(/演示账号暂无任务|新的照护安排会出现在这里/)).toBeTruthy()
    expect(screen.queryByText('暂无今日任务')).toBeNull()
    expect(screen.queryByText('经营入口')).toBeNull()
    listTasks.mockRestore()
  })
})

describe('今日任务客户端排序', () => {
  it('未完成优先，同状态下高优先级与更早时间靠前', () => {
    const sorted = sortTasksForToday([
      { id: 'c', state: 'completed', priority: 'high', scheduledAt: '2026-08-01T08:00:00+08:00' },
      { id: 'b', state: 'pending', priority: 'normal', scheduledAt: '2026-08-01T10:00:00+08:00' },
      { id: 'a', state: 'pending', priority: 'high', scheduledAt: '2026-08-01T11:00:00+08:00' },
      { id: 'd', state: 'pending', priority: 'normal', scheduledAt: '2026-08-01T09:00:00+08:00' }
    ])
    expect(sorted.map((item) => item.id)).toEqual(['a', 'd', 'b', 'c'])
  })
})

describe('B 端今日任务动作', () => {
  it('跳过面板不展示没有后端契约的顺延操作', async () => {
    saveBreederSession({
      accessToken: 'at_task',
      refreshToken: 'rt_task',
      expiresAt: Date.now() + 3600_000,
      memberRole: 'owner',
      capabilities: ['write_task']
    })
    const listTasks = vi.spyOn(defaultApi, 'listTasks').mockResolvedValue({
      data: [{
        id: 'task-1',
        title: '喂药',
        state: 'pending',
        version: 3,
        targetType: 'hamster',
        targetId: 'hamster-1',
        scheduledAt: new Date('2026-07-31T09:00:00+08:00')
      }]
    } as never)
    const listHamsters = vi.spyOn(defaultApi, 'listHamsters').mockResolvedValue({
      data: [{
        id: 'hamster-1',
        name: '布丁',
        sex: 'female',
        birthDate: '2026-07-21',
        internalCode: 'A01'
      }]
    } as never)
    const listLitters = vi.spyOn(defaultApi, 'listLitters').mockResolvedValue({ data: [] } as never)

    render(<TodayPage />)
    // 主视窗标题 + 列表行各有一处「喂药」
    await waitFor(() => expect(screen.getAllByText('喂药').length).toBeGreaterThan(0))
    // B4：副文案带目标真名 + 日龄（listHamsters 映射）
    await waitFor(() => expect(screen.getByText(/布丁/)).toBeTruthy())
    expect(screen.getByText(/日龄/)).toBeTruthy()
    // UI v3：主按钮「完成一件」，次按钮「稍后」打开跳过面板
    fireEvent.click(screen.getByText('稍后'))

    await waitFor(() => expect(screen.getByText('跳过一次')).toBeTruthy())
    expect(screen.queryByText('顺延到明天')).toBeNull()
    listTasks.mockRestore()
    listHamsters.mockRestore()
    listLitters.mockRestore()
  })
})

describe('B 端登录表单', () => {
  it('开发环境一键登录会换取真实 staging 会话', async () => {
    const sendVerificationCode = vi.spyOn(defaultApi, 'sendVerificationCode').mockResolvedValueOnce({
      data: { verificationId: '018f47a2-96a7-7e37-a202-cefdc69456ce' }
    } as never)
    const createSession = vi.spyOn(defaultApi, 'createSession').mockResolvedValueOnce({
      data: {
        accessToken: 'at_dev',
        refreshToken: 'rt_dev',
        expiresInSeconds: 3600,
        account: { displayName: '开发测试账号', phoneMasked: '138****8000' },
        currentOrganization: { name: '开发测试熊舍' },
        memberRole: 'owner',
        capabilities: ['tenant_scope', 'write_task']
      }
    } as never)

    render(<LoginPage />)
    fireEvent.click(screen.getByText('连 pet.scolv.com 进入'))

    await waitFor(() => {
      expect(recorded.toasts).toContain('开发会话已就绪')
      expect(recorded.storage.get('scolvpet_breeder_session')).toMatchObject({ accessToken: 'at_dev', memberRole: 'owner' })
    })
    expect(sendVerificationCode).toHaveBeenCalledWith(expect.objectContaining({
      sendVerificationCodeRequest: { phone: '+8613800138000', purpose: 'login' }
    }))
    expect(createSession).toHaveBeenCalledWith(expect.objectContaining({
      phoneCodeLoginRequest: expect.objectContaining({ phone: '+8613800138000', code: '123456' })
    }))
    vi.restoreAllMocks()
  })

  it('开发页预填演示号与 Mock 码，未取验证码前不能手填登录', () => {
    render(<LoginPage />)
    expect(screen.getByDisplayValue('13800138000')).toBeTruthy()
    expect(screen.getByDisplayValue('123456')).toBeTruthy()
    fireEvent.click(screen.getByText('登录'))
    expect(recorded.navigations).toHaveLength(0)
    expect(recorded.toasts).toHaveLength(0)
  })

  it('清空手机号后再获取验证码会提示格式', () => {
    render(<LoginPage />)
    const phoneInput = screen.getByDisplayValue('13800138000')
    fireEvent.input(phoneInput, { target: { value: '' } })
    fireEvent.click(screen.getByText('获取验证码'))
    expect(screen.getByText('请填写 11 位手机号')).toBeTruthy()
    expect(recorded.toasts).toHaveLength(0)
  })
})
