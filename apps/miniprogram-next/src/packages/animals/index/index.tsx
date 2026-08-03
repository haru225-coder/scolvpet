import { Input, ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useCallback, useEffect, useRef, useState } from 'react'
import {
  NavBar,
  LargeTitle,
  Section,
  SectionList,
  Cell,
  Tag,
  Empty,
  metrics,
  palette
} from '@scolvpet/mp-ui'

import { defaultApi } from '../../../api/client'
import { canUseCapability } from '../../../auth/permissions'
import { readBreederSession } from '../../../auth/session'
import { animalScanSubtitle, animalScanTitle } from '../../../utils/scan-labels'
import { humanShortLabel } from '../../../utils/tab-routes'

type Hamster = any

function lifecycleTag(status: string) {
  if (status === 'active') return <Tag tone="success">在养</Tag>
  if (status === 'retired') return <Tag>退役</Tag>
  if (status === 'deceased') return <Tag tone="danger">已离世</Tag>
  return <Tag tone="warning">{humanShortLabel(status) || '待确认'}</Tag>
}

export default function AnimalsPage() {
  const [animals, setAnimals] = useState<Hamster[]>([])
  const [query, setQuery] = useState('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  // 稳定引用：不依赖 query，初始加载和搜索共用此函数
  const fetchAnimals = useCallback(async (searchQuery: string) => {
    if (!readBreederSession()) {
      setError('请先登录经营账号')
      setLoading(false)
      return
    }
    setLoading(true)
    setError('')
    try {
      const response = await defaultApi.listHamsters({ limit: 100, q: searchQuery.trim() || undefined })
      setAnimals(response.data || [])
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : '个体列表加载失败')
    } finally {
      setLoading(false)
    }
  }, [])  // 无依赖，引用永不变化

  // 初始加载（仅 mount 时执行一次）
  useEffect(() => { void fetchAnimals('') }, [fetchAnimals])

  // 输入防抖：停止键入 350ms 后自动搜索
  const debounceRef = useRef<ReturnType<typeof setTimeout>>()
  const handleInput = useCallback((value: string) => {
    setQuery(value)
    if (debounceRef.current) clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(() => {
      void fetchAnimals(value)
    }, 350)
  }, [fetchAnimals])

  // 回车 / 搜索按键：立即搜索，取消防抖等待
  const handleConfirm = useCallback(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current)
    void fetchAnimals(query)
  }, [fetchAnimals, query])

  // 卸载时清理定时器
  useEffect(() => () => { if (debounceRef.current) clearTimeout(debounceRef.current) }, [])

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <NavBar title="个体" back />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        <LargeTitle title="个体" />
        <View style={{ padding: `0 ${metrics.pagePadding}px ${metrics.space16}px` }}>
          {canUseCapability('write_hamster') ? (
            <Cell
              title="新增个体"
              subtitle="建一条档案"
              chevron
              onClick={() => Taro.navigateTo({ url: '/packages/animals/create/index' })}
            />
          ) : null}
          {canUseCapability('write_hamster') ? (
            <Cell
              title="批量新增"
              subtitle="一次建多只"
              chevron
              onClick={() => Taro.navigateTo({ url: '/packages/animals/batch-create/index' })}
            />
          ) : null}
        </View>
        <View
          style={{
            margin: `0 ${metrics.pagePadding}px ${metrics.space16}px`,
            padding: '10px 14px',
            backgroundColor: palette.secondaryGroupedBackground,
            borderRadius: '14px'
          }}
        >
          <Input
            value={query}
            placeholder="搜索姓名、编号或品系"
            placeholderStyle={`color: ${palette.tertiaryLabel}`}
            confirmType="search"
            onInput={(event) => handleInput(event.detail.value)}
            onConfirm={() => void handleConfirm()}
          />
        </View>
        {loading ? <Empty title="正在读取个体" /> : null}
        {!loading && error ? (
          <SectionList><Section header="需要处理"><Cell title={error} subtitle="点击返回登录" onClick={() => Taro.navigateTo({ url: '/pages/login/index' })} /></Section></SectionList>
        ) : null}
        {!loading && !error && animals.length === 0 ? <Empty title="没有找到个体" description="调整关键词后再试" /> : null}
        {!loading && !error && animals.length > 0 ? (
          <SectionList>
            <Section header="在养档案" footer={`共 ${animals.length} 条 · 当前熊舍`}>
              {animals.map((animal) => (
                <Cell
                  key={animal.id}
                  title={animalScanTitle(animal)}
                  subtitle={animalScanSubtitle(animal)}
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
