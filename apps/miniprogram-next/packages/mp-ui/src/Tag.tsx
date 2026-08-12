import { View, Text } from '@tarojs/components'
import type { ReactNode } from 'react'
import { statusColors } from './tokens'

export type TagTone = 'default' | 'accent' | 'success' | 'danger' | 'warning'

const tones: Record<TagTone, { bg: string; fg: string }> = {
  default: { bg: 'rgba(255,255,255,0.08)', fg: 'rgba(255,255,255,0.7)' },
  // 2026-08-02：accent 不再当橙色装饰。页面层假徽章已删；剩余 Cell 上的
  // accent（「选择」「目录」）也退成中性，橙色只留给底栏/筛选真选中态。
  accent: { bg: 'rgba(255,255,255,0.06)', fg: 'rgba(255,255,255,0.5)' },
  // 2026-08-12：状态色统一走 statusColors(token 真源)，不再各自硬编码。
  success: { bg: 'rgba(107, 168, 120, 0.18)', fg: statusColors.systemGreen },
  danger: { bg: 'rgba(226, 104, 91, 0.16)', fg: statusColors.systemRed },
  warning: { bg: 'rgba(226, 192, 119, 0.18)', fg: statusColors.systemOrange }
}

export function Tag({ children, tone = 'default' }: { children: ReactNode; tone?: TagTone }) {
  const t = tones[tone]
  return (
    <View
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        padding: '3px 9px',
        borderRadius: '4px',
        backgroundColor: t.bg
      }}
    >
      <Text style={{ fontSize: '12px', fontWeight: 600, lineHeight: 1.35, color: t.fg }}>{children}</Text>
    </View>
  )
}
