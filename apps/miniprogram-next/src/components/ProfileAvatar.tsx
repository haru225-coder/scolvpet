import { View, Text } from '@tarojs/components'
import { useState } from 'react'
import { motion } from '@scolvpet/mp-ui'

import { openProfile } from '../utils/tab-routes'
import { peekBreederSession } from '../auth/session'

export default function ProfileAvatar() {
  const session = peekBreederSession()
  const name = session?.displayName || session?.organizationName || '我'
  const [pressed, setPressed] = useState(false)

  return (
    <View
      onClick={openProfile}
      onTouchStart={() => setPressed(true)}
      onTouchEnd={() => setPressed(false)}
      onTouchCancel={() => setPressed(false)}
      style={{
        // 2026-08-02：头像不应该是全页最亮的一块。橙实心 + 大投影 + 900 字重
        // 改成深底描边圆形，退到标题旁边当配角。
        width: '34px',
        height: '34px',
        borderRadius: '50%',
        backgroundColor: pressed ? 'rgba(255,255,255,0.16)' : '#1E1B19',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        transform: pressed ? 'scale(0.94)' : 'scale(1)',
        transition: `transform ${motion.spring}ms cubic-bezier(0.22, 1, 0.36, 1), background-color ${motion.press}ms ease`,
        border: '1px solid rgba(255,255,255,0.14)'
      }}
    >
      <Text style={{ fontSize: '13px', fontWeight: 600, color: 'rgba(255,255,255,0.65)' }}>{name.slice(0, 1)}</Text>
    </View>
  )
}
