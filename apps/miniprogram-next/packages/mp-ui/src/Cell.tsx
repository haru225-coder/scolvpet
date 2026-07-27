import { View, Text } from '@tarojs/components'
import type { ReactNode } from 'react'
import { crayon, metrics } from './tokens'
import { palette, typeStyle } from './theme'

// 蜡笔手账:分隔线用虚断笔迹,不用发丝实线
const sketchDivider = { borderTop: `2px dashed ${crayon.strokeSoft}` }

export interface CellProps {
  title: ReactNode
  subtitle?: ReactNode
  /** 右侧值文本或自定义节点 */
  value?: ReactNode
  /** 右侧披露箭头 */
  chevron?: boolean
  /** 行顶部发丝分隔线(SectionList 自动为非首行开启) */
  divider?: boolean
  onClick?: () => void
}

/** 列表行(docs/34 §8):标题 bodyLarge,副文 bodyMedium,行高 ≥48。 */
export function Cell({ title, subtitle, value, chevron = false, divider = false, onClick }: CellProps) {
  return (
    <View
      style={{
        display: 'flex',
        alignItems: 'center',
        minHeight: `${metrics.rowMinHeight}px`,
        padding: `${metrics.tileVerticalPadding}px ${metrics.tilePadding}px`,
        boxSizing: 'border-box',
        gap: `${metrics.space12}px`,
        ...(divider ? sketchDivider : {})
      }}
      hoverClass={onClick ? 'mp-press' : 'none'}
      hoverStayTime={90}
      onClick={onClick}
    >
      <View style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '2px', minWidth: 0 }}>
        <Text style={typeStyle('bodyLarge')}>{title}</Text>
        {subtitle ? <Text style={typeStyle('bodyMedium')}>{subtitle}</Text> : null}
      </View>
      {value != null ? (
        typeof value === 'string' || typeof value === 'number' ? (
          <Text style={{ ...typeStyle('bodyLarge'), color: palette.secondaryLabel }}>{value}</Text>
        ) : (
          value
        )
      ) : null}
      {chevron ? (
        <Text style={{ fontSize: '17px', fontWeight: 600, color: crayon.orange }}>›</Text>
      ) : null}
    </View>
  )
}
