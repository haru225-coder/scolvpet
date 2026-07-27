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

// M0-6 样例页:今日照护队列(假数据,本地状态可交互;真机 Gate 只评手感)。
// 功能收口约定:页内所有可点元素必须有响应;未开放能力统一 toast 提示 M1。
// 业务接线 M1 起走 @api/client + generated 契约客户端。
const MOCK_TASKS = [
  { id: 't1', title: '喂食 · 全部笼舍', time: '每日 20:00', state: 'todo' },
  { id: 't2', title: '换水 · A 区 1–8 笼', time: '每日 20:30', state: 'todo' },
  { id: 't3', title: '体重记录 · 布丁', time: '每周一', state: 'done' },
  { id: 't4', title: '垫料更换 · B 区', time: '每周三', state: 'todo' },
  { id: 't5', title: '健康观察 · 奶茶(产后)', time: '每日', state: 'overdue' }
]

const FILTERS = ['全部', '待办', '已完成'] as const

function stateTag(state: string) {
  if (state === 'done') return <Tag tone="success">已完成</Tag>
  if (state === 'skipped') return <Tag>已跳过</Tag>
  if (state === 'overdue') return <Tag tone="danger">逾期</Tag>
  return <Tag>待办</Tag>
}

export function toast(title: string) {
  Taro.showToast({ title, icon: 'none' })
}

export default function TodayPage() {
  const [tasks, setTasks] = useState(MOCK_TASKS)
  const [filter, setFilter] = useState(0)
  const [scrollTop, setScrollTop] = useState(0)
  const [panelFor, setPanelFor] = useState<string | null>(null)
  const [refreshing, setRefreshing] = useState(false)

  const setState = (id: string, state: string) =>
    setTasks((prev) => prev.map((t) => (t.id === id ? { ...t, state } : t)))

  const visible = tasks.filter((t) =>
    filter === 0 ? true : filter === 1 ? t.state === 'todo' || t.state === 'overdue' : t.state === 'done'
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
          // ponytail: 假数据无可刷,延时只为让 Gate 摸到回弹手感;M1 换真拉取
          setTimeout(() => {
            setRefreshing(false)
            toast('已是最新(示例数据)')
          }, 600)
        }}
        style={{ flex: 1 }}
        onScroll={(e: { detail?: { scrollTop?: number } }) => setScrollTop(e.detail?.scrollTop || 0)}
      >
        <LargeTitle title="今日" sticker={<Sticker name="hamster" size={52} tilt={4} />} />
        <View style={{ padding: `0 ${metrics.pagePadding}px ${metrics.space16}px` }}>
          <SegmentedControl segments={[...FILTERS]} value={filter} onChange={setFilter} />
        </View>
        {visible.length === 0 ? (
          <Empty
            title={filter === 2 ? '还没有完成的任务' : '暂无今日任务'}
            description={filter === 2 ? '完成一项就会出现在这里' : '今天的照护任务都完成了'}
          />
        ) : (
          <SectionList>
            <Section header="照护队列" footer={`共 ${visible.length} 项 · 示例数据`}>
              {visible.map((t) => (
                <SwipeAction
                  key={t.id}
                  actions={[
                    {
                      text: '完成',
                      onClick: () => {
                        setState(t.id, 'done')
                        toast(`已完成:${t.title}`)
                      }
                    },
                    { text: '跳过', danger: true, onClick: () => setPanelFor(t.id) }
                  ]}
                >
                  <Cell
                    title={t.title}
                    subtitle={t.time}
                    value={stateTag(t.state)}
                    chevron
                    onClick={() => toast('任务详情 M1 开放')}
                  />
                </SwipeAction>
              ))}
            </Section>
            <View style={{ display: 'flex', justifyContent: 'center', alignItems: 'flex-end', gap: '18px', padding: '2px 0' }}>
              <Sticker name="paw" size={26} tilt={-14} />
              <Sticker name="paw" size={30} tilt={10} />
              <Sticker name="paw" size={26} tilt={-8} />
              <Sticker name="sunflower" size={38} tilt={12} />
            </View>
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
        actions={[
          {
            text: '跳过一次',
            danger: true,
            onClick: () => {
              if (panelFor) setState(panelFor, 'skipped')
              toast('已跳过一次')
            }
          },
          { text: '顺延到明天', onClick: () => toast('已顺延到明天(示例)') }
        ]}
        onClose={() => setPanelFor(null)}
      />
    </View>
  )
}
