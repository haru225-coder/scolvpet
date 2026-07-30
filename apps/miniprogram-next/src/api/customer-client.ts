import { Configuration, CustomerApi } from '@scolvpet/api-client'

import config from '../utils/config'
import { createTaroFetch } from './taro-fetch'

export type CustomerPhoneAuthorizationCode =
  | 'WECHAT_PHONE_REAUTHORIZE'
  | 'UNSUPPORTED_PHONE_COUNTRY'
  | 'PHONE_ALREADY_BOUND'
  | 'WECHAT_PHONE_QUOTA_EXHAUSTED'
  | 'WECHAT_PHONE_UNAVAILABLE'
  | 'RATE_LIMITED'

export class CustomerPhoneAuthorizationError extends Error {
  constructor(
    readonly code: CustomerPhoneAuthorizationCode,
    message: string
  ) {
    super(message)
    this.name = 'CustomerPhoneAuthorizationError'
  }
}

let customerAccessToken = ''

export function setCustomerAccessToken(token: string) {
  customerAccessToken = token
}

export function getCustomerAccessToken() {
  return customerAccessToken
}

function customerConfiguration() {
  const base = (config.API_BASE as string).replace(/\/$/, '')
  return new Configuration({
    basePath: `${base}/v1`,
    fetchApi: createTaroFetch(),
    accessToken: async () => customerAccessToken
  })
}

const customerApi = new CustomerApi(customerConfiguration())

function fallbackAuthorizationError(error: unknown) {
  if (error && typeof error === 'object') {
    const message = (error as { message?: unknown }).message
    if (typeof message === 'string' && message) {
      return new CustomerPhoneAuthorizationError('WECHAT_PHONE_REAUTHORIZE', message)
    }
  }
  return new CustomerPhoneAuthorizationError('WECHAT_PHONE_REAUTHORIZE', '授权已超时，请重新授权手机号')
}

async function toAuthorizationError(error: unknown): Promise<CustomerPhoneAuthorizationError> {
  const response = error && typeof error === 'object' ? (error as { response?: Response }).response : undefined
  if (!response || typeof response.json !== 'function') return fallbackAuthorizationError(error)

  try {
    const body = await response.json() as { error?: { code?: unknown; message?: unknown } }
    const code = body?.error?.code
    const message = body?.error?.message
    if (
      code === 'WECHAT_PHONE_REAUTHORIZE' ||
      code === 'UNSUPPORTED_PHONE_COUNTRY' ||
      code === 'PHONE_ALREADY_BOUND' ||
      code === 'WECHAT_PHONE_QUOTA_EXHAUSTED' ||
      code === 'WECHAT_PHONE_UNAVAILABLE' ||
      code === 'RATE_LIMITED'
    ) {
      return new CustomerPhoneAuthorizationError(
        code,
        typeof message === 'string' && message ? message : '微信手机号授权暂不可用'
      )
    }
  } catch (_) {
    // A rejected or malformed response is indistinguishable from a consumed
    // one-shot phone_code. The caller must restart the whole authorization.
  }
  return fallbackAuthorizationError(error)
}

export async function createCustomerWechatPhoneBinding(wechatTicket: string, phoneCode: string) {
  try {
    const response = await customerApi.createCustomerWechatPhoneBinding({
      createCustomerWechatPhoneBindingRequest: { wechatTicket, phoneCode }
    })
    const token = response.data?.accessToken || ''
    const phone = response.data?.phone || ''
    if (!token || !phone) {
      throw new CustomerPhoneAuthorizationError('WECHAT_PHONE_REAUTHORIZE', '授权已超时，请重新授权手机号')
    }
    return { token, phone }
  } catch (error) {
    if (error instanceof CustomerPhoneAuthorizationError) throw error
    throw await toAuthorizationError(error)
  }
}
