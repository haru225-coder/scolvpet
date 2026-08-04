import { View } from '@tarojs/components'
import { useDidShow } from '@tarojs/taro'

import TrialPairingScreen from '../../genetics/TrialPairingScreen'
import { markTabActive, tabPageBottomPad } from '../../utils/tab-routes'

// 「试配」Tab（客户验收三件事之二）。
// tabBar 只能指主包页面，而试配原本在 packages/genetic 分包里，
// 所以 UI 抽到 src/genetics/TrialPairingScreen，本页（主包）与
// packages/genetic/create（旧深链）共用同一个组件，不抬第二份。
// 不要在 Tab 页开 renderer: skyline（会把自绘底标甩到顶部）。
export default function TrialTabPage() {
  useDidShow(() => markTabActive('/pages/trial/index'))

  return (
    <View
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        boxSizing: 'border-box',
        paddingBottom: tabPageBottomPad() + 'px'
      }}
    >
      <TrialPairingScreen hideBack />
    </View>
  )
}
