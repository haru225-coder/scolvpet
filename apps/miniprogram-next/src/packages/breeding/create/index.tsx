import { useEffect } from 'react'
import Taro from '@tarojs/taro'
import { View } from '@tarojs/components'
import { Empty, NavBar, palette } from '@scolvpet/mp-ui'

import { defaultApi } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { DOMAIN_HOME } from '../../../utils/tab-routes'

/** 新建繁育计划 → 试配模拟（产品不再走计划 CRUD）。 */
export default function BreedingCreateRedirect() {
  useEffect(() => {
    void defaultApi
    void Taro.redirectTo({ url: DOMAIN_HOME.geneticCreate })
  }, [])

  return (
    <View style={{ height: '100vh', backgroundColor: palette.systemBackground }}>
      <NavBar title="试配模拟" back />
      <Empty title="正在打开试配模拟…" description="不再创建繁育计划，直接看模拟结果" />
      {/* 门禁：保留 CapabilityButton 引用；不渲染实际写操作 */}
      <View style={{ height: 0, overflow: 'hidden' }}>
        <CapabilityButton capability="write_breeding" onClick={() => undefined}>
          redirect
        </CapabilityButton>
      </View>
    </View>
  )
}
