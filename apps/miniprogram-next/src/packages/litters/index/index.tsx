import { useCallback, useState } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { ActionPanel } from '@scolvpet/mp-ui'
import { defaultApi } from '../../../api/default-api'
import { p1Api } from '../../../api/p1-api'
import { canUseCapability } from '../../../auth/permissions'
import { litterScanSubtitle } from '../../../utils/scan-labels'
import { DOMAIN_HOME, humanShortLabel } from '../../../utils/tab-routes'
import { resolveLitterParentTrialUrl } from '../../../genetics/trial-deeplink'

export default function LittersPage() {
  /** 当前被点开的窝次(行菜单) */
  const [menu, setMenu] = useState<{ id: string; litter: any } | null>(null)
  const load = useCallback(async (): Promise<BListItem[]> => {
    const response = await defaultApi.listLitters({ limit: 100 })
    return (response.data || []).map((item: any) => {
      const state = humanShortLabel(item.state || 'active')
      const managed = Number(item.currentManagedCount ?? item.current_managed_count)
      return {
        id: item.id,
        title: item.name || item.code || '窝次',
        subtitle: litterScanSubtitle(item, state) || state,
        value: Number.isFinite(managed) && managed >= 0 ? `${managed}只` : state,
        tone: item.state === 'closed' ? ('success' as const) : ('warning' as const),
        data: { litter: item }
      }
    })
  }, [])

  async function openParentTrial(litter: any) {
    try {
      const resolved = await resolveLitterParentTrialUrl({
        litter,
        getHamster: (hamsterId) => defaultApi.getHamster({ hamsterId }),
        listProfiles: () => p1Api.listGeneticProfiles()
      })
      if ('error' in resolved) {
        void Taro.showToast({ title: resolved.error, icon: 'none' })
        return
      }
      void Taro.navigateTo({ url: resolved.url })
    } catch {
      void Taro.showToast({ title: '打开试配失败', icon: 'none' })
    }
  }

  return (
    <>
      <BListPage
        title="窝次看板"
        load={load}
        onSelect={(item) => {
          const litter = (item.data as any)?.litter
          setMenu({ id: item.id, litter: litter || { id: item.id } })
        }}
        footer="点窝次：打开详情或用公母试配 · 分笼/个体化/断奶在详情里"
        emptyTitle="还没有窝次"
        emptyDescription="这里只列已经在库里的窝次。要看配色去试配模拟"
        actionLabel="试配模拟"
        onAction={() => Taro.navigateTo({ url: DOMAIN_HOME.geneticCreate })}
      />
      <ActionPanel
        open={menu != null}
        title={menu ? (menu.litter?.name || menu.litter?.code || '窝次') : undefined}
        actions={[
          {
            text: '打开窝次',
            onClick: () =>
              void Taro.navigateTo({
                url: `/packages/litters/detail/index?id=${encodeURIComponent(menu?.id || '')}`
              })
          },
          { text: '用公母试配', onClick: () => void openParentTrial(menu?.litter) },
          ...(canUseCapability('write_weight')
            ? [
                {
                  text: '批量称重',
                  onClick: () =>
                    void Taro.navigateTo({
                      url: `/packages/litters/weight/index?litterId=${encodeURIComponent(menu?.id || '')}`
                    })
                }
              ]
            : [])
        ]}
        onClose={() => setMenu(null)}
      />
    </>
  )
}
