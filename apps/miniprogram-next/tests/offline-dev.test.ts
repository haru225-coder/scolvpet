import { beforeEach, describe, expect, it } from 'vitest'

import { createTaroFetch } from '../src/api/taro-fetch'
import { enterOfflineDevSession, isOfflineDevMode, isOfflineDevSession } from '../src/auth/offline-dev'
import { clearBreederSession, saveBreederSession } from '../src/auth/session'
import { recorded } from './stubs/taro'

beforeEach(() => {
  recorded.reset()
  clearBreederSession()
})

describe('离线开发进入', () => {
  it('enterOfflineDevSession 写本地会话且不依赖网络', () => {
    const session = enterOfflineDevSession()
    expect(isOfflineDevMode()).toBe(true)
    expect(isOfflineDevSession(session)).toBe(true)
    expect(session.accessToken).toBe('offline-dev-token')
    expect(session.organizationName).toContain('离线')
    expect(session.capabilities.length).toBeGreaterThan(5)
  })

  it('真机会话 saveBreederSession 清掉离线标记，避免粘住短路', () => {
    enterOfflineDevSession()
    expect(isOfflineDevMode()).toBe(true)
    saveBreederSession({
      accessToken: 'at_real',
      refreshToken: 'rt_real',
      expiresAt: Date.now() + 3600_000,
      capabilities: ['write_task']
    })
    expect(isOfflineDevMode()).toBe(false)
    expect(isOfflineDevSession({ accessToken: 'at_real' })).toBe(false)
  })

  it('离线模式 fetch 不打 Taro.request，返回空列表信封', async () => {
    enterOfflineDevSession()
    const fetchApi = createTaroFetch(async () => {
      throw new Error('should not call network')
    })
    const response = await fetchApi('https://p.scolv.com/v1/tasks', { method: 'GET' })
    expect(response.status).toBe(200)
    const body = await response.json() as { data: unknown[] }
    expect(Array.isArray(body.data)).toBe(true)
    expect(body.data).toHaveLength(0)
  })

  it('离线模式写接口必须失败，禁止假成功', async () => {
    enterOfflineDevSession()
    const fetchApi = createTaroFetch(async () => {
      throw new Error('should not call network')
    })
    const response = await fetchApi('https://p.scolv.com/v1/accounting/records', {
      method: 'POST',
      body: '{}'
    })
    expect(response.ok).toBe(false)
    expect(response.status).toBe(503)
    const body = (await response.json()) as { error?: { message?: string } }
    expect(body.error?.message || '').toMatch(/离线/)
  })

  it('退出登录清掉离线标记', () => {
    enterOfflineDevSession()
    expect(isOfflineDevMode()).toBe(true)
    clearBreederSession()
    expect(isOfflineDevMode()).toBe(false)
  })
})
