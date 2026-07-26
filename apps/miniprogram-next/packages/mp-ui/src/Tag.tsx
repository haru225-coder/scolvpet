import { View, Text } from '@tarojs/components'
import type { ReactNode } from 'react'
import { metrics, statusColors } from './tokens'
import { palette } from './theme'

export type TagTone = 'default' | 'accent' | 'success' | 'danger' | 'warning'

// 语义色仅表达真实状态(docs/34 §2.2)
const tones: Record<TagTone, { bg: string; fg: string }> = {
  default: { bg: 'rgba(58, 47, 41, 0.09)', fg: '#7A6E66' },
  accent: { bg: '#FBE8D8', fg: '#B26B3B' },
  success: { bg: 'rgba(107, 125, 107, 0.15)', fg: statusColors.systemGreen },
  danger: { bg: 'rgba(226, 104, 91, 0.14)', fg: statusColors.systemRed },
  warning: { bg: 'rgba(217, 139, 85, 0.16)', fg: '#B26B3B' }
}

export function Tag({ children, tone = 'default' }: { children: ReactNode; tone?: TagTone }) {
  const t = tones[tone]
  return (
    <View
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        padding: '2px 8px',
        borderRadius: `${metrics.pillRadius}px`,
        backgroundColor: t.bg
      }}
    >
      <Text style={{ fontSize: '13px', fontWeight: 500, lineHeight: 1.38, color: t.fg || palette.label }}>
        {children}
      </Text>
    </View>
  )
}
