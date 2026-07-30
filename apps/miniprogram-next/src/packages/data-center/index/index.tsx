import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { defaultApi } from '../../../api/client'

export default function DataCenterPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const response = await defaultApi.getDataCenterSummary()
    const data: any = response.data || {}
    return [
      { id: 'imports', title: '最近导入', subtitle: `${data.recentImports?.length || 0} 个任务`, value: data.usageStatus || 'current', tone: 'accent' as const },
      { id: 'exports', title: '最近导出', subtitle: `${data.recentExports?.length || 0} 个任务`, value: '任务', tone: 'accent' as const },
      { id: 'backups', title: '最近备份', subtitle: `${data.recentBackups?.length || 0} 个任务`, value: '任务', tone: 'success' as const },
      ...(data.usage || []).map((item: any, index: number) => ({ id: `usage-${index}`, title: item.metric || item.name || '用量', subtitle: String(item.value ?? item.current ?? '-'), value: '用量', tone: 'warning' as const }))
    ]
  }, [])
  return <BListPage title="数据中心" eyebrow="M4" load={load} footer="汇总、导入、导出、备份任务统一使用 DefaultApi" actionLabel="导入 / 导出 / 备份" actionCapability="read_data_center" onAction={() => Taro.navigateTo({ url: '/packages/data-center/actions/index' })} />
}
