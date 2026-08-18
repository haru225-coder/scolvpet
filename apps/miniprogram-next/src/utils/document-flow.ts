export function documentDetailUrl(kind: 'contract' | 'receipt', documentId: string) {
  const id = String(documentId || '').trim()
  if (!id) throw new Error('缺少单据编号')
  return `/packages/contracts/detail/index?kind=${kind}&documentId=${encodeURIComponent(id)}`
}

export function documentCreatedToast(issued: boolean, kind: 'contract' | 'receipt') {
  const label = kind === 'receipt' ? '回执' : '合同'
  return issued ? `${label}已创建并签发` : `${label}已创建，待签发`
}
