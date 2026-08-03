import { View, Text } from '@tarojs/components'
import type { ReactNode } from 'react'
import { metrics } from './tokens'
import { Button } from './Button'

/**
 * 空态(2026-08-02 重做)。
 *
 * 默认不上插图,左对齐,安安静静两行字。需要插图的页面仍可主动传 illustration。
 */
export interface EmptyProps {
  title: string
  description?: string
  actionText?: string
  onAction?: () => void
  illustration?: ReactNode
}

export function Empty({ title, description, actionText, onAction, illustration }: EmptyProps) {
  return (
    <View
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'flex-start',
        padding: `${metrics.space32 + 12}px ${metrics.space16}px`,
        gap: '6px'
      }}
    >
      {illustration ? <View style={{ marginBottom: '10px' }}>{illustration}</View> : null}

      <Text style={{ fontSize: '16px', fontWeight: 500, lineHeight: 1.4, color: 'rgba(255,255,255,0.72)' }}>
        {title}
      </Text>

      {description ? (
        <Text style={{ fontSize: '14px', lineHeight: 1.5, color: 'rgba(255,255,255,0.38)' }}>{description}</Text>
      ) : null}

      {actionText ? (
        <View style={{ marginTop: '16px' }}>
          <Button variant="outlined" onClick={onAction}>
            {actionText}
          </Button>
        </View>
      ) : null}
    </View>
  )
}
