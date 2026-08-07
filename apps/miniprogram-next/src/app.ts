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
import {
  createCustomerWechatPhoneBinding,
  CustomerPhoneAuthorizationError,
  setCustomerAccessToken,
  type CustomerPhoneAuthorizationCode
} from './api/customer-client'
import { ensureDevelopmentBreederSession } from './auth/dev-session'
import { readBreederSession } from './auth/session'

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
      siteTitle: ''
    },
    _launchEntry: {} as { slug?: string; hamsterId?: string },
    saveCustomer: (partial: CustomerPartial) => this.saveCustomer(partial),
    // 原生混写页只能访问 taroGlobalData：这里只暴露一条不含 ticket、
    // token 或手机号返回值的授权桥接，短期凭证仍保持 App 私有。
    authorizeCustomerPhone: (phoneCode: string) => this.authorizeCustomerPhone(phoneCode)
  }

  _silentLoginPromise: Promise<unknown> | null = null
  private customerWechatTicket = ''
  private customerWechatTicketObtainedAt = 0
  private customerPhoneAuthorizationPromise: Promise<CustomerPhoneAuthorizationResult> | null = null

  get globalData() {
    return this.taroGlobalData.globalData
  }

  get _launchEntry() {
    return this.taroGlobalData._launchEntry
  }

  onLaunch(options?: { query?: Record<string, string> }) {
    config.assertRuntimeConfig()
    // 开发构建：启动时清掉粘住的「离线假会话」。
    // 否则真机扫码仍会读到 offline-dev-token，所有请求被短路，看起来永远离线。
    try {
      if ((config as { APP_ENV?: string }).APP_ENV === 'development') {
        const offlineFlag = wx.getStorageSync('scolvpet_offline_dev_mode')
        const breeder = wx.getStorageSync('scolvpet_breeder_session') || {}
        if (offlineFlag === true || breeder.accessToken === 'offline-dev-token') {
          wx.removeStorageSync('scolvpet_offline_dev_mode')
          wx.removeStorageSync('scolvpet_breeder_session')
        }
      }
    } catch (_) {
      // ignore
    }
    // B 端会话：storage 有 token 时灌入内存。否则今日页 peek 有会话、请求无 Bearer → 突然 401。
    try {
      readBreederSession()
    } catch (_) {
      // ignore
    }
    // 开发构建：首屏已是种群/试配，不能再等进今日页才自动登录。
    // 生产 fail-closed（ensure 内部不抢跑）。失败不挡启动，页面侧会再 await 一次。
    void ensureDevelopmentBreederSession().catch(() => {
      // ignore — 页面 load 会呈现错误
    })
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
    setCustomerAccessToken(this.globalData.customerToken)
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
    // .catch：Node 冒烟/真机弱网时 fail 回调可能以裸 Object reject，避免 unhandledRejection。
    this._silentLoginPromise = this.silentWechatLogin().catch(() => ({ state: 'fallback' }))
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
        this.customerWechatTicket = ticket
        this.customerWechatTicketObtainedAt = obtainedAt
      }
    })
  }

  private clearCustomerWechatAuthorization() {
    this.customerWechatTicket = ''
    this.customerWechatTicketObtainedAt = 0
  }

  private async restartCustomerWechatAuthorization() {
    this.clearCustomerWechatAuthorization()
    // 清掉旧会话后再静默登录，否则 silentWechatLogin 会直接命中缓存身份，
    // 无法为本次手机号授权重新获取微信会话或 ticket。
    this.saveCustomer({ customerToken: '' })
    await this.silentWechatLogin()
    return Boolean(this.globalData.customerToken)
  }

  authorizeCustomerPhone(phoneCode: string): Promise<CustomerPhoneAuthorizationResult> {
    if (this.customerPhoneAuthorizationPromise) return this.customerPhoneAuthorizationPromise
    const attempt = this.authorizeCustomerPhoneOnce(phoneCode)
    this.customerPhoneAuthorizationPromise = attempt
    void attempt.finally(() => {
      if (this.customerPhoneAuthorizationPromise === attempt) {
        this.customerPhoneAuthorizationPromise = null
      }
    })
    return attempt
  }

  private async authorizeCustomerPhoneOnce(phoneCode: string): Promise<CustomerPhoneAuthorizationResult> {
    const ticket = this.customerWechatTicket
    const ticketFresh = wechatLogin.isTicketFresh(ticket, this.customerWechatTicketObtainedAt, Date.now())
    if (!ticketFresh || !String(phoneCode || '').trim()) {
      if (await this.restartCustomerWechatAuthorization()) return { ok: true }
      return customerPhoneAuthorizationFailure('WECHAT_PHONE_REAUTHORIZE', '授权已超时，请重新授权手机号')
    }

    // A ticket is consumed before the server calls WeChat. Clear it before the
    // network request so neither a second tap nor an uncertain response can
    // pair a new ticket with this one-shot phone_code.
    this.clearCustomerWechatAuthorization()
    try {
      const session = await createCustomerWechatPhoneBinding(ticket, String(phoneCode).trim())
      this.saveCustomer({ customerToken: session.token, phone: session.phone })
      return { ok: true }
    } catch (error) {
      const authError = asCustomerPhoneAuthorizationError(error)
      if (
        authError.code === 'WECHAT_PHONE_REAUTHORIZE' ||
        authError.code === 'WECHAT_PHONE_QUOTA_EXHAUSTED' ||
        authError.code === 'RATE_LIMITED'
      ) {
        if (await this.restartCustomerWechatAuthorization()) return { ok: true }
      }
      return customerPhoneAuthorizationFailure(authError.code, authError.message)
    }
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
    setCustomerAccessToken(this.globalData.customerToken)
    wx.setStorageSync('scolvpet_customer', next)
  }

  render() {
    return this.props.children
  }
}

type CustomerPhoneAuthorizationResult =
  | { ok: true }
  | { ok: false; code: CustomerPhoneAuthorizationCode; message: string }

function customerPhoneAuthorizationFailure(code: CustomerPhoneAuthorizationCode, message: string): CustomerPhoneAuthorizationResult {
  return { ok: false, code, message }
}

function asCustomerPhoneAuthorizationError(error: unknown) {
  if (error instanceof CustomerPhoneAuthorizationError) return error
  return new CustomerPhoneAuthorizationError('WECHAT_PHONE_REAUTHORIZE', '授权已超时，请重新授权手机号')
}

export default App
