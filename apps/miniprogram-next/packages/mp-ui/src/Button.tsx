import { View, Text } from '@tarojs/components'
import { useState, type CSSProperties, type ReactNode } from 'react'
import { motion } from './tokens'
import { palette } from './theme'

export interface ButtonProps {
  children: ReactNode
  variant?: 'filled' | 'outlined' | 'text'
  disabled?: boolean
  block?: boolean
  onClick?: () => void
}

/** 流媒体手感按钮：白实心主钮 / 半透明次钮 / 文字钮。 */
export function Button({ children, variant = 'filled', disabled = false, block = false, onClick }: ButtonProps) {
  const [pressed, setPressed] = useState(false)

  const base: CSSProperties = {
    display: block ? 'flex' : 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    boxSizing: 'border-box',
    transition: `transform ${motion.press}ms cubic-bezier(0.33, 1, 0.68, 1), opacity ${motion.press}ms ease, background-color ${motion.press}ms ease`,
    transform: pressed && !disabled ? 'scale(0.97)' : 'scale(1)',
    opacity: disabled ? 0.45 : 1
  }

  // 2026-08-02：主钮原 800 字重 + 大投影，黑底上像浮在页面外。
  // 降到 600 + 无投影；次钮灰实心改描边，避免和卡片抢层级。
  const variants: Record<string, CSSProperties> = {
    filled: {
      minHeight: '48px',
      padding: '12px 20px',
      borderRadius: '8px',
      backgroundColor: pressed ? 'rgba(255,255,255,0.82)' : '#FFFFFF',
      color: '#111111',
      fontSize: '15px',
      fontWeight: 600
    },
    outlined: {
      minHeight: '44px',
      padding: '10px 18px',
      borderRadius: '8px',
      backgroundColor: pressed ? 'rgba(255,255,255,0.12)' : 'transparent',
      border: '1px solid rgba(255,255,255,0.18)',
      color: 'rgba(255,255,255,0.82)',
      fontSize: '15px',
      fontWeight: 600
    },
    text: {
      color: disabled ? palette.tertiaryLabel : palette.accent,
      fontSize: '16px',
      fontWeight: 600,
      letterSpacing: '0.1px'
    }
  }

  return (
    <View
      style={{ ...base, ...variants[variant] }}
      onTouchStart={() => setPressed(true)}
      onTouchEnd={() => setPressed(false)}
      onTouchCancel={() => setPressed(false)}
      onClick={() => {
        if (!disabled && onClick) onClick()
      }}
    >
      <Text style={{ color: 'inherit', fontSize: 'inherit', fontWeight: 'inherit' as never }}>{children}</Text>
    </View>
  )
}
