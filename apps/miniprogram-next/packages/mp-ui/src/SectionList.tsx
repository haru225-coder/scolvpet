import { View, Text } from '@tarojs/components'
import { Children, cloneElement, isValidElement, type ReactNode } from 'react'
import { crayon, metrics } from './tokens'
import { typeStyle, wobble, crayonUnderline } from './theme'

export interface SectionProps {
  header?: string
  footer?: string
  children: ReactNode
  /** 手账卡片笔迹种子(相邻 Section 传不同值,四角笔迹错开) */
  seed?: number
}

/** 分组卡片(蜡笔手账):纸白卡 + 蜡笔描边 + 手绘不等圆角;组头带蜡笔波浪线。 */
export function Section({ header, footer, children, seed = 0 }: SectionProps) {
  const items = Children.toArray(children)
  return (
    <View style={{ display: 'flex', flexDirection: 'column', gap: `${metrics.space8}px` }}>
      {header ? (
        <View style={{ padding: `0 ${metrics.tilePadding}px`, display: 'flex' }}>
          <Text
            style={{
              ...typeStyle('labelMedium'),
              color: crayon.ink,
              paddingBottom: '7px',
              backgroundImage: crayonUnderline(crayon.orange),
              backgroundRepeat: 'no-repeat',
              backgroundPosition: 'left bottom',
              transform: 'rotate(-0.6deg)'
            }}
          >
            {header}
          </Text>
        </View>
      ) : null}
      <View
        style={{
          backgroundColor: '#FFFDF7',
          border: `2px solid ${crayon.stroke}`,
          borderRadius: wobble(seed),
          overflow: 'hidden',
          // 手贴微歪:相邻 Section(seed 不同)方向错开
          transform: `rotate(${seed % 2 === 0 ? -0.3 : 0.35}deg)`
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
