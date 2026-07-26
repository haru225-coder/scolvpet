import { View, Text, Input } from '@tarojs/components'
import { useState } from 'react'
import {
  Section,
  SectionList,
  FormRow,
  Button,
  palette,
  metrics,
  typeStyle
} from '@scolvpet/mp-ui'

// M0 静态 UI:B 端短信登录版式(复用繁育者短信登录契约,M1 经 @api/client 接线)。
export default function LoginPage() {
  const [phone, setPhone] = useState('')
  const [code, setCode] = useState('')

  return (
    <View style={{ minHeight: '100vh', backgroundColor: palette.groupedBackground, paddingTop: `${metrics.space32}px` }}>
      <View style={{ padding: `0 ${metrics.pagePadding}px ${metrics.sectionGap}px` }}>
        <Text style={typeStyle('headlineSmall')}>登录熊舍</Text>
      </View>
      <SectionList>
        <Section footer="M0 样例:短信登录 M1 接线,当前不发送请求">
          <FormRow label="手机号">
            <Input
              type="number"
              maxlength={11}
              placeholder="填写繁育者手机号"
              placeholderStyle={`color: ${palette.tertiaryLabel}`}
              value={phone}
              onInput={(e) => setPhone(e.detail.value)}
            />
          </FormRow>
          <FormRow label="验证码" divider>
            <View style={{ display: 'flex', alignItems: 'center', gap: `${metrics.space12}px` }}>
              <Input
                type="number"
                maxlength={6}
                placeholder="6 位验证码"
                placeholderStyle={`color: ${palette.tertiaryLabel}`}
                value={code}
                onInput={(e) => setCode(e.detail.value)}
                style={{ flex: 1 }}
              />
              <Button variant="outlined" disabled>
                获取验证码
              </Button>
            </View>
          </FormRow>
        </Section>
        <Button block disabled={phone.length !== 11 || code.length !== 6}>
          登录
        </Button>
      </SectionList>
    </View>
  )
}
