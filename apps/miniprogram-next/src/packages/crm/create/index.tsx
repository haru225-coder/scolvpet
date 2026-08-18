import { Input, ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useRef, useState } from 'react'
import { FormRow, NavBar, Section, SectionList, metrics, palette } from '@scolvpet/mp-ui'

import { p1CrmApi } from '../../../api/client'
import { createIdempotencyIntent } from '../../../api/idempotency'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { formatUserError } from '../../../api/errors'
import { contactDetailUrl } from '../../../utils/created-routes'

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
      const created = await p1CrmApi.createCrmContact({ idempotencyKey: createIntent.getKey(), createCrmContactRequest: { name: name.trim(), phone: phone.trim() || null, wechat: wechat.trim() || null, status: 'lead' } })
      createIntent.complete()
      const url = contactDetailUrl((created as { data?: { id?: string } }).data?.id)
      Taro.showToast({ title: '客户已创建', icon: 'success' })
      setTimeout(() => {
        void Taro.redirectTo({ url })
      }, 350)
    } catch (cause) { setMessage(await formatUserError(cause, '创建客户失败')) } finally { setBusy(false) }
  }
  return <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}><NavBar title="新增客户" back /><ScrollView scrollY style={{ flex: 1 }}><SectionList><Section header="客户资料" footer={message}><FormRow label="姓名"><Input placeholder="客户姓名" value={name} onInput={(event) => setName(event.detail.value)} /></FormRow><FormRow label="手机号" divider><Input type="number" placeholder="可选" value={phone} onInput={(event) => setPhone(event.detail.value)} /></FormRow><FormRow label="微信" divider><Input placeholder="可选" value={wechat} onInput={(event) => setWechat(event.detail.value)} /></FormRow></Section><CapabilityButton capability="write_crm" block disabled={busy} onClick={() => void submit()}>{busy ? '保存中…' : '创建客户'}</CapabilityButton><View style={{ height: `${metrics.bottomSafePadding}px` }} /></SectionList></ScrollView></View>
}
