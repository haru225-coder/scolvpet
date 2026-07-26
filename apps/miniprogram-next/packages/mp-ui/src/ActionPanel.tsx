import { View, Text } from '@tarojs/components'
import { metrics, statusColors } from './tokens'
import { palette } from './theme'
import { Sheet } from './Sheet'
import { hairlineTop } from './theme'

export interface ActionPanelItem {
  text: string
  /** 破坏性操作红字(需确认/可撤销路径由业务承担,docs/16 §4.2) */
  danger?: boolean
  onClick?: () => void
}

export interface ActionPanelProps {
  open: boolean
  title?: string
  actions: ActionPanelItem[]
  onClose?: () => void
}

/** 动作面板:动作列表 + 分离的取消项。 */
export function ActionPanel({ open, title, actions, onClose }: ActionPanelProps) {
  return (
    <Sheet open={open} onClose={onClose}>
      <View style={{ padding: `0 ${metrics.pagePadding}px`, display: 'flex', flexDirection: 'column', gap: `${metrics.space8}px` }}>
        <View style={{ backgroundColor: palette.secondaryGroupedBackground, borderRadius: `${metrics.continuousRadius}px`, overflow: 'hidden' }}>
          {title ? (
            <View style={{ display: 'flex', justifyContent: 'center', padding: `${metrics.space12}px` }}>
              <Text style={{ fontSize: '13px', color: palette.secondaryLabel }}>{title}</Text>
            </View>
          ) : null}
          {actions.map((a, i) => (
            <View
              key={a.text}
              style={{
                display: 'flex',
                justifyContent: 'center',
                padding: '14px',
                ...(i > 0 || title ? hairlineTop : {})
              }}
              onClick={() => {
                if (a.onClick) a.onClick()
                if (onClose) onClose()
              }}
            >
              <Text style={{ fontSize: '17px', color: a.danger ? statusColors.systemRed : palette.label }}>
                {a.text}
              </Text>
            </View>
          ))}
        </View>
        <View
          style={{
            display: 'flex',
            justifyContent: 'center',
            padding: '14px',
            backgroundColor: palette.secondaryGroupedBackground,
            borderRadius: `${metrics.continuousRadius}px`
          }}
          onClick={onClose}
        >
          <Text style={{ fontSize: '17px', fontWeight: 600, color: palette.accent }}>取消</Text>
        </View>
      </View>
    </Sheet>
  )
}
