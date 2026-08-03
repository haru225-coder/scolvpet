import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { p1Api } from '../../../api/client'
import { humanShortLabel } from '../../../utils/tab-routes'

export default function ContractsPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const [contracts, receipts] = await Promise.all([p1Api.listContracts(), p1Api.listReceipts()])
    return [
      ...(contracts.data || []).map((item: any) => {
        const status = humanShortLabel(item.status || item.state || 'draft')
        const who = String(item.contactName || item.customerName || '').trim()
        return {
          id: `contract-${item.id}`,
          title: item.title || item.documentNo || '合同',
          subtitle: [status, who].filter(Boolean).join(' · ') || status,
          value: status,
          tone: item.status === 'issued' ? ('success' as const) : ('warning' as const)
        }
      }),
      ...(receipts.data || []).map((item: any) => {
        const status = humanShortLabel(item.status || item.state || 'draft')
        const who = String(item.contactName || item.customerName || '').trim()
        return {
          id: `receipt-${item.id}`,
          title: item.title || item.documentNo || '回执',
          subtitle: [status, who].filter(Boolean).join(' · ') || status,
          value: status,
          tone: item.status === 'issued' ? ('success' as const) : ('warning' as const)
        }
      })
    ]
  }, [])
  return (
    <BListPage
      title="合同与回执"
      load={load}
      footer="点记录可查看签发、撤销和公开链接"
      emptyTitle="还没有合同或回执"
      emptyDescription="需要时点下方新增；也可先管模板"
      actionLabel="新增合同或回执"
      actionCapability="write_documents"
      onAction={() => Taro.navigateTo({ url: '/packages/contracts/create/index' })}
      secondaryActionLabel="管理模板"
      onSecondaryAction={() => Taro.navigateTo({ url: '/packages/contracts/templates/index' })}
      onSelect={(item) => {
        const separator = item.id.indexOf('-')
        const kind = separator > 0 ? item.id.slice(0, separator) : 'contract'
        const documentId = separator > 0 ? item.id.slice(separator + 1) : item.id
        Taro.navigateTo({
          url: `/packages/contracts/detail/index?kind=${kind}&documentId=${encodeURIComponent(documentId)}`
        })
      }}
    />
  )
}
