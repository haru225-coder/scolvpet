import { ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { formatUserError } from '../api/errors'
import {
  Button,
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
  footer?: string
  emptyTitle?: string
  emptyDescription?: string
  load: () => Promise<BListItem[]>
  onSelect?: (item: BListItem) => void
  actionLabel?: string
  onAction?: () => void
  actionCapability?: string
  secondaryActionLabel?: string
  onSecondaryAction?: () => void
}

/** 业务列表壳：与主 Tab 同一套沉浸深色，不再奶油纸纹。 */
export default function BListPage({
  title,
  footer = '来自当前熊舍账号',
  emptyTitle = '还没有内容',
  emptyDescription = '新增之后会出现在这里',
  load,
  onSelect,
  actionLabel,
  onAction,
  actionCapability,
  secondaryActionLabel,
  onSecondaryAction
}: Props) {
  const [items, setItems] = useState<BListItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    if (!readBreederSession()) {
      setError('请先登录经营账号')
      setLoading(false)
      return
    }
    void load()
      .then(setItems)
      .catch(async (cause) => setError(await formatUserError(cause, '加载失败，请稍后重试')))
      .finally(() => setLoading(false))
  }, [load])

  const showPrimary = Boolean(actionLabel && onAction && (!actionCapability || canUseCapability(actionCapability)))
  const showSecondary = Boolean(secondaryActionLabel && onSecondaryAction)

  return (
    <View
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: palette.systemBackground
      }}
    >
      <NavBar title={title} back />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        <LargeTitle title={title} />
        {showPrimary || showSecondary ? (
          <View
            style={{
              padding: `0 ${metrics.pagePadding}px ${metrics.space16}px`,
              display: 'flex',
              flexDirection: 'row',
              gap: `${metrics.space12}px`
            }}
          >
            {showPrimary ? (
              <View style={{ flex: 1 }}>
                <Button block onClick={onAction}>
                  {actionLabel}
                </Button>
              </View>
            ) : null}
            {showSecondary ? (
              <View style={{ flex: 1 }}>
                <Button block variant="outlined" onClick={onSecondaryAction}>
                  {secondaryActionLabel}
                </Button>
              </View>
            ) : null}
          </View>
        ) : null}
        {loading ? <Empty title="正在读取" /> : null}
        {!loading && error ? (
          <SectionList>
            <Section header="需要处理">
              <Cell
                title={error}
                subtitle="点这里去登录"
                onClick={() => Taro.navigateTo({ url: '/pages/login/index' })}
              />
            </Section>
          </SectionList>
        ) : null}
        {!loading && !error && items.length === 0 ? (
          <Empty
            title={emptyTitle}
            description={emptyDescription}
            actionText={showPrimary ? actionLabel : undefined}
            onAction={showPrimary ? onAction : undefined}
          />
        ) : null}
        {!loading && !error && items.length > 0 ? (
          <SectionList>
            <Section header="记录" footer={`${footer} · 共 ${items.length} 条`}>
              {items.map((item) => (
                <Cell
                  key={item.id}
                  title={item.title}
                  subtitle={item.subtitle}
                  value={item.value ? <Tag tone={item.tone}>{item.value}</Tag> : undefined}
                  chevron={Boolean(onSelect)}
                  onClick={() => onSelect?.(item)}
                />
              ))}
            </Section>
          </SectionList>
        ) : null}
        <View style={{ height: `${metrics.bottomSafePadding + 24}px` }} />
      </ScrollView>
    </View>
  )
}
