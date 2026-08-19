import { apiConfiguration } from './runtime-config'
import { p1CrmApi } from './p1-crm-api'

/** 复用生成客户端的 path/鉴权头，只补契约里还没声明的 contact_id。 */
export function withContactIdQuery(path: string, contactId: string): string {
  const id = String(contactId || '').trim()
  if (!id) return path
  return `${path}${path.includes('?') ? '&' : '?'}contact_id=${encodeURIComponent(id)}`
}

export function unwrapCrmList(raw: unknown): Array<Record<string, unknown>> {
  const data = raw && typeof raw === 'object' ? (raw as { data?: unknown }).data ?? raw : raw
  return Array.isArray(data)
    ? data.filter((item): item is Record<string, unknown> => Boolean(item) && typeof item === 'object')
    : []
}

export async function fetchCrmListWithContact(
  opts: { path: string; method?: string; headers?: Record<string, string> },
  contactId: string,
  fetchApi: (url: string, init: RequestInit) => Promise<Response>,
  basePath: string
): Promise<Array<Record<string, unknown>>> {
  const url = `${basePath.replace(/\/$/, '')}${withContactIdQuery(opts.path, contactId)}`
  const response = await fetchApi(url, { method: opts.method || 'GET', headers: opts.headers || {} })
  if (!response?.ok) throw new Error('CRM 列表读取失败')
  return unwrapCrmList(await response.json())
}

export async function listCrmReservationsForContact(contactId: string) {
  const fetchApi = apiConfiguration.fetchApi
  if (!fetchApi) throw new Error('API 未配置')
  return fetchCrmListWithContact(
    await p1CrmApi.listCrmReservationsRequestOpts(),
    contactId,
    fetchApi,
    apiConfiguration.basePath
  )
}

export async function listCrmHandoversForContact(contactId: string) {
  const fetchApi = apiConfiguration.fetchApi
  if (!fetchApi) throw new Error('API 未配置')
  return fetchCrmListWithContact(
    await p1CrmApi.listCrmHandoversRequestOpts(),
    contactId,
    fetchApi,
    apiConfiguration.basePath
  )
}
