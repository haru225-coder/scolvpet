import { Picker, ScrollView, Textarea, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useState } from 'react'
import { Cell, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import type { ApiEnvelope } from '../../../api/types'

type RuleOption = { id: string; label: string }

/** 接受 公/母/待定 或 male/female/unknown */
function parseSex(raw: string) {
  const t = String(raw || '').trim().toLowerCase()
  if (t === '公' || t === 'male' || t === 'm') return 'male'
  if (t === '母' || t === 'female' || t === 'f') return 'female'
  if (t === '待定' || t === '未知' || t === 'unknown' || t === 'u' || !t) return 'unknown'
  return 'unknown'
}

export default function BatchCreateAnimalsPage() {
  const [rules, setRules] = useState<RuleOption[]>([])
  const [ruleVersionId, setRuleVersionId] = useState('')
  const [rows, setRows] = useState('')
  const [message, setMessage] = useState('正在读取规则…')
  const [busy, setBusy] = useState(false)

  useLoad(() => {
    void defaultApi
      .listSpeciesRuleVersions({ limit: 20 })
      .then((response: ApiEnvelope) => {
        const opts = (response.data || []).map((item: any) => ({
          id: item.id,
          label: item.name || `规则 v${item.version ?? '?'}`
        }))
        setRules(opts)
        setRuleVersionId(opts[0]?.id || '')
        setMessage(
          opts.length
            ? '每行：编号,名字,性别,样子。性别写 公 / 母 / 待定'
            : '还没有物种规则，请联系管理员配置'
        )
      })
      .catch((cause: unknown) => setMessage(cause instanceof Error ? cause.message : '规则加载失败'))
  })

  async function submit() {
    const items = rows
      .split('\n')
      .map((row) => row.split(',').map((value) => value.trim()))
      .filter((parts) => parts[0])
    if (!ruleVersionId || !items.length) {
      setMessage(rules.length ? '请选规则，并至少写一行个体' : '没有可选规则')
      return
    }
    setBusy(true)
    try {
      await defaultApi.batchCreateHamsters({
        idempotencyKey: newIdempotencyKey(),
        hamsterBatchCreateRequest: {
          atomic: true,
          items: items.map(([internalCode, name, sex, varietyCode], index) => ({
            clientItemId: `${Date.now()}-${index}`,
            hamster: {
              internalCode,
              name: name || null,
              speciesRuleVersionId: ruleVersionId,
              sex: parseSex(sex),
              varietyCode: varietyCode || null,
              sourceType: 'introduced'
            }
          }))
        } as any
      })
      Taro.showToast({ title: `已创建 ${items.length} 只`, icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '批量创建失败')
    } finally {
      setBusy(false)
    }
  }

  const ruleIndex = Math.max(0, rules.findIndex((item) => item.id === ruleVersionId))

  return (
    <View style={{ height: '100vh', backgroundColor: palette.systemBackground }}>
      <NavBar title="批量新增个体" back />
      <ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}>
        <SectionList>
          <Section header="批次设置" footer={message}>
            {rules.length ? (
              <FormRow label="规则版本">
                <Picker
                  mode="selector"
                  range={rules.map((item) => item.label)}
                  value={ruleIndex}
                  onChange={(event) => setRuleVersionId(rules[Number(event.detail.value)]?.id || '')}
                >
                  <Cell title={rules[ruleIndex]?.label || '选择规则'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
            ) : (
              <FormRow label="规则版本">
                <Cell title="还没有规则" subtitle="请管理员先配置物种规则" />
              </FormRow>
            )}
            <FormRow label="个体清单" divider>
              <Textarea
                value={rows}
                maxlength={10000}
                placeholder={'编号,名字,性别,样子\nSY-001,布丁,母,蜜波利\nSY-002,小灰,公,黑蜜波利'}
                placeholderStyle="color: rgba(255,255,255,0.35)"
                onInput={(event) => setRows(event.detail.value)}
                style={{ minHeight: '180px', width: '100%', color: '#FFFFFF' }}
              />
            </FormRow>
          </Section>
          <CapabilityButton
            capability="write_hamster"
            block
            disabled={busy || !rules.length}
            onClick={() => void submit()}
          >
            {busy ? '批量创建中…' : '批量创建'}
          </CapabilityButton>
          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>
      </ScrollView>
    </View>
  )
}
