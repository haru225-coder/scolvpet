import { View, Text } from '@tarojs/components'
import { motion } from './tokens'
import { palette } from './theme'

/**
 * 筛选切换(2026-08-02 重做)。
 *
 * 原实现是通宽药丸 + 内嵌高亮块,空态下比内容还重。
 * 现在:平铺文字 tab + 2px 下划线(橙=真选中)。
 */
export interface SegmentedControlProps {
  segments: string[]
  value: number
  onChange?: (index: number) => void
}

export function SegmentedControl({ segments, value, onChange }: SegmentedControlProps) {
  return (
    <View
      style={{
        display: 'flex',
        flexDirection: 'row',
        borderBottom: `1px solid ${palette.separator}`
      }}
    >
      {segments.map((seg, i) => {
        const selected = i === value
        return (
          <View
            key={seg}
            onClick={() => onChange && onChange(i)}
            style={{
              marginRight: '22px',
              paddingBottom: '10px',
              marginBottom: '-1px',
              borderBottom: `2px solid ${selected ? palette.accent : 'transparent'}`,
              transition: `border-color ${motion.press}ms ease`
            }}
          >
            <Text
              style={{
                fontSize: '14px',
                fontWeight: selected ? 600 : 500,
                color: selected ? palette.label : 'rgba(255,255,255,0.42)'
              }}
            >
              {seg}
            </Text>
          </View>
        )
      })}
    </View>
  )
}
