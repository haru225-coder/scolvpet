export type ParentRole = 'sire' | 'dam'

export function parentRoleFromCard(roleLabel: string): ParentRole | null {
  if (roleLabel === '爸爸') return 'sire'
  if (roleLabel === '妈妈') return 'dam'
  return null
}

export function parentRoleLabel(role: ParentRole): string {
  return role === 'sire' ? '爸爸' : '妈妈'
}

export function buildEndParentageBody(args: {
  childHamsterId: string
  role: ParentRole
  correctionReason: string
}) {
  return {
    childHamsterId: args.childHamsterId,
    role: args.role,
    correctionReason: args.correctionReason.trim()
  }
}

export function buildCreateParentageBody(args: {
  childHamsterId: string
  parentHamsterId: string
  role: ParentRole
  correctionReason?: string
}) {
  const reason = args.correctionReason?.trim()
  return {
    childHamsterId: args.childHamsterId,
    parentHamsterId: args.parentHamsterId,
    role: args.role,
    evidenceType: 'manual' as const,
    confidence: 1,
    validFrom: new Date(),
    notes: '经营端族谱纠错',
    correctionReason: reason || null
  }
}

export function requireCorrectionReason(raw: string): string {
  const reason = raw.trim()
  if (!reason) {
    throw new Error('纠错必须写原因，原记录会留在审计链里')
  }
  return reason
}

export function buildTaskCorrectionRequest(raw: string) {
  return { reason: requireCorrectionReason(raw) }
}

export function buildWeightCorrectionRequest(args: {
  hamsterId: string
  weightG: number
  notes?: string
  correctsWeightRecordId?: string
  correctionReason?: string
}) {
  const request: Record<string, unknown> = {
    hamsterId: args.hamsterId,
    pupIdentityId: null,
    litterId: null,
    measurementKind: 'individual',
    subjectCount: null,
    weightG: args.weightG,
    recordedAt: new Date(),
    source: 'manual',
    notes: args.notes || null
  }
  if (args.correctsWeightRecordId) {
    request.correctsWeightRecordId = args.correctsWeightRecordId
    request.correctionReason = requireCorrectionReason(args.correctionReason || '')
  }
  return request
}
