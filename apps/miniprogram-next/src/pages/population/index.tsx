import { ScrollView, View } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { useCallback, useEffect, useState } from 'react'
import { Cell, Empty, Hero, PosterCard, Rail, Section, SectionList, palette } from '@scolvpet/mp-ui'

import { defaultApi } from '../../api/default-api'
import { getLastEnsureError, requireBreederSession } from '../../auth/dev-session'
import ProfileAvatar from '../../components/ProfileAvatar'
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

type Row = { id: string; title: string; subtitle?: string }

function toAnimalRow(item: any, index: number): Row {
  return {
    id: String(item?.id ?? index),
    title: animalScanTitle(item),
    subtitle: animalScanSubtitle(item) || undefined
  }
}

function toLitterRow(item: any, index: number): Row {
  const name = String(item?.name ?? item?.code ?? item?.title ?? '').trim()
  const stage = humanShortLabel(item?.stage ?? item?.state ?? item?.status)
  return {
    id: String(item?.id ?? index),
    title: name || `窝次 ${index + 1}`,
    subtitle: litterScanSubtitle(item, stage) || stage || undefined
  }
}

export default function PopulationPage() {
  const [animals, setAnimals] = useState<Row[]>([])
  const [litters, setLitters] = useState<Row[]>([])
  const [notice, setNotice] = useState('')
  const [needLogin, setNeedLogin] = useState(false)
  const [loading, setLoading] = useState(true)

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

  const focus = litters.length ? litters[0] : null
  const emptyBoth = !loading && !notice && !needLogin && animals.length === 0 && litters.length === 0

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <ScrollView scrollY type="list" enhanced bounces showScrollbar={false} style={{ flex: 1 }}>
        <Hero
          badge="本周重点"
          title={focus ? focus.title : '本周暂无重点窝次'}
          subtitle={focus ? focus.subtitle || '窝次进行中' : '建窝后，这里只显示需要盯的那一窝'}
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
                onClick={() => openPage(`/packages/animals/detail/index?id=${encodeURIComponent(row.id)}`)}
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
                onClick={() => openPage(`/packages/litters/detail/index?id=${encodeURIComponent(row.id)}`)}
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
            {/* 试配已升为底标 Tab，页脚不再重复入口 */}
            <Cell title="今日待办" chevron onClick={() => openPage(OFF_TAB_PAGES.today)} />
            <Cell title="经营（客户 / 合同 / 账目）" chevron onClick={() => openPage(OFF_TAB_PAGES.business)} />
            <Cell title="提醒与日历" chevron onClick={() => openPage(DOMAIN_HOME.reminders)} />
          </Section>
        </SectionList>
        <View style={{ height: tabPageBottomPad() + 'px' }} />
      </ScrollView>
    </View>
  )
}
