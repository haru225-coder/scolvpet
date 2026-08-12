import { View, Text } from '@tarojs/components'
import { Children, cloneElement, isValidElement, type ReactNode } from 'react'
import { metrics } from './tokens'
import { palette, typeStyle } from './theme'

export interface SectionProps {
  header?: string
  footer?: string
  children: ReactNode
  /** 保留兼容旧调用；深色卡不再使用 seed 纹理。 */
  seed?: number
}

/** 分组列表：沉浸深色卡，干净圆角（流媒体设置页感）。 */
export function Section({ header, footer, children, seed: _seed = 0 }: SectionProps) {
  const items = Children.toArray(children)
  return (
    <View style={{ display: 'flex', flexDirection: 'column', gap: `${metrics.space8}px` }}>
      {header ? (
        <View style={{ padding: `0 ${metrics.tilePadding}px` }}>
          <Text
            style={{
              fontSize: '12px',
              fontWeight: 600,
              letterSpacing: '0.6px',
              color: 'rgba(255,255,255,0.34)'
            }}
          >
            {header}
          </Text>
        </View>
      ) : null}
      <View
        style={{
          // 2026-08-02：黑底大投影糊边；靠 1px 描边分层
          backgroundColor: palette.surfaceCard,
          borderRadius: '10px',
          overflow: 'hidden',
          border: '1px solid rgba(255,255,255,0.09)'
        }}
      >
        {items.map((child, i) =>
          isValidElement(child)
            ? cloneElement(child, {
                // 仅给 Cell/FormRow 用；false 不写入，避免落到原生 View 上告警
                ...(i > 0 ? { divider: true } : {}),
                key: child.key ?? i
              } as never)
            : child
        )}
      </View>
      {footer ? (
        <Text style={{ ...typeStyle('bodySmall'), padding: `0 ${metrics.tilePadding}px`, color: 'rgba(255,255,255,0.35)' }}>
          {footer}
        </Text>
      ) : null}
    </View>
  )
}

export function SectionList({ children }: { children: ReactNode }) {
  return (
    <View
      style={{
        display: 'flex',
        flexDirection: 'column',
        gap: `${metrics.sectionGap}px`,
        padding: `0 ${metrics.pagePadding}px calc(${metrics.bottomSafePadding}px + env(safe-area-inset-bottom))`
      }}
    >
      {children}
    </View>
  )
}
