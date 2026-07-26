import { View, Text } from '@tarojs/components'
import type { ReactNode } from 'react'
import { metrics, statusColors } from './tokens'
import { typeStyle, hairlineTop } from './theme'

export interface FormRowProps {
  /** 表单标签不能只依赖 placeholder(docs/16 §4.3) */
  label: string
  children: ReactNode
  /** 校验错误贴字段显示 */
  error?: string
  divider?: boolean
}

export function FormRow({ label, children, error, divider = false }: FormRowProps) {
  return (
    <View
      style={{
        display: 'flex',
        flexDirection: 'column',
        gap: '4px',
        padding: `${metrics.tileVerticalPadding}px ${metrics.tilePadding}px`,
        ...(divider ? hairlineTop : {})
      }}
    >
      <View style={{ display: 'flex', alignItems: 'center', gap: `${metrics.space12}px`, minHeight: '24px' }}>
        <Text style={{ ...typeStyle('bodyMedium'), width: '88px', flexShrink: 0 }}>{label}</Text>
        <View style={{ flex: 1, minWidth: 0 }}>{children}</View>
      </View>
      {error ? (
        <Text style={{ fontSize: '13px', lineHeight: 1.38, color: statusColors.systemRed, paddingLeft: '100px' }}>
          {error}
        </Text>
      ) : null}
    </View>
  )
}
