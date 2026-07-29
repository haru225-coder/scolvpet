import { Input, ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useCallback, useEffect, useState } from 'react'
import {
  NavBar,
  LargeTitle,
  Section,
  SectionList,
  Cell,
  Tag,
  Sticker,
  Empty,
  crayon,
  paperGrain,
  metrics,
  palette
} from '@scolvpet/mp-ui'

import { defaultApi } from '../../../api/client'
import { canUseCapability } from '../../../auth/permissions'
import { readBreederSession } from '../../../auth/session'

type Hamster = any

function sexLabel(sex: string) {
  return sex === 'female' ? '♀' : sex === 'male' ? '♂' : '？'
}

function lifecycleTag(status: string) {
  if (status === 'active') return <Tag tone="success">在养</Tag>
  if (status === 'retired') return <Tag>退役</Tag>
  if (status === 'deceased') return <Tag tone="danger">已离世</Tag>
  return <Tag tone="warning">待确认</Tag>
}

export default function AnimalsPage() {
  const [animals, setAnimals] = useState<Hamster[]>([])
  const [query, setQuery] = useState('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const load = useCallback(async (q = query) => {
    if (!readBreederSession()) {
      setError('请先登录 B 端经营账号')
      setLoading(false)
      return
    }
    setLoading(true)
    setError('')
    try {
      const response = await defaultApi.listHamsters({ limit: 100, q: q.trim() || undefined })
      setAnimals(response.data || [])
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : '个体列表加载失败')
    } finally {
      setLoading(false)
    }
  }, [query])

  useEffect(() => { void load('') }, [load])

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: crayon.paper, backgroundImage: paperGrain }}>
      <NavBar title="个体" back right={<Tag tone="accent">已接 API</Tag>} />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        <LargeTitle title="个体" sticker={<Sticker name="paw" size={40} tilt={-8} />} />
        <View style={{ padding: `0 ${metrics.pagePadding}px ${metrics.space16}px` }}>
          {canUseCapability('write_hamster') ? <Cell title="新增个体" subtitle="创建真实档案" chevron onClick={() => Taro.navigateTo({ url: '/packages/animals/create/index' })} /> : null}
          {canUseCapability('write_hamster') ? <Cell title="批量新增" subtitle="原子批次创建多个个体" chevron onClick={() => Taro.navigateTo({ url: '/packages/animals/batch-create/index' })} /> : null}
        </View>
          <View style={{ margin: `0 ${metrics.pagePadding}px ${metrics.space16}px`, padding: '10px 14px', backgroundColor: palette.secondaryGroupedBackground, borderRadius: '14px' }}>
          <Input
            value={query}
            placeholder="搜索姓名、编号或品系"
            placeholderStyle={`color: ${palette.tertiaryLabel}`}
            confirmType="search"
            onInput={(event) => setQuery(event.detail.value)}
            onConfirm={() => void load()}
          />
        </View>
        {loading ? <Empty title="正在读取个体" description="从经营账户加载真实档案" /> : null}
        {!loading && error ? (
          <SectionList><Section header="需要处理"><Cell title={error} subtitle="点击返回登录" onClick={() => Taro.navigateTo({ url: '/pages/login/index' })} /></Section></SectionList>
        ) : null}
        {!loading && !error && animals.length === 0 ? <Empty title="没有找到个体" description="调整关键词后再试" /> : null}
        {!loading && !error && animals.length > 0 ? (
          <SectionList>
            <Section header="在养档案" footer={`共 ${animals.length} 条 · 真实经营数据`}>
              {animals.map((animal) => (
                <Cell
                  key={animal.id}
                  title={`${animal.name || animal.internalCode} ${sexLabel(animal.sex)}`}
                  subtitle={`${animal.internalCode} · ${animal.varietyCode || '品系未记录'} · ${animal.currentEnclosureId ? `笼舍 ${animal.currentEnclosureId}` : '未分配笼舍'}`}
                  value={lifecycleTag(animal.lifecycleStatus)}
                  chevron
                  onClick={() => Taro.navigateTo({ url: `/packages/animals/detail/index?id=${encodeURIComponent(animal.id)}` })}
                />
              ))}
            </Section>
          </SectionList>
        ) : null}
        <View style={{ height: `${metrics.bottomSafePadding}px` }} />
      </ScrollView>
    </View>
  )
}
