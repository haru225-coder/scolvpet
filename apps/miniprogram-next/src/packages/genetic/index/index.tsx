import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { p1Api } from '../../../api/client'
import { DOMAIN_HOME } from '../../../utils/tab-routes'

/** 试配入口列表：主 CTA 直接进模拟器；列表仅作档案/位点参考。 */
export default function GeneticPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const [profiles, loci] = await Promise.all([p1Api.listGeneticProfiles(), p1Api.listGeneticLoci()])
    return [
      ...(loci.data || []).map((item: any) => ({
        id: `locus-${item.id}`,
        title: item.name || item.code || '遗传位点',
        subtitle: item.series || item.description || item.code || undefined
      })),
      ...(profiles.data || []).map((item: any) => {
        const bound = String(item.hamsterName || item.hamsterCode || '').trim()
        return {
          id: `profile-${item.id}`,
          title: item.name || '遗传档案',
          subtitle: bound || (item.hamsterId ? '已关联个体' : '未绑定个体'),
          value: bound || undefined,
          tone: bound || item.hamsterId ? ('success' as const) : undefined
        }
      })
    ]
  }, [])
  return (
    <BListPage
      title="试配模拟"
      load={load}
      footer="主路径：选公母样子 → 看宝宝概率。不走繁育计划。"
      emptyTitle="直接开始试配"
      emptyDescription="选好公母样子，立刻看可能长什么样"
      actionLabel="开始试配"
      actionCapability="write_genetic"
      onAction={() => Taro.navigateTo({ url: DOMAIN_HOME.geneticCreate })}
    />
  )
}
