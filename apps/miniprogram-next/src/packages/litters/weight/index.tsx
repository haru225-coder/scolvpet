import { Input, ScrollView, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useCallback, useMemo, useState } from 'react'
import { Cell, Empty, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { defaultApi } from '../../../api/default-api'
import { formatUserError } from '../../../api/errors'
import { newIdempotencyKey } from '../../../api/runtime-config'
import { requireBreederSession } from '../../../auth/dev-session'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { shortDate } from '../../../utils/scan-labels'

type LitterSummary = {
  id: string
  code?: string
  name?: string
  bornAt?: string
  currentManagedCount?: number
}

type LitterMember = {
  id?: string
  pupIdentityId?: string | null
  hamsterId?: string | null
  temporaryCode?: string
  name?: string
}

function memberKey(item: LitterMember) {
  return String(item.pupIdentityId || item.hamsterId || item.id || '')
}

function memberLabel(item: LitterMember) {
  return String(item.temporaryCode || item.name || item.pupIdentityId || item.hamsterId || '幼崽')
}

export default function LitterWeightPage() {
  const [litterId, setLitterId] = useState('')
  const [litter, setLitter] = useState<LitterSummary | null>(null)
  const [members, setMembers] = useState<LitterMember[]>([])
  const [drafts, setDrafts] = useState<Record<string, string>>({})
  const [message, setMessage] = useState('')
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [scrollTop, setScrollTop] = useState(0)

  const filledCount = useMemo(
    () => members.filter((item) => Number(drafts[memberKey(item)]) > 0).length,
    [members, drafts]
  )

  const loadLitter = useCallback(async (id: string) => {
    const session = await requireBreederSession()
    if (!session) {
      setMessage('请先登录经营账号')
      setLoading(false)
      return
    }
    setLoading(true)
    try {
      const [detail, memberResponse] = await Promise.all([
        defaultApi.getLitter({ litterId: id }),
        defaultApi.listLitterMembers({ litterId: id, limit: 100 })
      ])
      const payload = detail.data as unknown as LitterSummary & { litter?: LitterSummary }
      setLitter({ ...(payload?.litter || payload), id })
      setMembers((memberResponse.data || []) as unknown as LitterMember[])
      setMessage('')
    } catch (cause) {
      setMessage(await formatUserError(cause, '窝次读取失败'))
    } finally {
      setLoading(false)
    }
  }, [])

  useLoad((options) => {
    const id = String(options?.litterId || options?.id || '')
    setLitterId(id)
    if (id) void loadLitter(id)
    else {
      setMessage('缺少窝次 ID')
      setLoading(false)
    }
  })

  async function submit() {
    const rows = members.filter((item) => Number(drafts[memberKey(item)]) > 0)
    if (!rows.length) {
      setMessage('请至少填一只的克数')
      return
    }
    setSubmitting(true)
    try {
      const settled = await Promise.allSettled(
        rows.map((item) => {
          const pupIdentityId = item.pupIdentityId ? String(item.pupIdentityId) : null
          return defaultApi.createWeightRecord({
            idempotencyKey: newIdempotencyKey(),
            weightRecordCreateRequest: {
              litterId,
              pupIdentityId,
              hamsterId: pupIdentityId ? null : item.hamsterId ? String(item.hamsterId) : null,
              measurementKind: 'individual',
              subjectCount: null,
              weightG: Number(drafts[memberKey(item)]),
              recordedAt: new Date(),
              source: 'manual',
              notes: null
            }
          })
        })
      )
      const ok = settled.filter((item) => item.status === 'fulfilled').length
      setMessage(`已记录 ${ok}/${rows.length} 只` + (ok < rows.length ? '，失败看列表' : ''))
      if (ok === rows.length) setTimeout(() => Taro.navigateBack(), 600)
    } catch (cause) {
      setMessage(await formatUserError(cause, '批量称重失败'))
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <NavBar title="批量称重" back scrollTop={scrollTop} />
      <ScrollView
        scrollY
        type="list"
        bounces
        enhanced
        showScrollbar={false}
        style={{ flex: 1 }}
        onScroll={(event) => setScrollTop(event.detail?.scrollTop || 0)}
      >
        {loading ? <Empty title="正在读取窝次" /> : null}
        {!loading && !litterId ? <Empty title="缺少窝次 ID" description="从窝次看板或详情进入" /> : null}
        {!loading && litterId ? (
          <SectionList>
            <Section header="窝次" footer={message || undefined}>
              <Cell
                title={litter?.name || litter?.code || '窝次'}
                subtitle={[shortDate(litter?.bornAt), litter?.currentManagedCount != null ? `在管 ${litter.currentManagedCount} 只` : '']
                  .filter(Boolean)
                  .join(' · ')}
              />
            </Section>
            <Section header="逐只称重" footer="填了克数才提交">
              {members.length ? (
                members.map((item) => {
                  const key = memberKey(item)
                  const filled = Number(drafts[key]) > 0
                  return (
                    <Cell
                      key={key}
                      title={memberLabel(item)}
                      value={
                        <View style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                          {filled ? <Tag tone="success">已称</Tag> : null}
                          <Input
                            type="digit"
                            placeholder="克"
                            placeholderStyle={`color: ${palette.tertiaryLabel}`}
                            value={drafts[key] || ''}
                            onInput={(event) => setDrafts((prev) => ({ ...prev, [key]: event.detail.value }))}
                            style={{ color: '#FFFFFF', width: '84px', textAlign: 'right' }}
                          />
                        </View>
                      }
                    />
                  )
                })
              ) : (
                <Empty title="没有窝仔成员" />
              )}
              <CapabilityButton capability="write_weight" block disabled={submitting} onClick={() => void submit()}>
                {submitting ? '提交中…' : `提交 ${filledCount} 只`}
              </CapabilityButton>
            </Section>
          </SectionList>
        ) : null}
        <View style={{ height: `${metrics.bottomSafePadding}px` }} />
      </ScrollView>
    </View>
  )
}
