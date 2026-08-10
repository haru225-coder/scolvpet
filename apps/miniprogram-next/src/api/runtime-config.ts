// 契约客户端运行时配置(docs/33 M0-4)：token / Configuration / Taro fetch。
// 不含任何 *Api 类，供 auth 等全站模块静态引用，避免把 DefaultApi 钉进主包。
import { Configuration, type Middleware } from '@scolvpet/api-client'
import Taro from '@tarojs/taro'

import config from '../utils/config'
import type { RequestContextLike } from './types'
import { createTaroFetch, type RequestFn } from './taro-fetch'

const MUTATING = new Set(['POST', 'PUT', 'PATCH', 'DELETE'])

// B 端登录 M1 接线后由登录流程 setApiToken;M0 保持空(样例页只用假数据)。
let currentToken = ''

export function setApiToken(token: string) {
  currentToken = token
}

export function getApiToken() {
  return currentToken
}

export function clearApiToken() {
  currentToken = ''
}

export function newIdempotencyKey(): string {
  return `mp-${Date.now()}-${Math.random().toString(16).slice(2)}`
}

/**
 * PDF is a binary download boundary: the generated JSON client deliberately
 * uses Taro.request, while this endpoint must preserve the temporary file.
 */
export function downloadDocumentPdf(kind: 'contract' | 'receipt', documentId: string): Promise<string> {
  const base = (config.API_BASE as string).replace(/\/$/, '')
  const resource = kind === 'receipt' ? 'receipts' : 'contracts'
  const token = getApiToken()
  return new Promise((resolve, reject) => {
    Taro.downloadFile({
      url: `${base}/v1/${resource}/${encodeURIComponent(documentId)}/pdf`,
      header: token ? { Authorization: `Bearer ${token}` } : {},
      success: (response) => {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          resolve(response.tempFilePath)
        } else {
          reject(new Error(`PDF 下载失败（${response.statusCode}）`))
        }
      },
      fail: (cause) => reject(new Error(cause.errMsg || 'PDF 下载失败'))
    })
  })
}

/** 写请求自动补 Idempotency-Key(与旧 utils/api.js 口径一致)。 */
export const idempotencyMiddleware: Middleware = {
  pre: async (ctx: RequestContextLike) => {
    const method = (ctx.init.method || 'GET').toUpperCase()
    const headers = { ...((ctx.init.headers as Record<string, string>) || {}) }
    if (MUTATING.has(method) && !headers['Idempotency-Key']) {
      headers['Idempotency-Key'] = newIdempotencyKey()
    }
    return { url: ctx.url, init: { ...ctx.init, headers } }
  }
}

export function buildConfiguration(options?: { requestFn?: RequestFn; basePath?: string }) {
  const base = (options?.basePath ?? (config.API_BASE as string)).replace(/\/$/, '')
  return new Configuration({
    basePath: `${base}/v1`,
    fetchApi: createTaroFetch(options?.requestFn),
    accessToken: async () => currentToken,
    middleware: [idempotencyMiddleware]
  })
}

/** 应用级共享配置(getter 便于测试重建)。 */
export const apiConfiguration = buildConfiguration()
