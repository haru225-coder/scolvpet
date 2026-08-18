export function requireCreatedId(raw: unknown, label: string) {
  const id = String(raw || '').trim()
  if (!id) throw new Error(`${label}已写入，但没有返回编号`)
  return id
}

export function animalDetailUrl(id: unknown) {
  return `/packages/animals/detail/index?id=${encodeURIComponent(requireCreatedId(id, '个体'))}`
}

export function contactDetailUrl(id: unknown) {
  return `/packages/crm/detail/index?id=${encodeURIComponent(`contact-${requireCreatedId(id, '客户')}`)}`
}

export function reservationDetailUrl(id: unknown) {
  return `/packages/crm/detail/index?id=${encodeURIComponent(`reservation-${requireCreatedId(id, '预订')}`)}`
}

export function handoverDetailUrl(id: unknown) {
  return `/packages/crm/detail/index?id=${encodeURIComponent(`handover-${requireCreatedId(id, '交付')}`)}`
}

export function animalsListUrl() {
  return '/packages/animals/index/index'
}

export function todayUrl() {
  return '/pages/today/index'
}
