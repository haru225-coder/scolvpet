import { View } from '@tarojs/components'
import { crayon } from './tokens'

/**
 * 图形标记(2026-08-02 重做)。
 *
 * 原实现是手绘蜡笔贴纸(填色圆脸 + 腻红)。真机深色底上 72px 糊成白饼。
 * 现在:单色线性图形,与底栏图标同一套语言。导出名与 props 保持不变。
 */

const LINE = encodeURIComponent(crayon.ink)
const ORANGE = encodeURIComponent(crayon.orange)
const GREEN = encodeURIComponent(crayon.green)

function glyph(inner: string, stroke: string = LINE): string {
  return (
    `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'` +
    ` fill='none' stroke='${stroke}' stroke-width='1.7' stroke-linecap='round'` +
    ` stroke-linejoin='round'%3E${inner}%3C/svg%3E")`
  )
}

/** 小宠（圆脸 + 两只耳，纯线性） */
const HAMSTER = glyph(
  `%3Cpath d='M7.6 6.6a2.6 2.6 0 1 1 3.1-1.2'/%3E` +
    `%3Cpath d='M16.4 6.6a2.6 2.6 0 1 0-3.1-1.2'/%3E` +
    `%3Cpath d='M12 5.6c4.4 0 7.4 3.3 7.4 7.3S16.4 20 12 20s-7.4-3.1-7.4-7.1S7.6 5.6 12 5.6Z'/%3E` +
    `%3Cpath d='M9.4 12.1h.01M14.6 12.1h.01'/%3E` +
    `%3Cpath d='M10.8 15.2a1.9 1.9 0 0 0 2.4 0'/%3E`
)

/** 爪印 */
const PAW = glyph(
  `%3Cpath d='M12 14.4c2.2 0 3.8 1.3 3.8 3s-1.4 2.6-3.8 2.6-3.8-.9-3.8-2.6 1.6-3 3.8-3Z'/%3E` +
    `%3Cpath d='M6.6 9.4c.9 0 1.6.9 1.6 2s-.7 2-1.6 2S5 12.5 5 11.4s.7-2 1.6-2Z'/%3E` +
    `%3Cpath d='M17.4 9.4c.9 0 1.6.9 1.6 2s-.7 2-1.6 2-1.6-.9-1.6-2 .7-2 1.6-2Z'/%3E` +
    `%3Cpath d='M10 5.2c.9 0 1.6.9 1.6 2.1s-.7 2.1-1.6 2.1-1.6-.9-1.6-2.1S9.1 5.2 10 5.2Z'/%3E` +
    `%3Cpath d='M14 5.2c.9 0 1.6.9 1.6 2.1s-.7 2.1-1.6 2.1-1.6-.9-1.6-2.1S13.1 5.2 14 5.2Z'/%3E`,
  ORANGE
)

/** 瓜子 */
const SEED = glyph(
  `%3Cpath d='M12 3.6c3.4 3.4 4.4 7.4 2.9 11.2C13.9 17.5 12.9 19 12 20c-.9-1-1.9-2.5-2.9-5.2C7.6 11 8.6 7 12 3.6Z'/%3E`
)

/** 向日葵 */
const SUNFLOWER = glyph(
  `%3Ccircle cx='12' cy='12' r='3.4'/%3E` +
    `%3Cpath d='M12 3.4v3.1M12 17.5v3.1M3.4 12h3.1M17.5 12h3.1'/%3E` +
    `%3Cpath d='M5.9 5.9l2.2 2.2M15.9 15.9l2.2 2.2M18.1 5.9l-2.2 2.2M8.1 15.9l-2.2 2.2'/%3E`,
  ORANGE
)

/** 爱心 */
const HEART = glyph(
  `%3Cpath d='M12 19.6s-7.3-4.2-7.3-9A3.9 3.9 0 0 1 12 8.3a3.9 3.9 0 0 1 7.3 2.3c0 4.8-7.3 9-7.3 9Z'/%3E`,
  ORANGE
)

/** 星星 */
const STAR = glyph(`%3Cpath d='M12 4.2l2.5 5.1 5.6.8-4.1 4 1 5.6-5-2.7-5 2.7 1-5.6-4.1-4 5.6-.8Z'/%3E`)

/** 嫩芽 */
const SPROUT = glyph(
  `%3Cpath d='M12 20.4v-7.6'/%3E` +
    `%3Cpath d='M12 13.2C12 9.9 9.8 7.7 6.2 7.4c-.3 3.6 1.9 5.8 5.8 5.8Z'/%3E` +
    `%3Cpath d='M12 12.2c0-3 2-5 5.3-5.3.3 3.3-1.7 5.3-5.3 5.3Z'/%3E`,
  GREEN
)

const ART = {
  hamster: HAMSTER,
  paw: PAW,
  seed: SEED,
  sunflower: SUNFLOWER,
  heart: HEART,
  star: STAR,
  sprout: SPROUT
} as const

export interface StickerProps {
  name: keyof typeof ART
  size?: number
  /** 保留入参以兼容旧调用；线性图形不再歪着放。 */
  tilt?: number
}

export function Sticker({ name, size = 40 }: StickerProps) {
  return (
    <View
      style={{
        width: `${size}px`,
        height: `${size}px`,
        backgroundImage: ART[name],
        backgroundSize: 'contain',
        backgroundRepeat: 'no-repeat',
        backgroundPosition: 'center'
      }}
    />
  )
}
