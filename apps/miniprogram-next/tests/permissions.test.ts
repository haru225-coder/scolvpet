import { beforeEach, describe, expect, it } from 'vitest'

import { recorded } from './stubs/taro'
import { canUseCapability } from '../src/auth/permissions'

beforeEach(() => {
  recorded.reset()
})

describe('B 端前端能力门禁', () => {
  it('owner 可以进入所有经营写入口', () => {
    recorded.storage.set('scolvpet_breeder_session', { accessToken: 'token', expiresAt: Date.now() + 60_000, memberRole: 'owner', capabilities: [] })
    expect(canUseCapability('write_documents')).toBe(true)
    expect(canUseCapability('manage_members')).toBe(true)
  })

  it('viewer 不显示写入口', () => {
    recorded.storage.set('scolvpet_breeder_session', { accessToken: 'token', expiresAt: Date.now() + 60_000, memberRole: 'viewer', capabilities: ['tenant_scope'] })
    expect(canUseCapability('write_task')).toBe(false)
    expect(canUseCapability('manage_members')).toBe(false)
  })

  it('普通成员只按返回能力开放入口', () => {
    recorded.storage.set('scolvpet_breeder_session', { accessToken: 'token', expiresAt: Date.now() + 60_000, memberRole: 'staff', capabilities: ['write_crm'] })
    expect(canUseCapability('write_crm')).toBe(true)
    expect(canUseCapability('write_accounting')).toBe(false)
    expect(canUseCapability('write_breeding')).toBe(false)
    expect(canUseCapability('manage_subscriptions')).toBe(true)
  })

  it('viewer 不开放订阅授权管理', () => {
    recorded.storage.set('scolvpet_breeder_session', { accessToken: 'token', expiresAt: Date.now() + 60_000, memberRole: 'viewer', capabilities: ['manage_subscriptions'] })
    expect(canUseCapability('manage_subscriptions')).toBe(false)
  })
})
