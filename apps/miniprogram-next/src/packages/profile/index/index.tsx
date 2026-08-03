import { ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Cell, LargeTitle, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { clearBreederSession, peekBreederSession } from '../../../auth/session'
import { resolveSubscribeTemplateIds } from '../../../utils/subscribe-templates'
import { DOMAIN_HOME, openPage } from '../../../utils/tab-routes'

// 「我的」不占底栏（UI 重组 v3 §3）：从主视窗右上角头像进入。
// 放在分包，不压主包体积（硬限 2MB / 预警 1.6MB）。
export default function ProfilePage() {
  const [scrollTop, setScrollTop] = useState(0)
  const [showSubscribe, setShowSubscribe] = useState(false)
  const session = peekBreederSession()

  useEffect(() => {
    let active = true
    void resolveSubscribeTemplateIds()
      .then((ids) => {
        if (active) setShowSubscribe(ids.length > 0)
      })
      .catch(() => {
        if (active) setShowSubscribe(false)
      })
    return () => {
      active = false
    }
  }, [])

  function logout() {
    clearBreederSession()
    void Taro.reLaunch({ url: '/pages/login/index' })
  }

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <NavBar title="我的" scrollTop={scrollTop} back />
      <ScrollView
        scrollY
        type="list"
        enhanced
        bounces
        showScrollbar={false}
        style={{ flex: 1 }}
        onScroll={(event: { detail?: { scrollTop?: number } }) => setScrollTop(event.detail?.scrollTop || 0)}
      >
        <LargeTitle title="我的" />
        <SectionList>
          {session ? (
            <Section header="当前账号" footer={session.organizationName || undefined}>
              <Cell
                title={session.displayName || session.phoneMasked || '已登录'}
                subtitle={session.phoneMasked && session.displayName ? session.phoneMasked : '熊舍经营账号'}
                value={<Tag tone="success">在线</Tag>}
              />
            </Section>
          ) : null}
          <Section header="工具">
            <Cell title="AI 助手" subtitle="问一句，直接查养熊数据" chevron onClick={() => openPage(DOMAIN_HOME.ai)} />
            <Cell title="数据中心" subtitle="导入、导出、备份" chevron onClick={() => openPage(DOMAIN_HOME.dataCenter)} />
            <Cell title="试配一下" subtitle="这两只会生出什么" chevron onClick={() => openPage(DOMAIN_HOME.genetic)} />
          </Section>
          <Section header="通知">
            {showSubscribe ? (
              <Cell
                title="订阅消息"
                subtitle="任务、预约到点提醒"
                chevron
                onClick={() => openPage('/packages/reminders/subscriptions/index')}
              />
            ) : null}
            <Cell title="提醒与日历" chevron onClick={() => openPage(DOMAIN_HOME.reminders)} />
          </Section>
          {session ? (
            <Section header="账号">
              <Cell title="退出登录" subtitle="清掉本机登录状态" onClick={logout} />
            </Section>
          ) : null}
        </SectionList>
        <View style={{ height: metrics.bottomSafePadding + 'px' }} />
      </ScrollView>
    </View>
  )
}
