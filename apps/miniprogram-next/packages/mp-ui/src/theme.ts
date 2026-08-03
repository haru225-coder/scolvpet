import type { CSSProperties } from 'react'
import { paletteOf, themeMode, typography, type ScolvPalette, type TypeToken } from './tokens'

// UI 重组 v3:整体切「奶油深色」= ScolvPalette.dark(docs/34 §2.1 需同步修订)。
// 单一开关在 tokens.themeMode;此处不再硬绑 light。
export const palette: ScolvPalette = paletteOf(themeMode)

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
  borderTop: `1px solid ${palette.separator}`
}

// 2026-08-02：删除 wobble() / paperGrain / crayonUnderline。
// 装饰不能解决 AI 味；页面层从未真正需要它们。

/** @deprecated 兼容尚未去掉纸纹/蜡笔的旧页；新页禁止使用。 */
export function wobble(_seed = 0, _kind: 'gentle' | 'bold' = 'gentle'): string {
  return '8px'
}

/** @deprecated 兼容旧页；新页用纯色底。 */
export const paperGrain = 'none'

/** @deprecated 兼容旧页；新页禁止装饰下划线。 */
export function crayonUnderline(_color: string): string {
  return 'none'
}

