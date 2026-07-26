import { View, Text } from '@tarojs/components'
import { metrics, motion } from './tokens'
import { palette } from './theme'

export interface SegmentedControlProps {
  segments: string[]
  value: number
  onChange?: (index: number) => void
}

/** iOS 分段控件(docs/34 §8):9px 圆角,选中白底浮起。 */
export function SegmentedControl({ segments, value, onChange }: SegmentedControlProps) {
  return (
    <View
      style={{
        display: 'flex',
        backgroundColor: palette.secondaryFill,
        borderRadius: '9px',
        padding: '2px',
        gap: '2px'
      }}
    >
      {segments.map((seg, i) => {
        const selected = i === value
        return (
          <View
            key={seg}
            style={{
              flex: 1,
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              minHeight: '28px',
              borderRadius: '7px',
              backgroundColor: selected ? palette.secondaryGroupedBackground : 'transparent',
              transition: `background-color ${motion.press}ms ease`,
              ...(selected ? { boxShadow: '0 1px 2px rgba(0, 0, 0, 0.08)' } : {})
            }}
            onClick={() => onChange && onChange(i)}
          >
            <Text
              style={{
                fontSize: '13px',
                fontWeight: 500,
                color: selected ? palette.label : palette.secondaryLabel,
                padding: `0 ${metrics.space8}px`
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
