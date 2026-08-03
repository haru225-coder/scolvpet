/**
 * ScolvPet 小程序仿 iOS 设计 token(docs/34《小程序仿 iOS 设计规范》)。
 *
 * 真源:apps/mobile/lib/ui/theme/ios_theme.dart(UI V2 视觉草稿:
 * 奶油底 × 金丝熊暖橙 × 深咖字)。Dart Color(0xAARRGGBB) 按
 * alpha/255 保留两位小数换算为 CSS rgba;不透明色保留 hex。
 * 改动流程:先改 Flutter 端 ios_theme.dart,再同步此文件与 docs/34。
 *
 * 数值单位:长度为设计 px(designWidth 375,即 iOS pt);时长为 ms。
 */

export interface ScolvPalette {
  groupedBackground: string
  secondaryGroupedBackground: string
  systemBackground: string
  secondarySystemBackground: string
  label: string
  secondaryLabel: string
  tertiaryLabel: string
  quaternaryLabel: string
  separator: string
  opaqueSeparator: string
  fill: string
  secondaryFill: string
  tertiaryFill: string
  accent: string
  accentSoft: string
  tabBarBackground: string
  navBarBackground: string
}

/**
 * 主题模式单一开关(UI 重组 v3:B 端整体切「奶油深色」)。
 * 改回浅色只需把 themeMode 改成 'light',无需改任何页面。
 * 真源仍是 apps/mobile/lib/ui/theme/ios_theme.dart 的 ScolvPalette.dark,
 * 本次未新增任何颜色。
 */
export type ThemeMode = 'light' | 'dark'
export const themeMode: ThemeMode = 'dark'

/** ScolvPalette.light */
export const paletteLight: ScolvPalette = {
  groupedBackground: '#FFF8EF',
  secondaryGroupedBackground: '#FFFFFF',
  systemBackground: '#FFF8EF',
  secondarySystemBackground: '#FFFFFF',
  label: '#3A2F29',
  secondaryLabel: '#7A6E66',
  tertiaryLabel: '#A0958C',
  quaternaryLabel: '#C4BAB2',
  separator: '#E8DFD6',
  opaqueSeparator: '#D9CFC5',
  fill: 'rgba(58, 47, 41, 0.14)',
  secondaryFill: 'rgba(58, 47, 41, 0.09)',
  tertiaryFill: 'rgba(58, 47, 41, 0.06)',
  accent: '#D98B55',
  accentSoft: '#FBE8D8',
  tabBarBackground: 'rgba(255, 253, 249, 0.97)',
  navBarBackground: 'rgba(255, 253, 249, 0.97)'
}

/** ScolvPalette.dark · 更深黑、更猛沉浸 */
export const paletteDark: ScolvPalette = {
  groupedBackground: '#050403',
  secondaryGroupedBackground: '#14110F',
  systemBackground: '#050403',
  secondarySystemBackground: '#0C0A09',
  label: '#FFFFFF',
  secondaryLabel: 'rgba(255,255,255,0.68)',
  tertiaryLabel: 'rgba(255,255,255,0.4)',
  quaternaryLabel: 'rgba(255,255,255,0.26)',
  separator: 'rgba(255,255,255,0.09)',
  opaqueSeparator: '#2A2622',
  fill: 'rgba(255,255,255,0.14)',
  secondaryFill: 'rgba(255,255,255,0.09)',
  tertiaryFill: 'rgba(255,255,255,0.05)',
  accent: '#E8A56A',
  accentSoft: 'rgba(232, 165, 106, 0.28)',
  tabBarBackground: 'rgba(5, 4, 3, 0.98)',
  navBarBackground: 'rgba(5, 4, 3, 0.9)'
}

/** 状态色(IosColors,两模式共用) */
export const statusColors = {
  /** 品牌橙(warning 同色) */
  accent: '#D98B55',
  accentSoft: '#FBE8D8',
  systemBlue: '#007AFF',
  /** 柔和绿 success */
  systemGreen: '#6B7D6B',
  /** 克制砖红 danger */
  systemRed: '#E2685B',
  /** 琥珀/品牌橙 warning */
  systemOrange: '#D98B55',
  systemTeal: '#5AC8FA',
  systemIndigo: '#5856D6',
  systemPurple: '#AF52DE',
  systemGray: '#8E8E93',
  systemGray5: '#E5E5EA',
  systemGray6: '#F2F2F7'
} as const

/** 间距 / 圆角 rhythm(IosMetrics:3 档圆角 + 4/8/12/16/24/32) */
export const metrics = {
  smallRadius: 8,
  /** medium */
  continuousRadius: 16,
  largeRadius: 24,
  pillRadius: 980,
  space4: 4,
  space8: 8,
  space12: 12,
  space16: 16,
  space24: 24,
  space32: 32,
  pagePadding: 14,
  sectionGap: 28,
  listGap: 12,
  tilePadding: 16,
  tileVerticalPadding: 14,
  cardPadding: 16,
  bottomSafePadding: 36,
  rowMinHeight: 52,
  hairline: 0.5,
  navBarHeight: 44,
  tabBarHeight: 68
} as const

/** 动效：更跟手的弹回 */
export const motion = {
  spring: 360,
  press: 90,
  page: 400
} as const

export interface TypeToken {
  fontSize: number
  fontWeight: 400 | 500 | 600 | 700
  letterSpacing: number
  lineHeight: number
  /** secondary/tertiary 表示默认用对应弱化 label 色 */
  color?: 'secondary' | 'tertiary'
}

/** 字阶(_iosTextTheme;系统字体,不引私有字体名) */
// 2026-08-02：原 14 档，页面实际只用 body 三档。重档 40/36/32 + 700 是「大标题压人」弹药库。
export const typography: Record<string, TypeToken> = {
  bodyLarge: { fontSize: 17, fontWeight: 400, letterSpacing: -0.16, lineHeight: 1.52 },
  bodyMedium: { fontSize: 15, fontWeight: 400, letterSpacing: -0.08, lineHeight: 1.56, color: 'secondary' },
  bodySmall: { fontSize: 13, fontWeight: 400, letterSpacing: 0, lineHeight: 1.48, color: 'secondary' }
}

/**
 * 蜡笔手账表层(2026-07-27 用户 Gate 裁定:iOS 素面判「AI 味」不过,
 * 叠加手绘/蜡笔质感;交互结构仍 iOS HIG)。色相与 palette 同族,饱和略提。
 */
export const crayonLight = {
  /** 牛皮纸底(替代 groupedBackground 用于 B 端新页) */
  paper: '#FBF2E3',
  paperDeep: '#F5E7D0',
  ink: '#46362A',
  orange: '#E08A4F',
  green: '#7C9A6D',
  yellow: '#EFC35F',
  red: '#D96C5B',
  /** 蜡笔描边(卡片/按钮/贴纸共用) */
  stroke: 'rgba(70, 54, 42, 0.48)',
  strokeSoft: 'rgba(70, 54, 42, 0.24)'
} as const

/** 深色手账层：与 Netflix 沉浸黑对齐，避免列表页偏灰棕 */
export const crayonDark = {
  paper: '#050403',
  paperDeep: '#0C0A09',
  ink: '#F5F5F5',
  orange: '#E8A56A',
  green: '#8FA890',
  yellow: '#E2C077',
  red: '#E08375',
  stroke: 'rgba(255, 255, 255, 0.14)',
  strokeSoft: 'rgba(255, 255, 255, 0.08)'
} as const

/** 当前模式的手账层。23 个页面直接 import { crayon },由此处一刀切。 */
export const crayon = themeMode === 'dark' ? crayonDark : crayonLight

/** 导航栏专用(AppBar:title 17/600/-0.41,大标题用 displayMedium 收缩到 title) */
export const navBar = {
  titleFontSize: 17,
  titleFontWeight: 600,
  titleLetterSpacing: -0.41,
  largeTitleFontSize: 32,
  largeTitleFontWeight: 700,
  iconSize: 22
} as const

export function paletteOf(mode: ThemeMode): ScolvPalette {
  return mode === 'dark' ? paletteDark : paletteLight
}
