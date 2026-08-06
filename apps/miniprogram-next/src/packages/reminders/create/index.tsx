import { Input, Picker, ScrollView, Textarea, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useState } from 'react'
import { Button, Cell, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { formatUserError } from '../../../api/errors'

type Option = { id: string; label: string }

const TARGET_OPTIONS = [
  { value: 'hamster', label: '一只仓鼠' },
  { value: 'litter', label: '一窝' },
  { value: 'custom', label: '其他（写在备注里）' }
]

const TASK_OPTIONS = [
  { value: 'custom', label: '普通提醒' },
  { value: 'medication', label: '用药' },
  { value: 'enclosure_cleaning', label: '笼舍清洁' },
  { value: 'pup_weight_check', label: '幼崽称重' },
  { value: 'health_check', label: '健康观察' }
]

const PRIORITY_OPTIONS = [
  { value: 'low', label: '低' },
  { value: 'normal', label: '普通' },
  { value: 'high', label: '高' },
  { value: 'urgent', label: '紧急' },
  { value: 'critical', label: '关键' }
]

function hamsterLabel(item: any) {
  const name = String(item?.name || '').trim()
  const code = String(item?.internalCode || item?.internal_code || '').trim()
  if (name && code) return `${name} · ${code}`
  return name || code || item?.id
}

export default function CreateReminderPage() {
  const [title, setTitle] = useState('')
  const [targetType, setTargetType] = useState('hamster')
  const [targetId, setTargetId] = useState('')
  const [taskType, setTaskType] = useState('custom')
  const [priority, setPriority] = useState('normal')
  const [notes, setNotes] = useState('')
  const [scheduledDate, setScheduledDate] = useState(new Date().toISOString().slice(0, 10))
  const [message, setMessage] = useState('创建后会出现在「今日」照护队列里')
  const [busy, setBusy] = useState(false)
  const [hamsters, setHamsters] = useState<Option[]>([])
  const [litters, setLitters] = useState<Option[]>([])
  const [loadFailed, setLoadFailed] = useState(false)

  function reloadTargets() {
    setLoadFailed(false)
    void Promise.all([
      defaultApi.listHamsters({ limit: 100 }),
      defaultApi.listLitters({ limit: 50 }).catch(() => ({ data: [] as any[] }))
    ])
      .then(([h, l]) => {
        const hamsterOpts = (h.data || []).map((item: any) => ({ id: item.id, label: hamsterLabel(item) }))
        const litterOpts = ((l as any).data || []).map((item: any) => ({
          id: item.id,
          label: item.name || item.code || item.id
        }))
        setHamsters(hamsterOpts)
        setLitters(litterOpts)
        if (targetType === 'hamster' && !targetId && hamsterOpts[0]) setTargetId(hamsterOpts[0].id)
        if (targetType === 'litter' && !targetId && litterOpts[0]) setTargetId(litterOpts[0].id)
        if (!hamsterOpts.length && !litterOpts.length) {
          setMessage('还没有可提醒的个体或窝次，请先建档')
        }
      })
      .catch(async (cause) => {
        setLoadFailed(true)
        setMessage(await formatUserError(cause, '读取对象列表失败，请重试'))
      })
  }

  useLoad((options) => {
    if (options?.title) setTitle(String(options.title))
    if (options?.targetType) setTargetType(String(options.targetType))
    if (options?.targetId) setTargetId(String(options.targetId))
    if (options?.taskType) setTaskType(String(options.taskType))
    if (options?.priority) setPriority(String(options.priority))
    if (options?.notes) setNotes(String(options.notes))
    if (options?.scheduledAt) setScheduledDate(String(options.scheduledAt).slice(0, 10))
    if (options?.targetId || options?.title) setMessage('已带入助手建议，核对后点创建即可')
    reloadTargets()
  })

  const targetOptions = targetType === 'litter' ? litters : hamsters
  const targetIndex = Math.max(0, targetOptions.findIndex((item) => item.id === targetId))
  const typeIndex = Math.max(0, TARGET_OPTIONS.findIndex((o) => o.value === targetType))
  const taskIndex = Math.max(0, TASK_OPTIONS.findIndex((o) => o.value === taskType))
  const priorityIndex = Math.max(0, PRIORITY_OPTIONS.findIndex((o) => o.value === priority))

  function onTargetTypeChange(next: string) {
    setTargetType(next)
    const list = next === 'litter' ? litters : hamsters
    setTargetId(list[0]?.id || '')
  }

  async function submit() {
    if (!title.trim()) {
      setMessage('请填写标题')
      return
    }
    if (targetType !== 'custom' && !targetId) {
      setMessage('请选择要提醒的对象，或改为「其他」')
      return
    }
    setBusy(true)
    try {
      const scheduledAt = new Date(`${scheduledDate || new Date().toISOString().slice(0, 10)}T09:00:00`)
      await defaultApi.createTask({
        idempotencyKey: newIdempotencyKey(),
        careTaskCreateRequest: {
          taskType: taskType.trim(),
          targetType: targetType.trim(),
          targetId: targetType === 'custom' ? 'custom' : targetId.trim(),
          title: title.trim(),
          scheduledAt,
          priority,
          notes: notes.trim() || null
        } as any
      })
      Taro.showToast({ title: '提醒已创建', icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) {
      setMessage(await formatUserError(cause, '提醒创建失败'))
    } finally {
      setBusy(false)
    }
  }

  return (
    <View style={{ height: '100vh', backgroundColor: palette.systemBackground }}>
      <NavBar title="新增提醒" back />
      <ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}>
        <SectionList>
          <Section header="照护任务" footer={message}>
            <FormRow label="标题">
              <Input
                value={title}
                placeholder="例如：给布丁做健康观察"
                placeholderStyle="color: rgba(255,255,255,0.35)"
                onInput={(event) => setTitle(event.detail.value)}
                style={{ color: '#FFFFFF' }}
              />
            </FormRow>
            <FormRow label="对象类型" divider>
              <Picker
                mode="selector"
                range={TARGET_OPTIONS.map((o) => o.label)}
                value={typeIndex}
                onChange={(event) =>
                  onTargetTypeChange(TARGET_OPTIONS[Number(event.detail.value)]?.value || 'hamster')
                }
              >
                <Cell title={TARGET_OPTIONS[typeIndex]?.label || '选择'} value={<Tag>选择</Tag>} />
              </Picker>
            </FormRow>
            {targetType === 'custom' ? (
              <FormRow label="说明" divider>
                <Input
                  value={notes}
                  placeholder="写清楚提醒谁、提醒什么"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  onInput={(event) => setNotes(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
            ) : targetOptions.length ? (
              <FormRow label="选择对象" divider>
                <Picker
                  mode="selector"
                  range={targetOptions.map((item) => item.label)}
                  value={targetIndex}
                  onChange={(event) => setTargetId(targetOptions[Number(event.detail.value)]?.id || '')}
                >
                  <Cell title={targetOptions[targetIndex]?.label || '选择'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
            ) : (
              <FormRow label="选择对象" divider>
                <Cell
                  title={loadFailed ? '读取失败' : '还没有可选对象'}
                  subtitle={loadFailed ? '点下方重试' : '先去建个体或窝次'}
                  chevron
                  onClick={() =>
                    loadFailed
                      ? reloadTargets()
                      : Taro.navigateTo({
                          url:
                            targetType === 'litter'
                              ? '/packages/litters/index/index'
                              : '/packages/animals/create/index'
                        })
                  }
                />
              </FormRow>
            )}
            <FormRow label="任务类型" divider>
              <Picker
                mode="selector"
                range={TASK_OPTIONS.map((o) => o.label)}
                value={taskIndex}
                onChange={(event) => setTaskType(TASK_OPTIONS[Number(event.detail.value)]?.value || 'custom')}
              >
                <Cell title={TASK_OPTIONS[taskIndex]?.label || '选择'} value={<Tag>选择</Tag>} />
              </Picker>
            </FormRow>
            <FormRow label="优先级" divider>
              <Picker
                mode="selector"
                range={PRIORITY_OPTIONS.map((o) => o.label)}
                value={priorityIndex}
                onChange={(event) =>
                  setPriority(PRIORITY_OPTIONS[Number(event.detail.value)]?.value || 'normal')
                }
              >
                <Cell title={PRIORITY_OPTIONS[priorityIndex]?.label || '普通'} value={<Tag>选择</Tag>} />
              </Picker>
            </FormRow>
            <FormRow label="计划日期" divider>
              <Picker mode="date" value={scheduledDate} onChange={(event) => setScheduledDate(event.detail.value)}>
                <Cell title={scheduledDate} value={<Tag>选择</Tag>} />
              </Picker>
            </FormRow>
            {targetType !== 'custom' ? (
              <FormRow label="备注" divider>
                <Textarea
                  value={notes}
                  maxlength={1000}
                  placeholder="可选"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  onInput={(event) => setNotes(event.detail.value)}
                  style={{ color: '#FFFFFF', width: '100%', minHeight: '72px' }}
                />
              </FormRow>
            ) : null}
          </Section>
          <CapabilityButton capability="write_task" block disabled={busy} onClick={() => void submit()}>
            {busy ? '创建中…' : '创建照护提醒'}
          </CapabilityButton>
          {loadFailed ? (
            <Button block variant="outlined" disabled={busy} onClick={reloadTargets}>
              重新读取对象列表
            </Button>
          ) : null}
          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>
      </ScrollView>
    </View>
  )
}
