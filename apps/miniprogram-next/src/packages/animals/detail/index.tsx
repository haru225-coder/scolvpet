import { Image, Input, Picker, ScrollView, Text, Textarea, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useCallback, useEffect, useState } from 'react'
import {
  NavBar,
  Section,
  SectionList,
  Cell,
  FormRow,
  Tag,
  Empty,
  metrics,
  palette
} from '@scolvpet/mp-ui'

import { defaultApi, geneticApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { readBreederSession } from '../../../auth/session'
import { readAnimalSnapshot, saveAnimalSnapshot } from '../../../offline/snapshots'
import config from '../../../utils/config'
import { sha256 } from '../../../utils/sha256'
import { decodePhenotype, encodePhenotype, readPhenotypeSeries, type PhenotypeSeries } from '../../../utils/phenotype'
import { ageLabel, animalScanSubtitle, animalScanTitle, shortDate } from '../../../utils/scan-labels'
import { humanShortLabel } from '../../../utils/tab-routes'
import type { ApiEnvelope } from '../../../api/types'

export default function AnimalDetailPage() {
  const [animalId, setAnimalId] = useState('')
  const [animal, setAnimal] = useState<any>(null)
  const [weights, setWeights] = useState<any[]>([])
  const [health, setHealth] = useState<any[]>([])
  const [weight, setWeight] = useState('')
  const [note, setNote] = useState('')
  const [animalInternalCode, setAnimalInternalCode] = useState('')
  const [animalName, setAnimalName] = useState('')
  const [animalSex, setAnimalSex] = useState('unknown')
  const [animalVarietyCode, setAnimalVarietyCode] = useState('')
  const [seriesCode, setSeriesCode] = useState('')
  const [phenotypeLabel, setPhenotypeLabel] = useState('')
  const [seriesOptions, setSeriesOptions] = useState<PhenotypeSeries[]>([])
  const [animalBirthDate, setAnimalBirthDate] = useState('')
  const [animalNotes, setAnimalNotes] = useState('')
  const [avatarUrl, setAvatarUrl] = useState('')
  const [avatarBusy, setAvatarBusy] = useState(false)
  const [savingProfile, setSavingProfile] = useState(false)
  const [loading, setLoading] = useState(true)
  const [message, setMessage] = useState('')
  const [showAdvanced, setShowAdvanced] = useState(false)

  useEffect(() => {
    void geneticApi.listGeneticPhenotypeCatalog().then((response: ApiEnvelope) => setSeriesOptions(readPhenotypeSeries(response))).catch(() => undefined)
  }, [])

  useEffect(() => {
    const decoded = decodePhenotype(animalVarietyCode)
    if (!decoded || !seriesOptions.some((item) => item.code === decoded.series)) return
    setSeriesCode((current) => current === decoded.series ? current : decoded.series)
    setPhenotypeLabel((current) => current === decoded.label ? current : decoded.label)
  }, [animalVarietyCode, seriesOptions])

  const load = useCallback(async (id: string) => {
    if (!readBreederSession()) {
      setMessage('请先登录经营账号')
      setLoading(false)
      return
    }
    try {
      const [animalResponse, weightResponse, healthResponse] = await Promise.all([
        defaultApi.getHamster({ hamsterId: id }),
        defaultApi.listWeightRecords({ hamsterId: id, limit: 20 }),
        defaultApi.listHealthRecords({ hamsterId: id, limit: 20 })
      ])
      const loadedAnimal: any = animalResponse.data
      setAnimal(loadedAnimal)
      setAnimalInternalCode(loadedAnimal?.internalCode || loadedAnimal?.internal_code || '')
      setAnimalName(loadedAnimal?.name || '')
      setAnimalSex(loadedAnimal?.sex || 'unknown')
      setAnimalVarietyCode(loadedAnimal?.varietyCode || loadedAnimal?.variety_code || '')
      setAnimalBirthDate(toDateInput(loadedAnimal?.birthDate || loadedAnimal?.birth_date))
      setAnimalNotes(loadedAnimal?.notes || '')
      setAvatarUrl('')
      if (animalResponse.data?.coverMediaId) {
        void resolveMediaUrl(String(animalResponse.data.coverMediaId)).then((url) => setAvatarUrl(url || ''))
      }
      setWeights(weightResponse.data || [])
      setHealth(healthResponse.data || [])
      saveAnimalSnapshot(id, { animal: animalResponse.data, weights: weightResponse.data || [], health: healthResponse.data || [] })
    } catch (cause) {
      const snapshot = readAnimalSnapshot<{ animal: any; weights: any[]; health: any[] }>(id)
      if (snapshot) {
        setAnimal(snapshot.value.animal)
        setAnimalInternalCode(snapshot.value.animal?.internalCode || snapshot.value.animal?.internal_code || '')
        setAnimalName(snapshot.value.animal?.name || '')
        setAnimalSex(snapshot.value.animal?.sex || 'unknown')
        setAnimalVarietyCode(snapshot.value.animal?.varietyCode || snapshot.value.animal?.variety_code || '')
        setAnimalBirthDate(toDateInput(snapshot.value.animal?.birthDate || snapshot.value.animal?.birth_date))
        setAnimalNotes(snapshot.value.animal?.notes || '')
        setWeights(snapshot.value.weights)
        setHealth(snapshot.value.health)
        setMessage(`网络暂时不可用，展示 ${new Date(snapshot.savedAt).toLocaleString('zh-CN')} 的只读档案快照`)
      } else setMessage(cause instanceof Error ? cause.message : '档案加载失败')
    } finally {
      setLoading(false)
    }
  }, [])

  function toDateInput(value: unknown): string {
    if (!value) return ''
    const raw = value instanceof Date ? value.toISOString() : String(value)
    return raw.slice(0, 10)
  }

  const selectedSeries = seriesOptions.find((item) => item.code === seriesCode)
  const phenotypeOptions = selectedSeries?.phenotypes || []
  const phenotypeIndex = Math.max(0, phenotypeOptions.indexOf(phenotypeLabel))

  useLoad((options) => {
    const id = String(options?.id || '')
    setAnimalId(id)
    if (id) void load(id)
    else { setMessage('缺少个体 ID'); setLoading(false) }
  })

  async function resolveMediaUrl(mediaId: string): Promise<string | null> {
    try {
      const response = await defaultApi.getMediaAsset({ mediaId })
      const media: any = response.data
      const variants = Array.isArray(media?.variants) ? media.variants : []
      const preferred = ['thumbnail', 'preview', 'cover']
      const selected = preferred.map((kind) => variants.find((item: any) => item.kind === kind && item.status === 'ready' && item.url)).find(Boolean)
      const url = selected?.url || media?.originalUrl
      if (!url) return null
      if (/^https?:\/\//i.test(url)) return url
      const base = String(config.API_BASE).replace(/\/$/, '')
      return `${base}${String(url).startsWith('/') ? '' : '/'}${url}`
    } catch (_) {
      return null
    }
  }

  function readFile(filePath: string): Promise<ArrayBuffer> {
    return new Promise((resolve, reject) => {
      Taro.getFileSystemManager().readFile({ filePath, success: (result) => resolve(result.data as ArrayBuffer), fail: reject })
    })
  }

  async function uploadAvatar() {
    if (!animal || !animalId) return
    setAvatarBusy(true)
    try {
      const chosen = await Taro.chooseImage({ count: 1, sizeType: ['compressed'], sourceType: ['album', 'camera'] })
      const file: any = chosen.tempFiles?.[0]
      if (!file?.path) return
      const bytes = await readFile(file.path)
      const sizeBytes = Number(file.size || bytes.byteLength)
      if (!sizeBytes || sizeBytes > 20 * 1024 * 1024) throw new Error('头像文件需小于 20 MB')
      const extension = String(file.path).split('.').pop()?.toLowerCase()
      const contentType = extension === 'png' ? 'image/png' : extension === 'webp' ? 'image/webp' : 'image/jpeg'
      const digest = sha256(bytes)
      const presign = await defaultApi.presignMediaUpload({
        idempotencyKey: newIdempotencyKey(),
        mediaUploadPresignRequest: { fileName: file.name || `hamster-${animalId}.${extension || 'jpg'}`, contentType, sizeBytes, sha256: digest, purpose: 'hamster_profile' } as any
      })
      const session: any = presign.data
      const uploaded: any = await Taro.request({ url: session.uploadUrl, method: session.method || 'PUT', data: bytes, header: { ...(session.headers || {}), 'Content-Type': contentType } })
      if (uploaded.statusCode < 200 || uploaded.statusCode >= 300) throw new Error(`图片上传失败（${uploaded.statusCode}）`)
      const headers = uploaded.header || uploaded.headers || {}
      const etagEntry = Object.entries(headers).find(([key]) => key.toLowerCase() === 'etag')
      const etag = etagEntry ? String(etagEntry[1]).trim() : ''
      if (!etag) throw new Error('图片已上传，但对象存储未返回校验标识')
      const completed = await defaultApi.completeMediaUpload({
        uploadId: session.id,
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(session.version ?? 0),
        mediaUploadCompleteRequest: { objectEtag: etag, sizeBytes, sha256: digest, timezone: 'Asia/Taipei' }
      })
      const mediaId = (completed.data as any)?.media?.id
      if (!mediaId) throw new Error('媒体完成响应缺少 media ID')
      await defaultApi.updateHamster({ idempotencyKey: newIdempotencyKey(), ifMatch: String(animal.version ?? 0), hamsterId: animalId, hamsterUpdateRequest: { coverMediaId: mediaId } })
      setMessage('头像已更新')
      await load(animalId)
    } catch (cause) {
      if ((cause as any)?.errMsg?.includes('cancel')) setMessage('已取消选择头像')
      else setMessage(cause instanceof Error ? cause.message : '头像上传失败')
    } finally {
      setAvatarBusy(false)
    }
  }

  async function removeAvatar() {
    if (!animal || !animalId || !animal.coverMediaId) return
    const confirmation = await Taro.showModal({ title: '移除头像', content: '确认移除这个体的头像吗？' })
    if (!confirmation.confirm) return
    setAvatarBusy(true)
    try {
      await defaultApi.updateHamster({ idempotencyKey: newIdempotencyKey(), ifMatch: String(animal.version ?? 0), hamsterId: animalId, hamsterUpdateRequest: { coverMediaId: null } })
      setAvatarUrl('')
      setMessage('头像已移除')
      await load(animalId)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '头像移除失败')
    } finally {
      setAvatarBusy(false)
    }
  }

  async function saveWeight() {
    const value = Number(weight)
    if (!animalId || !Number.isFinite(value) || value <= 0) {
      setMessage('请输入有效体重（克）')
      return
    }
    try {
      await defaultApi.createWeightRecord({
        idempotencyKey: newIdempotencyKey(),
        weightRecordCreateRequest: {
          hamsterId: animalId,
          pupIdentityId: null,
          litterId: null,
          measurementKind: 'individual',
          subjectCount: null,
          weightG: value,
          recordedAt: new Date(),
          source: 'manual',
          notes: note || null
        } as any
      })
      setWeight('')
      setNote('')
      setMessage('体重已记录')
      await load(animalId)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '体重记录失败')
    }
  }

  async function saveProfile() {
    if (!animal || !animalId) return
    setSavingProfile(true)
    try {
      await defaultApi.updateHamster({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(animal.version ?? 0),
        hamsterId: animalId,
        hamsterUpdateRequest: {
          internalCode: animalInternalCode.trim() || undefined,
          name: animalName.trim() || null,
          sex: animalSex as any,
          varietyCode: animalVarietyCode.trim() || encodePhenotype(seriesCode, phenotypeLabel) || null,
          birthDate: animalBirthDate ? new Date(`${animalBirthDate}T00:00:00Z`) : null,
          notes: animalNotes.trim() || null
        }
      })
      setMessage('个体档案已更新')
      await load(animalId)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '个体档案更新失败')
    } finally {
      setSavingProfile(false)
    }
  }

  async function saveHealth() {
    try {
      await defaultApi.createHealthRecord({
        idempotencyKey: newIdempotencyKey(),
        healthRecordCreateRequest: {
          hamsterId: animalId,
          type: 'daily_check',
          observedAt: new Date(),
          severity: 'info',
          notes: note || '小程序端快速健康观察'
        }
      })
      setNote('')
      setMessage('健康观察已记录')
      await load(animalId)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '健康记录失败')
    }
  }

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <NavBar title={animal?.name || animal?.internalCode || '个体档案'} back />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        {loading ? <Empty title="正在读取档案" /> : null}
        {!loading && !animal ? <Empty title="档案暂不可用" description={message} /> : null}
        {animal ? (
          <SectionList>
            <Section header="基本信息" footer={message || '记录会进入后端审计链'}>
              {avatarUrl ? <Image src={avatarUrl} mode="aspectFill" style={{ width: '96px', height: '96px', borderRadius: '48px', margin: '12px auto', display: 'block' }} /> : null}
              <Cell
                title={animalScanTitle(animal)}
                subtitle={
                  animalScanSubtitle({
                    ...animal,
                    corePhenotypeLabel: phenotypeLabel || animal.corePhenotypeLabel
                  }) || undefined
                }
                value={
                  <Tag
                    tone={
                      animal.lifecycleStatus === 'deceased'
                        ? 'danger'
                        : animal.lifecycleStatus === 'active'
                          ? 'success'
                          : 'warning'
                    }
                  >
                    {animal.lifecycleStatus === 'active'
                      ? '在养'
                      : humanShortLabel(animal.lifecycleStatus || animal.status || 'active')}
                  </Tag>
                }
              />
              <Cell
                title="日龄"
                value={
                  ageLabel(animal.birthDate || animal.birth_date) ||
                  shortDate(animal.birthDate || animal.birth_date) ||
                  '未记录出生'
                }
              />
              <Cell
                title="当前笼舍"
                value={animal.currentEnclosureName || animal.enclosureName || (animal.currentEnclosureId ? '已分配' : '未分配')}
              />
              <Cell
                title="繁育状态"
                value={humanShortLabel(animal.breedingStatus) || '未记录'}
              />
            </Section>
            <Section header="头像">
              <CapabilityButton capability="write_hamster" block disabled={avatarBusy} onClick={() => void uploadAvatar()}>{avatarBusy ? '处理中…' : animal.coverMediaId ? '更换头像' : '从相册选择'}</CapabilityButton>
              {animal.coverMediaId ? <CapabilityButton capability="write_hamster" block variant="outlined" disabled={avatarBusy} onClick={() => void removeAvatar()}>移除头像</CapabilityButton> : null}
            </Section>
            <Section header="档案编辑">
              <FormRow label="内部编号">
                <Input
                  value={animalInternalCode}
                  placeholder="内部编号"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  onInput={(event) => setAnimalInternalCode(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              <FormRow label="名称" divider>
                <Input
                  value={animalName}
                  placeholder="可选"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  onInput={(event) => setAnimalName(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              <FormRow label="性别" divider>
                <Picker
                  mode="selector"
                  range={['待定', '公', '母']}
                  value={Math.max(0, ['unknown', 'male', 'female'].indexOf(animalSex))}
                  onChange={(event) =>
                    setAnimalSex(['unknown', 'male', 'female'][Number(event.detail.value)] || 'unknown')
                  }
                >
                  <Cell
                    title={animalSex === 'male' ? '公' : animalSex === 'female' ? '母' : '待定'}
                    value={<Tag>选择</Tag>}
                  />
                </Picker>
              </FormRow>
              {seriesOptions.length ? (
                <>
                  <FormRow label="样子系列" divider>
                    <Picker
                      mode="selector"
                      range={seriesOptions.map((item) => item.name)}
                      value={Math.max(0, seriesOptions.findIndex((item) => item.code === seriesCode))}
                      onChange={(event) => {
                        const selected = seriesOptions[Number(event.detail.value)]
                        setSeriesCode(selected?.code || '')
                        setPhenotypeLabel(selected?.phenotypes[0] || '')
                        setAnimalVarietyCode(
                          encodePhenotype(selected?.code || '', selected?.phenotypes[0] || '')
                        )
                      }}
                    >
                      <Cell title={selectedSeries?.name || '选择系列'} value={<Tag>选择</Tag>} />
                    </Picker>
                  </FormRow>
                  <FormRow label="样子" divider>
                    <Picker
                      mode="selector"
                      range={phenotypeOptions}
                      value={phenotypeIndex}
                      onChange={(event) => {
                        const label = phenotypeOptions[Number(event.detail.value)] || ''
                        setPhenotypeLabel(label)
                        setAnimalVarietyCode(encodePhenotype(seriesCode, label))
                      }}
                    >
                      <Cell title={phenotypeLabel || '选择样子'} value={<Tag>选择</Tag>} />
                    </Picker>
                  </FormRow>
                </>
              ) : null}
              <FormRow label="出生日期" divider>
                <Picker mode="date" value={animalBirthDate} onChange={(event) => setAnimalBirthDate(event.detail.value)}>
                  <Cell title={animalBirthDate || '未填写'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
              <FormRow label="备注" divider>
                <Textarea
                  value={animalNotes}
                  maxlength={1000}
                  placeholder="可选"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  onInput={(event) => setAnimalNotes(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              <Cell
                title={showAdvanced ? '收起高级' : '展开高级'}
                subtitle="手动品系代码，选样子后通常可留空"
                value={<Tag>{showAdvanced ? '已展开' : '折叠'}</Tag>}
                onClick={() => setShowAdvanced((v) => !v)}
              />
              {showAdvanced ? (
                <FormRow label="品系代码" divider>
                  <Input
                    value={animalVarietyCode}
                    placeholder={seriesOptions.length ? '可选，默认使用系列|表型' : '可选'}
                    placeholderStyle="color: rgba(255,255,255,0.35)"
                    onInput={(event) => setAnimalVarietyCode(event.detail.value)}
                    style={{ color: '#FFFFFF' }}
                  />
                </FormRow>
              ) : null}
              <CapabilityButton capability="write_hamster" block disabled={savingProfile} onClick={() => void saveProfile()}>{savingProfile ? '保存中…' : '保存档案'}</CapabilityButton>
            </Section>
            <Section header="体重快录">
              <FormRow label="克数">
                <Input
                  type="digit"
                  placeholder="例如 128.5"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  value={weight}
                  onInput={(event) => setWeight(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              <FormRow label="备注" divider>
                <Input
                  placeholder="可选"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  value={note}
                  onInput={(event) => setNote(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              <CapabilityButton capability="write_weight" block onClick={() => void saveWeight()}>保存体重</CapabilityButton>
            </Section>
            <Section header="健康快录">
              <CapabilityButton capability="write_health" block variant="outlined" onClick={() => void saveHealth()}>记录一次日常观察</CapabilityButton>
            </Section>
            <Section header="最近体重" footer={`共 ${weights.length} 条`}>
              {weights.length
                ? weights.slice(0, 10).map((item) => (
                    <Cell
                      key={item.id}
                      title={`${item.weightG ?? item.weight_g ?? '-'} g`}
                      subtitle={String(item.recordedAt || item.recorded_at || '')}
                      value={<Tag>{humanShortLabel(item.source || 'manual') || '手记'}</Tag>}
                    />
                  ))
                : <Cell title="暂无体重记录" />}
            </Section>
            <Section header="健康记录" footer={`共 ${health.length} 条`}>
              {health.length
                ? health.slice(0, 10).map((item) => (
                    <Cell
                      key={item.id}
                      title={humanShortLabel(item.type) || item.type || '观察'}
                      subtitle={item.notes || String(item.observedAt || '')}
                      value={
                        <Tag
                          tone={
                            item.severity === 'high' || item.severity === 'critical'
                              ? 'danger'
                              : 'success'
                          }
                        >
                          {humanShortLabel(item.severity || 'info') || '一般'}
                        </Tag>
                      }
                    />
                  ))
                : <Cell title="暂无健康记录" />}
            </Section>
            <Text style={{ display: 'block', color: palette.secondaryLabel, padding: `0 ${metrics.pagePadding}px ${metrics.bottomSafePadding}px` }}>只追加记录，原始数据由服务端保留审计链。</Text>
          </SectionList>
        ) : null}
      </ScrollView>
    </View>
  )
}
