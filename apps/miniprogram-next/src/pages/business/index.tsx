import { ScrollView, View } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { useCallback, useEffect, useState } from 'react'
import { Cell, Empty, Hero, MiniCard, Rail, Section, SectionList, palette } from '@scolvpet/mp-ui'

import { defaultApi } from '../../api/default-api'
import { getLastEnsureError, requireBreederSession } from '../../auth/dev-session'
import ProfileAvatar from '../../components/ProfileAvatar'
import {
  DOMAIN_HOME,
  humanMetricTitle,
  markTabActive,
  openPage,
  tabPageBottomPad
} from '../../utils/tab-routes'

type Metric = { id: string; title: string; value: string; subtitle?: string }

// 主视窗放「下一个要处理的人/事」，不堆数字看板。
export default function BusinessPage() {
  const [headline, setHeadline] = useState<{ title: string; subtitle?: string } | null>(null)
  const [metrics_, setMetrics] = useState<Metric[]>([])
  const [notice, setNotice] = useState('')
  const [needLogin, setNeedLogin] = useState(false)
  const [loading, setLoading] = useState(true)

  useDidShow(() => markTabActive('/pages/business/index'))

  const load = useCallback(async () => {
    setLoading(true)
    setNeedLogin(false)
    const session = await requireBreederSession()
    if (!session) {
      setHeadline(null)
      setMetrics([])
      setNeedLogin(true)
      setNotice(getLastEnsureError() || '请先登录经营账号')
      setLoading(false)
      return
    }
    let hasHead = false
    try {
      const reminders = await defaultApi.listReminders({ limit: 10 } as any)
      const first = ((reminders as any)?.data || [])[0]
      if (first) {
        hasHead = true
        setHeadline({
          title: String(first?.title ?? first?.name ?? '待处理事项'),
          subtitle: first?.dueAt || first?.scheduledAt
            ? new Date(first.dueAt || first.scheduledAt).toLocaleString('zh-CN', {
                month: 'numeric',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
              })
            : '提醒'
        })
      } else {
        setHeadline(null)
      }
      setNotice('')
    } catch (_cause) {
      setNotice('经营数据暂时读不到')
    }
    try {
      const summary = await defaultApi.getDataCenterSummary({} as any)
      const data = (summary as any)?.data || {}
      const next: Metric[] = Object.keys(data)
        .filter((key) => typeof data[key] === 'number')
        .slice(0, 6)
        .map((key) => ({
          id: key,
          title: humanMetricTitle(key),
          value: String(data[key])
        }))
      setMetrics(next)
      if (!hasHead && next.length) setNotice('')
    } catch (_cause) {
      setMetrics([])
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void load()
  }, [load])

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <ScrollView scrollY type="list" enhanced bounces showScrollbar={false} style={{ flex: 1 }}>
        <Hero
          back
          badge="下一个"
          title={headline ? headline.title : '暂无待办客户事项'}
          subtitle={headline?.subtitle || '有提醒时排在这里。客户和合同从下面进'}
          primary={{ text: '打开客户', onClick: () => openPage(DOMAIN_HOME.crm) }}
          secondary={{ text: '合同', onClick: () => openPage(DOMAIN_HOME.contracts) }}
          right={<ProfileAvatar />}
        />
        {loading ? <Empty title="正在读取经营概况" /> : null}
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
        {!loading && !needLogin && metrics_.length ? (
          <Rail title="一眼概况" action={{ text: '数据中心', onClick: () => openPage(DOMAIN_HOME.dataCenter) }}>
            {metrics_.map((metric) => (
              <MiniCard
                key={metric.id}
                title={metric.title}
                value={metric.value}
                subtitle={metric.subtitle}
                onClick={() => openPage(DOMAIN_HOME.dataCenter)}
              />
            ))}
          </Rail>
        ) : null}
        {!loading && notice && !needLogin ? (
          <Empty title={notice} description="下面入口仍可直接进" />
        ) : null}
        <SectionList>
          <Section header="经营">
            <Cell title="客户" subtitle="预订、交付、跟进" chevron onClick={() => openPage(DOMAIN_HOME.crm)} />
            <Cell title="合同与回执" chevron onClick={() => openPage(DOMAIN_HOME.contracts)} />
            <Cell title="财务" chevron onClick={() => openPage(DOMAIN_HOME.finance)} />
            <Cell title="数据中心" subtitle="导入 CSV" chevron onClick={() => openPage(DOMAIN_HOME.dataCenter)} />
          </Section>
        </SectionList>
        <View style={{ height: tabPageBottomPad() + 'px' }} />
      </ScrollView>
    </View>
  )
}
