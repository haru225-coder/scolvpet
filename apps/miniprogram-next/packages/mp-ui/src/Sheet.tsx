import { View } from '@tarojs/components'
import type { ReactNode } from 'react'
import { metrics, motion } from './tokens'

export interface SheetProps {
  open: boolean
  onClose?: () => void
  children: ReactNode
}

/** 底部弹层：深色沉浸 + 顺滑上推。 */
export function Sheet({ open, onClose, children }: SheetProps) {
  if (!open) return null
  return (
    <View style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, zIndex: 100 }}>
      <View
        className="mp-mask-in"
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'rgba(0, 0, 0, 0.72)'
        }}
        onClick={onClose}
      />
      <View
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: '#14110F',
          borderRadius: '16px 16px 0 0',
          paddingBottom: `${metrics.bottomSafePadding}px`,
          borderTop: '1px solid rgba(255,255,255,0.08)',
          animation: `mp-sheet-in ${motion.spring}ms cubic-bezier(0.22, 1, 0.36, 1)`
        }}
      >
        <View style={{ display: 'flex', justifyContent: 'center', padding: `${metrics.space8}px 0 2px` }}>
          <View
            style={{
              width: '40px',
              height: '4px',
              borderRadius: '2px',
              backgroundColor: 'rgba(255,255,255,0.22)'
            }}
          />
        </View>
        {children}
      </View>
    </View>
  )
}
