import { beforeEach, describe, expect, it, vi } from 'vitest'

const customerPhoneClient = vi.hoisted(() => {
  class FixtureCustomerPhoneAuthorizationError extends Error {
    code: string

    constructor(code: string, message: string) {
      super(message)
      this.code = code
    }
  }

  return {
    bind: vi.fn(),
    setToken: vi.fn(),
    FixtureCustomerPhoneAuthorizationError
  }
})

vi.mock('../src/api/customer-client', () => ({
  createCustomerWechatPhoneBinding: customerPhoneClient.bind,
  CustomerPhoneAuthorizationError: customerPhoneClient.FixtureCustomerPhoneAuthorizationError,
  setCustomerAccessToken: customerPhoneClient.setToken
}))

// app.ts 胶水层功能收口:原生混写页依赖 getApp().globalData /
// saveCustomer / _launchEntry,这里在无小程序运行时的环境下把
// onLaunch 全路径(缓存恢复 → 深链解析 → 静默登录降级)跑一遍。

type WxStub = {
  storage: Record<string, unknown>
  getStorageSync: (k: string) => unknown
  setStorageSync: (k: string, v: unknown) => void
  login: (opt: { success?: (res: { code?: string }) => void; fail?: () => void }) => void
  request: (opt: { fail?: (e: { errMsg: string }) => void }) => void
}

function installWx(overrides?: Partial<WxStub>) {
  const stub: WxStub = {
    storage: {},
    getStorageSync(k) {
      return this.storage[k]
    },
    setStorageSync(k, v) {
      this.storage[k] = v
    },
    // 默认:wx.login 拿不到 code → 静默登录走 fallback,不发请求
    login: (opt) => opt.fail && opt.fail(),
    request: (opt) => opt.fail && opt.fail({ errMsg: 'stub: no network in tests' }),
    ...overrides
  }
  ;(globalThis as Record<string, unknown>).wx = stub
  return stub
}

async function launchApp(options?: { query?: Record<string, string> }) {
  const { default: App } = await import('../src/app')
  const app = new (App as unknown as new (p: object) => {
    globalData: Record<string, string>
    taroGlobalData: Record<string, unknown>
    _launchEntry: { slug?: string; hamsterId?: string }
    _silentLoginPromise: Promise<{ state: string }> | null
    onLaunch: (o?: { query?: Record<string, string> }) => void
    saveCustomer: (p: Record<string, string>) => void
  })({})
  app.onLaunch(options)
  return app
}

beforeEach(() => {
  vi.resetModules()
  customerPhoneClient.bind.mockReset()
  customerPhoneClient.setToken.mockReset()
})

describe('app.ts 胶水层', () => {
  it('缓存恢复 + 深链 slug 覆盖 + 持久化', async () => {
    const wx = installWx()
    wx.storage['scolvpet_customer'] = { phone: '138', slug: 'old-cattery', customerToken: '' }
    const app = await launchApp({ query: { scene: encodeURIComponent('s=bear-house&h=h-1') } })

    expect(app.globalData.phone).toBe('138')
    expect(app.globalData.slug).toBe('bear-house')
    expect(app._launchEntry).toMatchObject({ slug: 'bear-house', hamsterId: 'h-1' })
    expect((wx.storage['scolvpet_customer'] as { slug: string }).slug).toBe('bear-house')
    // 原生页可见面必须全部收在 taroGlobalData(Taro 桥接契约)
    expect(Object.keys(app.taroGlobalData).sort()).toEqual([
      '_launchEntry',
      'authorizeCustomerPhone',
      'globalData',
      'saveCustomer'
    ])
  })

  it('无 code 时静默登录降级 fallback,不炸 onLaunch', async () => {
    installWx()
    const app = await launchApp({})
    await expect(app._silentLoginPromise).resolves.toMatchObject({ state: 'fallback' })
  })

  it('已有缓存 token 时静默登录短路为 session', async () => {
    const wx = installWx()
    wx.storage['scolvpet_customer'] = { customerToken: 'tok-1' }
    const app = await launchApp({})
    await expect(app._silentLoginPromise).resolves.toMatchObject({ state: 'session', cached: true })
  })

  it('saveCustomer 合并写入 storage,原生页语义不变', async () => {
    const wx = installWx()
    const app = await launchApp({})
    app.saveCustomer({ slug: 's1', phone: '139' })
    app.saveCustomer({ wechat: 'wx-id' })
    expect(wx.storage['scolvpet_customer']).toMatchObject({ slug: 's1', phone: '139', wechat: 'wx-id' })
    expect(app.globalData.slug).toBe('s1')
  })

  it('微信手机号授权桥接存在，且一次性 ticket 不暴露给原生页', async () => {
    installWx()
    const app = await launchApp({})
    const bridge = app.taroGlobalData as unknown as {
      authorizeCustomerPhone?: unknown
      globalData: Record<string, unknown>
    }

    expect(bridge.authorizeCustomerPhone).toBeTypeOf('function')
    expect(bridge.globalData).not.toHaveProperty('wechatTicket')
    expect(bridge.globalData).not.toHaveProperty('wechatTicketObtainedAt')
  })

  it('微信手机号授权成功只经 saveCustomer 持久化客户会话', async () => {
    const wx = installWx()
    const app = await launchApp({})
    const instance = app as unknown as {
      customerWechatTicket: string
      customerWechatTicketObtainedAt: number
    }
    const bridge = app.taroGlobalData as unknown as {
      authorizeCustomerPhone: (code: string) => Promise<unknown>
      globalData: Record<string, unknown>
    }
    instance.customerWechatTicket = 'wt_fixture_ticket'
    instance.customerWechatTicketObtainedAt = Date.now()
    customerPhoneClient.bind.mockResolvedValue({ token: 'ct_fixture_token', phone: '+8613800138000' })

    await expect(bridge.authorizeCustomerPhone('phone-code-1')).resolves.toEqual({ ok: true })
    expect(customerPhoneClient.bind).toHaveBeenCalledWith('wt_fixture_ticket', 'phone-code-1')
    expect(wx.storage.scolvpet_customer).toMatchObject({
      customerToken: 'ct_fixture_token',
      phone: '+8613800138000'
    })
    expect(instance.customerWechatTicket).toBe('')
    expect(bridge.globalData).not.toHaveProperty('wechatTicket')
  })

  it('手机号凭证结果不确定时不重放，清空 ticket 后整段重新授权', async () => {
    installWx()
    const app = await launchApp({})
    const instance = app as unknown as {
      customerWechatTicket: string
      customerWechatTicketObtainedAt: number
    }
    const bridge = app.taroGlobalData as unknown as {
      authorizeCustomerPhone: (code: string) => Promise<unknown>
    }
    instance.customerWechatTicket = 'wt_fixture_ticket'
    instance.customerWechatTicketObtainedAt = Date.now()
    customerPhoneClient.bind.mockRejectedValue(
      new customerPhoneClient.FixtureCustomerPhoneAuthorizationError(
        'WECHAT_PHONE_REAUTHORIZE',
        '授权已超时，请重新授权手机号'
      )
    )

    await expect(bridge.authorizeCustomerPhone('phone-code-1')).resolves.toEqual({
      ok: false,
      code: 'WECHAT_PHONE_REAUTHORIZE',
      message: '授权已超时，请重新授权手机号'
    })
    expect(customerPhoneClient.bind).toHaveBeenCalledTimes(1)
    expect(instance.customerWechatTicket).toBe('')
    expect(instance.customerWechatTicketObtainedAt).toBe(0)
  })

  it('绑定结果丢失后静默登录已恢复会话时，原生页桥接直接成功', async () => {
    const wx = installWx()
    const app = await launchApp({})
    const instance = app as unknown as {
      customerWechatTicket: string
      customerWechatTicketObtainedAt: number
      silentWechatLogin: () => Promise<unknown>
      saveCustomer: (partial: Record<string, string>) => void
    }
    const bridge = app.taroGlobalData as unknown as {
      authorizeCustomerPhone: (code: string) => Promise<unknown>
    }
    instance.customerWechatTicket = 'wt_fixture_ticket'
    instance.customerWechatTicketObtainedAt = Date.now()
    customerPhoneClient.bind.mockRejectedValue(
      new customerPhoneClient.FixtureCustomerPhoneAuthorizationError(
        'WECHAT_PHONE_REAUTHORIZE',
        '授权已超时，请重新授权手机号'
      )
    )
    vi.spyOn(instance, 'silentWechatLogin').mockImplementation(async () => {
      instance.saveCustomer({ customerToken: 'ct_recovered_token', phone: '+8613800138000' })
      return { state: 'session' }
    })

    await expect(bridge.authorizeCustomerPhone('phone-code-1')).resolves.toEqual({ ok: true })
    expect(wx.storage.scolvpet_customer).toMatchObject({
      customerToken: 'ct_recovered_token',
      phone: '+8613800138000'
    })
    expect(customerPhoneClient.bind).toHaveBeenCalledTimes(1)
  })

  it('微信手机号配额熔断后预取新 ticket，但仍要求用户重新点击授权', async () => {
    installWx()
    const app = await launchApp({})
    const instance = app as unknown as {
      customerWechatTicket: string
      customerWechatTicketObtainedAt: number
      silentWechatLogin: () => Promise<unknown>
    }
    const bridge = app.taroGlobalData as unknown as {
      authorizeCustomerPhone: (code: string) => Promise<unknown>
    }
    instance.customerWechatTicket = 'wt_fixture_ticket'
    instance.customerWechatTicketObtainedAt = Date.now()
    const refresh = vi.spyOn(instance, 'silentWechatLogin').mockResolvedValue({ state: 'bind_required' })
    customerPhoneClient.bind.mockRejectedValue(
      new customerPhoneClient.FixtureCustomerPhoneAuthorizationError(
        'WECHAT_PHONE_QUOTA_EXHAUSTED',
        '微信手机号授权服务繁忙，请稍后再试'
      )
    )

    await expect(bridge.authorizeCustomerPhone('phone-code-1')).resolves.toEqual({
      ok: false,
      code: 'WECHAT_PHONE_QUOTA_EXHAUSTED',
      message: '微信手机号授权服务繁忙，请稍后再试'
    })
    expect(refresh).toHaveBeenCalledTimes(1)
    expect(customerPhoneClient.bind).toHaveBeenCalledTimes(1)
  })
})
