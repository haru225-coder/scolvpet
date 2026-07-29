import { ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Button, Cell, Empty, LargeTitle, NavBar, Section, SectionList, Sticker, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { readBreederSession } from '../auth/session'
import { canUseCapability } from '../auth/permissions'

export type BListItem = {
  id: string
  title: string
  subtitle?: string
  value?: string
  tone?: 'success' | 'warning' | 'danger' | 'accent'
}

type Props = {
  title: string
  eyebrow?: string
  footer?: string
  load: () => Promise<BListItem[]>
  onSelect?: (item: BListItem) => void
  actionLabel?: string
  onAction?: () => void
  actionCapability?: string
  secondaryActionLabel?: string
  onSecondaryAction?: () => void
}

export default function BListPage({ title, eyebrow = 'B 端', footer = '真实经营数据', load, onSelect, actionLabel, onAction, actionCapability, secondaryActionLabel, onSecondaryAction }: Props) {
  const [items, setItems] = useState<BListItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    if (!readBreederSession()) {
      setError('请先登录 B 端经营账号')
      setLoading(false)
      return
    }
    void load().then(setItems).catch((cause) => setError(cause instanceof Error ? cause.message : '数据加载失败')).finally(() => setLoading(false))
  }, [load])

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: crayon.paper, backgroundImage: paperGrain }}>
      <NavBar title={title} back right={<Tag tone="accent">{eyebrow}</Tag>} />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        <LargeTitle title={title} sticker={<Sticker name="paw" size={40} tilt={-8} />} />
        {((actionLabel && onAction && (!actionCapability || canUseCapability(actionCapability))) || (secondaryActionLabel && onSecondaryAction)) ? <View style={{ padding: `0 ${metrics.pagePadding}px ${metrics.space16}px`, display: 'flex', gap: `${metrics.space12}px` }}>
          {actionLabel && onAction && (!actionCapability || canUseCapability(actionCapability)) ? <Button block onClick={onAction}>{actionLabel}</Button> : null}
          {secondaryActionLabel && onSecondaryAction ? <Button block variant="outlined" onClick={onSecondaryAction}>{secondaryActionLabel}</Button> : null}
        </View> : null}
        {loading ? <Empty title="正在加载" description="从经营账户读取数据" /> : null}
        {!loading && error ? <SectionList><Section header="需要处理"><Cell title={error} onClick={() => Taro.navigateTo({ url: '/pages/login/index' })} /></Section></SectionList> : null}
        {!loading && !error && items.length === 0 ? <Empty title="暂无数据" description="新增业务数据后会出现在这里" /> : null}
        {!loading && !error && items.length > 0 ? (
          <SectionList>
            <Section header="记录" footer={`${footer} · 共 ${items.length} 条`}>
              {items.map((item) => <Cell key={item.id} title={item.title} subtitle={item.subtitle} value={item.value ? <Tag tone={item.tone}>{item.value}</Tag> : undefined} chevron={Boolean(onSelect)} onClick={() => onSelect?.(item)} />)}
            </Section>
          </SectionList>
        ) : null}
        <View style={{ height: `${metrics.bottomSafePadding}px` }} />
      </ScrollView>
    </View>
  )
}
