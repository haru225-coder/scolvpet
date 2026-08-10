import config from './config'

/** 逗号 / 中文逗号 / 空白分隔的 tmpl_ 列表。 */
export function parseTemplateIds(value: string) {
  return [...new Set(String(value || '').split(/[,，\s]+/).map((item) => item.trim()).filter(Boolean))]
}

/** 构建配置里写的模板（未注入时为空）。 */
export function localConfiguredTemplateIds() {
  return parseTemplateIds(
    (config as { WECHAT_SUBSCRIBE_TEMPLATE_IDS?: string }).WECHAT_SUBSCRIBE_TEMPLATE_IDS || ''
  )
}

/**
 * 可用订阅模板 = 服务端登记 ∪ 构建配置。
 * 入口展示前应调用：无模板则隐藏入口，勿对用户说「运营配置」。
 */
export async function resolveSubscribeTemplateIds(): Promise<string[]> {
  const fromConfig = localConfiguredTemplateIds()
  try {
    const { defaultApi } = await import('../api/default-api')
    const response = await defaultApi.listWechatSubscriptions()
    const records = Array.isArray(response.data) ? response.data : []
    const serverIds = records
      .map((record: { templateId?: string | null }) => String(record.templateId || '').trim())
      .filter(Boolean)
    return [...new Set([...serverIds, ...fromConfig])]
  } catch {
    return fromConfig
  }
}

export function hasAnySubscribeTemplates(ids: string[]) {
  return ids.length > 0
}
