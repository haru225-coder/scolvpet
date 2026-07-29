import { Input, ScrollView, Textarea, View } from '@tarojs/components'
import { useLoad } from '@tarojs/taro'
import { useCallback, useState } from 'react'
import { Cell, Empty, FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'

type LitterData = { id: string; code?: string; state?: string; currentManagedCount?: number; initialAliveCount?: number; version?: number; damId?: string; sireId?: string; bornAt?: string }

function parseRows(value: string, fields: number) {
  return value.split(/[,\n]/).map((row) => row.trim()).filter(Boolean).map((row) => row.split(':').map((part) => part.trim())).filter((parts) => parts.length >= fields)
}

export default function LitterDetailPage() {
  const [litterId, setLitterId] = useState('')
  const [litter, setLitter] = useState<LitterData | null>(null)
  const [members, setMembers] = useState<any[]>([])
  const [countDelta, setCountDelta] = useState('')
  const [countReason, setCountReason] = useState('现场盘点修正')
  const [sexRows, setSexRows] = useState('')
  const [individualRows, setIndividualRows] = useState('')
  const [message, setMessage] = useState('正在读取窝次…')
  const [busy, setBusy] = useState(false)

  const load = useCallback(async (id: string) => {
    try {
      const [detail, memberResponse] = await Promise.all([
        defaultApi.getLitter({ litterId: id }),
        defaultApi.listLitterMembers({ litterId: id, limit: 100 })
      ])
      setLitter(((detail.data as any).litter || detail.data) as LitterData)
      setMembers(memberResponse.data || [])
      setMessage('数量、性别和个体化动作会由服务端做完整对账')
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '窝次读取失败')
    }
  }, [])

  useLoad((options) => {
    const id = String(options?.id || '')
    setLitterId(id)
    if (id) void load(id)
    else setMessage('缺少窝次 ID')
  })

  async function adjustCount() {
    if (!litter || !litterId || !Number(countDelta)) {
      setMessage('请输入非零数量变化')
      return
    }
    setBusy(true)
    try {
      await defaultApi.createLitterCountEvent({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(litter.version ?? 0),
        litterId,
        adjustLitterCountRequest: { eventType: Number(countDelta) > 0 ? 'discovered' : 'death', delta: Number(countDelta), occurredAt: new Date(), reason: countReason.trim() || '小程序端数量调整' } as any
      })
      setCountDelta('')
      setMessage('窝次数量事实已追加')
      await load(litterId)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '数量调整失败')
    } finally {
      setBusy(false)
    }
  }

  async function sexAndSeparate() {
    if (!litter || !litterId) return
    const rows = parseRows(sexRows, 4)
    if (!rows.length) {
      setMessage('请按 pupIdentityId:sex:destinationEnclosureId:requiresRecheck 填写分笼清单')
      return
    }
    setBusy(true)
    try {
      await defaultApi.sexAndSeparateLitter({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(litter.version ?? 0),
        litterId,
        sexAndSeparateRequest: {
          separatedAt: new Date(),
          timezone: 'Asia/Taipei',
          items: rows.map(([pupIdentityId, sex, destinationEnclosureId, requiresRecheck]) => ({ pupIdentityId, sex, destinationEnclosureId, requiresRecheck: requiresRecheck === 'true' }))
        } as any
      })
      setSexRows('')
      setMessage('性别分笼事实已提交')
      await load(litterId)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '性别分笼失败')
    } finally {
      setBusy(false)
    }
  }

  async function wean() {
    if (!litter || !litterId || !members.length) {
      setMessage('当前没有可断奶的窝仔成员')
      return
    }
    setBusy(true)
    try {
      await defaultApi.weanLitter({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(litter.version ?? 0),
        litterId,
        weanLitterRequest: { weanedAt: new Date(), timezone: 'Asia/Taipei', items: members.map((item) => ({ pupIdentityId: item.pupIdentityId || item.id, outcomeStatus: 'alive' })) } as any
      })
      setMessage('断奶事实已提交')
      await load(litterId)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '断奶失败')
    } finally {
      setBusy(false)
    }
  }

  async function individualize() {
    if (!litter || !litterId) return
    setBusy(true)
    try {
      const eligibility = await defaultApi.getLitterIndividualizationEligibility({ litterId })
      const eligible = eligibility.data
      const rows = parseRows(individualRows, 2)
      if (!eligible.canIndividualize) {
        setMessage((eligible.blockers || []).map((blocker: any) => blocker.message).join('；') || '当前窝次还不满足个体化条件')
        return
      }
      if (rows.length !== eligible.eligibleCount) {
        setMessage(`需要完整填写 ${eligible.eligibleCount} 条个体化信息，格式为 pupIdentityId:internalCode[:name]`)
        return
      }
      await defaultApi.individualizeLitter({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(litter.version ?? 0),
        litterId,
        individualizeLitterRequest: {
          individualizedAt: new Date(),
          timezone: 'Asia/Taipei',
          eligibleSetToken: eligible.eligibleSetToken,
          items: rows.map(([pupIdentityId, internalCode, name]) => ({ pupIdentityId, internalCode, name: name || null }))
        } as any
      })
      setIndividualRows('')
      setMessage('窝仔已批量个体化')
      await load(litterId)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '个体化失败')
    } finally {
      setBusy(false)
    }
  }

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: crayon.paper, backgroundImage: paperGrain }}>
      <NavBar title={litter?.code || '窝次详情'} back right={<Tag tone="accent">窝次</Tag>} />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        {!litter ? <Empty title="正在读取窝次" description={message} /> : (
          <SectionList>
            <Section header="窝次状态" footer={message}>
              <Cell title={litter.code || litterId} subtitle={`${litter.bornAt || '出生日期未记录'} · ${litter.sireId || '-'} × ${litter.damId || '-'}`} value={<Tag tone={litter.state === 'closed' ? 'success' : 'warning'}>{litter.state || 'active'}</Tag>} />
              <Cell title="数量" value={`${litter.currentManagedCount ?? '-'} / ${litter.initialAliveCount ?? '-'} 只`} />
              <Cell title="版本" value={String(litter.version ?? '-')} />
            </Section>
            <Section header="数量对账">
              <FormRow label="变化数量"><Input type="number" value={countDelta} placeholder="正数发现，负数死亡/转出" onInput={(event) => setCountDelta(event.detail.value)} /></FormRow>
              <FormRow label="原因" divider><Input value={countReason} onInput={(event) => setCountReason(event.detail.value)} /></FormRow>
              <CapabilityButton capability="write_litter" block disabled={busy} onClick={() => void adjustCount()}>追加数量事实</CapabilityButton>
            </Section>
            <Section header="性别分笼" footer="每行：pupIdentityId:male|female|unknown:目标笼舍 ID:true|false">
              <FormRow label="分笼清单"><Textarea value={sexRows} placeholder="每行一只，支持逗号或换行分隔" onInput={(event) => setSexRows(event.detail.value)} style={{ minHeight: '120px', width: '100%' }} /></FormRow>
              <CapabilityButton capability="write_litter" block disabled={busy} onClick={() => void sexAndSeparate()}>提交性别分笼</CapabilityButton>
            </Section>
            <Section header="断奶">
              <CapabilityButton capability="write_litter" block variant="outlined" disabled={busy || !members.length} onClick={() => void wean()}>按当前成员提交断奶</CapabilityButton>
            </Section>
            <Section header="批量个体化" footer="先由服务端计算 eligible set，再按 pupIdentityId:internalCode[:name] 填写完整清单">
              <FormRow label="个体化清单"><Textarea value={individualRows} placeholder="一行一个临时幼崽" onInput={(event) => setIndividualRows(event.detail.value)} style={{ minHeight: '120px', width: '100%' }} /></FormRow>
              <CapabilityButton capability="write_litter" block disabled={busy} onClick={() => void individualize()}>校验并批量个体化</CapabilityButton>
            </Section>
            <Section header="窝仔成员" footer={`共 ${members.length} 条`}>
              {members.length ? members.map((item) => <Cell key={item.id} title={item.temporaryCode || item.pupIdentityId || item.id} subtitle={`${item.sex || '性别未定'} · ${item.outcomeStatus || ''}`} value={<Tag>{item.currentEnclosureId || '未分笼'}</Tag>} />) : <Cell title="暂无成员" />}
            </Section>
            <View style={{ height: `${metrics.bottomSafePadding}px` }} />
          </SectionList>
        )}
      </ScrollView>
    </View>
  )
}
