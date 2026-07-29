import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { recorded } from './stubs/taro'
import { defaultApi } from '../src/api/client'
import { saveBreederSession } from '../src/auth/session'
import TodayPage from '../src/pages/today'
import LoginPage from '../src/pages/login'
import AnimalsPage from '../src/packages/animals/index'

// M1 起页面以真实 B 端会话为入口；没有会话时必须明确引导登录，不能再渲染静态样例数据。
beforeEach(() => recorded.reset())

describe('B 端未登录态', () => {
  it('今日页显示登录引导并可跳转', () => {
    render(<TodayPage />)
    expect(screen.getByText('请先登录 B 端经营账号')).toBeTruthy()
    fireEvent.click(screen.getByText('请先登录 B 端经营账号'))
    expect(recorded.navigations).toContain('/pages/login/index')
  })

  it('个体页不显示静态样例数据', () => {
    render(<AnimalsPage />)
    expect(screen.getByText('请先登录 B 端经营账号')).toBeTruthy()
    expect(screen.queryByText('布丁 ♀')).toBeNull()
  })

  it('今日没有任务时仍显示全量经营入口', async () => {
    saveBreederSession({
      accessToken: 'at_test',
      refreshToken: 'rt_test',
      expiresAt: Date.now() + 3600_000,
      memberRole: 'owner',
      capabilities: []
    })
    const listTasks = vi.spyOn(defaultApi, 'listTasks').mockResolvedValue({ data: [] } as never)
    render(<TodayPage />)
    await waitFor(() => expect(screen.getByText('经营入口')).toBeTruthy())
    expect(screen.getByText('数据中心')).toBeTruthy()
    listTasks.mockRestore()
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
    fireEvent.click(screen.getByText('开发环境一键登录（免扫码）'))

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

  it('手机号和验证码未完成前保持不可提交', () => {
    const { container } = render(<LoginPage />)
    const inputs = container.querySelectorAll('input')
    const loginButton = screen.getByText('登录')
    expect(loginButton).toBeTruthy()
    fireEvent.input(inputs[0], { target: { value: '13800138000' } })
    fireEvent.input(inputs[1], { target: { value: '123456' } })
    fireEvent.click(loginButton)
    expect(recorded.navigations).toHaveLength(0)
    expect(recorded.toasts).toHaveLength(0)
  })

  it('验证码请求前校验手机号', () => {
    render(<LoginPage />)
    fireEvent.click(screen.getByText('获取验证码'))
    expect(screen.getByText('请填写 11 位手机号')).toBeTruthy()
    expect(recorded.toasts).toHaveLength(0)
  })
})
