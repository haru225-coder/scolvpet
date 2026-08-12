import { ScrollView, View, Text } from '@tarojs/components'
import { useState, type ReactNode } from 'react'
import { metrics, motion } from './tokens'
import { palette } from './theme'
export interface RailProps {
  title: string
  action?: { text: string; onClick?: () => void }
  children: ReactNode
}

const EASE = 'cubic-bezier(0.22, 1, 0.36, 1)'

/** 横滑信息行（读信息，不是选片货架） */
export function Rail({ title, action, children }: RailProps) {
  const [actionPressed, setActionPressed] = useState(false)
  return (
    <View style={{ marginTop: '26px' }}>
      <View
        style={{
          display: 'flex',
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: `0 ${metrics.pagePadding}px 12px`
        }}
      >
        <Text
          style={{
            fontSize: '18px',
            fontWeight: 600,
            letterSpacing: '-0.3px',
            color: '#FFFFFF'
          }}
        >
          {title}
        </Text>
        {action ? (
          <Text
            onClick={action.onClick}
            onTouchStart={() => setActionPressed(true)}
            onTouchEnd={() => setActionPressed(false)}
            onTouchCancel={() => setActionPressed(false)}
            style={{
              fontSize: '13px',
              fontWeight: 600,
              color: actionPressed ? 'rgba(255,255,255,0.3)' : 'rgba(255,255,255,0.5)',
              padding: '6px 0 6px 12px',
              transition: `color ${motion.press}ms ease`
            }}
          >
            {action.text} ›
          </Text>
        ) : null}
      </View>
      <ScrollView scrollX type="list" enhanced showScrollbar={false} style={{ width: '100%' }}>
        <View
          style={{
            display: 'flex',
            flexDirection: 'row',
            alignItems: 'center',
            padding: `2px ${metrics.pagePadding + 48}px 6px ${metrics.pagePadding}px`
          }}
        >
          {children}
        </View>
      </ScrollView>
    </View>
  )
}

// 2026-08-02：原先是六条 165° 三色渐变，无真图时冒充宠物海报。
// 假多样性本身是装饰噪声。收敛为单一中性深底；保留导出名兼容旧调用。
export const PLACEHOLDER_SURFACE = '#1E1C1A'
export const COAT_SWATCHES: string[] = [PLACEHOLDER_SURFACE]

/** 近方形信息卡尺寸（非 2:3 电影海报） */
const CARD_W = 138
const CARD_H = 122

export interface PosterCardProps {
  title: string
  subtitle?: string
  swatch?: string
  seed?: number
  /**
   * 保留以兼容旧调用。2026-08-02 起不再放大主推位——
   * 养殖信息流不需要 Netflix 货架感。
   */
  featured?: boolean
  badge?: string
  photoUrl?: string
  onClick?: () => void
  /** 长按（如种群卡片试配菜单） */
  onLongPress?: () => void
}

export function PosterCard({
  title,
  subtitle,
  swatch,
  badge,
  photoUrl,
  onClick,
  onLongPress
}: PosterCardProps) {
  const [pressed, setPressed] = useState(false)
  const fill = swatch || PLACEHOLDER_SURFACE
  const w = CARD_W
  const h = CARD_H

  return (
    <View
      onClick={onClick}
      onLongPress={onLongPress}
      onTouchStart={() => setPressed(true)}
      onTouchEnd={() => setPressed(false)}
      onTouchCancel={() => setPressed(false)}
      style={{
        width: w + 'px',
        marginRight: '8px',
        transform: pressed ? 'scale(0.97)' : 'scale(1)',
        // 按压用 press(90ms)快速到位，回弹才用 spring(§5)
        transition: `transform ${pressed ? motion.press : motion.spring}ms ${EASE}`
      }}
    >
      <View
        style={{
          position: 'relative',
          width: w + 'px',
          height: h + 'px',
          borderRadius: '6px',
          overflow: 'hidden',
          backgroundImage: photoUrl ? `url(${photoUrl})` : undefined,
          backgroundColor: photoUrl ? undefined : fill,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          outline: pressed ? '2px solid rgba(255,255,255,0.85)' : '1px solid rgba(255,255,255,0.07)'
        }}
      >
        {photoUrl ? (
          <View
            style={{
              position: 'absolute',
              left: 0,
              right: 0,
              bottom: 0,
              height: '52%',
              backgroundImage: 'linear-gradient(180deg, rgba(0,0,0,0) 0%, rgba(0,0,0,0.72) 100%)',
              pointerEvents: 'none'
            }}
          />
        ) : (
          <View
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}
          >
            <Text style={{ fontSize: '26px', fontWeight: 600, color: 'rgba(255,255,255,0.12)' }}>
              {title.slice(0, 1)}
            </Text>
          </View>
        )}
        {badge ? (
          <View
            style={{
              position: 'absolute',
              left: '8px',
              top: '8px',
              padding: '3px 8px',
              borderRadius: '3px',
              backgroundColor: 'rgba(0,0,0,0.82)'
            }}
          >
            <Text style={{ fontSize: '10px', fontWeight: 600, color: 'rgba(255,255,255,0.82)' }}>
              {badge}
            </Text>
          </View>
        ) : null}
        <View
          style={{
            position: 'absolute',
            left: '10px',
            right: '10px',
            bottom: '10px'
          }}
        >
          <Text
            style={{
              display: 'block',
              fontSize: '13px',
              fontWeight: 600,
              color: '#FFFFFF',
              overflow: 'hidden',
              whiteSpace: 'nowrap',
              textOverflow: 'ellipsis'
            }}
          >
            {title}
          </Text>
          {subtitle ? (
            <Text
              style={{
                display: 'block',
                marginTop: '3px',
                fontSize: '11px',
                color: 'rgba(255,255,255,0.7)',
                overflow: 'hidden',
                whiteSpace: 'nowrap',
                textOverflow: 'ellipsis'
              }}
            >
              {subtitle}
            </Text>
          ) : null}
        </View>
      </View>
    </View>
  )
}

export interface MiniCardProps {
  title: string
  value?: string
  subtitle?: string
  onClick?: () => void
}

export function MiniCard({ title, value, subtitle, onClick }: MiniCardProps) {
  const [pressed, setPressed] = useState(false)
  return (
    <View
      onClick={onClick}
      onTouchStart={() => setPressed(true)}
      onTouchEnd={() => setPressed(false)}
      onTouchCancel={() => setPressed(false)}
      style={{
        width: '160px',
        marginRight: '8px',
        padding: '16px 14px 18px',
        borderRadius: '8px',
        backgroundColor: pressed ? 'rgba(255,255,255,0.06)' : palette.surfaceCard,
        border: '1px solid rgba(255,255,255,0.09)',
        boxSizing: 'border-box',
        transform: pressed ? 'scale(0.97)' : 'scale(1)',
        transition: `transform ${pressed ? motion.press : motion.spring}ms ${EASE}, background-color ${motion.press}ms ease`
      }}
    >
      <Text style={{ display: 'block', fontSize: '12px', color: 'rgba(255,255,255,0.48)', fontWeight: 600 }}>
        {title}
      </Text>
      {value ? (
        <Text
          style={{
            display: 'block',
            marginTop: '8px',
            fontSize: '28px',
            fontWeight: 600,
            letterSpacing: '-0.6px',
            color: '#FFFFFF'
          }}
        >
          {value}
        </Text>
      ) : null}
      {subtitle ? (
        <Text style={{ display: 'block', marginTop: '5px', fontSize: '11px', color: 'rgba(255,255,255,0.32)' }}>
          {subtitle}
        </Text>
      ) : null}
    </View>
  )
}
