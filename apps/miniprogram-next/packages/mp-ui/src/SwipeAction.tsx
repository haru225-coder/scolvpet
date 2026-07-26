import { View, Text, type ITouchEvent } from '@tarojs/components'
import { useRef, useState, type ReactNode } from 'react'
import { motion, statusColors } from './tokens'
import { palette } from './theme'

export interface SwipeActionItem {
  text: string
  /** danger 红底(docs/34 §8:语义色仅真实状态) */
  danger?: boolean
  onClick?: () => void
}

export interface SwipeActionProps {
  children: ReactNode
  actions: SwipeActionItem[]
}

const ACTION_WIDTH = 72

/** 行左滑操作:触摸位移 + spring 回弹;点击动作后收起。 */
export function SwipeAction({ children, actions }: SwipeActionProps) {
  const [offset, setOffset] = useState(0)
  const [dragging, setDragging] = useState(false)
  const startX = useRef(0)
  const startOffset = useRef(0)
  const maxOffset = actions.length * ACTION_WIDTH

  const onTouchStart = (e: ITouchEvent) => {
    if (!e.touches || !e.touches[0]) return
    startX.current = e.touches[0].clientX
    startOffset.current = offset
    setDragging(true)
  }
  const onTouchMove = (e: ITouchEvent) => {
    if (!dragging || !e.touches || !e.touches[0]) return
    const delta = e.touches[0].clientX - startX.current
    setOffset(Math.min(0, Math.max(-maxOffset, startOffset.current + delta)))
  }
  const onTouchEnd = () => {
    setDragging(false)
    setOffset(offset < -maxOffset / 2 ? -maxOffset : 0)
  }

  return (
    <View style={{ position: 'relative', overflow: 'hidden' }}>
      <View style={{ position: 'absolute', top: 0, bottom: 0, right: 0, display: 'flex' }}>
        {actions.map((a) => (
          <View
            key={a.text}
            style={{
              width: `${ACTION_WIDTH}px`,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: a.danger ? statusColors.systemRed : palette.fill
            }}
            onClick={() => {
              setOffset(0)
              if (a.onClick) a.onClick()
            }}
          >
            <Text style={{ fontSize: '15px', color: a.danger ? '#FFFFFF' : palette.label }}>{a.text}</Text>
          </View>
        ))}
      </View>
      <View
        style={{
          position: 'relative',
          backgroundColor: palette.secondaryGroupedBackground,
          transform: `translateX(${offset}px)`,
          transition: dragging ? 'none' : `transform ${motion.spring}ms cubic-bezier(0.22, 1, 0.36, 1)`
        }}
        onTouchStart={onTouchStart as never}
        onTouchMove={onTouchMove as never}
        onTouchEnd={onTouchEnd}
      >
        {children}
      </View>
    </View>
  )
}
