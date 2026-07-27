import { Component, type PropsWithChildren } from 'react'

// 与旧 apps/miniprogram/app.js 行为对齐:原生混写页依赖
// getApp().globalData / getApp().saveCustomer / app._launchEntry。
// Taro 只把 React 实例上 `taroGlobalData` 内的键桥接到原生 getApp()
// (见 @tarojs/plugin-framework-react createReactApp),因此对外契约
// 必须全部收进 taroGlobalData —— 普通实例字段在真机上取不到。
// 且桥接是启动时按引用快照:键值只能原地 mutate,禁止整体重赋值,
// 否则原生页拿到的是旧引用(tools/mp-dist-smoke.mjs 对此有回归断言)。
// utils/* 为 CommonJS 原生模块。
import config from './utils/config'
import api from './utils/api'
import wechatLogin from './utils/wechat_login'

import './app.css'

type CustomerPartial = {
  phone?: string
  wechat?: string
  slug?: string
  customerToken?: string
  siteTitle?: string
}

class App extends Component<PropsWithChildren> {
  // —— 原生页可见面(经 Taro 桥接到 getApp())——
  taroGlobalData = {
    globalData: {
      apiBase: config.API_BASE as string,
      slug: '',
      phone: '',
      wechat: '',
      customerToken: '',
      siteTitle: '',
      // In-memory only (never persisted): one-shot bind ticket from wechat-sessions.
      wechatTicket: '',
      wechatTicketObtainedAt: 0
    },
    _launchEntry: {} as { slug?: string; hamsterId?: string },
    saveCustomer: (partial: CustomerPartial) => this.saveCustomer(partial)
  }

  _silentLoginPromise: Promise<unknown> | null = null

  get globalData() {
    return this.taroGlobalData.globalData
  }

  get _launchEntry() {
    return this.taroGlobalData._launchEntry
  }

  onLaunch(options?: { query?: Record<string, string> }) {
    config.assertRuntimeConfig()
    try {
      const stored = wx.getStorageSync('scolvpet_customer') || {}
      if (stored.phone) this.globalData.phone = stored.phone
      if (stored.wechat) this.globalData.wechat = stored.wechat
      if (stored.slug) this.globalData.slug = stored.slug
      if (stored.customerToken) this.globalData.customerToken = stored.customerToken
      if (stored.siteTitle) this.globalData.siteTitle = stored.siteTitle
    } catch (_) {
      // ignore
    }
    // Deep link from 小程序码 / share query
    const entry = api.parseEntryQuery((options && options.query) || {})
    if (entry.slug) {
      this.globalData.slug = entry.slug
      try {
        this.saveCustomer({ slug: entry.slug })
      } catch (_) {
        // ignore
      }
    }
    Object.assign(this.taroGlobalData._launchEntry, entry)
    // P2-3 静默微信登录:有缓存 token 维持现状;任何失败都无感降级到短信流程。
    this._silentLoginPromise = this.silentWechatLogin()
  }

  silentWechatLogin() {
    if (this.globalData.customerToken) {
      return Promise.resolve({ state: 'session', cached: true })
    }
    return wechatLogin.performSilentLogin({
      now: Date.now(),
      wxLogin: () =>
        new Promise((resolve) => {
          wx.login({
            success: (res: { code?: string }) => resolve((res && res.code) || ''),
            fail: () => resolve('')
          })
        }),
      createSession: (jsCode: string) => api.createWechatSession(jsCode),
      onToken: ({ token, phone }: { token: string; phone?: string }) => {
        const partial: CustomerPartial = { customerToken: token }
        if (phone) partial.phone = phone
        this.saveCustomer(partial)
      },
      onTicket: ({ ticket, obtainedAt }: { ticket: string; obtainedAt: number }) => {
        this.globalData.wechatTicket = ticket
        this.globalData.wechatTicketObtainedAt = obtainedAt
      }
    })
  }

  saveCustomer(partial: CustomerPartial) {
    const next = {
      phone: this.globalData.phone,
      wechat: this.globalData.wechat,
      slug: this.globalData.slug,
      customerToken: this.globalData.customerToken,
      siteTitle: this.globalData.siteTitle,
      ...partial
    }
    this.globalData.phone = next.phone || ''
    this.globalData.wechat = next.wechat || ''
    this.globalData.slug = next.slug || ''
    this.globalData.customerToken = next.customerToken || ''
    this.globalData.siteTitle = next.siteTitle || ''
    wx.setStorageSync('scolvpet_customer', next)
  }

  render() {
    return this.props.children
  }
}

export default App
