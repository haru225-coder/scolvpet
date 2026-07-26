// @tarojs/components 的 DOM 桩:快照测试只关心结构与样式,不跑小程序运行时。
import { forwardRef, type CSSProperties, type PropsWithChildren, type ReactNode } from 'react'

type AnyProps = PropsWithChildren<{
  style?: CSSProperties
  className?: string
  onClick?: (e: unknown) => void
  [key: string]: unknown
}>

function domify(tag: string, displayName: string) {
  const C = forwardRef<HTMLElement, AnyProps>((props, ref) => {
    const { children, onTouchStart, onTouchMove, onTouchEnd, onInput, hoverClass, hoverStayTime, ...rest } = props
    if (hoverClass != null) (rest as Record<string, unknown>)['data-hover-class'] = hoverClass
    if (hoverStayTime != null) (rest as Record<string, unknown>)['data-hover-stay'] = hoverStayTime
    const Tag = tag as 'div'
    return (
      <Tag
        ref={ref as never}
        data-taro={displayName}
        onTouchStart={onTouchStart as never}
        onTouchMove={onTouchMove as never}
        onTouchEnd={onTouchEnd as never}
        onInput={onInput as never}
        {...(rest as object)}
      >
        {children as ReactNode}
      </Tag>
    )
  })
  C.displayName = displayName
  return C
}

export const View = domify('div', 'View')
export const Text = domify('span', 'Text')
export const ScrollView = domify('div', 'ScrollView')
export const Input = domify('input', 'Input')
export const Image = domify('img', 'Image')
export const Button = domify('button', 'Button')
