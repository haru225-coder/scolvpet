import { Input, Picker, ScrollView, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useState } from 'react'
import { Button, Cell, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'

type Option = { id: string; label: string }

function labelOf(item: any) {
  const name = String(item?.name || item?.displayName || '').trim()
  const code = String(item?.internalCode || item?.internal_code || item?.code || '').trim()
  if (name && code) return `${name} · ${code}`
  return name || code || item?.id || '未命名'
}

export default function CreateBreedingPlanPage() {
  const [males, setMales] = useState<Option[]>([])
  const [females, setFemales] = useState<Option[]>([])
  const [rules, setRules] = useState<Option[]>([])
  const [sireId, setSireId] = useState('')
  const [damId, setDamId] = useState('')
  const [ruleVersionId, setRuleVersionId] = useState('')
  const [name, setName] = useState('')
  const [message, setMessage] = useState('正在读取个体与规则…')
  const [busy, setBusy] = useState(false)
  const [loadFailed, setLoadFailed] = useState(false)

  function reload() {
    setLoadFailed(false)
    setMessage('正在读取个体与规则…')
    void Promise.all([
      defaultApi.listHamsters({ limit: 100 }),
      defaultApi.listSpeciesRuleVersions({ limit: 20 })
    ])
      .then(([hamsters, ruleRes]) => {
        const list = hamsters.data || []
        const maleOpts = list
          .filter((item: any) => item.sex === 'male')
          .map((item: any) => ({ id: item.id, label: labelOf(item) }))
        const femaleOpts = list
          .filter((item: any) => item.sex === 'female')
          .map((item: any) => ({ id: item.id, label: labelOf(item) }))
        const ruleOpts = (ruleRes.data || []).map((item: any) => ({
          id: item.id,
          label: item.name || item.version || item.id
        }))
        setMales(maleOpts)
        setFemales(femaleOpts)
        setRules(ruleOpts)
        if (!sireId && maleOpts[0]) setSireId(maleOpts[0].id)
        if (!damId && femaleOpts[0]) setDamId(femaleOpts[0].id)
        if (!ruleVersionId && ruleOpts[0]) setRuleVersionId(ruleOpts[0].id)
        if (!maleOpts.length || !femaleOpts.length) {
          setMessage('还缺公或母个体。请先去档案里建几只，再回来配对。')
        } else if (!ruleOpts.length) {
          setMessage('还没有物种规则版本，请联系管理员配置后再建计划。')
        } else {
          setMessage(`已载入公 ${maleOpts.length} · 母 ${femaleOpts.length} · 规则 ${ruleOpts.length}`)
        }
      })
      .catch((cause) => {
        setLoadFailed(true)
        setMessage(cause instanceof Error ? cause.message : '读取失败，请重试')
      })
  }

  useLoad(() => {
    reload()
  })

  const sireIndex = Math.max(0, males.findIndex((item) => item.id === sireId))
  const damIndex = Math.max(0, females.findIndex((item) => item.id === damId))
  const ruleIndex = Math.max(0, rules.findIndex((item) => item.id === ruleVersionId))

  const canSubmit = Boolean(sireId && damId && ruleVersionId && males.length && females.length && rules.length)

  async function submit() {
    if (!canSubmit) {
      setMessage('请先选好公、母和规则版本')
      return
    }
    setBusy(true)
    try {
      await defaultApi.createBreedingPlan({
        idempotencyKey: newIdempotencyKey(),
        breedingPlanCreateRequest: {
          name: name.trim() || null,
          sireId,
          damId,
          ruleVersionId
        }
      })
      Taro.showToast({ title: '繁育计划已创建', icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '创建繁育计划失败')
    } finally {
      setBusy(false)
    }
  }

  return (
    <View style={{ height: '100vh', backgroundColor: palette.systemBackground }}>
      <NavBar title="新建繁育计划" back />
      <ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}>
        <SectionList>
          <Section header="配对" footer={message}>
            {males.length ? (
              <FormRow label="公（爸爸）">
                <Picker
                  mode="selector"
                  range={males.map((item) => item.label)}
                  value={sireIndex}
                  onChange={(event) => setSireId(males[Number(event.detail.value)]?.id || '')}
                >
                  <Cell title={males[sireIndex]?.label || '选择公'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
            ) : (
              <FormRow label="公（爸爸）">
                <Cell
                  title={loadFailed ? '读取失败' : '还没有公个体'}
                  subtitle={loadFailed ? '点下方重试' : '去档案新增一只公'}
                  chevron={!loadFailed}
                  onClick={() =>
                    loadFailed
                      ? reload()
                      : Taro.navigateTo({ url: '/packages/animals/create/index' })
                  }
                />
              </FormRow>
            )}
            {females.length ? (
              <FormRow label="母（妈妈）" divider>
                <Picker
                  mode="selector"
                  range={females.map((item) => item.label)}
                  value={damIndex}
                  onChange={(event) => setDamId(females[Number(event.detail.value)]?.id || '')}
                >
                  <Cell title={females[damIndex]?.label || '选择母'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
            ) : (
              <FormRow label="母（妈妈）" divider>
                <Cell
                  title={loadFailed ? '读取失败' : '还没有母个体'}
                  subtitle={loadFailed ? '点下方重试' : '去档案新增一只母'}
                  chevron={!loadFailed}
                  onClick={() =>
                    loadFailed
                      ? reload()
                      : Taro.navigateTo({ url: '/packages/animals/create/index' })
                  }
                />
              </FormRow>
            )}
            {rules.length ? (
              <FormRow label="规则版本" divider>
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
              <FormRow label="规则版本" divider>
                <Cell title={loadFailed ? '读取失败' : '暂无规则版本'} subtitle="请重试或联系管理员" />
              </FormRow>
            )}
            <FormRow label="计划名称" divider>
              <Input
                value={name}
                placeholder="可选，例如：春窝一号"
                placeholderStyle="color: rgba(255,255,255,0.35)"
                onInput={(event) => setName(event.detail.value)}
                style={{ color: '#FFFFFF' }}
              />
            </FormRow>
          </Section>
          <CapabilityButton capability="write_breeding" block disabled={busy || !canSubmit} onClick={() => void submit()}>
            {busy ? '创建中…' : '创建计划'}
          </CapabilityButton>
          {loadFailed || !males.length || !females.length ? (
            <View style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {loadFailed ? (
                <Button block variant="outlined" disabled={busy} onClick={reload}>
                  重新读取
                </Button>
              ) : null}
              <Button
                block
                variant="outlined"
                disabled={busy}
                onClick={() => Taro.navigateTo({ url: '/packages/animals/create/index' })}
              >
                去新增个体
              </Button>
            </View>
          ) : null}
          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>
      </ScrollView>
    </View>
  )
}
