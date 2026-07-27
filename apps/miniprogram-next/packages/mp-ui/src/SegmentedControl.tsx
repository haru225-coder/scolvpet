import { View, Text } from '@tarojs/components'
import { crayon, metrics, motion } from './tokens'
import { palette, wobble } from './theme'

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
        backgroundColor: crayon.paperDeep,
        border: `1.5px dashed ${crayon.strokeSoft}`,
        borderRadius: wobble(0),
        padding: '3px',
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
              borderRadius: wobble(i, 'bold'),
              backgroundColor: selected ? '#FFFDF7' : 'transparent',
              border: `2px solid ${selected ? crayon.stroke : 'transparent'}`,
              transition: `background-color ${motion.press}ms ease`,
              transform: selected ? 'rotate(-0.8deg)' : undefined
            }}
            onClick={() => onChange && onChange(i)}
          >
            <Text
              style={{
                fontSize: '13px',
                fontWeight: selected ? 600 : 500,
                color: selected ? crayon.ink : palette.secondaryLabel,
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
