import { Input, ScrollView, View } from '@tarojs/components'
import Taro, { useRouter } from '@tarojs/taro'
import { useCallback, useEffect, useRef, useState } from 'react'
import {
  Cell,
  Empty,
  LargeTitle,
  NavBar,
  Section,
  SectionList,
  Tag,
  metrics,
  palette
} from '@scolvpet/mp-ui'

import { defaultApi } from '../../../api/default-api'
import { p1Api } from '../../../api/p1-api'
import { formatUserError, notifyUserError } from '../../../api/errors'
import { requireBreederSession } from '../../../auth/dev-session'
import { humanShortLabel } from '../../../utils/tab-routes'

type Hamster = {
  id?: string
  name?: string
  internalCode?: string
  internal_code?: string
  lifecycleStatus?: string
  lifecycle_status?: string
}

/**
 * 全量种群选择器：绑定遗传档案 ↔ 个体。
 * query: profile_id, version, current_hamster_id?
 */
export default function BindHamsterPage() {
  const router = useRouter()
  const profileId = String(router.params?.profile_id || '').trim()
  const version = Number(router.params?.version || 0)
  const currentHamsterId = String(router.params?.current_hamster_id || '').trim()

  const [animals, setAnimals] = useState<Hamster[]>([])
  const [query, setQuery] = useState('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)
  /** NavBar 折叠滚动进度 */
  const [scrollTop, setScrollTop] = useState(0)

  const fetchAnimals = useCallback(async (searchQuery: string) => {
    const session = await requireBreederSession()
    if (!session) {
      setError('请先登录经营账号')
      setLoading(false)
      return
    }
    setLoading(true)
    setError('')
    try {
      const response = await defaultApi.listHamsters({
        limit: 20,
        q: searchQuery.trim() || undefined
      })
      const data = (response as any)?.data ?? response
      setAnimals(Array.isArray(data) ? data : data?.items || [])
    } catch (cause) {
      setError(await formatUserError(cause, '个体列表加载失败'))
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void fetchAnimals('')
  }, [fetchAnimals])

  const debounceRef = useRef<ReturnType<typeof setTimeout>>()
  const handleInput = useCallback(
    (value: string) => {
      setQuery(value)
      if (debounceRef.current) clearTimeout(debounceRef.current)
      debounceRef.current = setTimeout(() => {
        void fetchAnimals(value)
      }, 350)
    },
    [fetchAnimals]
  )

  useEffect(
    () => () => {
      if (debounceRef.current) clearTimeout(debounceRef.current)
    },
    []
  )

  async function bind(hamsterId: string, label: string) {
    if (!profileId || version <= 0) {
      void Taro.showToast({ title: '缺少档案参数', icon: 'none' })
      return
    }
    setBusy(true)
    try {
      await p1Api.updateGeneticProfile({
        profileId,
        updateGeneticProfileRequest: {
          version,
          hamsterId
        } as any
      } as any)
      void Taro.showToast({ title: `已绑定 ${label}`, icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 400)
    } catch (cause) {
      await notifyUserError(cause, '绑定失败')
    } finally {
      setBusy(false)
    }
  }

  async function unbind() {
    if (!profileId || version <= 0) return
    const modal = await Taro.showModal({
      title: '解除绑定',
      content: '确定解除该档案与个体的关联？'
    })
    if (!modal.confirm) return
    setBusy(true)
    try {
      await p1Api.updateGeneticProfile({
        profileId,
        updateGeneticProfileRequest: {
          version,
          hamsterId: ''
        } as any
      } as any)
      void Taro.showToast({ title: '已解除绑定', icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 400)
    } catch (cause) {
      await notifyUserError(cause, '解绑失败')
    } finally {
      setBusy(false)
    }
  }

  return (
    <View
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: palette.systemBackground
      }}
    >
      <NavBar title="绑定个体" back scrollTop={scrollTop} />
      <ScrollView
        scrollY
        type="list"
        bounces
        enhanced
        showScrollbar={false}
        style={{ flex: 1 }}
        onScroll={(event) => setScrollTop(event.detail?.scrollTop || 0)}
      >
        <LargeTitle title="选择个体" />
        <View style={{ padding: `0 ${metrics.pagePadding}px ${metrics.space12}px` }}>
          <Input
            value={query}
            placeholder="搜索编号 / 名字"
            placeholderStyle={`color: ${palette.tertiaryLabel}`}
            confirmType="search"
            onInput={(e) => handleInput(e.detail.value)}
            onConfirm={() => {
              if (debounceRef.current) clearTimeout(debounceRef.current)
              void fetchAnimals(query)
            }}
            style={{
              background: 'rgba(255,255,255,0.08)',
              borderRadius: `${metrics.continuousRadius}px`,
              padding: '10px 14px',
              color: '#fff',
              fontSize: '15px'
            }}
          />
        </View>

        {loading ? <Empty title="正在读取种群…" /> : null}
        {!loading && error ? (
          <SectionList>
            <Section header="需要处理">
              <Cell title={error} subtitle="点此重试" onClick={() => void fetchAnimals(query)} />
            </Section>
          </SectionList>
        ) : null}
        {!loading && !error && animals.length === 0 ? (
          <Empty title="没有匹配的个体" description="换个关键词，或先去种群建档" />
        ) : null}

        {!loading && !error && animals.length > 0 ? (
          <SectionList>
            <Section header="种群" footer={`共 ${animals.length} 只 · 点选绑定到当前档案`}>
              {animals.map((h) => {
                const id = String(h.id || '')
                const name = String(h.name || '').trim()
                const code = String(h.internalCode || h.internal_code || '').trim()
                const label = name || code || id.slice(0, 8)
                const title = name && code ? `${name} · ${code}` : label
                const status = String(h.lifecycleStatus || h.lifecycle_status || '')
                const isCurrent = currentHamsterId && id === currentHamsterId
                return (
                  <Cell
                    key={id}
                    title={title}
                    subtitle={isCurrent ? '当前已绑定' : humanShortLabel(status) || undefined}
                    value={isCurrent ? <Tag tone="success">已绑</Tag> : <Tag>选择</Tag>}
                    onClick={() => {
                      if (busy) return
                      void bind(id, label)
                    }}
                  />
                )
              })}
            </Section>
            {currentHamsterId ? (
              <Section header="其它">
                <Cell
                  title="解除绑定"
                  subtitle="档案不再关联任何个体"
                  value={<Tag tone="danger">解绑</Tag>}
                  onClick={() => {
                    if (busy) return
                    void unbind()
                  }}
                />
              </Section>
            ) : null}
          </SectionList>
        ) : null}
        <View style={{ height: `${metrics.bottomSafePadding + 24}px` }} />
      </ScrollView>
    </View>
  )
}
