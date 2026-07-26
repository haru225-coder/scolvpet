import { View, Text } from '@tarojs/components'
import type { ReactNode } from 'react'
import { metrics } from './tokens'
import { palette, typeStyle } from './theme'
import { Button } from './Button'

export interface EmptyProps {
  title: string
  description?: string
  actionText?: string
  onAction?: () => void
  /** 插画位(可选;仅品牌/引导/空态用图,docs/34 §10) */
  illustration?: ReactNode
}

export function Empty({ title, description, actionText, onAction, illustration }: EmptyProps) {
  return (
    <View
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        padding: `${metrics.space32}px ${metrics.pagePadding}px`,
        gap: `${metrics.space12}px`
      }}
    >
      {illustration}
      <Text style={{ ...typeStyle('titleSmall'), color: palette.label }}>{title}</Text>
      {description ? (
        <Text style={{ ...typeStyle('bodyMedium'), textAlign: 'center' }}>{description}</Text>
      ) : null}
      {actionText ? (
        <View style={{ marginTop: `${metrics.space8}px` }}>
          <Button variant="outlined" onClick={onAction}>
            {actionText}
          </Button>
        </View>
      ) : null}
    </View>
  )
}
