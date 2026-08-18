import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { defaultApi } from '../../../api/client'

export default function DataCenterPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const response = await defaultApi.getDataCenterSummary()
    const data = (response.data || {}) as unknown as Record<string, unknown>
    const imports = Array.isArray(data.recentImports) ? data.recentImports : []
    const usage = Array.isArray(data.usage) ? data.usage : []
    const importItems = imports.map((raw) => {
      const item = (raw && typeof raw === 'object' ? raw : {}) as Record<string, unknown>
      const id = String(item.id || '')
      return {
        id: id || `import-${String(item.createdAt || '')}`,
        title: String(item.templateType || item.template_type || '导入任务'),
        subtitle: String(item.phase || item.status || '处理中'),
        value: item.importedRows != null ? `${item.importedRows} 行` : undefined,
        data: { jobId: id }
      }
    })
    const usageItems = usage.map((raw, index) => {
      const item = (raw && typeof raw === 'object' ? raw : {}) as Record<string, unknown>
      return {
        id: `usage-${index}`,
        title: String(item.metric || item.name || '用量'),
        subtitle: item.unit ? String(item.unit) : undefined,
        value: String(item.value ?? item.current ?? '—')
      }
    })
    return [...importItems, ...usageItems]
  }, [])
  return (
    <BListPage
      title="数据中心"
      load={load}
      footer="点导入任务可继续预检/提交；导出和备份还没上线"
      emptyTitle="还没有导入任务"
      emptyDescription="需要批量导入档案时，从这里进"
      actionLabel="导入 CSV"
      actionCapability="read_data_center"
      onAction={() => Taro.navigateTo({ url: '/packages/data-center/actions/index' })}
      onSelect={(item) => {
        const jobId = String(item.data?.jobId || item.id || '')
        if (!jobId || jobId.startsWith('usage-')) return
        void Taro.navigateTo({
          url: `/packages/data-center/actions/index?jobId=${encodeURIComponent(jobId)}`
        })
      }}
    />
  )
}
