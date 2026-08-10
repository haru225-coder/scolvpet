import { Input, Picker, ScrollView, Textarea, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useCallback, useState } from 'react'
import { Cell, Empty, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { defaultApi } from '../../../api/default-api'
import { p1Api } from '../../../api/p1-api'
import { newIdempotencyKey } from '../../../api/runtime-config'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { litterScanSubtitle } from '../../../utils/scan-labels'
import { humanShortLabel } from '../../../utils/tab-routes'
import { formatUserError } from '../../../api/errors'
import { resolveLitterParentTrialUrl } from '../../../genetics/trial-deeplink'

type LitterData = {
  id: string
  code?: string
  state?: string
  currentManagedCount?: number
  initialAliveCount?: number
  version?: number
  damId?: string
  sireId?: string
  bornAt?: string
}

type EnclosureOpt = { id: string; label: string }

type MemberDraft = {
  pupIdentityId: string
  label: string
  sex: string
  enclosureId: string
  requiresRecheck: boolean
  internalCode: string
  name: string
}

const SEX_OPTIONS = [
  { value: 'unknown', label: '待定' },
  { value: 'male', label: '公' },
  { value: 'female', label: '母' }
]

function parseRows(value: string, fields: number) {
  return value
    .split(/[,\n]/)
    .map((row) => row.trim())
    .filter(Boolean)
    .map((row) => row.split(':').map((part) => part.trim()))
    .filter((parts) => parts.length >= fields)
}

function parseSex(raw: string) {
  const t = String(raw || '').trim().toLowerCase()
  if (t === '公' || t === 'male' || t === 'm') return 'male'
  if (t === '母' || t === 'female' || t === 'f') return 'female'
  return 'unknown'
}

function parseBool(raw: string) {
  const t = String(raw || '').trim().toLowerCase()
  return t === 'true' || t === '1' || t === '是' || t === '要' || t === '需复核'
}

function memberKey(item: any) {
  return String(item.pupIdentityId || item.id || '')
}

function memberLabel(item: any) {
  return String(item.temporaryCode || item.name || item.pupIdentityId || '幼崽')
}

function enclosureLabel(item: any) {
  const name = String(item?.name || item?.code || '').trim()
  return name || item?.id || '笼舍'
}

export default function LitterDetailPage() {
  const [litterId, setLitterId] = useState('')
  const [litter, setLitter] = useState<LitterData | null>(null)
  const [members, setMembers] = useState<any[]>([])
  const [enclosures, setEnclosures] = useState<EnclosureOpt[]>([])
  const [drafts, setDrafts] = useState<MemberDraft[]>([])
  const [countDelta, setCountDelta] = useState('')
  const [countReason, setCountReason] = useState('现场盘点修正')
  const [sexRows, setSexRows] = useState('')
  const [individualRows, setIndividualRows] = useState('')
  const [message, setMessage] = useState('正在读取窝次…')
  const [busy, setBusy] = useState(false)
  const [showAdvanced, setShowAdvanced] = useState(false)

  const syncDrafts = useCallback((memberList: any[], enclosureList: EnclosureOpt[]) => {
    const defaultEnc = enclosureList[0]?.id || ''
    setDrafts((prev) => {
      const byId = new Map(prev.map((item) => [item.pupIdentityId, item]))
      return memberList.map((item) => {
        const id = memberKey(item)
        const existing = byId.get(id)
        const sex = String(item.sex || existing?.sex || 'unknown')
        return {
          pupIdentityId: id,
          label: memberLabel(item),
          sex: sex === 'male' || sex === 'female' ? sex : 'unknown',
          enclosureId: existing?.enclosureId || item.currentEnclosureId || defaultEnc,
          requiresRecheck: existing?.requiresRecheck ?? false,
          internalCode: existing?.internalCode || '',
          name: existing?.name || String(item.name || '')
        }
      })
    })
  }, [])

  const load = useCallback(
    async (id: string) => {
      try {
        const [detail, memberResponse, enclosureResponse] = await Promise.all([
          defaultApi.getLitter({ litterId: id }),
          defaultApi.listLitterMembers({ litterId: id, limit: 100 }),
          defaultApi.listEnclosures({ limit: 100 }).catch(() => ({ data: [] as any[] }))
        ])
        const nextMembers = memberResponse.data || []
        const encOpts = ((enclosureResponse as any).data || []).map((item: any) => ({
          id: item.id,
          label: enclosureLabel(item)
        }))
        setLitter(((detail.data as any).litter || detail.data) as LitterData)
        setMembers(nextMembers)
        setEnclosures(encOpts)
        syncDrafts(nextMembers, encOpts)
        setMessage(
          encOpts.length
            ? '点选性别和笼舍后提交分笼；个体化可填正式编号'
            : '暂无笼舍列表，请先建笼舍再分笼'
        )
      } catch (cause) {
        setMessage(await formatUserError(cause, '窝次读取失败'))
      }
    },
    [syncDrafts]
  )

  useLoad((options) => {
    const id = String(options?.id || '')
    setLitterId(id)
    if (id) void load(id)
    else setMessage('缺少窝次')
  })

  /** 用窝次登记的公母带入试配（双侧；优先遗传档案基因型）。 */
  async function openParentTrial() {
    if (!litter) return
    setBusy(true)
    try {
      const resolved = await resolveLitterParentTrialUrl({
        litter,
        getHamster: (hamsterId) => defaultApi.getHamster({ hamsterId }),
        listProfiles: () => p1Api.listGeneticProfiles()
      })
      if ('error' in resolved) {
        setMessage(resolved.error)
        void Taro.showToast({ title: resolved.error, icon: 'none' })
        return
      }
      void Taro.navigateTo({ url: resolved.url })
    } catch (cause) {
      setMessage(await formatUserError(cause, '打开试配失败'))
    } finally {
      setBusy(false)
    }
  }

  function updateDraft(pupIdentityId: string, patch: Partial<MemberDraft>) {
    setDrafts((prev) =>
      prev.map((item) => (item.pupIdentityId === pupIdentityId ? { ...item, ...patch } : item))
    )
  }

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
        adjustLitterCountRequest: {
          eventType: Number(countDelta) > 0 ? 'discovered' : 'death',
          delta: Number(countDelta),
          occurredAt: new Date(),
          reason: countReason.trim() || '小程序端数量调整'
        } as any
      })
      setCountDelta('')
      setMessage('数量变更已记录')
      await load(litterId)
    } catch (cause) {
      setMessage(await formatUserError(cause, '数量调整失败'))
    } finally {
      setBusy(false)
    }
  }

  async function sexAndSeparateFromDrafts() {
    if (!litter || !litterId) return
    if (!enclosures.length) {
      setMessage('没有可选笼舍，请先建笼舍')
      return
    }
    const items = drafts
      .filter((item) => item.pupIdentityId && item.enclosureId)
      .map((item) => ({
        pupIdentityId: item.pupIdentityId,
        sex: item.sex || 'unknown',
        destinationEnclosureId: item.enclosureId,
        requiresRecheck: item.requiresRecheck
      }))
    if (!items.length) {
      setMessage('请为至少一只幼崽选好目标笼舍')
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
          items
        } as any
      })
      setMessage(`已提交 ${items.length} 只分笼`)
      await load(litterId)
    } catch (cause) {
      setMessage(await formatUserError(cause, '性别分笼失败'))
    } finally {
      setBusy(false)
    }
  }

  async function sexAndSeparateFromText() {
    if (!litter || !litterId) return
    const rows = parseRows(sexRows, 4)
    if (!rows.length) {
      setMessage('请按「临时编号:性别:目标笼舍编号:是否复核」填写')
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
          items: rows.map(([pupIdentityId, sex, destinationEnclosureId, requiresRecheck]) => ({
            pupIdentityId,
            sex: parseSex(sex),
            destinationEnclosureId,
            requiresRecheck: parseBool(requiresRecheck)
          }))
        } as any
      })
      setSexRows('')
      setMessage('性别分笼已提交')
      await load(litterId)
    } catch (cause) {
      setMessage(await formatUserError(cause, '性别分笼失败'))
    } finally {
      setBusy(false)
    }
  }

  async function wean() {
    if (!litter || !litterId || !members.length) {
      setMessage('当前没有可断奶的窝仔')
      return
    }
    setBusy(true)
    try {
      await defaultApi.weanLitter({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(litter.version ?? 0),
        litterId,
        weanLitterRequest: {
          weanedAt: new Date(),
          timezone: 'Asia/Taipei',
          items: members.map((item) => ({
            pupIdentityId: item.pupIdentityId || item.id,
            outcomeStatus: 'alive'
          }))
        } as any
      })
      setMessage('断奶已提交')
      await load(litterId)
    } catch (cause) {
      setMessage(await formatUserError(cause, '断奶失败'))
    } finally {
      setBusy(false)
    }
  }

  async function individualizeFromDrafts() {
    if (!litter || !litterId) return
    setBusy(true)
    try {
      const eligibility = await defaultApi.getLitterIndividualizationEligibility({ litterId })
      const eligible = eligibility.data
      if (!eligible.canIndividualize) {
        setMessage(
          (eligible.blockers || []).map((blocker: any) => blocker.message).join('；') ||
            '当前窝次还不满足个体化条件'
        )
        return
      }
      const filled = drafts.filter((item) => item.internalCode.trim())
      if (filled.length !== eligible.eligibleCount) {
        setMessage(`需要给 ${eligible.eligibleCount} 只都填好正式编号（当前 ${filled.length} 只）`)
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
          items: filled.map((item) => ({
            pupIdentityId: item.pupIdentityId,
            internalCode: item.internalCode.trim(),
            name: item.name.trim() || null
          }))
        } as any
      })
      setMessage('窝仔已批量个体化')
      await load(litterId)
    } catch (cause) {
      setMessage(await formatUserError(cause, '个体化失败'))
    } finally {
      setBusy(false)
    }
  }

  async function individualizeFromText() {
    if (!litter || !litterId) return
    setBusy(true)
    try {
      const eligibility = await defaultApi.getLitterIndividualizationEligibility({ litterId })
      const eligible = eligibility.data
      const rows = parseRows(individualRows, 2)
      if (!eligible.canIndividualize) {
        setMessage(
          (eligible.blockers || []).map((blocker: any) => blocker.message).join('；') ||
            '当前窝次还不满足个体化条件'
        )
        return
      }
      if (rows.length !== eligible.eligibleCount) {
        setMessage(`需要完整填写 ${eligible.eligibleCount} 条：临时编号:正式编号[:名字]`)
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
          items: rows.map(([pupIdentityId, internalCode, name]) => ({
            pupIdentityId,
            internalCode,
            name: name || null
          }))
        } as any
      })
      setIndividualRows('')
      setMessage('窝仔已批量个体化')
      await load(litterId)
    } catch (cause) {
      setMessage(await formatUserError(cause, '个体化失败'))
    } finally {
      setBusy(false)
    }
  }

  const bornLabel = litter
    ? litterScanSubtitle(litter, humanShortLabel(litter.state || 'active')) ||
      (litter.bornAt ? new Date(litter.bornAt).toLocaleDateString('zh-CN') : '出生日期未记录')
    : '出生日期未记录'
  const encLabels = enclosures.map((item) => item.label)

  return (
    <View
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: palette.systemBackground
      }}
    >
      <NavBar title={litter?.code || '窝次详情'} back />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        {!litter ? (
          <Empty title="正在读取窝次" description={message} />
        ) : (
          <SectionList>
            <Section header="窝次状态" footer={message}>
              <Cell
                title={litter.code || '窝次'}
                subtitle={bornLabel}
                value={
                  <Tag tone={litter.state === 'closed' ? 'success' : 'warning'}>
                    {humanShortLabel(litter.state || 'active')}
                  </Tag>
                }
              />
              <Cell
                title="当前数量"
                value={`${litter.currentManagedCount ?? '-'} / ${litter.initialAliveCount ?? '-'} 只`}
              />
            </Section>

            <Section header="窝仔成员" footer={`共 ${members.length} 只`}>
              {members.length ? (
                members.map((item) => (
                  <Cell
                    key={item.id}
                    title={memberLabel(item)}
                    subtitle={`${humanShortLabel(item.sex || 'unknown')}${
                      item.outcomeStatus ? ` · ${humanShortLabel(item.outcomeStatus)}` : ''
                    }`}
                    value={
                      <Tag tone={item.currentEnclosureId ? 'success' : 'warning'}>
                        {item.currentEnclosureId ? '已分笼' : '未分笼'}
                      </Tag>
                    }
                  />
                ))
              ) : (
                <Cell title="暂无成员" />
              )}
            </Section>

            <Section header="常用操作">
              <Cell
                title="用这对公母试配"
                subtitle={
                  String((litter as any).sireId || (litter as any).sire_id || '') ||
                  String((litter as any).damId || (litter as any).dam_id || '')
                    ? '带入已登记父母的样子/基因型'
                    : '本窝未登记公母'
                }
                chevron
                onClick={() => {
                  if (!busy) void openParentTrial()
                }}
              />
              <FormRow label="数量变化">
                <Input
                  type="number"
                  value={countDelta}
                  placeholder="正数发现，负数死亡/转出"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  onInput={(event) => setCountDelta(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              <FormRow label="原因" divider>
                <Input
                  value={countReason}
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  onInput={(event) => setCountReason(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              <CapabilityButton
                capability="write_litter"
                block
                disabled={busy}
                onClick={() => void adjustCount()}
              >
                记录数量变化
              </CapabilityButton>
              <CapabilityButton
                capability="write_litter"
                block
                variant="outlined"
                disabled={busy || !members.length}
                onClick={() => void wean()}
              >
                按当前成员提交断奶
              </CapabilityButton>
            </Section>

            <Section header="分笼（点选）" footer="为每只幼崽选性别和目标笼舍">
              {!drafts.length ? (
                <Cell title="没有可分笼的幼崽" />
              ) : (
                drafts.map((draft) => {
                  const sexIndex = Math.max(
                    0,
                    SEX_OPTIONS.findIndex((o) => o.value === draft.sex)
                  )
                  const encIndex = Math.max(
                    0,
                    enclosures.findIndex((item) => item.id === draft.enclosureId)
                  )
                  return (
                    <View key={draft.pupIdentityId}>
                      <Cell title={draft.label} subtitle="性别 · 笼舍 · 是否复核" />
                      <FormRow label="性别">
                        <Picker
                          mode="selector"
                          range={SEX_OPTIONS.map((o) => o.label)}
                          value={sexIndex}
                          onChange={(event) =>
                            updateDraft(draft.pupIdentityId, {
                              sex: SEX_OPTIONS[Number(event.detail.value)]?.value || 'unknown'
                            })
                          }
                        >
                          <Cell title={SEX_OPTIONS[sexIndex]?.label || '待定'} value={<Tag>选择</Tag>} />
                        </Picker>
                      </FormRow>
                      {enclosures.length ? (
                        <FormRow label="目标笼舍" divider>
                          <Picker
                            mode="selector"
                            range={encLabels}
                            value={encIndex}
                            onChange={(event) =>
                              updateDraft(draft.pupIdentityId, {
                                enclosureId: enclosures[Number(event.detail.value)]?.id || ''
                              })
                            }
                          >
                            <Cell
                              title={enclosures[encIndex]?.label || '选择笼舍'}
                              value={<Tag>选择</Tag>}
                            />
                          </Picker>
                        </FormRow>
                      ) : (
                        <FormRow label="目标笼舍" divider>
                          <Cell title="还没有笼舍" subtitle="请先在系统中建笼舍" />
                        </FormRow>
                      )}
                      <FormRow label="需要复核" divider>
                        <Cell
                          title={draft.requiresRecheck ? '是，稍后复核' : '否'}
                          value={
                            <Tag tone={draft.requiresRecheck ? 'warning' : 'success'}>
                              {draft.requiresRecheck ? '需复核' : '不用'}
                            </Tag>
                          }
                          onClick={() =>
                            updateDraft(draft.pupIdentityId, {
                              requiresRecheck: !draft.requiresRecheck
                            })
                          }
                        />
                      </FormRow>
                    </View>
                  )
                })
              )}
              <CapabilityButton
                capability="write_litter"
                block
                disabled={busy || !drafts.length || !enclosures.length}
                onClick={() => void sexAndSeparateFromDrafts()}
              >
                提交性别分笼
              </CapabilityButton>
            </Section>

            <Section header="个体化（点选）" footer="给每只填正式编号；名字可选">
              {!drafts.length ? (
                <Cell title="没有可个体化的幼崽" />
              ) : (
                drafts.map((draft) => (
                  <View key={`ind-${draft.pupIdentityId}`}>
                    <Cell title={draft.label} />
                    <FormRow label="正式编号">
                      <Input
                        value={draft.internalCode}
                        placeholder="例如 SY-101"
                        placeholderStyle="color: rgba(255,255,255,0.35)"
                        onInput={(event) =>
                          updateDraft(draft.pupIdentityId, { internalCode: event.detail.value })
                        }
                        style={{ color: '#FFFFFF' }}
                      />
                    </FormRow>
                    <FormRow label="名字" divider>
                      <Input
                        value={draft.name}
                        placeholder="可选"
                        placeholderStyle="color: rgba(255,255,255,0.35)"
                        onInput={(event) =>
                          updateDraft(draft.pupIdentityId, { name: event.detail.value })
                        }
                        style={{ color: '#FFFFFF' }}
                      />
                    </FormRow>
                  </View>
                ))
              )}
              <CapabilityButton
                capability="write_litter"
                block
                disabled={busy || !drafts.length}
                onClick={() => void individualizeFromDrafts()}
              >
                校验并批量个体化
              </CapabilityButton>
            </Section>

            <Section header="批量粘贴（一般不用）" footer="大批量时可用文本清单">
              <Cell
                title={showAdvanced ? '收起文本清单' : '展开文本清单'}
                subtitle={showAdvanced ? '点此收起' : '按行粘贴时再用'}
                value={<Tag tone={showAdvanced ? 'accent' : 'warning'}>{showAdvanced ? '已展开' : '折叠'}</Tag>}
                onClick={() => setShowAdvanced((v) => !v)}
              />
              {showAdvanced ? (
                <>
                  <FormRow label="分笼清单" divider>
                    <Textarea
                      value={sexRows}
                      placeholder={'临时编号:公:笼舍编号:否\nPUP-01:母:A-02:是'}
                      placeholderStyle="color: rgba(255,255,255,0.35)"
                      onInput={(event) => setSexRows(event.detail.value)}
                      style={{ minHeight: '100px', width: '100%', color: '#FFFFFF' }}
                    />
                  </FormRow>
                  <CapabilityButton
                    capability="write_litter"
                    block
                    variant="outlined"
                    disabled={busy}
                    onClick={() => void sexAndSeparateFromText()}
                  >
                    按文本提交分笼
                  </CapabilityButton>
                  <FormRow label="个体化清单" divider>
                    <Textarea
                      value={individualRows}
                      placeholder={'临时编号:正式编号:名字\nPUP-01:SY-101:小灰'}
                      placeholderStyle="color: rgba(255,255,255,0.35)"
                      onInput={(event) => setIndividualRows(event.detail.value)}
                      style={{ minHeight: '100px', width: '100%', color: '#FFFFFF' }}
                    />
                  </FormRow>
                  <CapabilityButton
                    capability="write_litter"
                    block
                    variant="outlined"
                    disabled={busy}
                    onClick={() => void individualizeFromText()}
                  >
                    按文本提交个体化
                  </CapabilityButton>
                </>
              ) : null}
            </Section>
            <View style={{ height: `${metrics.bottomSafePadding}px` }} />
          </SectionList>
        )}
      </ScrollView>
    </View>
  )
}
