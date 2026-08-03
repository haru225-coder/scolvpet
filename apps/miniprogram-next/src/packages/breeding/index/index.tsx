import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { defaultApi } from '../../../api/client'
import { shortDate } from '../../../utils/scan-labels'
import { humanShortLabel } from '../../../utils/tab-routes'

function breedingScanSubtitle(item: Record<string, any>, state: string): string {
  const start = shortDate(item.expectedBirthStart ?? item.expected_birth_start)
  const end = shortDate(item.expectedBirthEnd ?? item.expected_birth_end)
  let window: string | undefined
  if (start && end && start !== end) window = `预产 ${start}–${end}`
  else if (start || end) window = `预产 ${start || end}`

  const pair = shortDate(item.plannedPairingAt ?? item.planned_pairing_at)
  const pairBit = pair ? `配对 ${pair}` : undefined

  // 状态只放在 value，避免副文案复读
  return [window, pairBit].filter(Boolean).join(' · ') || state
}

export default function BreedingPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const response = await defaultApi.listBreedingPlans({ limit: 100 })
    return (response.data || []).map((item: any) => {
      const state = humanShortLabel(item.state || 'draft') || String(item.state || 'draft')
      return {
        id: item.id,
        title: item.title || item.name || '繁育计划',
        subtitle: breedingScanSubtitle(item, state),
        value: state,
        tone:
          item.state === 'completed'
            ? ('success' as const)
            : item.state === 'blocked'
              ? ('danger' as const)
              : ('warning' as const)
      }
    })
  }, [])
  return (
    <BListPage
      title="繁育计划"
      load={load}
      onSelect={(item) =>
        Taro.navigateTo({ url: `/packages/breeding/detail/index?id=${encodeURIComponent(item.id)}` })
      }
      footer="配对、孕期与出生进度"
      emptyTitle="还没有繁育计划"
      emptyDescription="建一条计划后，可在这里跟进度"
      actionLabel="新建繁育计划"
      actionCapability="write_breeding"
      onAction={() => Taro.navigateTo({ url: '/packages/breeding/create/index' })}
    />
  )
}
