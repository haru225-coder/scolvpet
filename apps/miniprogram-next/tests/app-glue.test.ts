import { beforeEach, describe, expect, it, vi } from 'vitest'

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
    expect(Object.keys(app.taroGlobalData).sort()).toEqual(['_launchEntry', 'globalData', 'saveCustomer'])
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
})
