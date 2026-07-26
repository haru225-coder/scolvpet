import { View, Text } from '@tarojs/components'
import { Children, cloneElement, isValidElement, type ReactNode } from 'react'
import { metrics } from './tokens'
import { palette, typeStyle } from './theme'

export interface SectionProps {
  header?: string
  footer?: string
  children: ReactNode
}

/** 分组卡片(docs/34 §8):圆角 16 白卡,组头 labelMedium;子行自动补发丝分隔。 */
export function Section({ header, footer, children }: SectionProps) {
  const items = Children.toArray(children)
  return (
    <View style={{ display: 'flex', flexDirection: 'column', gap: `${metrics.space8}px` }}>
      {header ? (
        <Text style={{ ...typeStyle('labelMedium'), padding: `0 ${metrics.tilePadding}px` }}>{header}</Text>
      ) : null}
      <View
        style={{
          backgroundColor: palette.secondaryGroupedBackground,
          borderRadius: `${metrics.continuousRadius}px`,
          overflow: 'hidden'
        }}
      >
        {items.map((child, i) =>
          isValidElement(child)
            ? cloneElement(child, { divider: i > 0, key: child.key ?? i } as never)
            : child
        )}
      </View>
      {footer ? (
        <Text style={{ ...typeStyle('bodySmall'), padding: `0 ${metrics.tilePadding}px` }}>{footer}</Text>
      ) : null}
    </View>
  )
}

/** 页面级分组列表容器:节间距 24,页边距 16。 */
export function SectionList({ children }: { children: ReactNode }) {
  return (
    <View
      style={{
        display: 'flex',
        flexDirection: 'column',
        gap: `${metrics.sectionGap}px`,
        // 原生 env() 处理 iPhone 底部指示条,免 JS 探测
        padding: `0 ${metrics.pagePadding}px calc(${metrics.bottomSafePadding}px + env(safe-area-inset-bottom))`
      }}
    >
      {children}
    </View>
  )
}
