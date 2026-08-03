import { describe, expect, it, vi } from 'vitest'

import { p1Api } from '../src/api/client'
import { isDocumentVersionConflict, loadDocumentDetail } from '../src/packages/contracts/detail'

describe('合同详情冲突处理', () => {
  it('只把 HTTP 409 识别为 If-Match 冲突', () => {
    expect(isDocumentVersionConflict({ response: { status: 409 } })).toBe(true)
    expect(isDocumentVersionConflict({ response: { status: 401 } })).toBe(false)
    expect(isDocumentVersionConflict(new Error('network down'))).toBe(false)
  })

  it('按单据类型读取生成客户端详情，不再拉取整张列表', async () => {
    const getContract = vi.spyOn(p1Api, 'getContract').mockResolvedValue({ data: { id: 'contract-1' } } as never)
    const getReceipt = vi.spyOn(p1Api, 'getReceipt').mockResolvedValue({ data: { id: 'receipt-1' } } as never)

    await expect(loadDocumentDetail('contract', 'contract-1')).resolves.toMatchObject({ data: { id: 'contract-1' } })
    await expect(loadDocumentDetail('receipt', 'receipt-1')).resolves.toMatchObject({ data: { id: 'receipt-1' } })

    expect(getContract).toHaveBeenCalledWith({ documentId: 'contract-1' })
    expect(getReceipt).toHaveBeenCalledWith({ documentId: 'receipt-1' })
  })
})
