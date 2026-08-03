import { View, Text } from '@tarojs/components'
import Taro from '@tarojs/taro'
import type { ReactNode } from 'react'
import { metrics, navBar, motion } from './tokens'
import { palette } from './theme'

export interface NavBarProps {
  title: string
  /** 页面滚动距离(px);大标题滚过此距离后小标题淡入 */
  scrollTop?: number
  /** 显示返回箭头;默认点击 Taro.navigateBack */
  back?: boolean
  onBack?: () => void
  /** 右侧操作位 */
  right?: ReactNode
  /** 关闭大标题模式(小标题常显) */
  largeTitle?: boolean
}

const COLLAPSE_RANGE = 44

export function statusBarHeight(): number {
  try {
    return Taro.getWindowInfo().statusBarHeight || 44
  } catch (_) {
    return 44
  }
}

/**
 * iOS 风自定义导航栏(docs/34 §6)。固定栏 + 占位;大标题用 <LargeTitle>
 * 放进页面滚动容器首部,随内容真实滚走(iOS 原生行为),小标题按
 * scrollTop 淡入。Skyline 手势返回由页面路由配置承担,组件不感知引擎。
 */
export function NavBar({ title, scrollTop = 0, back = false, onBack, right, largeTitle = true }: NavBarProps) {
  const inset = statusBarHeight()
  const progress = largeTitle ? Math.min(Math.max(scrollTop / COLLAPSE_RANGE, 0), 1) : 1

  return (
    <View style={{ position: 'relative', zIndex: 10 }}>
      <View
        style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          zIndex: 10,
          paddingTop: `${inset}px`,
          backgroundColor: palette.navBarBackground,
          transition: `border-color ${motion.press}ms linear, background-color ${motion.press}ms linear`,
          borderBottom: progress >= 1 ? '1px solid rgba(255,255,255,0.06)' : '1px solid transparent'
        }}
      >
        <View
          style={{
            display: 'flex',
            alignItems: 'center',
            height: `${metrics.navBarHeight}px`,
            padding: `0 ${metrics.pagePadding}px`,
            boxSizing: 'border-box'
          }}
        >
          <View
            style={{ width: '60px', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'flex-start' }}
            onClick={back ? onBack || (() => Taro.navigateBack()) : undefined}
          >
            {back ? (
              <Text style={{ fontSize: `${navBar.iconSize}px`, color: '#FFFFFF', fontWeight: 300 }}>‹</Text>
            ) : null}
          </View>
          <View style={{ flex: 1, display: 'flex', justifyContent: 'center' }}>
            <Text
              style={{
                fontSize: `${navBar.titleFontSize}px`,
                fontWeight: 600,
                letterSpacing: `${navBar.titleLetterSpacing}px`,
                color: '#FFFFFF',
                opacity: progress,
                transition: `opacity ${motion.press}ms linear`
              }}
            >
              {title}
            </Text>
          </View>
          <View style={{ width: '60px', display: 'flex', justifyContent: 'flex-end' }}>{right}</View>
        </View>
      </View>
      {/* 固定栏占位 */}
      <View style={{ height: `${inset + metrics.navBarHeight}px` }} />
    </View>
  )
}

/** 大标题：流媒体式粗标题，装饰可选。 */
export function LargeTitle({ title, sticker }: { title: string; sticker?: ReactNode }) {
  return (
    <View
      style={{
        padding: `8px ${metrics.pagePadding}px 12px`,
        display: 'flex',
        alignItems: 'flex-end',
        justifyContent: 'space-between'
      }}
    >
      <Text
        style={{
          // 2026-08-02：32/800 压人，收到 28/600，与 Hero 页标题同阶
          fontSize: '28px',
          fontWeight: 600,
          letterSpacing: '-0.5px',
          lineHeight: 1.15,
          color: '#FFFFFF'
        }}
      >
        {title}
      </Text>
      {sticker}
    </View>
  )
}
