import { View, Text, Image } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { metrics, palette } from '@scolvpet/mp-ui'

import { TAB_ACTIVE_EVENT, TAB_PAGES } from '../utils/tab-routes'

// 2026-08：两栏（种群 + 试配）。复用 assets/tab/*：种群=population，试配=today（视觉区分）。
// app.config tabBar.list 的 iconPath 须与此一致（原生降级路径）。
const TABS = [
  {
    path: TAB_PAGES[0],
    text: '种群',
    icon: '/assets/tab/population.png',
    iconActive: '/assets/tab/population-active.png'
  },
  {
    path: TAB_PAGES[1],
    text: '试配',
    icon: '/assets/tab/today.png',
    iconActive: '/assets/tab/today-active.png'
  }
]

function indexFromRoute(): number {
  try {
    const pages = Taro.getCurrentPages()
    const route = pages.length ? pages[pages.length - 1].route || '' : ''
    return TABS.findIndex((tab) => tab.path === '/' + route || tab.path === route)
  } catch {
    return -1
  }
}

export default function CustomTabBar() {
  const [active, setActive] = useState(0)
  const [iconsOk, setIconsOk] = useState(true)

  useDidShow(() => {
    const index = indexFromRoute()
    if (index >= 0) setActive(index)
  })

  useEffect(() => {
    const onActive = (index: number) => {
      if (typeof index === 'number' && index >= 0 && index < TABS.length) setActive(index)
    }
    try {
      Taro.eventCenter.on(TAB_ACTIVE_EVENT, onActive)
    } catch {
      // ignore
    }
    return () => {
      try {
        Taro.eventCenter.off(TAB_ACTIVE_EVENT, onActive)
      } catch {
        // ignore
      }
    }
  }, [])

  return (
    <View
      style={{
        // 不依赖框架定位。Skyline 不接管 custom-tab-bar 时会把本组件甩到文档流顶部。
        position: 'fixed',
        left: 0,
        right: 0,
        bottom: 0,
        zIndex: 500,
        display: 'flex',
        flexDirection: 'row',
        height: metrics.tabBarHeight + 4 + 'px',
        paddingBottom: 'env(safe-area-inset-bottom)',
        boxSizing: 'content-box',
        backgroundColor: palette.tabBarBackground,
        borderTop: `1px solid ${palette.separator}`
      }}
    >
      {TABS.map((tab, index) => {
        const isActive = index === active
        return (
          <View
            key={tab.path}
            onClick={() => {
              setActive(index)
              void Taro.switchTab({ url: tab.path })
            }}
            style={{
              flex: 1,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              paddingTop: '4px',
              gap: '5px'
            }}
          >
            {iconsOk ? (
              <Image
                src={isActive ? tab.iconActive : tab.icon}
                mode="aspectFit"
                style={{ width: '23px', height: '23px' }}
                onError={() => setIconsOk(false)}
              />
            ) : (
              <View
                style={{
                  width: '23px',
                  height: '3px',
                  borderRadius: '2px',
                  marginBottom: '4px',
                  backgroundColor: isActive ? palette.accent : 'rgba(255,255,255,0.22)'
                }}
              />
            )}
            <Text
              style={{
                fontSize: '10px',
                fontWeight: isActive ? 600 : 500,
                letterSpacing: '0.2px',
                color: isActive ? '#FFFFFF' : 'rgba(255,255,255,0.40)'
              }}
            >
              {tab.text}
            </Text>
          </View>
        )
      })}
    </View>
  )
}
