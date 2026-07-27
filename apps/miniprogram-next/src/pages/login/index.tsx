import { View, Text, Input } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useState } from 'react'
import {
  Section,
  SectionList,
  FormRow,
  Button,
  Sticker,
  crayon,
  paperGrain,
  crayonUnderline,
  palette,
  metrics,
  typeStyle
} from '@scolvpet/mp-ui'

// M0 静态 UI:B 端短信登录版式(复用繁育者短信登录契约,M1 经 @api/client 接线)。
export default function LoginPage() {
  const [phone, setPhone] = useState('')
  const [code, setCode] = useState('')

  return (
    <View
      style={{
        minHeight: '100vh',
        backgroundColor: crayon.paper,
        backgroundImage: paperGrain,
        paddingTop: `${metrics.space32}px`
      }}
    >
      <View
        style={{
          padding: `0 ${metrics.pagePadding}px ${metrics.sectionGap}px`,
          display: 'flex',
          alignItems: 'flex-end',
          justifyContent: 'space-between'
        }}
      >
        <Text
          style={{
            ...typeStyle('headlineSmall'),
            color: crayon.ink,
            paddingBottom: '8px',
            backgroundImage: crayonUnderline(crayon.orange),
            backgroundRepeat: 'no-repeat',
            backgroundPosition: 'left bottom',
            backgroundSize: '96px 8px'
          }}
        >
          登录熊舍
        </Text>
        <Sticker name="seed" size={40} tilt={10} />
      </View>
      <SectionList>
        {/* 探头的仓鼠:压在表单卡上沿 */}
        <View style={{ display: 'flex', justifyContent: 'flex-end', paddingRight: '22px', marginBottom: '-14px', position: 'relative', zIndex: 1 }}>
          <Sticker name="hamster" size={58} tilt={-6} />
        </View>
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
              <Button
                variant="outlined"
                onClick={() => Taro.showToast({ title: '短信通道 M1 接入', icon: 'none' })}
              >
                获取验证码
              </Button>
            </View>
          </FormRow>
        </Section>
        <Button
          block
          disabled={phone.length !== 11 || code.length !== 6}
          onClick={() => Taro.showToast({ title: '示例版式:登录接线在 M1', icon: 'none' })}
        >
          登录
        </Button>
        <View style={{ display: 'flex', justifyContent: 'center', gap: '20px', alignItems: 'flex-end' }}>
          <Sticker name="star" size={26} tilt={-10} />
          <Sticker name="paw" size={30} tilt={8} />
          <Sticker name="star" size={20} tilt={14} />
        </View>
      </SectionList>
    </View>
  )
}
