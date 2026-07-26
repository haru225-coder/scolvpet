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
