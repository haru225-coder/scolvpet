import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { defaultApi } from '../../../api/client'

export default function DataCenterPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const response = await defaultApi.getDataCenterSummary()
    const data: any = response.data || {}
    const nImport = data.recentImports?.length || 0
    return [
      {
        id: 'imports',
        title: '最近导入',
        subtitle: nImport ? `${nImport} 个任务` : '暂无',
        value: String(nImport)
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
      footer="这里只做 CSV 导入；导出和备份还没上线"
      emptyTitle="还没有导入任务"
      emptyDescription="需要批量导入档案时，从这里进"
      actionLabel="导入 CSV"
      actionCapability="read_data_center"
      onAction={() => Taro.navigateTo({ url: '/packages/data-center/actions/index' })}
    />
  )
}
