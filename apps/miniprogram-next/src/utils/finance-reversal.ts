export type AccountingLike = {
  id?: string
  title?: string
  amountCents?: number
  amount_cents?: number
  entryType?: string
  type?: string
}

export function buildReversalDraft(record: AccountingLike) {
  const cents = Number(record.amountCents ?? record.amount_cents)
  const sourceType = String(record.entryType || record.type || 'expense')
  const entryType = sourceType === 'income' ? 'expense' : 'income'
  const title = String(record.title || '收支记录').trim() || '收支记录'
  if (!Number.isFinite(cents) || cents <= 0) {
    throw new Error('原记录金额无效，不能冲销')
  }
  return {
    title: title.startsWith('冲销：') ? title : `冲销：${title}`,
    amount: (cents / 100).toFixed(2),
    entryType,
    notes: record.id ? `冲销原记录 ${record.id}` : '冲销记账'
  }
}
