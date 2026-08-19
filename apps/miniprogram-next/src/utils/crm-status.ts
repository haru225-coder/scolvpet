export function reservationCanConfirm(status: string) {
  return status === 'held'
}

export function reservationCanCancel(status: string) {
  return status === 'held' || status === 'confirmed'
}

export function handoverCanComplete(status: string) {
  return status === 'scheduled'
}

export function reservationStatusNote(status: string) {
  if (reservationCanConfirm(status) || reservationCanCancel(status)) {
    return '待确认可确认或取消；已确认还能取消。取消后不能恢复。'
  }
  if (status === 'cancelled' || status === 'canceled') return '已取消，不能恢复'
  if (status === 'handed_over') return '已交付，不能再改预订状态'
  return '当前状态不能在小程序里继续改'
}

/** 列表接口没有 contact_id 过滤时，详情页只留这位客户的行。 */
export const MAX_CRM_RELATED = 20

export function rowsForContact<T extends { contactId?: unknown; contact_id?: unknown }>(
  rows: T[] | null | undefined,
  contactId: string,
  limit = MAX_CRM_RELATED
): T[] {
  const id = String(contactId || '').trim()
  if (!id) return []
  return (rows || [])
    .filter((item) => String(item.contactId || item.contact_id || '') === id)
    .slice(0, limit)
}
