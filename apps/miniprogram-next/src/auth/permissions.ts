import { readBreederSession } from './session'

/**
 * 前端只负责收敛入口，后端 RBAC 仍是最终权限裁决。
 * 兼容旧会话：当 capabilities 尚未落盘时按 memberRole 给出最小可用判断。
 */
// 只给 owner：账目/流水写入与数据导入。
// 即使服务端下发了这两个 capability，前端也不给非 owner 开入口；
// 后端 RBAC 仍是最终裁决。
const OWNER_ONLY_CAPABILITIES = ['write_accounting', 'write_import']

export function canUseCapability(capability: string): boolean {
  const session = readBreederSession()
  if (!session) return false
  if (session.memberRole === 'owner') return true
  if (session.memberRole === 'viewer') return false
  if (OWNER_ONLY_CAPABILITIES.includes(capability)) return false
  if (session.capabilities.includes(capability)) return true
  const roleFallback: Record<string, string[]> = {
    breeder: ['write_breeding', 'write_litter', 'write_hamster', 'write_weight', 'write_health', 'write_task', 'write_genetic', 'manage_subscriptions'],
    caretaker: ['write_litter', 'write_hamster', 'write_weight', 'write_health', 'write_task', 'manage_subscriptions'],
    staff: ['write_crm', 'write_documents', 'manage_subscriptions']
  }
  return roleFallback[session.memberRole || '']?.includes(capability) ?? false
}
