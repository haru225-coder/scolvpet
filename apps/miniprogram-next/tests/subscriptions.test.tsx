import { render, screen, waitFor } from '@testing-library/react'
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
  it('首屏从服务端恢复模板，不展示手填 tmpl 输入框', async () => {
    const list = vi.spyOn(defaultApi, 'listWechatSubscriptions').mockResolvedValue({
      data: [
        { templateId: 'tmpl_accept', status: 'accept' },
        { templateId: 'tmpl_reject', status: 'reject' }
      ]
    } as never)

    render(<SubscriptionSettingsPage />)

    await waitFor(() => expect(screen.getByText('提醒模板 1')).toBeTruthy())
    expect(screen.getByText('已授权')).toBeTruthy()
    expect(screen.getByText('已拒绝')).toBeTruthy()
    expect(screen.queryByPlaceholderText('从微信公众平台复制 tmpl_xxx')).toBeNull()
    expect(list).toHaveBeenCalledTimes(1)
  })

  it('无模板时不讲运营术语，也不要求手填', async () => {
    vi.spyOn(defaultApi, 'listWechatSubscriptions').mockResolvedValue({ data: [] } as never)
    render(<SubscriptionSettingsPage />)
    await waitFor(() => expect(screen.getByText('暂时开不了到点提醒')).toBeTruthy())
    expect(screen.queryByText('保存模板列表')).toBeNull()
    expect(screen.queryByText(/运营/)).toBeNull()
    expect(screen.queryByText(/tmpl_/)).toBeNull()
  })
})
