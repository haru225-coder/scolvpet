import { Input, ScrollView, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useCallback, useEffect, useRef, useState } from 'react'
import { formatUserError } from '../../../api/errors'
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

import { defaultApi } from '../../../api/default-api'
import { p1Api } from '../../../api/p1-api'
import { canUseCapability } from '../../../auth/permissions'
import { requireBreederSession } from '../../../auth/dev-session'
import { animalScanSubtitle, animalScanTitle } from '../../../utils/scan-labels'
import { humanShortLabel } from '../../../utils/tab-routes'
import {
  buildTrialDeepLink,
  dualTrialFromPair,
  findProfileByHamsterId,
  profileListFromResponse,
  trialSideFromAnimal
} from '../../../genetics/trial-deeplink'

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
  /** 选两只试配模式 */
  const [pairMode, setPairMode] = useState(false)
  const [pickedIds, setPickedIds] = useState<string[]>([])

  // 稳定引用：不依赖 query，初始加载和搜索共用此函数
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
      const response = await defaultApi.listHamsters({ limit: 100, q: searchQuery.trim() || undefined })
      setAnimals(response.data || [])
    } catch (cause) {
      setError(await formatUserError(cause, '个体列表加载失败'))
    } finally {
      setLoading(false)
    }
  }, [])  // 无依赖，引用永不变化

  // 初始加载（仅 mount 时执行一次）
  useEffect(() => { void fetchAnimals('') }, [fetchAnimals])

  useLoad((options) => {
    if (String(options?.pair_trial || '') === '1') {
      setPairMode(true)
      setPickedIds([])
      void Taro.showToast({ title: '点两只开始试配', icon: 'none' })
    }
  })

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

  function openAnimalDetail(id: string) {
    void Taro.navigateTo({
      url: `/packages/animals/detail/index?id=${encodeURIComponent(id)}`
    })
  }

  function togglePairMode() {
    setPairMode((on) => {
      if (on) setPickedIds([])
      return !on
    })
  }

  function togglePick(id: string) {
    setPickedIds((prev) => {
      if (prev.includes(id)) return prev.filter((x) => x !== id)
      if (prev.length >= 2) {
        void Taro.showToast({ title: '最多选两只', icon: 'none' })
        return prev
      }
      return [...prev, id]
    })
  }

  async function startPairTrial() {
    if (pickedIds.length !== 2) {
      void Taro.showToast({ title: '请先点选两只', icon: 'none' })
      return
    }
    const a = animals.find((h) => String(h.id) === pickedIds[0])
    const b = animals.find((h) => String(h.id) === pickedIds[1])
    if (!a || !b) {
      void Taro.showToast({ title: '个体不在当前列表', icon: 'none' })
      return
    }
    let profiles: any[] = []
    try {
      profiles = profileListFromResponse(await p1Api.listGeneticProfiles())
    } catch {
      // 无档案也可表型
    }
    const profileA = findProfileByHamsterId(profiles, String(a.id))
    const profileB = findProfileByHamsterId(profiles, String(b.id))
    const pair = dualTrialFromPair(a, b, profileA, profileB)
    if (!pair.assignedBySex) {
      void Taro.showToast({ title: '按点选顺序：先公后母', icon: 'none', duration: 1600 })
    }
    void Taro.navigateTo({
      url: buildTrialDeepLink({
        series: pair.series,
        sire: pair.sire,
        dam: pair.dam
      })
    })
  }

  /** 普通模式：打开档案 / 单侧试配。 */
  function onAnimalRow(animal: Hamster) {
    const id = String(animal?.id || '')
    if (!id) return
    if (pairMode) {
      togglePick(id)
      return
    }
    void Taro.showActionSheet({
      itemList: ['打开档案', '用这个体试配', '选两只试配']
    })
      .then(async (res) => {
        if (res.tapIndex === 0) {
          openAnimalDetail(id)
          return
        }
        if (res.tapIndex === 2) {
          setPairMode(true)
          setPickedIds([id])
          void Taro.showToast({ title: '再点一只配对', icon: 'none' })
          return
        }
        if (res.tapIndex !== 1) return
        let profile: any = null
        try {
          const profilesRes = await p1Api.listGeneticProfiles()
          profile = findProfileByHamsterId(profileListFromResponse(profilesRes), id)
        } catch {
          // 无档案也可表型试配
        }
        const side = trialSideFromAnimal(animal, profile)
        void Taro.navigateTo({
          url: buildTrialDeepLink({
            series: side.series,
            side: side.side,
            key: side.key,
            phenotype: side.phenotype
          })
        })
      })
      .catch(() => undefined)
  }

  function pickOrder(id: string): number {
    const idx = pickedIds.indexOf(id)
    return idx >= 0 ? idx + 1 : 0
  }

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <NavBar title={pairMode ? '选两只试配' : '个体'} back />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        <LargeTitle title={pairMode ? '选两只试配' : '个体'} />
        <View style={{ padding: `0 ${metrics.pagePadding}px ${metrics.space16}px` }}>
          <Cell
            title={pairMode ? '退出双选' : '选两只试配'}
            subtitle={
              pairMode
                ? pickedIds.length === 2
                  ? '已选两只，点下方开始'
                  : `已选 ${pickedIds.length}/2 · 再点一只`
                : '按性别自动公母；不明时按点选顺序'
            }
            chevron
            onClick={() => {
              if (pairMode && pickedIds.length === 2) {
                void startPairTrial()
                return
              }
              togglePairMode()
            }}
          />
          {pairMode && pickedIds.length === 2 ? (
            <Cell
              title="开始试配"
              subtitle="带入公母样子 / 基因型"
              chevron
              onClick={() => void startPairTrial()}
            />
          ) : null}
          {!pairMode && canUseCapability('write_hamster') ? (
            <Cell
              title="新增个体"
              subtitle="建一条档案"
              chevron
              onClick={() => Taro.navigateTo({ url: '/packages/animals/create/index' })}
            />
          ) : null}
          {!pairMode && canUseCapability('write_hamster') ? (
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
            <Section
              header={pairMode ? '点选配对' : '在养档案'}
              footer={
                pairMode
                  ? `已选 ${pickedIds.length}/2 · 共 ${animals.length} 条`
                  : `共 ${animals.length} 条 · 当前熊舍`
              }
            >
              {animals.map((animal) => {
                const id = String(animal.id)
                const order = pickOrder(id)
                return (
                  <Cell
                    key={id}
                    title={animalScanTitle(animal)}
                    subtitle={
                      pairMode
                        ? order
                          ? `已选为第 ${order} 只`
                          : animalScanSubtitle(animal) || '点选加入配对'
                        : animalScanSubtitle(animal) || '点选：打开档案或试配'
                    }
                    value={
                      pairMode ? (
                        order ? (
                          <Tag tone={order === 1 ? 'accent' : 'success'}>{order === 1 ? '①' : '②'}</Tag>
                        ) : (
                          lifecycleTag(animal.lifecycleStatus)
                        )
                      ) : (
                        lifecycleTag(animal.lifecycleStatus)
                      )
                    }
                    chevron
                    onClick={() => onAnimalRow(animal)}
                  />
                )
              })}
            </Section>
          </SectionList>
        ) : null}
        <View style={{ height: `${metrics.bottomSafePadding}px` }} />
      </ScrollView>
    </View>
  )
}
