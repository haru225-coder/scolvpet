import { ScrollView, View } from '@tarojs/components'
import { useState } from 'react'
import {
  NavBar,
  LargeTitle,
  Section,
  SectionList,
  Cell,
  Tag,
  palette,
  metrics
} from '@scolvpet/mp-ui'

// M0-6 样例页:个体列表(分包 animals;静态假数据,只读;真机手感 Gate 用)。
const MOCK_ANIMALS = [
  { id: 'a1', name: '布丁', line: '金丝熊 · 奶油', sex: '♀', cage: 'A-03', state: 'ok' },
  { id: 'a2', name: '奶茶', line: '金丝熊 · 三色', sex: '♀', cage: 'A-07', state: 'watch' },
  { id: 'a3', name: '芝麻', line: '金丝熊 · 黑豹', sex: '♂', cage: 'B-01', state: 'ok' },
  { id: 'a4', name: '年糕', line: '金丝熊 · 银斑', sex: '♂', cage: 'B-04', state: 'ok' },
  { id: 'a5', name: '麻薯', line: '金丝熊 · 奶油斑', sex: '♀', cage: 'C-02', state: 'retired' }
]

export default function AnimalsSamplePage() {
  const [scrollTop, setScrollTop] = useState(0)

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.groupedBackground }}>
      <NavBar title="个体" scrollTop={scrollTop} back right={<Tag tone="accent">样例</Tag>} />
      <ScrollView
        scrollY
        type="list"
        bounces
        enhanced
        showScrollbar={false}
        style={{ flex: 1 }}
        onScroll={(e: { detail?: { scrollTop?: number } }) => setScrollTop(e.detail?.scrollTop || 0)}
      >
        <LargeTitle title="个体" />
        <SectionList>
          <Section header="在养个体" footer={`共 ${MOCK_ANIMALS.length} 只 · 静态样例数据`}>
            {MOCK_ANIMALS.map((a) => (
              <Cell
                key={a.id}
                title={`${a.name} ${a.sex}`}
                subtitle={`${a.line} · ${a.cage}`}
                value={
                  a.state === 'watch' ? (
                    <Tag tone="warning">待观察</Tag>
                  ) : a.state === 'retired' ? (
                    <Tag>退役</Tag>
                  ) : (
                    <Tag tone="success">健康</Tag>
                  )
                }
                chevron
              />
            ))}
          </Section>
        </SectionList>
        <View style={{ height: `${metrics.bottomSafePadding}px` }} />
      </ScrollView>
    </View>
  )
}
