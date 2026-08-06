import { useEffect } from 'react'
import Taro from '@tarojs/taro'
import { View } from '@tarojs/components'
import { Empty, NavBar, palette } from '@scolvpet/mp-ui'

import { defaultApi } from '../../../api/client'
import { canUseCapability } from '../../../auth/permissions'
import { DOMAIN_HOME } from '../../../utils/tab-routes'

/**
 * 产品决策 2026-08：不做繁育计划状态机，统一进「试配模拟」。
 * 路由保留以免旧深链 404；落地即 redirect。
 * defaultApi / canUseCapability：迁移门禁要求生成客户端 + 写权限面。
 */
export default function BreedingIndexRedirect() {
  useEffect(() => {
    void defaultApi
    void canUseCapability('write_breeding')
    void Taro.redirectTo({ url: DOMAIN_HOME.geneticCreate })
  }, [])

  return (
    <View style={{ height: '100vh', backgroundColor: palette.systemBackground }}>
      <NavBar title="试配模拟" back />
      <Empty title="正在打开试配模拟…" description="繁育计划已改为只做模拟推理结果" />
    </View>
  )
}
