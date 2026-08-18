import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { p1Api } from '../../../api/client'
import { shortDate } from '../../../utils/scan-labels'
import { humanShortLabel } from '../../../utils/tab-routes'

function formatYuan(cents: unknown) {
  const n = Number(cents)
  if (!Number.isFinite(n)) return '—'
  return `¥${(n / 100).toFixed(2)}`
}

export default function FinancePage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const [summary, records] = await Promise.all([
      p1Api.getAccountingSummary({}),
      p1Api.listAccountingRecords({})
    ])
    const data = summary.data as any
    const income = Number(data?.incomeCents ?? data?.income_cents)
    const expense = Number(data?.expenseCents ?? data?.expense_cents)
    const net =
      Number.isFinite(income) && Number.isFinite(expense) ? income - expense : Number.NaN
    const summaryItem: BListItem = {
      id: 'summary',
      title: '本期收支汇总',
      subtitle: `收入 ${formatYuan(income)} · 支出 ${formatYuan(expense)}`,
      value: Number.isFinite(net) ? formatYuan(net) : undefined,
      tone: Number.isFinite(net) && net >= 0 ? 'success' : Number.isFinite(net) ? 'warning' : undefined
    }
    const rows = (records.data || []).map((item: any) => {
      const entry = item.entryType || item.type || 'expense'
      const kind = humanShortLabel(entry) || String(entry)
      const when = shortDate(item.occurredAt || item.occurred_at) || ''
      return {
        id: item.id,
        title: item.title || item.description || '收支记录',
        subtitle: [kind, when].filter(Boolean).join(' · '),
        value: formatYuan(item.amountCents ?? item.amount_cents),
        tone: entry === 'income' ? ('success' as const) : ('warning' as const),
        data: {
          id: item.id,
          title: item.title || item.description || '收支记录',
          amountCents: item.amountCents ?? item.amount_cents,
          entryType: entry
        }
      }
    })
    return rows.length ? [summaryItem, ...rows] : [summaryItem]
  }, [])
  return (
    <BListPage
      title="财务"
      load={load}
      footer="记账不能改。点一笔记反向冲销"
      emptyTitle="还没有收支记录"
      emptyDescription="记一笔收入或支出，汇总会出现在这里"
      actionLabel="新增收支"
      actionCapability="write_accounting"
      onAction={() => Taro.navigateTo({ url: '/packages/finance/create/index' })}
      secondaryActionLabel="管理记账分类"
      onSecondaryAction={() => Taro.navigateTo({ url: '/packages/finance/categories/index' })}
      onSelect={(item) => {
        if (item.id === 'summary' || !item.data) return
        const q = [
          `reverse=1`,
          `id=${encodeURIComponent(String(item.data.id || ''))}`,
          `title=${encodeURIComponent(String(item.data.title || ''))}`,
          `amountCents=${encodeURIComponent(String(item.data.amountCents || ''))}`,
          `entryType=${encodeURIComponent(String(item.data.entryType || 'expense'))}`
        ].join('&')
        void Taro.navigateTo({ url: `/packages/finance/create/index?${q}` })
      }}
    />
  )
}
