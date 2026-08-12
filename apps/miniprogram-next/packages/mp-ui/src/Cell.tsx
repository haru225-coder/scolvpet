import { View, Text } from '@tarojs/components'
import type { ReactNode } from 'react'
import { metrics, motion } from './tokens'
import { typeStyle } from './theme'

export interface CellProps {
  title: ReactNode
  subtitle?: ReactNode
  value?: ReactNode
  chevron?: boolean
  divider?: boolean
  onClick?: () => void
  /** 整行可点但点击由外层接管(如包在 Picker 内)时,仍启用按压反馈 */
  pressable?: boolean
}

/** 列表行：深色行 + 细分割，hover 提亮。 */
export function Cell({ title, subtitle, value, chevron = false, divider = false, onClick, pressable = false }: CellProps) {
  return (
    <View
      style={{
        display: 'flex',
        alignItems: 'center',
        minHeight: `${metrics.rowMinHeight}px`,
        padding: `${metrics.tileVerticalPadding}px ${metrics.tilePadding}px`,
        boxSizing: 'border-box',
        gap: `${metrics.space12}px`,
        borderTop: divider ? '1px solid rgba(255,255,255,0.06)' : undefined
      }}
      hoverClass={onClick || pressable ? 'mp-press' : 'none'}
      hoverStayTime={motion.press}
      onClick={onClick}
    >
      <View style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '3px', minWidth: 0 }}>
        <Text style={{ ...typeStyle('bodyLarge'), color: '#FFFFFF' }}>{title}</Text>
        {subtitle ? (
          <Text style={{ ...typeStyle('bodyMedium'), color: 'rgba(255,255,255,0.45)' }}>{subtitle}</Text>
        ) : null}
      </View>
      {value != null ? (
        typeof value === 'string' || typeof value === 'number' ? (
          <Text style={{ ...typeStyle('bodyLarge'), color: 'rgba(255,255,255,0.45)' }}>{value}</Text>
        ) : (
          value
        )
      ) : null}
      {chevron ? (
        <Text style={{ fontSize: '18px', fontWeight: 500, color: 'rgba(255,255,255,0.35)' }}>›</Text>
      ) : null}
    </View>
  )
}
