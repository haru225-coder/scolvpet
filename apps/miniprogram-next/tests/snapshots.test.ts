import { beforeEach, describe, expect, it } from 'vitest'

import { clearBreederSession, saveBreederSession } from '../src/auth/session'
import { saveAnimalSnapshot, saveTodaySnapshot } from '../src/offline/snapshots'
import { recorded } from './stubs/taro'

beforeEach(() => recorded.reset())

describe('B 端离线快照清理', () => {
  it('登出后清除今日快照和 40 条个体快照', () => {
    saveBreederSession({
      accessToken: 'at_fixture',
      refreshToken: 'rt_fixture',
      expiresAt: Date.now() + 60_000,
      memberRole: 'owner',
      capabilities: []
    })
    saveTodaySnapshot([{ id: 'task-1' }])
    for (let index = 0; index < 40; index += 1) {
      saveAnimalSnapshot(`animal-${index}`, { id: `animal-${index}` })
    }

    expect(recorded.storage.size).toBe(42)
    clearBreederSession()
    expect(recorded.storage.size).toBe(0)
  })
})
