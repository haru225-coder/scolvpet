import { View } from '@tarojs/components'
import { crayon } from './tokens'

// 手绘贴纸(内联 SVG data URI,零外部资源;蜡笔手账表层)。
// 线条刻意不闭合/不对称,模拟蜡笔笔迹。

const INK = encodeURIComponent(crayon.ink)
const ORANGE = encodeURIComponent(crayon.orange)

/** 金丝熊脸:圆脸 + 耳 + 腮红 + 瓜子嘴 */
const HAMSTER = `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 96 96'%3E%3Cg fill='none' stroke='${INK}' stroke-width='3' stroke-linecap='round'%3E%3Cpath d='M27 26 Q20 12 31 13 Q38 14 36 23' fill='%23F5E7D0'/%3E%3Cpath d='M69 26 Q76 12 65 13 Q58 14 60 23' fill='%23F5E7D0'/%3E%3Cpath d='M48 16 Q78 17 79 48 Q80 76 48 79 Q16 76 17 48 Q18 17 48 16 Z' fill='%23FBF2E3'/%3E%3Cpath d='M35 44 q2 -3 4 0' /%3E%3Cpath d='M57 44 q2 -3 4 0' /%3E%3Cpath d='M45 55 q3 3 6 0' /%3E%3Cpath d='M48 55 l0 6' stroke-width='2.4'/%3E%3C/g%3E%3Ccircle cx='30' cy='53' r='5' fill='${ORANGE}' opacity='0.45'/%3E%3Ccircle cx='66' cy='53' r='5' fill='${ORANGE}' opacity='0.45'/%3E%3C/svg%3E")`

/** 爪印 */
const PAW = `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 48 48'%3E%3Cg fill='${ORANGE}' opacity='0.8'%3E%3Cellipse cx='24' cy='30' rx='9' ry='7.5'/%3E%3Cellipse cx='11' cy='20' rx='4' ry='5' transform='rotate(-18 11 20)'/%3E%3Cellipse cx='20' cy='14' rx='4' ry='5'/%3E%3Cellipse cx='29' cy='14' rx='4' ry='5'/%3E%3Cellipse cx='37' cy='20' rx='4' ry='5' transform='rotate(18 37 20)'/%3E%3C/g%3E%3C/svg%3E")`

/** 瓜子(空态/装饰) */
const SEED = `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 40 40'%3E%3Cpath d='M20 4 Q31 16 27 28 Q24 36 20 36 Q16 36 13 28 Q9 16 20 4 Z' fill='%23F5E7D0' stroke='${INK}' stroke-width='2.6' stroke-linecap='round'/%3E%3Cpath d='M20 10 L20 30' stroke='${INK}' stroke-width='2' opacity='0.5'/%3E%3C/svg%3E")`

const ART = { hamster: HAMSTER, paw: PAW, seed: SEED } as const

export interface StickerProps {
  name: keyof typeof ART
  size?: number
  /** 手贴的歪度(deg) */
  tilt?: number
}

export function Sticker({ name, size = 72, tilt = 0 }: StickerProps) {
  return (
    <View
      style={{
        width: `${size}px`,
        height: `${size}px`,
        backgroundImage: ART[name],
        backgroundSize: 'contain',
        backgroundRepeat: 'no-repeat',
        transform: tilt ? `rotate(${tilt}deg)` : undefined
      }}
    />
  )
}
