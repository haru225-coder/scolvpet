import { Input, Picker, ScrollView, Textarea, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useState } from 'react'
import { Cell, FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'

export default function CreateReminderPage() {
  const [title, setTitle] = useState('')
  const [targetType, setTargetType] = useState('custom')
  const [targetId, setTargetId] = useState('')
  const [taskType, setTaskType] = useState('custom')
  const [priority, setPriority] = useState('normal')
  const [notes, setNotes] = useState('')
  const [scheduledDate, setScheduledDate] = useState(new Date().toISOString().slice(0, 10))
  const [message, setMessage] = useState('创建后会进入今日照护队列，并由服务端生成提醒投影')
  const [busy, setBusy] = useState(false)

  useLoad((options) => {
    if (options?.title) setTitle(String(options.title))
    if (options?.targetType) setTargetType(String(options.targetType))
    if (options?.targetId) setTargetId(String(options.targetId))
    if (options?.taskType) setTaskType(String(options.taskType))
    if (options?.priority) setPriority(String(options.priority))
    if (options?.notes) setNotes(String(options.notes))
    if (options?.scheduledAt) setScheduledDate(String(options.scheduledAt).slice(0, 10))
    if (options?.targetId || options?.title) setMessage('已载入 AI 任务草案，请核对内容后确认提交')
  })

  async function submit() {
    if (!title.trim() || !targetId.trim()) {
      setMessage('请填写提醒标题和目标 ID')
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
          targetId: targetId.trim(),
          title: title.trim(),
          scheduledAt,
          priority,
          notes: notes.trim() || null
        } as any
      })
      Taro.showToast({ title: '提醒已创建', icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '提醒创建失败')
    } finally {
      setBusy(false)
    }
  }

  const priorityLabels = ['低', '普通', '高', '紧急', '关键']
  const priorityValues = ['low', 'normal', 'high', 'urgent', 'critical']
  const priorityIndex = Math.max(0, priorityValues.indexOf(priority))
  return <View style={{ height: '100vh', backgroundColor: crayon.paper, backgroundImage: paperGrain }}><NavBar title="新增提醒" back right={<Tag tone="accent">M2</Tag>} /><ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}><SectionList><Section header="照护任务" footer={message}><FormRow label="标题"><Input value={title} placeholder="例如：给 001 做健康观察" onInput={(event) => setTitle(event.detail.value)} /></FormRow><FormRow label="目标类型" divider><Input value={targetType} placeholder="hamster / litter / enclosure / custom" onInput={(event) => setTargetType(event.detail.value)} /></FormRow><FormRow label="目标 ID" divider><Input value={targetId} placeholder="个体、窝次或笼舍 ID" onInput={(event) => setTargetId(event.detail.value)} /></FormRow><FormRow label="任务类型" divider><Input value={taskType} placeholder="custom / medication / enclosure_cleaning" onInput={(event) => setTaskType(event.detail.value)} /></FormRow><FormRow label="优先级" divider><Picker mode="selector" range={priorityLabels} value={priorityIndex} onChange={(event) => setPriority(priorityValues[Number(event.detail.value)] || 'normal')}><Cell title={priorityLabels[priorityIndex]} value={<Tag>选择</Tag>} /></Picker></FormRow><FormRow label="计划日期" divider><Picker mode="date" value={scheduledDate} onChange={(event) => setScheduledDate(event.detail.value)}><Cell title={scheduledDate} value={<Tag>选择</Tag>} /></Picker></FormRow><FormRow label="备注" divider><Textarea value={notes} maxlength={1000} placeholder="可选" onInput={(event) => setNotes(event.detail.value)} /></FormRow></Section><CapabilityButton capability="write_task" block disabled={busy} onClick={() => void submit()}>{busy ? '创建中…' : '创建照护提醒'}</CapabilityButton><View style={{ height: `${metrics.bottomSafePadding}px` }} /></SectionList></ScrollView></View>
}
