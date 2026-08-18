/**
 * 列表/卡片可扫读字段（P2.8）。
 * 原则：一行里先放决策信息（性别、日龄、状态、数量），再放编号/笼位。
 */

function asDate(raw: unknown): Date | null {
  if (raw == null || raw === '') return null
  if (raw instanceof Date) return Number.isNaN(raw.getTime()) ? null : raw
  const d = new Date(String(raw))
  return Number.isNaN(d.getTime()) ? null : d
}

/** 公 / 母 / 空（列表标题旁的短符号） */
export function sexMark(sex: unknown): string {
  const s = String(sex ?? '').trim()
  if (s === 'female') return '♀'
  if (s === 'male') return '♂'
  return ''
}

/** 日龄 / 月龄；无出生日期则 undefined */
export function ageLabel(birth: unknown, now = Date.now()): string | undefined {
  const d = asDate(birth)
  if (!d) return undefined
  const days = Math.floor((now - d.getTime()) / 86_400_000)
  if (days < 0) return undefined
  // 仓鼠体量：60 天内看日龄；1 年内看月龄；之后看岁
  if (days < 60) return `${days}日龄`
  if (days < 365) return `${Math.max(1, Math.floor(days / 30.4375))}月龄`
  const years = Math.floor(days / 365.25)
  return `${Math.max(1, years)}岁`
}

/** 短日期 yyyy/m/d */
export function shortDate(raw: unknown): string | undefined {
  const d = asDate(raw)
  if (!d) return undefined
  return `${d.getFullYear()}/${d.getMonth() + 1}/${d.getDate()}`
}

function pickString(...candidates: unknown[]): string {
  for (const c of candidates) {
    const s = String(c ?? '').trim()
    if (s) return s
  }
  return ''
}

/** 个体列表/海报副文案：编号 · 日龄 · 样子 · 笼位 */
export function animalScanSubtitle(animal: Record<string, unknown> | null | undefined): string {
  if (!animal) return ''
  const code = pickString(animal.internalCode, animal.internal_code)
  const age = ageLabel(animal.birthDate ?? animal.birth_date)
  const pheno = pickString(
    animal.corePhenotypeLabel,
    animal.phenotypeLabel,
    animal.phenotype,
    animal.varietyCode,
    animal.variety_code
  )
  const encName = pickString(animal.currentEnclosureName, animal.enclosureName)
  const cage = encName || (animal.currentEnclosureId || animal.current_enclosure_id ? '已分笼' : '未分笼')
  // 无样子时不写「样子未记」——占字数且零信息
  return [code, age, pheno || undefined, cage].filter(Boolean).join(' · ')
}

/** 个体展示名 + 性别符 */
export function animalScanTitle(animal: Record<string, unknown> | null | undefined): string {
  if (!animal) return '个体'
  const name = pickString(animal.name, animal.internalCode, animal.internal_code) || '未命名'
  const mark = sexMark(animal.sex)
  return mark ? `${name} ${mark}` : name
}

/** 窝次副文案：状态 · 日龄/出生 · 在管 N 只 */
export function litterScanSubtitle(litter: Record<string, unknown> | null | undefined, stateLabel?: string): string {
  if (!litter) return ''
  const state = stateLabel || pickString(litter.state, litter.status)
  const age = ageLabel(litter.bornAt ?? litter.born_at)
  const born = age ? undefined : shortDate(litter.bornAt ?? litter.born_at)
  const managed = Number(litter.currentManagedCount ?? litter.current_managed_count)
  const count =
    Number.isFinite(managed) && managed >= 0 ? `在管 ${managed} 只` : undefined
  return [state, age || born, count].filter(Boolean).join(' · ')
}

/** 任务计划时间：到点 HH:mm；无效则「时间待定」 */
export function taskTimeLabel(scheduledAt: unknown): string {
  const d = asDate(scheduledAt)
  if (!d) return '时间待定'
  return d.toLocaleString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

/**
 * 任务目标扫读：优先用 subject 映射（今日页按任务 id 点查），
 * 否则回退 task 上偶发字段或类型占位。不编造假名。
 */
export function taskTargetScanLabel(
  task: Record<string, unknown> | null | undefined,
  subject?: Record<string, unknown> | null
): string {
  if (!task && !subject) return '照护对象'
  const type = String(task?.targetType ?? task?.target_type ?? '').toLowerCase()
  const isLitter =
    type === 'litter' ||
    Boolean(subject && (subject.bornAt != null || subject.born_at != null || subject.currentManagedCount != null))

  if (subject) {
    if (isLitter) {
      const litterName = pickString(subject.name, subject.title, subject.internalCode, subject.internal_code)
      if (litterName) return litterName
      const managed = Number(subject.currentManagedCount ?? subject.current_managed_count)
      if (Number.isFinite(managed) && managed >= 0) return `窝次 · 在管 ${managed}`
      return '一窝'
    }
    return animalScanTitle(subject)
  }

  const rawName = pickString(
    task?.targetName,
    task?.target_name,
    task?.subjectName,
    task?.subject_name,
    task?.hamsterName,
    task?.hamster_name
  )
  if (rawName) return rawName
  if (type === 'hamster' || type === 'animal' || type === 'pup_identity') return '一只仓鼠'
  if (type === 'litter') return '一窝'
  if (type === 'enclosure') return '笼舍'
  if (type === 'breeding_plan') return '繁育计划'
  return '照护对象'
}

/** 任务目标日龄：个体用 birthDate，窝次用 bornAt；无则 undefined */
export function taskTargetAgeLabel(
  task: Record<string, unknown> | null | undefined,
  subject?: Record<string, unknown> | null,
  now = Date.now()
): string | undefined {
  if (subject) {
    const fromSubject =
      ageLabel(subject.birthDate ?? subject.birth_date, now) ||
      ageLabel(subject.bornAt ?? subject.born_at, now)
    if (fromSubject) return fromSubject
  }
  if (!task) return undefined
  return (
    ageLabel(task.targetBirthDate ?? task.target_birth_date ?? task.birthDate ?? task.birth_date, now) ||
    ageLabel(task.bornAt ?? task.born_at, now)
  )
}

/**
 * 今日/任务列表副文案：时间 · 目标 · 日龄
 * 例：`09:00 · 布丁 ♀ · 12日龄`
 */
export function taskScanSubtitle(
  task: Record<string, unknown> | null | undefined,
  subject?: Record<string, unknown> | null,
  now = Date.now()
): string {
  if (!task) return ''
  const time = taskTimeLabel(task.scheduledAt ?? task.scheduled_at)
  const target = taskTargetScanLabel(task, subject)
  const age = taskTargetAgeLabel(task, subject, now)
  return [time, target, age].filter(Boolean).join(' · ')
}
