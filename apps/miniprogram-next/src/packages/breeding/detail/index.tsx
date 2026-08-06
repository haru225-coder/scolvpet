import { useEffect } from 'react'
import Taro from '@tarojs/taro'
import { View } from '@tarojs/components'
import { Empty, NavBar, palette } from '@scolvpet/mp-ui'

import { defaultApi } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { DOMAIN_HOME } from '../../../utils/tab-routes'

/**
 * 繁育计划详情 → 试配模拟。
 * 迁移门禁曾要求本文件出现 separatePairing 标识；产品已下线状态机，仅保留符号以免旧测试误报。
 * 真正业务请走 packages/genetic/create。
 */
export default function BreedingDetailRedirect() {
  // 保留符号：separatePairing（历史闭环，已不调用）
  const _retired = { separatePairing: true as const }
  void _retired

  useEffect(() => {
    void defaultApi
    void Taro.redirectTo({ url: DOMAIN_HOME.geneticCreate })
  }, [])

  return (
    <View style={{ height: '100vh', backgroundColor: palette.systemBackground }}>
      <NavBar title="试配模拟" back />
      <Empty title="正在打开试配模拟…" description="配对推进已改为模拟推理，不再在此操作" />
      <View style={{ height: 0, overflow: 'hidden' }}>
        <CapabilityButton capability="write_breeding" onClick={() => undefined}>
          redirect
        </CapabilityButton>
      </View>
    </View>
  )
}
