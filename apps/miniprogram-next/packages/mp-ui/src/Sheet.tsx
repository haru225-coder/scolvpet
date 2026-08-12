import { View } from '@tarojs/components'
import { useEffect, useRef, useState, type ReactNode } from 'react'
import { metrics, motion } from './tokens'
import { palette } from './theme'

export interface SheetProps {
  open: boolean
  onClose?: () => void
  children: ReactNode
}

/** 底部弹层：深色沉浸 + 顺滑上推，关闭时先播退场动画再卸载(§5 状态转换)。 */
export function Sheet({ open, onClose, children }: SheetProps) {
  const [closing, setClosing] = useState(false)
  const prevOpen = useRef(open)

  // 状态机：open 从 true→false 时不是立即卸载，而是置 closing=true 播退场；
  // 动画结束（或超时兜底）后才真正卸载。open false→true 复位回弹入态。
  useEffect(() => {
    if (prevOpen.current && !open) {
      setClosing(true)
    } else if (open) {
      setClosing(false)
    }
    prevOpen.current = open
  }, [open])

  // 兜底：若 onAnimationEnd 未触发（动画中断/页面隐藏），400ms 后强制卸载。
  useEffect(() => {
    if (!closing) return
    const timer = setTimeout(() => setClosing(false), 400)
    return () => clearTimeout(timer)
  }, [closing])

  // 初次挂载 open=false 时直接不渲染，不播动画。
  if (!open && !closing) return null

  return (
    <View style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, zIndex: 100 }}>
      <View
        className={closing ? 'mp-mask-out' : 'mp-mask-in'}
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
          backgroundColor: palette.surfaceCard,
          borderRadius: `${metrics.largeRadius}px ${metrics.largeRadius}px 0 0`,
          paddingBottom: `${metrics.bottomSafePadding}px`,
          borderTop: '1px solid rgba(255,255,255,0.08)',
          // 弹入快速跟手(spring)，退场舒缓(page)：快进慢出(iOS 原生节奏)
          animation: closing
            ? `mp-sheet-out ${motion.page}ms cubic-bezier(0.32, 0.72, 0.32, 1)`
            : `mp-sheet-in ${motion.spring}ms cubic-bezier(0.22, 1, 0.36, 1)`
        }}
        onAnimationEnd={() => {
          if (closing) setClosing(false)
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
