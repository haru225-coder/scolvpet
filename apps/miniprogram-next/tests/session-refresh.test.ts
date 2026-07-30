import { beforeEach, describe, expect, it, vi } from 'vitest'

import { defaultApi } from '../src/api/client'
import { BREEDER_SESSION_KEY, restoreBreederSession } from '../src/auth/session'
import { recorded } from './stubs/taro'

beforeEach(() => {
  recorded.reset()
  vi.restoreAllMocks()
})

describe('B 端会话刷新', () => {
  it('访问令牌过期时消费 refresh token 并轮换保存新会话', async () => {
    recorded.storage.set(BREEDER_SESSION_KEY, {
      accessToken: 'at_expired',
      refreshToken: 'rt_fixture',
      expiresAt: Date.now() - 1,
      displayName: '旧账号',
      phoneMasked: '138****8000',
      organizationName: '旧熊舍',
      memberRole: 'owner',
      capabilities: ['write_task']
    })
    const refreshSession = vi.spyOn(defaultApi, 'refreshSession').mockResolvedValue({
      data: {
        tokenType: 'Bearer',
        accessToken: 'at_refreshed',
        refreshToken: 'rt_rotated',
        expiresInSeconds: 3600,
        account: { displayName: '新账号', phoneMasked: '139****8000' },
        currentOrganization: { name: '新熊舍' },
        memberRole: 'owner',
        capabilities: ['write_task', 'write_health']
      }
    } as never)

    await expect(restoreBreederSession()).resolves.toMatchObject({
      accessToken: 'at_refreshed',
      refreshToken: 'rt_rotated',
      organizationName: '新熊舍'
    })
    expect(refreshSession).toHaveBeenCalledWith(expect.objectContaining({
      refreshSessionRequest: { refreshToken: 'rt_fixture' },
      xTimezone: 'Asia/Taipei'
    }))
    expect(recorded.storage.get(BREEDER_SESSION_KEY)).toMatchObject({
      accessToken: 'at_refreshed',
      refreshToken: 'rt_rotated'
    })
  })
})
