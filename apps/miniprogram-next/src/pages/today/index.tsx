import { ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useState } from 'react'
import {
  NavBar,
  LargeTitle,
  Section,
  SectionList,
  Cell,
  SwipeAction,
  SegmentedControl,
  Tag,
  Empty,
  ActionPanel,
  Sticker,
  crayon,
  paperGrain,
  metrics
} from '@scolvpet/mp-ui'

// M0-6 样例页:今日照护队列(静态假数据,只读;真机手感 Gate 用)。
// 业务接线 M1 起走 @api/client + generated 契约客户端。
const MOCK_TASKS = [
  { id: 't1', title: '喂食 · 全部笼舍', time: '每日 20:00', state: 'todo' },
  { id: 't2', title: '换水 · A 区 1–8 笼', time: '每日 20:30', state: 'todo' },
  { id: 't3', title: '体重记录 · 布丁', time: '每周一', state: 'done' },
  { id: 't4', title: '垫料更换 · B 区', time: '每周三', state: 'todo' },
  { id: 't5', title: '健康观察 · 奶茶(产后)', time: '每日', state: 'overdue' }
]

const FILTERS = ['全部', '待办', '已完成'] as const

export default function TodayPage() {
  const [filter, setFilter] = useState(0)
  const [scrollTop, setScrollTop] = useState(0)
  const [panelFor, setPanelFor] = useState<string | null>(null)
  const [refreshing, setRefreshing] = useState(false)

  const tasks = MOCK_TASKS.filter((t) =>
    filter === 0 ? true : filter === 1 ? t.state !== 'done' : t.state === 'done'
  )

  return (
    <View
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: crayon.paper,
        backgroundImage: paperGrain
      }}
    >
      <NavBar title="今日" scrollTop={scrollTop} right={<Tag tone="accent">样例</Tag>} />
      <ScrollView
        scrollY
        type="list"
        bounces
        enhanced
        showScrollbar={false}
        refresherEnabled
        refresherTriggered={refreshing}
        refresherBackground={crayon.paper}
        onRefresherRefresh={() => {
          if (refreshing) return
          setRefreshing(true)
          // ponytail: 假数据无可刷,600ms 只为让 Gate 摸到回弹手感;M1 换真拉取
          setTimeout(() => setRefreshing(false), 600)
        }}
        style={{ flex: 1 }}
        onScroll={(e: { detail?: { scrollTop?: number } }) => setScrollTop(e.detail?.scrollTop || 0)}
      >
        <LargeTitle title="今日" sticker={<Sticker name="hamster" size={52} tilt={4} />} />
        <View style={{ padding: `0 ${metrics.pagePadding}px ${metrics.space16}px` }}>
          <SegmentedControl segments={[...FILTERS]} value={filter} onChange={setFilter} />
        </View>
        {tasks.length === 0 ? (
          <Empty title="暂无今日任务" description="今天的照护任务都完成了" />
        ) : (
          <SectionList>
            <Section header="照护队列" footer={`共 ${tasks.length} 项 · 静态样例数据`}>
              {tasks.map((t) => (
                <SwipeAction
                  key={t.id}
                  actions={[
                    { text: '完成' },
                    { text: '跳过', danger: true, onClick: () => setPanelFor(t.id) }
                  ]}
                >
                  <Cell
                    title={t.title}
                    subtitle={t.time}
                    value={
                      t.state === 'done' ? (
                        <Tag tone="success">已完成</Tag>
                      ) : t.state === 'overdue' ? (
                        <Tag tone="danger">逾期</Tag>
                      ) : (
                        <Tag>待办</Tag>
                      )
                    }
                    chevron
                  />
                </SwipeAction>
              ))}
            </Section>
            <Section header="快捷入口" seed={1}>
              <Cell
                title="个体列表(分包样例)"
                subtitle="packages/animals"
                chevron
                onClick={() => Taro.navigateTo({ url: '/packages/animals/index/index' })}
              />
              <Cell
                title="B 端登录(M1 接线)"
                chevron
                onClick={() => Taro.navigateTo({ url: '/pages/login/index' })}
              />
            </Section>
          </SectionList>
        )}
      </ScrollView>
      <ActionPanel
        open={panelFor != null}
        title="跳过这项任务?"
        actions={[{ text: '跳过一次', danger: true }, { text: '顺延到明天' }]}
        onClose={() => setPanelFor(null)}
      />
    </View>
  )
}
