import { storageGet, storageKeys, storageRemove, storageSet } from '../utils/storage'

const TODAY_SNAPSHOT_KEY = 'scolvpet_b_today_snapshot'
const ANIMAL_SNAPSHOT_PREFIX = 'scolvpet_b_animal_snapshot:'

// 快照只为弱网应急，过期就不该再当作“可信经营数据”展示。
const SNAPSHOT_TTL_MS = 7 * 24 * 60 * 60 * 1000
// 个体快照按 id 展开，不设上限会慢慢吃光 Storage（微信 10MB）。
const MAX_ANIMAL_SNAPSHOTS = 40

type Snapshot<T> = { savedAt?: number; value?: T; tasks?: T }

function isFresh(savedAt: unknown): savedAt is number {
  const at = Number(savedAt) || 0
  return at > 0 && Date.now() - at < SNAPSHOT_TTL_MS
}

function animalSnapshotKeys(): string[] {
  return storageKeys().filter((key) => key.startsWith(ANIMAL_SNAPSHOT_PREFIX))
}

/** 超出上限时先淘汰最旧的个体快照；宿主不支持枚举时自然降级为无操作。 */
function evictAnimalSnapshots() {
  const keys = animalSnapshotKeys()
  if (keys.length <= MAX_ANIMAL_SNAPSHOTS) return
  const aged = keys
    .map((key) => ({ key, savedAt: Number(storageGet<Snapshot<unknown>>(key)?.savedAt) || 0 }))
    .sort((a, b) => a.savedAt - b.savedAt)
  for (const item of aged.slice(0, keys.length - MAX_ANIMAL_SNAPSHOTS)) storageRemove(item.key)
}

export function saveTodaySnapshot(tasks: unknown[]) {
  storageSet(TODAY_SNAPSHOT_KEY, { savedAt: Date.now(), tasks })
}

export function readTodaySnapshot(): { savedAt: number; tasks: any[] } | null {
  const value = storageGet<Snapshot<any[]>>(TODAY_SNAPSHOT_KEY)
  if (!value?.savedAt || !Array.isArray(value.tasks)) return null
  if (!isFresh(value.savedAt)) {
    storageRemove(TODAY_SNAPSHOT_KEY)
    return null
  }
  return { savedAt: value.savedAt, tasks: value.tasks }
}

export function saveAnimalSnapshot(id: string, value: unknown) {
  storageSet(`${ANIMAL_SNAPSHOT_PREFIX}${id}`, { savedAt: Date.now(), value })
  evictAnimalSnapshots()
}

export function readAnimalSnapshot<T = any>(id: string): { savedAt: number; value: T } | null {
  const key = `${ANIMAL_SNAPSHOT_PREFIX}${id}`
  const stored = storageGet<Snapshot<T>>(key)
  if (!stored?.savedAt || stored.value === undefined) return null
  if (!isFresh(stored.savedAt)) {
    storageRemove(key)
    return null
  }
  return { savedAt: stored.savedAt, value: stored.value }
}

/** 退出登录时调用：上一个账号的离线数据不能留在本机。 */
export function clearAllSnapshots() {
  storageRemove(TODAY_SNAPSHOT_KEY)
  for (const key of animalSnapshotKeys()) storageRemove(key)
}
