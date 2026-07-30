import { View, Text, Input } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import {
  Section,
  SectionList,
  FormRow,
  Button,
  Sticker,
  crayon,
  paperGrain,
  crayonUnderline,
  palette,
  metrics,
  typeStyle
} from '@scolvpet/mp-ui'
import { defaultApi, newIdempotencyKey } from '../../api/client'
import config from '../../utils/config'
import {
  readSessionStorage,
  removeSessionStorage,
  restoreBreederSession,
  saveBreederSession,
  writeSessionStorage
} from '../../auth/session'

const runtimeConfig = config as {
  APP_ENV?: string
  DEV_LOGIN_PHONE?: string
  DEV_LOGIN_CODE?: string
}
// 开发一键登录只在「开发构建 + 确实注入了演示凭据」时存在；
// config.js 在非开发语义下会把 DEV_LOGIN_* 强制清空，此处因而 fail-closed。
const isDevelopmentBuild =
  runtimeConfig.APP_ENV === 'development' &&
  Boolean(runtimeConfig.DEV_LOGIN_PHONE) &&
  Boolean(runtimeConfig.DEV_LOGIN_CODE)

const BREEDER_WECHAT_TICKET_KEY = 'scolvpet_breeder_wechat_bind_ticket'

function apiPhone(value: string) {
  const digits = value.replace(/\D/g, '')
  return /^1\d{10}$/.test(digits) ? `+86${digits}` : value
}

function enterApp() {
  return Taro.reLaunch({ url: '/pages/today/index' })
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
  const [phone, setPhone] = useState('')
  const [code, setCode] = useState('')
  const [verificationId, setVerificationId] = useState('')
  const [wechatTicket, setWechatTicket] = useState(() => readSessionStorage<string>(BREEDER_WECHAT_TICKET_KEY) || '')
  const [cooldown, setCooldown] = useState(0)
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState('')

  useEffect(() => {
    let active = true
    void restoreBreederSession().then((session) => {
      if (active && session) void enterApp()
    })
    return () => { active = false }
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
      setMessage(error instanceof Error ? error.message : '验证码发送失败，请稍后重试')
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
      setMessage(error instanceof Error ? error.message : '登录失败，请检查验证码')
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
      setMessage(error instanceof Error ? error.message : '微信登录暂不可用，请使用手机号验证码登录')
    } finally {
      setBusy(false)
    }
  }

  async function developmentQuickLogin() {
    if (!isDevelopmentBuild) return
    const quickPhone = /^1\d{10}$/.test(phone)
      ? phone
      : runtimeConfig.DEV_LOGIN_PHONE || ''
    const quickCode = runtimeConfig.DEV_LOGIN_CODE || ''
    if (!quickPhone || !quickCode) return
    setBusy(true)
    setMessage('正在创建开发测试会话…')
    try {
      const codeResponse = await defaultApi.sendVerificationCode({
        idempotencyKey: `mp-dev-login-code-${Date.now()}`,
        sendVerificationCodeRequest: { phone: apiPhone(quickPhone), purpose: 'login' } as any,
        xTimezone: 'Asia/Taipei'
      })
      const response = await defaultApi.createSession({
        idempotencyKey: newIdempotencyKey(),
        phoneCodeLoginRequest: {
          phone: apiPhone(quickPhone),
          verificationId: codeResponse.data.verificationId,
          code: quickCode,
          device: { platform: 'android', appVersion: 'miniprogram-dev', deviceName: 'WeChat Mini Program Dev' }
        } as any,
        xTimezone: 'Asia/Taipei'
      })
      saveSessionData(response.data)
      Taro.showToast({ title: '开发会话已就绪', icon: 'success' })
      void enterApp()
    } catch (error) {
      setMessage(error instanceof Error ? error.message : '开发会话创建失败，请检查 staging 服务')
    } finally {
      setBusy(false)
    }
  }

  return (
    <View
      style={{
        minHeight: '100vh',
        backgroundColor: crayon.paper,
        backgroundImage: paperGrain,
        paddingTop: `${metrics.space32}px`
      }}
    >
      <View
        style={{
          padding: `0 ${metrics.pagePadding}px ${metrics.sectionGap}px`,
          display: 'flex',
          alignItems: 'flex-end',
          justifyContent: 'space-between'
        }}
      >
        <Text
          style={{
            ...typeStyle('headlineSmall'),
            color: crayon.ink,
            paddingBottom: '8px',
            backgroundImage: crayonUnderline(crayon.orange),
            backgroundRepeat: 'no-repeat',
            backgroundPosition: 'left bottom',
            backgroundSize: '96px 8px'
          }}
        >
          登录熊舍
        </Text>
        <Sticker name="seed" size={40} tilt={10} />
      </View>
      <SectionList>
        {/* 探头的仓鼠:压在表单卡上沿 */}
        <View style={{ display: 'flex', justifyContent: 'flex-end', paddingRight: '22px', marginBottom: '-14px', position: 'relative', zIndex: 1 }}>
          <Sticker name="hamster" size={58} tilt={-6} />
        </View>
        <Section footer={wechatTicket ? '首次微信登录需要手机号验证码完成绑定' : 'B 端经营账号使用手机号验证码登录'}>
          <FormRow label="手机号">
            <Input
              type="number"
              maxlength={11}
              placeholder="填写繁育者手机号"
              placeholderStyle={`color: ${palette.tertiaryLabel}`}
              value={phone}
              onInput={(e) => setPhone(e.detail.value)}
            />
          </FormRow>
          <FormRow label="验证码" divider>
            <View style={{ display: 'flex', alignItems: 'center', gap: `${metrics.space12}px` }}>
              <Input
                type="number"
                maxlength={6}
                placeholder="6 位验证码"
                placeholderStyle={`color: ${palette.tertiaryLabel}`}
                value={code}
                onInput={(e) => setCode(e.detail.value)}
                style={{ flex: 1 }}
              />
              <Button
                variant="outlined"
                disabled={busy || cooldown > 0}
                onClick={requestCode}
              >
                {cooldown ? `${cooldown}s` : '获取验证码'}
              </Button>
            </View>
          </FormRow>
        </Section>
        <Button
          variant="outlined"
          block
          disabled={busy}
          onClick={wechatLogin}
        >
          {busy ? '处理中…' : '微信快捷登录'}
        </Button>
        {isDevelopmentBuild ? (
          <View style={{ display: 'flex', flexDirection: 'column', gap: `${metrics.space8}px` }}>
            <Button
              variant="outlined"
              block
              disabled={busy}
              onClick={developmentQuickLogin}
            >
              开发环境一键登录（免扫码）
            </Button>
            <Text style={{ display: 'block', color: palette.secondaryLabel, textAlign: 'center', fontSize: '12px' }}>
              使用 staging Mock 会话，仅开发构建可见
            </Text>
          </View>
        ) : null}
        <Button
          block
          disabled={busy || phone.length !== 11 || code.length !== 6 || !verificationId}
          onClick={login}
        >
          {busy ? '处理中…' : wechatTicket ? '绑定微信并登录' : '登录'}
        </Button>
        {message ? (
          <Text style={{ display: 'block', color: crayon.ink, padding: `${metrics.space16}px ${metrics.pagePadding}px 0`, textAlign: 'center' }}>
            {message}
          </Text>
        ) : null}
        <View style={{ display: 'flex', justifyContent: 'center', gap: '20px', alignItems: 'flex-end' }}>
          <Sticker name="star" size={26} tilt={-10} />
          <Sticker name="paw" size={30} tilt={8} />
          <Sticker name="star" size={20} tilt={14} />
        </View>
      </SectionList>
    </View>
  )
}
