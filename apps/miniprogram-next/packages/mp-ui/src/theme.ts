import type { CSSProperties } from 'react'
import { paletteLight, typography, type ScolvPalette, type TypeToken } from './tokens'

// M0 先固定 light(docs/34 §2.1);M2 评估微信 DarkMode 后由 Provider 切换。
export const palette: ScolvPalette = paletteLight

/** 把字阶 token 摊平成 CSSProperties(px = 设计 pt) */
export function typeStyle(name: keyof typeof typography): CSSProperties {
  const t: TypeToken = typography[name]
  const color =
    t.color === 'secondary'
      ? palette.secondaryLabel
      : t.color === 'tertiary'
        ? palette.tertiaryLabel
        : palette.label
  return {
    fontSize: `${t.fontSize}px`,
    fontWeight: t.fontWeight,
    letterSpacing: `${t.letterSpacing}px`,
    lineHeight: t.lineHeight,
    color
  }
}

export const hairlineTop: CSSProperties = {
  borderTop: `0.5px solid ${palette.separator}`
}

// —— 蜡笔手账表层工具(见 tokens.crayon 注释)——

/** 手绘感圆角:四角不等,seed 取不同笔迹;gentle 用于卡片,bold 用于按钮/贴纸 */
export function wobble(seed = 0, kind: 'gentle' | 'bold' = 'gentle'): string {
  const gentle = [
    '17px 21px 15px 23px / 21px 15px 23px 17px',
    '22px 15px 21px 16px / 15px 22px 16px 21px',
    '15px 23px 17px 21px / 23px 17px 21px 15px'
  ]
  const bold = [
    '255px 25px 225px 25px / 25px 225px 25px 255px',
    '25px 225px 25px 255px / 255px 25px 225px 25px'
  ]
  const set = kind === 'bold' ? bold : gentle
  return set[Math.abs(seed) % set.length]
}

/** 纸纹(SVG 噪点,低透明度;data URI,无外部资源) */
export const paperGrain =
  "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2'/%3E%3C/filter%3E%3Crect width='140' height='140' filter='url(%23n)' opacity='0.05'/%3E%3C/svg%3E\")"

/** 蜡笔波浪下划线(组头/大标题装饰) */
export function crayonUnderline(color: string): string {
  const c = encodeURIComponent(color)
  return `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='72' height='6' viewBox='0 0 72 6'%3E%3Cpath d='M1 4 Q 10 1 19 3.5 T 37 3 T 55 3.6 T 71 2.6' fill='none' stroke='${c}' stroke-width='2.4' stroke-linecap='round' opacity='0.85'/%3E%3C/svg%3E")`
}
