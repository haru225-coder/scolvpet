import { ScrollView, View } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { useCallback, useEffect, useState } from 'react'
import {
  ActionPanel,
  Cell,
  Empty,
  Hero,
  PosterCard,
  Rail,
  Section,
  SectionList,
  palette
} from '@scolvpet/mp-ui'

import { defaultApi } from '../../api/default-api'
import { p1Api } from '../../api/p1-api'
import { getLastEnsureError, requireBreederSession } from '../../auth/dev-session'
import ProfileAvatar from '../../components/ProfileAvatar'
import {
  buildTrialDeepLink,
  findProfileByHamsterId,
  profileListFromResponse,
  resolveLitterParentTrialUrl,
  trialSideFromAnimal
} from '../../genetics/trial-deeplink'
import {
  animalScanSubtitle,
  animalScanTitle,
  litterScanSubtitle
} from '../../utils/scan-labels'
import {
  DOMAIN_HOME,
  OFF_TAB_PAGES,
  humanShortLabel,
  markTabActive,
  openPage,
  tabPageBottomPad
} from '../../utils/tab-routes'

type AnimalRow = {
  id: string
  title: string
  subtitle?: string
  raw: any
}

type LitterRow = { id: string; title: string; subtitle?: string; raw: any }

/** 卡片点按弹出的操作菜单：个体 or 窝次 */
type CardMenu = { kind: 'animal'; row: AnimalRow } | { kind: 'litter'; row: LitterRow } | null

function toAnimalRow(item: any, index: number): AnimalRow {
  return {
    id: String(item?.id ?? index),
    title: animalScanTitle(item),
    subtitle: animalScanSubtitle(item) || undefined,
    raw: item
  }
}

function toLitterRow(item: any, index: number): LitterRow {
  const name = String(item?.name ?? item?.code ?? item?.title ?? '').trim()
  const stage = humanShortLabel(item?.stage ?? item?.state ?? item?.status)
  return {
    id: String(item?.id ?? index),
    title: name || `窝次 ${index + 1}`,
    subtitle: litterScanSubtitle(item, stage) || stage || undefined,
    raw: item
  }
}

export default function PopulationPage() {
  const [animals, setAnimals] = useState<AnimalRow[]>([])
  const [litters, setLitters] = useState<LitterRow[]>([])
  const [notice, setNotice] = useState('')
  const [needLogin, setNeedLogin] = useState(false)
  const [loading, setLoading] = useState(true)
  const [menu, setMenu] = useState<CardMenu>(null)

  useDidShow(() => markTabActive('/pages/population/index'))

  const load = useCallback(async () => {
    setLoading(true)
    setNeedLogin(false)
    try {
      // 开发：首屏直接是本页，必须先保证演示会话再拉列表（否则像「又要登录 / 读不到」）
      const session = await requireBreederSession()
      if (!session) {
        setAnimals([])
        setLitters([])
        setNeedLogin(true)
        setNotice(getLastEnsureError() || '请先登录经营账号')
        return
      }
      const [hamsters, litterList] = await Promise.all([
        defaultApi.listHamsters({ limit: 20 } as any),
        defaultApi.listLitters({ limit: 20 } as any)
      ])
      setAnimals(((hamsters as any)?.data || []).map(toAnimalRow))
      setLitters(((litterList as any)?.data || []).map(toLitterRow))
      setNotice('')
    } catch (_cause) {
      setNeedLogin(false)
      setNotice('暂时读不到种群数据，可先从下方入口进去')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void load()
  }, [load])

  async function openTrialForAnimal(animal: any) {
    const id = String(animal?.id || '')
    let profile: any = null
    try {
      const profilesRes = await p1Api.listGeneticProfiles()
      profile = findProfileByHamsterId(profileListFromResponse(profilesRes), id)
    } catch {
      // 表型试配仍可用
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
  }

  function onAnimalCard(row: AnimalRow) {
    setMenu({ kind: 'animal', row })
  }

  async function openTrialForLitter(litter: any) {
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

  function onLitterCard(row: LitterRow) {
    setMenu({ kind: 'litter', row })
  }

  const focus = litters.length ? litters[0] : null
  const emptyBoth = !loading && !notice && !needLogin && animals.length === 0 && litters.length === 0

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <ScrollView scrollY type="list" enhanced bounces showScrollbar={false} style={{ flex: 1 }}>
        <Hero
          badge="本周重点"
          title={focus ? focus.title : '本周暂无重点窝次'}
          subtitle={focus ? focus.subtitle || '窝次进行中' : '有窝次时，这里只盯当前最需要看的那一窝'}
          primary={{ text: focus ? '打开这一窝' : '看窝次', onClick: () => openPage(DOMAIN_HOME.litters) }}
          secondary={{ text: '看个体', onClick: () => openPage(DOMAIN_HOME.animals) }}
          right={<ProfileAvatar />}
        />
        {loading ? <Empty title="正在读取种群" /> : null}
        {!loading && animals.length ? (
          <Rail title="个体" action={{ text: '全部', onClick: () => openPage(DOMAIN_HOME.animals) }}>
            {animals.map((row) => (
              <PosterCard
                key={row.id}
                title={row.title}
                subtitle={row.subtitle}
                onClick={() => onAnimalCard(row)}
                onLongPress={() => void openTrialForAnimal(row.raw)}
              />
            ))}
          </Rail>
        ) : null}
        {!loading && litters.length ? (
          <Rail title="窝次" action={{ text: '看板', onClick: () => openPage(DOMAIN_HOME.litters) }}>
            {litters.map((row) => (
              <PosterCard
                key={row.id}
                badge={row.subtitle}
                title={row.title}
                onClick={() => onLitterCard(row)}
                onLongPress={() => void openTrialForLitter(row.raw)}
              />
            ))}
          </Rail>
        ) : null}
        {!loading && needLogin ? (
          <SectionList>
            <Section header="需要处理">
              <Cell
                title="请先登录经营账号"
                subtitle="点这里去登录"
                chevron
                onClick={() => void Taro.navigateTo({ url: '/pages/login/index' })}
              />
            </Section>
          </SectionList>
        ) : null}
        {!loading && notice && !needLogin ? (
          <Empty title={notice} description="点下方入口也能直接进列表" />
        ) : null}
        {emptyBoth ? (
          <Empty
            title="还没有个体和窝次"
            description="演示号可在工程根执行 node scripts/seed-demo.mjs 塞哈豆/哈米；也可先去试配模拟"
          />
        ) : null}
        <SectionList>
          <Section header="常用">
            <Cell
              title="选两只试配"
              subtitle="在个体列表里点两只，自动带公母"
              chevron
              onClick={() => openPage(`${DOMAIN_HOME.animals}?pair_trial=1`)}
            />
            <Cell title="今日待办" chevron onClick={() => openPage(OFF_TAB_PAGES.today)} />
            <Cell title="经营（客户 / 合同 / 账目）" chevron onClick={() => openPage(OFF_TAB_PAGES.business)} />
            <Cell title="提醒与日历" chevron onClick={() => openPage(DOMAIN_HOME.reminders)} />
          </Section>
        </SectionList>
        <View style={{ height: tabPageBottomPad() + 'px' }} />
      </ScrollView>
      <ActionPanel
        open={menu != null}
        title={menu ? menu.row.title : undefined}
        actions={
          menu?.kind === 'animal'
            ? [
                {
                  text: '打开档案',
                  onClick: () => openPage(`/packages/animals/detail/index?id=${encodeURIComponent(menu.row.id)}`)
                },
                { text: '用这个体试配', onClick: () => void openTrialForAnimal(menu.row.raw) }
              ]
            : menu?.kind === 'litter'
              ? [
                  {
                    text: '打开窝次',
                    onClick: () => openPage(`/packages/litters/detail/index?id=${encodeURIComponent(menu.row.id)}`)
                  },
                  { text: '用公母试配', onClick: () => void openTrialForLitter(menu.row.raw) }
                ]
              : []
        }
        onClose={() => setMenu(null)}
      />
    </View>
  )
}
