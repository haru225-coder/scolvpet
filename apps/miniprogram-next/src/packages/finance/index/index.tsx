import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { p1Api } from '../../../api/client'

export default function FinancePage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const [summary, records] = await Promise.all([p1Api.getAccountingSummary({}), p1Api.listAccountingRecords({})])
    const data = summary.data as any
    const summaryItem: BListItem = { id: 'summary', title: '本期收支汇总', subtitle: `收入 ${data?.incomeCents ?? 0} · 支出 ${data?.expenseCents ?? 0}`, value: '汇总', tone: 'accent' }
    return [summaryItem, ...(records.data || []).map((item: any) => ({ id: item.id, title: item.title || item.description || '收支记录', subtitle: `${item.entryType || item.type || ''} · ${item.occurredAt || ''}`, value: `${item.amountCents ?? item.amount_cents ?? 0}`, tone: item.entryType === 'income' ? 'success' as const : 'warning' as const }))]
  }, [])
  return <BListPage title="财务" eyebrow="M3" load={load} footer="收支记录、分类与汇总来自 P1 API" actionLabel="新增收支" actionCapability="write_accounting" onAction={() => Taro.navigateTo({ url: '/packages/finance/create/index' })} secondaryActionLabel="管理记账分类" onSecondaryAction={() => Taro.navigateTo({ url: '/packages/finance/categories/index' })} />
}
