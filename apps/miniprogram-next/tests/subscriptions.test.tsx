import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { defaultApi } from '../src/api/client'
import { saveBreederSession } from '../src/auth/session'
import SubscriptionSettingsPage from '../src/packages/reminders/subscriptions'
import { recorded } from './stubs/taro'

beforeEach(() => {
  recorded.reset()
  saveBreederSession({
    accessToken: 'at_subscriptions',
    refreshToken: 'rt_subscriptions',
    expiresAt: Date.now() + 3600_000,
    memberRole: 'owner',
    capabilities: ['manage_subscriptions']
  })
  vi.restoreAllMocks()
})

describe('订阅消息设置', () => {
  it('首屏从服务端恢复模板 ID，不读取本机模板缓存', async () => {
    const list = vi.spyOn(defaultApi, 'listWechatSubscriptions').mockResolvedValue({
      data: [
        { templateId: 'tmpl_accept', status: 'accept' },
        { templateId: 'tmpl_reject', status: 'reject' }
      ]
    } as never)

    render(<SubscriptionSettingsPage />)

    await waitFor(() => expect(screen.getByDisplayValue('tmpl_accept,tmpl_reject')).toBeTruthy())
    expect(list).toHaveBeenCalledTimes(1)
    expect(recorded.storage.get('scolvpet_wechat_subscribe_template_ids')).toBeUndefined()
  })

  it('保存模板列表写入服务端并使用 unknown 状态占位', async () => {
    vi.spyOn(defaultApi, 'listWechatSubscriptions').mockResolvedValue({ data: [] } as never)
    const upsert = vi.spyOn(defaultApi, 'upsertWechatSubscriptions').mockResolvedValue({ data: [] } as never)

    render(<SubscriptionSettingsPage />)
    const input = await screen.findByPlaceholderText('从微信公众平台复制 tmpl_xxx')
    fireEvent.input(input, { target: { value: 'tmpl_manual' } })
    fireEvent.click(screen.getByText('保存模板列表'))

    await waitFor(() => expect(upsert).toHaveBeenCalledWith(expect.objectContaining({
      upsertWechatSubscriptionsRequest: { templates: { tmpl_manual: 'unknown' } }
    })))
  })
})
