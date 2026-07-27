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

/** ScolvPalette.dark */
export const paletteDark: ScolvPalette = {
  groupedBackground: '#14110F',
  secondaryGroupedBackground: '#1E1A17',
  systemBackground: '#14110F',
  secondarySystemBackground: '#1E1A17',
  label: '#F5EEE2',
  secondaryLabel: '#AFA69C',
  tertiaryLabel: '#7A726A',
  quaternaryLabel: '#524C46',
  separator: 'rgba(59, 61, 61, 0.15)',
  opaqueSeparator: '#3B3834',
  fill: 'rgba(245, 238, 226, 0.21)',
  secondaryFill: 'rgba(245, 238, 226, 0.14)',
  tertiaryFill: 'rgba(245, 238, 226, 0.08)',
  accent: '#E0A070',
  accentSoft: 'rgba(217, 139, 85, 0.20)',
  tabBarBackground: 'rgba(20, 17, 15, 0.94)',
  navBarBackground: 'rgba(20, 17, 15, 0.93)'
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
  pagePadding: 16,
  sectionGap: 24,
  listGap: 12,
  tilePadding: 16,
  tileVerticalPadding: 12,
  cardPadding: 16,
  bottomSafePadding: 32,
  rowMinHeight: 48,
  hairline: 0.5,
  navBarHeight: 44,
  tabBarHeight: 64
} as const

/** 动效强度(IosMetrics,ms) */
export const motion = {
  spring: 280,
  press: 90,
  page: 320
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
export const typography: Record<string, TypeToken> = {
  displayLarge: { fontSize: 40, fontWeight: 700, letterSpacing: -0.5, lineHeight: 1.08 },
  displayMedium: { fontSize: 32, fontWeight: 700, letterSpacing: -0.4, lineHeight: 1.1 },
  headlineLarge: { fontSize: 36, fontWeight: 700, letterSpacing: -0.4, lineHeight: 1.1 },
  headlineMedium: { fontSize: 30, fontWeight: 700, letterSpacing: -0.3, lineHeight: 1.12 },
  headlineSmall: { fontSize: 24, fontWeight: 700, letterSpacing: -0.2, lineHeight: 1.14 },
  titleLarge: { fontSize: 22, fontWeight: 600, letterSpacing: -0.3, lineHeight: 1.18 },
  titleMedium: { fontSize: 17, fontWeight: 600, letterSpacing: -0.24, lineHeight: 1.26 },
  titleSmall: { fontSize: 15, fontWeight: 600, letterSpacing: -0.16, lineHeight: 1.28 },
  bodyLarge: { fontSize: 17, fontWeight: 400, letterSpacing: -0.16, lineHeight: 1.52 },
  bodyMedium: { fontSize: 15, fontWeight: 400, letterSpacing: -0.08, lineHeight: 1.56, color: 'secondary' },
  bodySmall: { fontSize: 13, fontWeight: 400, letterSpacing: 0, lineHeight: 1.48, color: 'secondary' },
  labelLarge: { fontSize: 17, fontWeight: 400, letterSpacing: -0.16, lineHeight: 1.4 },
  labelMedium: { fontSize: 13, fontWeight: 500, letterSpacing: 0, lineHeight: 1.38, color: 'secondary' },
  labelSmall: { fontSize: 12, fontWeight: 500, letterSpacing: 0.05, lineHeight: 1.36, color: 'tertiary' }
}

/**
 * 蜡笔手账表层(2026-07-27 用户 Gate 裁定:iOS 素面判「AI 味」不过,
 * 叠加手绘/蜡笔质感;交互结构仍 iOS HIG)。色相与 palette 同族,饱和略提。
 */
export const crayon = {
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

/** 导航栏专用(AppBar:title 17/600/-0.41,大标题用 displayMedium 收缩到 title) */
export const navBar = {
  titleFontSize: 17,
  titleFontWeight: 600,
  titleLetterSpacing: -0.41,
  largeTitleFontSize: 32,
  largeTitleFontWeight: 700,
  iconSize: 22
} as const

export type ThemeMode = 'light' | 'dark'

export function paletteOf(mode: ThemeMode): ScolvPalette {
  return mode === 'dark' ? paletteDark : paletteLight
}
