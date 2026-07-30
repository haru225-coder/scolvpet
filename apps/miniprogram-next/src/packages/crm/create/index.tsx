import { Input, ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useRef, useState } from 'react'
import { FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { p1CrmApi } from '../../../api/client'
import { createIdempotencyIntent } from '../../../api/idempotency'
import { CapabilityButton } from '../../../components/CapabilityButton'

export default function CreateContactPage() {
  const [name, setName] = useState('')
  const [phone, setPhone] = useState('')
  const [wechat, setWechat] = useState('')
  const [message, setMessage] = useState('')
  const [busy, setBusy] = useState(false)
  const createIntent = useRef(createIdempotencyIntent()).current
  async function submit() {
    if (!name.trim()) { setMessage('请填写客户姓名'); return }
    setBusy(true)
    try {
      await p1CrmApi.createCrmContact({ idempotencyKey: createIntent.getKey(), createCrmContactRequest: { name: name.trim(), phone: phone.trim() || null, wechat: wechat.trim() || null, status: 'lead' } })
      createIntent.complete()
      Taro.showToast({ title: '客户已创建', icon: 'success' }); setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '创建客户失败') } finally { setBusy(false) }
  }
  return <View style={{ height: '100vh', backgroundColor: crayon.paper, backgroundImage: paperGrain }}><NavBar title="新增客户" back right={<Tag tone="accent">CRM</Tag>} /><ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}><SectionList><Section header="客户资料" footer={message}><FormRow label="姓名"><Input placeholder="客户姓名" value={name} onInput={(event) => setName(event.detail.value)} /></FormRow><FormRow label="手机号" divider><Input type="number" placeholder="可选" value={phone} onInput={(event) => setPhone(event.detail.value)} /></FormRow><FormRow label="微信" divider><Input placeholder="可选" value={wechat} onInput={(event) => setWechat(event.detail.value)} /></FormRow></Section><CapabilityButton capability="write_crm" block disabled={busy} onClick={() => void submit()}>{busy ? '保存中…' : '创建客户'}</CapabilityButton><View style={{ height: `${metrics.bottomSafePadding}px` }} /></SectionList></ScrollView></View>
}
