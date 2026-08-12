import { View, Text } from '@tarojs/components'
import { useState } from 'react'
import { metrics, motion, statusColors } from './tokens'
import { palette } from './theme'
import { Sheet } from './Sheet'

export interface ActionPanelItem {
  text: string
  danger?: boolean
  onClick?: () => void
}

export interface ActionPanelProps {
  open: boolean
  title?: string
  actions: ActionPanelItem[]
  onClose?: () => void
}

function Row({
  text,
  danger,
  bold,
  onClick
}: {
  text: string
  danger?: boolean
  bold?: boolean
  onClick?: () => void
}) {
  const [pressed, setPressed] = useState(false)
  return (
    <View
      onClick={onClick}
      onTouchStart={() => setPressed(true)}
      onTouchEnd={() => setPressed(false)}
      onTouchCancel={() => setPressed(false)}
      style={{
        display: 'flex',
        justifyContent: 'center',
        padding: '16px',
        backgroundColor: pressed ? 'rgba(255,255,255,0.08)' : 'transparent',
        transition: `background-color ${motion.press}ms ease`
      }}
    >
      <Text
        style={{
          fontSize: '17px',
          fontWeight: bold ? 700 : 500,
          color: danger ? statusColors.systemRed : bold ? '#FFFFFF' : 'rgba(255,255,255,0.92)'
        }}
      >
        {text}
      </Text>
    </View>
  )
}

export function ActionPanel({ open, title, actions, onClose }: ActionPanelProps) {
  return (
    <Sheet open={open} onClose={onClose}>
      <View
        style={{
          padding: `0 ${metrics.pagePadding}px ${metrics.space8}px`,
          display: 'flex',
          flexDirection: 'column',
          gap: '10px'
        }}
      >
        <View
          style={{
            backgroundColor: palette.surfaceCard,
            borderRadius: '12px',
            overflow: 'hidden',
            border: '1px solid rgba(255,255,255,0.06)'
          }}
        >
          {title ? (
            <View
              style={{
                display: 'flex',
                justifyContent: 'center',
                padding: '12px',
                borderBottom: '1px solid rgba(255,255,255,0.06)'
              }}
            >
              <Text style={{ fontSize: '13px', color: 'rgba(255,255,255,0.45)' }}>{title}</Text>
            </View>
          ) : null}
          {actions.map((a, i) => (
            <View
              key={a.text}
              style={
                i > 0 || title ? { borderTop: '1px solid rgba(255,255,255,0.06)' } : undefined
              }
            >
              <Row
                text={a.text}
                danger={a.danger}
                onClick={() => {
                  if (a.onClick) a.onClick()
                  if (onClose) onClose()
                }}
              />
            </View>
          ))}
        </View>
        <View
          style={{
            backgroundColor: palette.surfaceCard,
            borderRadius: '12px',
            overflow: 'hidden',
            border: '1px solid rgba(255,255,255,0.06)'
          }}
        >
          <Row text="取消" bold onClick={onClose} />
        </View>
      </View>
    </Sheet>
  )
}
