import { View, Text } from '@tarojs/components'
import type { ReactNode } from 'react'
import { crayon } from './tokens'
import { wobble } from './theme'

export type TagTone = 'default' | 'accent' | 'success' | 'danger' | 'warning'

// 蜡笔贴纸风:淡蜡底 + 同色描边 + 手贴微歪;语义色仅表达真实状态(docs/34 §2.2)
const tones: Record<TagTone, { bg: string; fg: string; tilt: number }> = {
  default: { bg: 'rgba(70, 54, 42, 0.07)', fg: '#7A6E66', tilt: 0 },
  accent: { bg: 'rgba(224, 138, 79, 0.16)', fg: '#B26B3B', tilt: -1.2 },
  success: { bg: 'rgba(124, 154, 109, 0.16)', fg: crayon.green, tilt: 1 },
  danger: { bg: 'rgba(217, 108, 91, 0.15)', fg: crayon.red, tilt: -1.4 },
  warning: { bg: 'rgba(239, 195, 95, 0.22)', fg: '#A2742B', tilt: 1.2 }
}

export function Tag({ children, tone = 'default' }: { children: ReactNode; tone?: TagTone }) {
  const t = tones[tone]
  return (
    <View
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        padding: '2px 9px',
        borderRadius: wobble(t.tilt < 0 ? 0 : 1, 'bold'),
        border: `1.5px solid ${t.fg}55`,
        backgroundColor: t.bg,
        transform: t.tilt ? `rotate(${t.tilt}deg)` : undefined
      }}
    >
      <Text style={{ fontSize: '13px', fontWeight: 500, lineHeight: 1.38, color: t.fg }}>
        {children}
      </Text>
    </View>
  )
}
