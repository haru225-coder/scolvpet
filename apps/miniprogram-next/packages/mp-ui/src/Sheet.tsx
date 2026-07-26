import { View } from '@tarojs/components'
import type { ReactNode } from 'react'
import { metrics, motion } from './tokens'
import { palette } from './theme'

export interface SheetProps {
  open: boolean
  onClose?: () => void
  children: ReactNode
}

/** 底部弹层(docs/34 §8):large 24 圆角、拖拽指示条、遮罩点击关闭。 */
export function Sheet({ open, onClose, children }: SheetProps) {
  if (!open) return null
  return (
    <View style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, zIndex: 100 }}>
      <View
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'rgba(0, 0, 0, 0.35)'
        }}
        onClick={onClose}
      />
      <View
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: palette.groupedBackground,
          borderRadius: `${metrics.largeRadius}px ${metrics.largeRadius}px 0 0`,
          paddingBottom: `${metrics.bottomSafePadding}px`,
          animation: `mp-sheet-in ${motion.spring}ms cubic-bezier(0.22, 1, 0.36, 1)`
        }}
      >
        <View style={{ display: 'flex', justifyContent: 'center', padding: `${metrics.space8}px 0` }}>
          <View
            style={{
              width: '36px',
              height: '5px',
              borderRadius: '3px',
              backgroundColor: palette.fill
            }}
          />
        </View>
        {children}
      </View>
    </View>
  )
}
