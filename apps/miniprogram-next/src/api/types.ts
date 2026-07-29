// 生成客户端(@scolvpet/api-client)在 monorepo 外不可解析，回调参数因此拿不到
// 推导类型。这里给出最小信封类型，把原本隐式的 any 变成显式、可搜索的声明。
// 待 make generate-ts-client 后，可逐个换成生成的响应类型。
export type ApiEnvelope<T = any> = {
  data?: T
  meta?: unknown
}

/** typescript-fetch middleware 的 pre 上下文（仅用到的字段）。 */
export type RequestContextLike = {
  url: string
  init: RequestInit
}
