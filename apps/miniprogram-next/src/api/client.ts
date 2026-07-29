// 契约客户端统一入口(docs/33 M0-4):generated/ts/scolvpet-api + Taro adapter。
// 注入:Taro.request(fetch 桥)、Bearer token、写请求 Idempotency-Key。
// 业务代码只 import 本模块与 @scolvpet/api-client 的类型,禁止手写 fetch 封装。
import {
  Configuration,
  DefaultApi,
  GeneticApi,
  P1Api,
  P1CRMApi,
  P2Api,
  type Middleware
} from '@scolvpet/api-client'
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

export function clearApiToken() {
  currentToken = ''
}

export function newIdempotencyKey(): string {
  return `mp-${Date.now()}-${Math.random().toString(16).slice(2)}`
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

// 所有 B 端业务页只从这些实例消费生成客户端，避免页面自行拼接 URL。
export const defaultApi = new DefaultApi(apiConfiguration)
export const p1Api = new P1Api(apiConfiguration)
export const p1CrmApi = new P1CRMApi(apiConfiguration)
export const p2Api = new P2Api(apiConfiguration)
export const geneticApi = new GeneticApi(apiConfiguration)
