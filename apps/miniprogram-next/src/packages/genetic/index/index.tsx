import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { p1Api } from '../../../api/client'

export default function GeneticPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const [profiles, loci] = await Promise.all([p1Api.listGeneticProfiles(), p1Api.listGeneticLoci()])
    return [
      ...(loci.data || []).map((item: any) => ({ id: `locus-${item.id}`, title: item.name || item.code || '遗传位点', subtitle: item.series || item.description || '', value: '位点', tone: 'accent' as const })),
      ...(profiles.data || []).map((item: any) => ({ id: `profile-${item.id}`, title: item.name || '遗传档案', subtitle: item.hamsterId || item.genotype || '', value: '档案', tone: 'success' as const }))
    ]
  }, [])
  return <BListPage title="遗传与模拟" eyebrow="M4" load={load} footer="位点、表型档案与模拟接口来自 P1 API" actionLabel="打开遗传工作台" actionCapability="write_genetic" onAction={() => Taro.navigateTo({ url: '/packages/genetic/create/index' })} />
}
