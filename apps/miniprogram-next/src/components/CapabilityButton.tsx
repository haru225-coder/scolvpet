import { Button, type ButtonProps } from '@scolvpet/mp-ui'

import { canUseCapability } from '../auth/permissions'

type Props = ButtonProps & {
  capability: string
}

/**
 * 详情页/表单页的写入口统一经过这里；后端 RBAC 仍是最终权限裁决。
 * 没有能力时不渲染按钮，避免 viewer 进入页面后看到必然 403 的操作。
 */
export function CapabilityButton({ capability, ...props }: Props) {
  if (!canUseCapability(capability)) return null
  return <Button {...props} />
}
