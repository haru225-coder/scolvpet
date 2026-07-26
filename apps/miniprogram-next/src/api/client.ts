// 契约客户端统一入口(docs/33 M0-4):generated/ts/scolvpet-api + Taro adapter。
// 注入:Taro.request(fetch 桥)、Bearer token、写请求 Idempotency-Key。
// 业务代码只 import 本模块与 @scolvpet/api-client 的类型,禁止手写 fetch 封装。
import { Configuration, type Middleware } from '@scolvpet/api-client'

import config from '../utils/config'
import { createTaroFetch, type RequestFn } from './taro-fetch'

const MUTATING = new Set(['POST', 'PUT', 'PATCH', 'DELETE'])

// B 端登录 M1 接线后由登录流程 setApiToken;M0 保持空(样例页只用假数据)。
let currentToken = ''

export function setApiToken(token: string) {
  currentToken = token
}

export function newIdempotencyKey(): string {
  return `mp-${Date.now()}-${Math.random().toString(16).slice(2)}`
}

/** 写请求自动补 Idempotency-Key(与旧 utils/api.js 口径一致)。 */
export const idempotencyMiddleware: Middleware = {
  pre: async (ctx) => {
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
