import { View, Text } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useState, type ReactNode } from 'react'
import { metrics, motion } from './tokens'
import { palette } from './theme'
import { statusBarHeight } from './NavBar'

/**
 * 页头(2026-08-02 重做)。
 *
 * 原实现是「Netflix billboard」:三层叠加渐变 + 36px/900 标题 + textShadow +
 * 半屏 400px 高。现在:纯平底色,靠字阶和留白分层级。props 保持兼容。
 */

/** 保留类型以兼容既有调用;当前视觉不再按 tone 换配色。 */
export type HeroTone = 'accent' | 'sage' | 'clay'

export interface HeroAction {
  text: string
  onClick?: () => void
}

export interface HeroProps {
  badge?: string
  title: string
  subtitle?: string
  /** @deprecated 视觉不再使用 tone；保留以免调用方报错 */
  tone?: HeroTone
  primary?: HeroAction
  secondary?: HeroAction
  right?: ReactNode
  /**
   * 显示返回箭头(离栏页从 navigateTo 推入时必须有返回路径，§10.4)。
   * 默认 Taro.navigateBack。
   */
  back?: boolean
  onBack?: () => void
}

function HeaderButton({
  text,
  onClick,
  kind
}: {
  text: string
  onClick?: () => void
  kind: 'primary' | 'secondary'
}) {
  const [pressed, setPressed] = useState(false)
  const primary = kind === 'primary'
  return (
    <View
      onClick={onClick}
      onTouchStart={() => setPressed(true)}
      onTouchEnd={() => setPressed(false)}
      onTouchCancel={() => setPressed(false)}
      style={{
        minHeight: '44px',
        padding: '0 20px',
        marginRight: '10px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        borderRadius: '8px',
        boxSizing: 'border-box',
        backgroundColor: primary
          ? pressed
            ? 'rgba(255,255,255,0.82)'
            : '#FFFFFF'
          : pressed
            ? 'rgba(255,255,255,0.12)'
            : 'transparent',
        border: primary ? 'none' : '1px solid rgba(255,255,255,0.18)',
        transition: `background-color ${motion.press}ms ease`
      }}
    >
      <Text
        style={{
          fontSize: '15px',
          fontWeight: 600,
          color: primary ? '#111111' : 'rgba(255,255,255,0.82)'
        }}
      >
        {text}
      </Text>
    </View>
  )
}

export function Hero({ badge, title, subtitle, primary, secondary, right, back = false, onBack }: HeroProps) {
  const inset = statusBarHeight()
  const [backPressed, setBackPressed] = useState(false)
  return (
    <View
      style={{
        paddingTop: inset + 'px',
        backgroundColor: palette.systemBackground
      }}
    >
      {/* 微信胶囊按钮占位:标题从胶囊下方开始 */}
      <View style={{ height: metrics.navBarHeight + 'px' }}>
        {/* 离栏页返回入口(§10.4)：60px 整槽可点，与 NavBar 返回槽同宽 */}
        {back ? (
          <View
            style={{
              position: 'absolute',
              left: 0,
              width: '60px',
              height: metrics.navBarHeight + 'px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'flex-start',
              paddingLeft: metrics.pagePadding + 'px',
              boxSizing: 'border-box',
              opacity: backPressed ? 0.5 : 1,
              transition: `opacity ${motion.press}ms ease`
            }}
            onTouchStart={() => setBackPressed(true)}
            onTouchEnd={() => setBackPressed(false)}
            onTouchCancel={() => setBackPressed(false)}
            onClick={onBack || (() => Taro.navigateBack())}
          >
            <Text style={{ fontSize: '22px', color: '#FFFFFF', fontWeight: 300, lineHeight: 1 }}>‹</Text>
          </View>
        ) : null}
      </View>

      <View
        style={{
          padding: `0 ${metrics.space16}px ${metrics.space24}px`,
          display: 'flex',
          flexDirection: 'row',
          alignItems: 'flex-start',
          justifyContent: 'space-between'
        }}
      >
        <View style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column' }}>
          {badge ? (
            <Text
              style={{
                fontSize: '13px',
                fontWeight: 500,
                letterSpacing: '0.3px',
                color: palette.tertiaryLabel,
                marginBottom: '8px'
              }}
            >
              {badge}
            </Text>
          ) : null}

          <Text
            style={{
              fontSize: '28px',
              fontWeight: 600,
              letterSpacing: '-0.5px',
              lineHeight: 1.2,
              color: palette.label
            }}
          >
            {title}
          </Text>

          {subtitle ? (
            <Text
              style={{
                marginTop: '8px',
                fontSize: '15px',
                lineHeight: 1.5,
                color: palette.secondaryLabel
              }}
            >
              {subtitle}
            </Text>
          ) : null}

          {primary || secondary ? (
            <View style={{ display: 'flex', flexDirection: 'row', marginTop: '20px' }}>
              {primary ? <HeaderButton text={primary.text} onClick={primary.onClick} kind="primary" /> : null}
              {secondary ? (
                <HeaderButton text={secondary.text} onClick={secondary.onClick} kind="secondary" />
              ) : null}
            </View>
          ) : null}
        </View>

        {right ? <View style={{ flex: 'none', marginLeft: '16px', marginTop: '2px' }}>{right}</View> : null}
      </View>
    </View>
  )
}
