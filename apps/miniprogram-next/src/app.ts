import { Component, type PropsWithChildren } from 'react'

// 与旧 apps/miniprogram/app.js 行为对齐:原生混写页依赖
// getApp().globalData / getApp().saveCustomer / app._launchEntry。
// utils/* 为 CommonJS 原生模块,同时被原样拷贝进 dist 供原生页 require。
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
  globalData = {
    apiBase: config.API_BASE as string,
    slug: '',
    phone: '',
    wechat: '',
    customerToken: '',
    siteTitle: '',
    // In-memory only (never persisted): one-shot bind ticket from wechat-sessions.
    wechatTicket: '',
    wechatTicketObtainedAt: 0
  }

  _launchEntry: { slug?: string } = {}

  _silentLoginPromise: Promise<unknown> | null = null

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
    this._launchEntry = entry
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
