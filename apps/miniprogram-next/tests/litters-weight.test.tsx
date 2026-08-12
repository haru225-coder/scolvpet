import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { recorded, useLoadQuery } from './stubs/taro'
import { defaultApi } from '../src/api/client'
import { saveBreederSession } from '../src/auth/session'
import LittersPage from '../src/packages/litters/index'
import LitterWeightPage from '../src/packages/litters/weight'

function login() {
  saveBreederSession({
    accessToken: 'at_litter',
    refreshToken: 'rt_litter',
    expiresAt: Date.now() + 3600_000,
    memberRole: 'owner',
    capabilities: []
  })
}

beforeEach(() => {
  recorded.reset()
  login()
})

describe('窝次批量称重', () => {
  it('逐只提交时带 litterId，并按成员区分 pupIdentityId / hamsterId', async () => {
    Object.assign(useLoadQuery, { litterId: 'litter-1' })
    const getLitter = vi.spyOn(defaultApi, 'getLitter').mockResolvedValue({
      data: { id: 'litter-1', code: 'L-01', bornAt: '2026-07-01', currentManagedCount: 2 }
    } as never)
    const listLitterMembers = vi.spyOn(defaultApi, 'listLitterMembers').mockResolvedValue({
      data: [
        { pupIdentityId: 'PUP-1', temporaryCode: 'PUP-1' },
        { hamsterId: 'H-9', name: '已个体化' }
      ]
    } as never)
    const createWeightRecord = vi.spyOn(defaultApi, 'createWeightRecord').mockResolvedValue({} as never)

    render(<LitterWeightPage />)
    await waitFor(() => expect(screen.getByText('PUP-1')).toBeTruthy())
    expect(screen.getByText('已个体化')).toBeTruthy()

    const inputs = screen.getAllByPlaceholderText('克')
    fireEvent.input(inputs[0], { target: { value: '12' } })
    fireEvent.input(inputs[1], { target: { value: '34' } })
    fireEvent.click(screen.getByText('提交 2 只'))

    await waitFor(() => expect(createWeightRecord).toHaveBeenCalledTimes(2))
    expect(createWeightRecord).toHaveBeenCalledWith(expect.objectContaining({
      weightRecordCreateRequest: expect.objectContaining({
        litterId: 'litter-1',
        pupIdentityId: 'PUP-1',
        measurementKind: 'individual',
        weightG: 12
      })
    }))
    expect(createWeightRecord).toHaveBeenCalledWith(expect.objectContaining({
      weightRecordCreateRequest: expect.objectContaining({
        litterId: 'litter-1',
        hamsterId: 'H-9',
        measurementKind: 'individual',
        weightG: 34
      })
    }))

    getLitter.mockRestore()
    listLitterMembers.mockRestore()
    createWeightRecord.mockRestore()
  })

  it('不填克数不发请求', async () => {
    Object.assign(useLoadQuery, { litterId: 'litter-1' })
    vi.spyOn(defaultApi, 'getLitter').mockResolvedValue({
      data: { id: 'litter-1', code: 'L-01' }
    } as never)
    vi.spyOn(defaultApi, 'listLitterMembers').mockResolvedValue({
      data: [{ pupIdentityId: 'PUP-1', temporaryCode: 'PUP-1' }]
    } as never)
    const createWeightRecord = vi.spyOn(defaultApi, 'createWeightRecord').mockResolvedValue({} as never)

    render(<LitterWeightPage />)
    await waitFor(() => expect(screen.getByText('提交 0 只')).toBeTruthy())
    fireEvent.click(screen.getByText('提交 0 只'))
    expect(createWeightRecord).not.toHaveBeenCalled()
    expect(screen.getByText('请至少填一只的克数')).toBeTruthy()
    vi.restoreAllMocks()
  })
})

describe('窝次看板入口', () => {
  it('行菜单含「批量称重」并导航到称重页', async () => {
    const listLitters = vi.spyOn(defaultApi, 'listLitters').mockResolvedValue({
      data: [{ id: 'litter-1', name: '7月一窝', code: 'L-01', state: 'active', currentManagedCount: 4 }]
    } as never)

    render(<LittersPage />)
    await waitFor(() => expect(screen.getByText('7月一窝')).toBeTruthy())
    fireEvent.click(screen.getByText('7月一窝'))
    await waitFor(() => expect(screen.getByText('批量称重')).toBeTruthy())
    fireEvent.click(screen.getByText('批量称重'))
    expect(recorded.navigations).toContain('/packages/litters/weight/index?litterId=litter-1')
    listLitters.mockRestore()
  })
})
