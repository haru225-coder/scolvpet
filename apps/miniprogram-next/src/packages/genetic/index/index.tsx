import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { p1Api } from '../../../api/client'

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
      title="这两只会生出什么"
      load={load}
      footer="结果先说人话，专业代码收在「专业信息」里"
      emptyTitle="还没有试配记录"
      emptyDescription="选好公母样子，点试配看宝宝可能长什么样"
      actionLabel="试配一下"
      actionCapability="write_genetic"
      onAction={() => Taro.navigateTo({ url: '/packages/genetic/create/index' })}
    />
  )
}
