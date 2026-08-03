import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { defaultApi } from '../../../api/client'

export default function DataCenterPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const response = await defaultApi.getDataCenterSummary()
    const data: any = response.data || {}
    const nImport = data.recentImports?.length || 0
    const nExport = data.recentExports?.length || 0
    const nBackup = data.recentBackups?.length || 0
    return [
      {
        id: 'imports',
        title: '最近导入',
        subtitle: nImport ? `${nImport} 个任务` : '暂无',
        value: String(nImport)
      },
      {
        id: 'exports',
        title: '最近导出',
        subtitle: nExport ? `${nExport} 个任务` : '暂无',
        value: String(nExport)
      },
      {
        id: 'backups',
        title: '最近备份',
        subtitle: nBackup ? `${nBackup} 个任务` : '暂无',
        value: String(nBackup)
      },
      ...(data.usage || []).map((item: any, index: number) => ({
        id: `usage-${index}`,
        title: item.metric || item.name || '用量',
        subtitle: item.unit ? String(item.unit) : undefined,
        value: String(item.value ?? item.current ?? '—')
      }))
    ]
  }, [])
  return (
    <BListPage
      title="数据中心"
      load={load}
      footer="导入、导出和备份都在这里"
      emptyTitle="还没有数据任务"
      emptyDescription="需要导入导出或备份时，从这里进"
      actionLabel="导入 / 导出 / 备份"
      actionCapability="read_data_center"
      onAction={() => Taro.navigateTo({ url: '/packages/data-center/actions/index' })}
    />
  )
}
