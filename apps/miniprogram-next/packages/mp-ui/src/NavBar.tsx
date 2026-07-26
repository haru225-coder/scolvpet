import { View, Text } from '@tarojs/components'
import Taro from '@tarojs/taro'
import type { ReactNode } from 'react'
import { crayon, metrics, navBar, motion } from './tokens'
import { palette, crayonUnderline } from './theme'

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
          backgroundColor: 'rgba(251, 242, 227, 0.96)',
          transition: `border-color ${motion.press}ms linear`,
          borderBottom: `1.5px dashed ${progress >= 1 ? crayon.strokeSoft : 'transparent'}`
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
          {/* 触控目标 ≥44pt:点击落在整个左槽,不只箭头字形(docs/16 §4.2) */}
          <View
            style={{ width: '60px', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'flex-start' }}
            onClick={back ? onBack || (() => Taro.navigateBack()) : undefined}
          >
            {back ? (
              <Text style={{ fontSize: `${navBar.iconSize}px`, color: palette.accent }}>‹</Text>
            ) : null}
          </View>
          <View style={{ flex: 1, display: 'flex', justifyContent: 'center' }}>
            <Text
              style={{
                fontSize: `${navBar.titleFontSize}px`,
                fontWeight: navBar.titleFontWeight,
                letterSpacing: `${navBar.titleLetterSpacing}px`,
                color: palette.label,
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

/** 大标题块:放在页面滚动容器的第一个子节点,随内容滚入导航栏下方。
 *  蜡笔手账:标题下压一道蜡笔波浪线,右侧可贴装饰(sticker)。 */
export function LargeTitle({ title, sticker }: { title: string; sticker?: ReactNode }) {
  return (
    <View
      style={{
        padding: `4px ${metrics.pagePadding}px 8px`,
        display: 'flex',
        alignItems: 'flex-end',
        justifyContent: 'space-between'
      }}
    >
      <Text
        style={{
          fontSize: `${navBar.largeTitleFontSize}px`,
          fontWeight: navBar.largeTitleFontWeight,
          letterSpacing: '-0.4px',
          lineHeight: 1.25,
          color: crayon.ink,
          paddingBottom: '8px',
          backgroundImage: crayonUnderline(crayon.orange),
          backgroundRepeat: 'no-repeat',
          backgroundPosition: 'left bottom',
          backgroundSize: '104px 8px'
        }}
      >
        {title}
      </Text>
      {sticker}
    </View>
  )
}
