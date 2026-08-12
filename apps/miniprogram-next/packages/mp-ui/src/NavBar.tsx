import { View, Text } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useState, type ReactNode } from 'react'
import { metrics, navBar, motion } from './tokens'
import { palette } from './theme'

export interface NavBarProps {
  title: string
  /** 页面滚动距离(px);大标题滚过此距离后小标题淡入。不传 = 小标题常显。 */
  scrollTop?: number
  /** 显示返回箭头;默认点击 Taro.navigateBack */
  back?: boolean
  onBack?: () => void
  /** 右侧操作位 */
  right?: ReactNode
  /**
   * 关闭大标题模式(小标题常显)。默认「跟随 scrollTop」:
   * 传了 scrollTop 才进入折叠模式,不传则标题常显(修复 2026-08-11:
   * 原默认 largeTitle=true 让不传 scrollTop 的页面 progress=0、标题不可见)。
   */
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
export function NavBar({ title, scrollTop, back = false, onBack, right, largeTitle }: NavBarProps) {
  const inset = statusBarHeight()
  const [backPressed, setBackPressed] = useState(false)
  // 折叠模式 = 页面显式传了 scrollTop(进入大标题滚动折叠),且未显式关闭。
  // 不传 scrollTop 的表单/详情页默认小标题常显(largeTitle undefined + 无 scrollTop)。
  // 注意:此处不能给 scrollTop 设解构默认值 0——否则 `scrollTop !== undefined`
  // 恒为 true、collapsing 恒 true、progress 恒 0,标题不可见(2026-08-12 修复)。
  const collapsing = largeTitle === true || (largeTitle === undefined && scrollTop !== undefined)
  const progress = collapsing ? Math.min(Math.max((scrollTop ?? 0) / COLLAPSE_RANGE, 0), 1) : 1

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
            style={{
              width: '60px',
              height: '100%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'flex-start',
              opacity: backPressed ? 0.5 : 1,
              transition: `opacity ${motion.press}ms ease`
            }}
            onTouchStart={() => setBackPressed(true)}
            onTouchEnd={() => setBackPressed(false)}
            onTouchCancel={() => setBackPressed(false)}
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
