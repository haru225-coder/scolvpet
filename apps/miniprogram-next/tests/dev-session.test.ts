import { beforeEach, describe, expect, it, vi } from 'vitest'

import { defaultApi } from '../src/api/client'
import {
  createDevelopmentBreederSession,
  isDevelopmentQuickLoginEnabled,
  shouldAutoEnterDevelopmentSession
} from '../src/auth/dev-session'
import { recorded } from './stubs/taro'

beforeEach(() => recorded.reset())

describe('开发会话引导', () => {
  it('开发配置下允许快速登录，单测环境不自动进入', () => {
    expect(isDevelopmentQuickLoginEnabled()).toBe(true)
    // Vitest 进程带 VITEST=true，避免页面挂载时抢跑登录污染表单断言
    expect(shouldAutoEnterDevelopmentSession()).toBe(false)
  })

  it('createDevelopmentBreederSession 用 Mock 码换会话并落盘', async () => {
    const sendVerificationCode = vi.spyOn(defaultApi, 'sendVerificationCode').mockResolvedValueOnce({
      data: { verificationId: 'vid-dev-1', expiresInSeconds: 300, retryAfterSeconds: 60 }
    } as never)
    const createSession = vi.spyOn(defaultApi, 'createSession').mockResolvedValueOnce({
      data: {
        accessToken: 'at_auto',
        refreshToken: 'rt_auto',
        expiresInSeconds: 3600,
        account: { displayName: '演示舍主一', phoneMasked: '+86138****8000' },
        currentOrganization: { name: '龙之介' },
        memberRole: 'owner',
        capabilities: ['write_task']
      }
    } as never)

    const session = await createDevelopmentBreederSession()
    expect(session.accessToken).toBe('at_auto')
    expect(session.organizationName).toBe('龙之介')
    expect(recorded.storage.get('scolvpet_breeder_session')).toMatchObject({ accessToken: 'at_auto' })
    expect(sendVerificationCode).toHaveBeenCalled()
    expect(createSession).toHaveBeenCalledWith(expect.objectContaining({
      phoneCodeLoginRequest: expect.objectContaining({ phone: '+8613800138000', code: '123456' })
    }))
    vi.restoreAllMocks()
  })
})
