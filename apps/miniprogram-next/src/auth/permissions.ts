import { peekBreederSession } from './session'

/**
 * 前端只负责收敛入口，后端 RBAC 仍是最终权限裁决。
 * 兼容旧会话：当 capabilities 尚未落盘时按 memberRole 给出最小可用判断。
 */
// 只给 owner：账目/流水写入与数据导入。
// 即使服务端下发了这两个 capability，前端也不给非 owner 开入口；
// 后端 RBAC 仍是最终裁决。
const OWNER_ONLY_CAPABILITIES = ['write_accounting', 'write_import']

export function canUseCapability(capability: string): boolean {
  const session = peekBreederSession()
  if (!session) return false
  // 兼容 capabilities 里带 member_role:owner、或 memberRole 字段
  const role = String(session.memberRole || '').toLowerCase()
  const caps = Array.isArray(session.capabilities) ? session.capabilities : []
  if (role === 'owner' || caps.includes('member_role:owner')) return true
  if (role === 'viewer') return false
  if (OWNER_ONLY_CAPABILITIES.includes(capability)) return false
  if (caps.includes(capability)) return true
  // 试配模拟：服务端按成员可读；演示号常有 write_breeding 而无 write_genetic
  if (capability === 'write_genetic' && (caps.includes('write_breeding') || caps.includes('write_hamster'))) {
    return true
  }
  const roleFallback: Record<string, string[]> = {
    breeder: ['read_data_center', 'write_breeding', 'write_litter', 'write_hamster', 'write_weight', 'write_health', 'write_task', 'write_genetic', 'manage_subscriptions'],
    caretaker: ['read_data_center', 'write_litter', 'write_hamster', 'write_weight', 'write_health', 'write_task', 'manage_subscriptions'],
    staff: ['read_data_center', 'write_crm', 'write_documents', 'manage_subscriptions']
  }
  return roleFallback[role]?.includes(capability) ?? false
}
