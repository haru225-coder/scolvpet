import { View, Text } from '@tarojs/components'
import { useState, type CSSProperties, type ReactNode } from 'react'
import { crayon, motion } from './tokens'
import { palette, wobble } from './theme'

export interface ButtonProps {
  children: ReactNode
  variant?: 'filled' | 'outlined' | 'text'
  disabled?: boolean
  block?: boolean
  onClick?: () => void
}

/** iOS 风按钮(docs/34 §8):filled 52 高圆角 16;outlined 胶囊;text 纯文字。 */
export function Button({ children, variant = 'filled', disabled = false, block = false, onClick }: ButtonProps) {
  const [pressed, setPressed] = useState(false)

  const base: CSSProperties = {
    display: block ? 'flex' : 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    boxSizing: 'border-box',
    transition: `transform ${motion.press}ms ease, opacity ${motion.press}ms ease`,
    // 蜡笔手账:按压是"捏一下"——缩 + 一丝歪
    transform: pressed && !disabled ? 'scale(0.96) rotate(-0.8deg)' : 'scale(1)',
    opacity: pressed && !disabled ? 0.85 : 1
  }
  const variants: Record<string, CSSProperties> = {
    filled: {
      minHeight: '52px',
      padding: '14px 20px',
      borderRadius: wobble(0, 'bold'),
      border: `2px solid ${crayon.stroke}`,
      backgroundColor: disabled ? palette.tertiaryFill : crayon.orange,
      color: disabled ? palette.tertiaryLabel : '#FFFDF7',
      fontSize: '17px',
      fontWeight: 600,
      letterSpacing: '-0.41px'
    },
    outlined: {
      minHeight: '36px',
      padding: '8px 14px',
      borderRadius: wobble(1, 'bold'),
      border: `1.5px dashed ${disabled ? crayon.strokeSoft : crayon.stroke}`,
      color: disabled ? palette.tertiaryLabel : '#B26B3B',
      fontSize: '15px',
      fontWeight: 500,
      letterSpacing: '-0.24px'
    },
    text: {
      color: disabled ? palette.tertiaryLabel : palette.accent,
      fontSize: '17px',
      fontWeight: 400,
      letterSpacing: '-0.41px'
    }
  }

  return (
    <View
      style={{ ...base, ...variants[variant] }}
      onTouchStart={() => setPressed(true)}
      onTouchEnd={() => setPressed(false)}
      onClick={() => {
        if (!disabled && onClick) onClick()
      }}
    >
      <Text>{children}</Text>
    </View>
  )
}
