import { View, Text, Input } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import {
  Section,
  SectionList,
  FormRow,
  Button,
  LargeTitle,
  palette,
  metrics
} from '@scolvpet/mp-ui'
import { defaultApi } from '../../api/default-api'
import { newIdempotencyKey } from '../../api/runtime-config'
import { formatNetworkError } from '../../api/errors'
import {
  createDevelopmentBreederSession,
  developmentLoginHints,
  formatDevelopmentLoginError,
  isDevelopmentQuickLoginEnabled,
  shouldAutoEnterDevelopmentSession
} from '../../auth/dev-session'
import { isOfflineDevMode, isOfflineDevSession } from '../../auth/offline-dev'
import { copyDiag } from '../../utils/diag'
import {
  clearBreederSession,
  peekBreederSession,
  readSessionStorage,
  removeSessionStorage,
  restoreBreederSession,
  saveBreederSession,
  writeSessionStorage
} from '../../auth/session'

// 开发一键登录只在「开发构建 + 确实注入了演示凭据」时存在；
// config.js 在非开发语义下会把 DEV_LOGIN_* 强制清空，此处因而 fail-closed。
const isDevelopmentBuild = isDevelopmentQuickLoginEnabled()
const devHints = developmentLoginHints()

const BREEDER_WECHAT_TICKET_KEY = 'scolvpet_breeder_wechat_bind_ticket'

function apiPhone(value: string) {
  const digits = value.replace(/\D/g, '')
  return /^1\d{10}$/.test(digits) ? `+86${digits}` : value
}

function enterApp() {
  // 首屏已是种群 Tab；登录成功回到验收主路径，不要 reLaunch 到已离栏的今日页
  return Taro.reLaunch({ url: '/pages/population/index' })
}

type SessionData = {
  accessToken?: string
  refreshToken?: string
  expiresInSeconds?: number
  account?: { displayName?: string | null; phoneMasked?: string }
  currentOrganization?: { name?: string }
  memberRole?: string
  capabilities?: string[]
}

function saveSessionData(data: SessionData) {
  if (
    !data.accessToken ||
    !data.expiresInSeconds ||
    !data.account ||
    !Array.isArray(data.capabilities)
  ) {
    throw new Error('服务端返回的登录会话不完整')
  }
  saveBreederSession({
    accessToken: data.accessToken,
    refreshToken: data.refreshToken || '',
    expiresAt: Date.now() + data.expiresInSeconds * 1000,
    displayName: data.account.displayName || undefined,
    phoneMasked: data.account.phoneMasked,
    organizationName: data.currentOrganization?.name,
    memberRole: data.memberRole,
    capabilities: data.capabilities
  })
}

export default function LoginPage() {
  // 开发构建直接预填演示号 + Mock 码，真机不用猜「验证码发到哪」。
  const [phone, setPhone] = useState(isDevelopmentBuild ? devHints.phone : '')
  const [code, setCode] = useState(isDevelopmentBuild ? devHints.code : '')
  const [verificationId, setVerificationId] = useState('')
  const [wechatTicket, setWechatTicket] = useState(() => readSessionStorage<string>(BREEDER_WECHAT_TICKET_KEY) || '')
  const [cooldown, setCooldown] = useState(0)
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState(isDevelopmentBuild ? devHints.hint : '')

  useEffect(() => {
    let active = true
    void (async () => {
      const session = await restoreBreederSession()
      if (!active) return

      // 已有真机（非离线）会话：直接进。
      if (session && !isOfflineDevSession(session) && !isOfflineDevMode()) {
        void enterApp()
        return
      }

      // 开发构建：始终优先连 staging。
      // 旧逻辑失败就静默 enterOfflineDevSession，真机扫预览码会永远「离线」；
      // 且离线 token 粘在 storage 里，下次启动 restore 直接成功、再也不试网络。
      if (!shouldAutoEnterDevelopmentSession()) {
        if (session && !isOfflineDevSession(session)) void enterApp()
        return
      }

      setBusy(true)
      setMessage('正在连接服务器…')
      try {
        // 清掉粘住的离线会话，否则 fetch 仍被短路
        if (isOfflineDevMode() || isOfflineDevSession(session || peekBreederSession())) {
          clearBreederSession()
        }
        await createDevelopmentBreederSession(devHints.phone)
        if (!active) return
        Taro.showToast({ title: '已登录', icon: 'success' })
        void enterApp()
      } catch (error) {
        if (!active) return
        // 不再自动离线。留在登录页，把合法域名/网络原因写清楚；离线只能手点。
        setMessage(formatDevelopmentLoginError(error))
        Taro.showToast({ title: '连不上服务器', icon: 'none', duration: 2500 })
      } finally {
        if (active) setBusy(false)
      }
    })()
    return () => {
      active = false
    }
    // 仅挂载时自动进入；故意不依赖 phone，避免输入时反复打登录。
  }, [])

  useEffect(() => {
    if (!cooldown) return
    const timer = setInterval(() => setCooldown((value) => Math.max(value - 1, 0)), 1000)
    return () => clearInterval(timer)
  }, [cooldown])

  async function requestCode() {
    if (!/^1\d{10}$/.test(phone)) {
      setMessage('请填写 11 位手机号')
      return
    }
    if (cooldown) return
    setBusy(true)
    setMessage('')
    try {
      const response = await defaultApi.sendVerificationCode({
        idempotencyKey: `mp-login-code-${Date.now()}`,
        sendVerificationCodeRequest: { phone: apiPhone(phone), purpose: 'login' } as any,
        xTimezone: 'Asia/Taipei'
      })
      setVerificationId(response.data.verificationId)
      setCooldown(response.data.retryAfterSeconds || 60)
      setMessage(`验证码已发送，有效期 ${response.data.expiresInSeconds} 秒`)
    } catch (error) {
      setMessage(formatNetworkError(error, '验证码发送失败，请稍后重试'))
    } finally {
      setBusy(false)
    }
  }

  async function login() {
    if (!verificationId || !/^\d{6}$/.test(code)) {
      setMessage('请先获取验证码并填写 6 位验证码')
      return
    }
    setBusy(true)
    setMessage('')
    try {
      if (wechatTicket) {
        const response = await defaultApi.createBreederWechatBinding({
          idempotencyKey: newIdempotencyKey(),
          createBreederWechatBindingRequest: {
            wechatTicket,
            phone: apiPhone(phone),
            verificationId,
            code
          },
          xTimezone: 'Asia/Taipei'
        })
        saveSessionData(response.data)
        removeSessionStorage(BREEDER_WECHAT_TICKET_KEY)
        setWechatTicket('')
      } else {
        const response = await defaultApi.createSession({
          idempotencyKey: newIdempotencyKey(),
          phoneCodeLoginRequest: {
            phone: apiPhone(phone),
            verificationId,
            code,
            device: { platform: 'android', appVersion: 'miniprogram-1.0.0', deviceName: 'WeChat Mini Program' }
          } as any,
          xTimezone: 'Asia/Taipei'
        })
        saveSessionData(response.data)
      }
      Taro.showToast({ title: '登录成功', icon: 'success' })
      void enterApp()
    } catch (error) {
      setMessage(formatNetworkError(error, '登录失败，请检查验证码'))
    } finally {
      setBusy(false)
    }
  }

  async function wechatLogin() {
    setBusy(true)
    setMessage('')
    try {
      const result = await Taro.login()
      if (!result.code) throw new Error('微信未返回登录凭证，请重试')
      const response = await defaultApi.createBreederWechatSession({
        idempotencyKey: newIdempotencyKey(),
        createBreederWechatSessionRequest: { jsCode: result.code },
        xTimezone: 'Asia/Taipei'
      })
      const data = response.data
      if (data.bindRequired && data.wechatTicket) {
        writeSessionStorage(BREEDER_WECHAT_TICKET_KEY, data.wechatTicket)
        setWechatTicket(data.wechatTicket)
        setMessage('微信已识别，请填写手机号并获取验证码完成首次绑定')
        return
      }
      saveSessionData(data)
      Taro.showToast({ title: '登录成功', icon: 'success' })
      void enterApp()
    } catch (error) {
      setMessage(formatNetworkError(error, '微信登录暂不可用，请使用手机号验证码登录'))
    } finally {
      setBusy(false)
    }
  }

  async function developmentQuickLogin() {
    if (!isDevelopmentBuild) return
    setBusy(true)
    setMessage('正在创建开发测试会话…')
    try {
      await createDevelopmentBreederSession(/^1\d{10}$/.test(phone) ? phone : devHints.phone)
      Taro.showToast({ title: '开发会话已就绪', icon: 'success' })
      void enterApp()
    } catch (error) {
      setMessage(formatDevelopmentLoginError(error))
    } finally {
      setBusy(false)
    }
  }

  return (
    <View
      style={{
        minHeight: '100vh',
        backgroundColor: palette.systemBackground,
        paddingTop: `${metrics.space24}px`
      }}
    >
      <LargeTitle title="登录熊舍" />
      <Text
        style={{
          display: 'block',
          padding: `0 ${metrics.pagePadding}px ${metrics.space16}px`,
          fontSize: '14px',
          color: 'rgba(255,255,255,0.5)',
          lineHeight: 1.5
        }}
      >
        {wechatTicket
          ? '微信已识别，补一下手机号验证码完成绑定'
          : '用手机号验证码进入经营端'}
      </Text>
      <SectionList>
        {isDevelopmentBuild ? (
          <Section
            header="开发真机"
            footer="开发预览可一键进入演示熊舍。若真机连不上，请确认公众平台已配置 request 合法域名。"
          >
            <View
              style={{
                padding: `${metrics.space12}px ${metrics.tilePadding}px`,
                display: 'flex',
                flexDirection: 'column',
                gap: '10px'
              }}
            >
              <Button block disabled={busy} onClick={developmentQuickLogin}>
                {busy ? '正在登录…' : '一键进入演示熊舍'}
              </Button>
              <Button
                variant="outlined"
                block
                disabled={busy}
                onClick={() => {
                  void copyDiag().then((ok) =>
                    Taro.showToast({ title: ok ? '诊断已复制' : '复制失败', icon: 'none' })
                  )
                }}
              >
                复制连接详情
              </Button>
            </View>
          </Section>
        ) : null}
        <Section
          header="账号"
          footer={
            isDevelopmentBuild
              ? '手填时：先获取验证码，框里默认 123456'
              : '验证码登录后进入今日'
          }
        >
          <FormRow label="手机号">
            <Input
              type="number"
              maxlength={11}
              placeholder="11 位手机号"
              placeholderStyle="color: rgba(255,255,255,0.35)"
              value={phone}
              onInput={(e) => setPhone(e.detail.value)}
              style={{ color: '#FFFFFF', fontSize: '16px' }}
            />
          </FormRow>
          <FormRow label="验证码" divider>
            <View style={{ display: 'flex', alignItems: 'center', gap: `${metrics.space12}px` }}>
              <Input
                type="number"
                maxlength={6}
                placeholder={isDevelopmentBuild ? '开发固定 123456' : '6 位验证码'}
                placeholderStyle="color: rgba(255,255,255,0.35)"
                value={code}
                onInput={(e) => setCode(e.detail.value)}
                style={{ flex: 1, color: '#FFFFFF', fontSize: '16px' }}
              />
              <Button variant="outlined" disabled={busy || cooldown > 0} onClick={requestCode}>
                {cooldown ? `${cooldown}s` : '获取验证码'}
              </Button>
            </View>
          </FormRow>
        </Section>
        <View style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <Button variant="outlined" block disabled={busy} onClick={wechatLogin}>
            {busy ? '处理中…' : '微信快捷登录'}
          </Button>
          <Button
            block
            disabled={busy || phone.length !== 11 || code.length !== 6 || !verificationId}
            onClick={login}
          >
            {busy ? '处理中…' : wechatTicket ? '绑定微信并登录' : '登录'}
          </Button>
        </View>
        {message ? (
          <Text
            style={{
              display: 'block',
              color: 'rgba(255,255,255,0.65)',
              padding: `${metrics.space16}px ${metrics.pagePadding}px 0`,
              textAlign: 'center',
              fontSize: '13px',
              lineHeight: '20px'
            }}
          >
            {message}
          </Text>
        ) : null}
        <View style={{ height: `${metrics.bottomSafePadding + 24}px` }} />
      </SectionList>
    </View>
  )
}
