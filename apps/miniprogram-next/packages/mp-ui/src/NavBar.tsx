import { View, Text } from '@tarojs/components'
import Taro from '@tarojs/taro'
import type { ReactNode } from 'react'
import { metrics, navBar, motion } from './tokens'
import { palette } from './theme'

export interface NavBarProps {
  title: string
  /** 页面滚动距离(px);超过 largeTitle 高度后收缩为居中小标题 */
  scrollTop?: number
  /** 显示返回箭头;默认点击 Taro.navigateBack */
  back?: boolean
  onBack?: () => void
  /** 右侧操作位 */
  right?: ReactNode
  /** 关闭大标题模式(纯居中小标题) */
  largeTitle?: boolean
}

const COLLAPSE_RANGE = 52

export function statusBarHeight(): number {
  try {
    return Taro.getWindowInfo().statusBarHeight || 44
  } catch (_) {
    return 44
  }
}

/**
 * iOS 风自定义导航栏(docs/34 §6):大标题(displayMedium 32)随滚动收缩为
 * 居中 17/600 标题。navigationStyle: custom 页面专用;Skyline 手势返回由
 * 页面路由配置承担,组件不感知渲染引擎。
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
          backgroundColor: progress >= 1 ? palette.navBarBackground : 'transparent',
          transition: `background-color ${motion.press}ms linear`,
          ...(progress >= 1 ? { borderBottom: `0.5px solid ${palette.separator}` } : {})
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
          <View style={{ width: '60px', display: 'flex', justifyContent: 'flex-start' }}>
            {back ? (
              <Text
                style={{ fontSize: `${navBar.iconSize}px`, color: palette.accent }}
                onClick={onBack || (() => Taro.navigateBack())}
              >
                ‹
              </Text>
            ) : null}
          </View>
          <View style={{ flex: 1, display: 'flex', justifyContent: 'center' }}>
            <Text
              style={{
                fontSize: `${navBar.titleFontSize}px`,
                fontWeight: navBar.titleFontWeight,
                letterSpacing: `${navBar.titleLetterSpacing}px`,
                color: palette.label,
                opacity: progress
              }}
            >
              {title}
            </Text>
          </View>
          <View style={{ width: '60px', display: 'flex', justifyContent: 'flex-end' }}>{right}</View>
        </View>
      </View>
      {/* 占位 + 大标题区(随滚动淡出) */}
      <View style={{ height: `${inset + metrics.navBarHeight}px` }} />
      {largeTitle ? (
        <View style={{ padding: `4px ${metrics.pagePadding}px 8px` }}>
          <Text
            style={{
              fontSize: `${navBar.largeTitleFontSize}px`,
              fontWeight: navBar.largeTitleFontWeight,
              letterSpacing: '-0.4px',
              lineHeight: 1.1,
              color: palette.label,
              opacity: 1 - progress
            }}
          >
            {title}
          </Text>
        </View>
      ) : null}
    </View>
  )
}
