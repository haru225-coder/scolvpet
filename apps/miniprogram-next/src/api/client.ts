// 契约客户端统一入口(docs/33 M0-4):generated/ts/scolvpet-api + Taro adapter。
// 注入:Taro.request(fetch 桥)、Bearer token、写请求 Idempotency-Key。
// 业务代码只 import 本模块与 @scolvpet/api-client 的类型,禁止手写 fetch 封装。
//
// 2026-08-10：按域拆文件 + 全站 auth 不再静态拉 DefaultApi。
// 仍可从本 barrel 按需 import；未用到的 *Api 模块可被打包器剔除。
// 体积敏感路径请直接 import 对应域文件（如 ./genetic-api）。

export {
  apiConfiguration,
  buildConfiguration,
  clearApiToken,
  downloadDocumentPdf,
  getApiToken,
  idempotencyMiddleware,
  newIdempotencyKey,
  setApiToken
} from './runtime-config'

export { defaultApi } from './default-api'
export { p1Api } from './p1-api'
export { p1CrmApi } from './p1-crm-api'
export { p2Api } from './p2-api'
export { geneticApi } from './genetic-api'
