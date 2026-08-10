import { Image, Input, Picker, ScrollView, Text, Textarea, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useCallback, useEffect, useMemo, useState } from 'react'
import { formatUserError } from '../../../api/errors'
import {
  NavBar,
  Section,
  SectionList,
  Cell,
  FormRow,
  Tag,
  Empty,
  SegmentedControl,
  metrics,
  palette,
  typeStyle
} from '@scolvpet/mp-ui'

import { defaultApi } from '../../../api/default-api'
import { geneticApi } from '../../../api/genetic-api'
import { p1Api } from '../../../api/p1-api'
import { newIdempotencyKey } from '../../../api/runtime-config'
import { canUseCapability } from '../../../auth/permissions'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { requireBreederSession } from '../../../auth/dev-session'
import { readAnimalSnapshot, saveAnimalSnapshot } from '../../../offline/snapshots'
import config from '../../../utils/config'
import { sha256 } from '../../../utils/sha256'
import { decodePhenotype, encodePhenotype, readPhenotypeSeries, type PhenotypeSeries } from '../../../utils/phenotype'
import { ageLabel, animalScanSubtitle, animalScanTitle, shortDate } from '../../../utils/scan-labels'
import { DOMAIN_HOME, humanShortLabel } from '../../../utils/tab-routes'
import type { ApiEnvelope } from '../../../api/types'

/** 产品分段：先看再改，对齐 Flutter 个体档案主路径。 */
const SEGMENTS = ['概览', '成长', '健康', '编辑'] as const

function toDateInput(value: unknown): string {
  if (!value) return ''
  const raw = value instanceof Date ? value.toISOString() : String(value)
  return raw.slice(0, 10)
}

function lifecycleTone(status: unknown): 'success' | 'danger' | 'warning' | 'default' {
  if (status === 'deceased') return 'danger'
  if (status === 'active') return 'success'
  if (status === 'retired') return 'default'
  return 'warning'
}

function lifecycleLabel(status: unknown): string {
  if (status === 'active') return '在养'
  return humanShortLabel(status) || '待确认'
}

function sexLabel(sex: unknown): string {
  if (sex === 'male') return '公'
  if (sex === 'female') return '母'
  return '待定'
}

function enclosureLabel(animal: Record<string, unknown> | null | undefined): string {
  if (!animal) return '未分配'
  return String(
    animal.currentEnclosureName ||
      animal.enclosureName ||
      (animal.currentEnclosureId ? '已分配' : '未分配')
  )
}

/**
 * 个体档案（产品化）。
 * 2026-08：默认只读概览 + 分段快录；完整表单收进「编辑」。
 * 能力与契约不变：头像预签、体重/健康追加、If-Match 档案更新、离线快照。
 */
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
  const [segment, setSegment] = useState(0)

  useEffect(() => {
    void geneticApi
      .listGeneticPhenotypeCatalog()
      .then((response: ApiEnvelope) => setSeriesOptions(readPhenotypeSeries(response)))
      .catch(() => undefined)
  }, [])

  useEffect(() => {
    const decoded = decodePhenotype(animalVarietyCode)
    if (!decoded || !seriesOptions.some((item) => item.code === decoded.series)) return
    setSeriesCode((current) => (current === decoded.series ? current : decoded.series))
    setPhenotypeLabel((current) => (current === decoded.label ? current : decoded.label))
  }, [animalVarietyCode, seriesOptions])

  const applyAnimalFields = useCallback((loadedAnimal: any) => {
    setAnimal(loadedAnimal)
    setAnimalInternalCode(loadedAnimal?.internalCode || loadedAnimal?.internal_code || '')
    setAnimalName(loadedAnimal?.name || '')
    setAnimalSex(loadedAnimal?.sex || 'unknown')
    setAnimalVarietyCode(loadedAnimal?.varietyCode || loadedAnimal?.variety_code || '')
    setAnimalBirthDate(toDateInput(loadedAnimal?.birthDate || loadedAnimal?.birth_date))
    setAnimalNotes(loadedAnimal?.notes || '')
  }, [])

  const load = useCallback(
    async (id: string) => {
      const session = await requireBreederSession()
      if (!session) {
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
        applyAnimalFields(loadedAnimal)
        setAvatarUrl('')
        if (animalResponse.data?.coverMediaId) {
          void resolveMediaUrl(String(animalResponse.data.coverMediaId)).then((url) => setAvatarUrl(url || ''))
        }
        setWeights(weightResponse.data || [])
        setHealth(healthResponse.data || [])
        saveAnimalSnapshot(id, {
          animal: animalResponse.data,
          weights: weightResponse.data || [],
          health: healthResponse.data || []
        })
        setMessage('')
      } catch (cause) {
        const snapshot = readAnimalSnapshot<{ animal: any; weights: any[]; health: any[] }>(id)
        if (snapshot) {
          applyAnimalFields(snapshot.value.animal)
          setWeights(snapshot.value.weights)
          setHealth(snapshot.value.health)
          setMessage(`暂时连不上服务器，展示 ${new Date(snapshot.savedAt).toLocaleString('zh-CN')} 的只读快照`)
        } else {
          setMessage(await formatUserError(cause, '档案加载失败'))
        }
      } finally {
        setLoading(false)
      }
    },
    [applyAnimalFields]
  )

  const selectedSeries = seriesOptions.find((item) => item.code === seriesCode)
  const phenotypeOptions = selectedSeries?.phenotypes || []
  const phenotypeIndex = Math.max(0, phenotypeOptions.indexOf(phenotypeLabel))

  const latestWeight = weights[0]
  const metaLine = useMemo(() => {
    if (!animal) return ''
    return (
      animalScanSubtitle({
        ...animal,
        corePhenotypeLabel: phenotypeLabel || animal.corePhenotypeLabel
      }) || ''
    )
  }, [animal, phenotypeLabel])

  useLoad((options) => {
    const id = String(options?.id || '')
    setAnimalId(id)
    if (id) void load(id)
    else {
      setMessage('缺少个体 ID')
      setLoading(false)
    }
  })

  async function resolveMediaUrl(mediaId: string): Promise<string | null> {
    try {
      const response = await defaultApi.getMediaAsset({ mediaId })
      const media: any = response.data
      const variants = Array.isArray(media?.variants) ? media.variants : []
      const preferred = ['thumbnail', 'preview', 'cover']
      const selected = preferred
        .map((kind) => variants.find((item: any) => item.kind === kind && item.status === 'ready' && item.url))
        .find(Boolean)
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
      Taro.getFileSystemManager().readFile({
        filePath,
        success: (result) => resolve(result.data as ArrayBuffer),
        fail: reject
      })
    })
  }

  async function uploadAvatar() {
    if (!animal || !animalId) return
    setAvatarBusy(true)
    try {
      const chosen = await Taro.chooseImage({
        count: 1,
        sizeType: ['compressed'],
        sourceType: ['album', 'camera']
      })
      const file: any = chosen.tempFiles?.[0]
      if (!file?.path) return
      const bytes = await readFile(file.path)
      const sizeBytes = Number(file.size || bytes.byteLength)
      if (!sizeBytes || sizeBytes > 20 * 1024 * 1024) throw new Error('头像文件需小于 20 MB')
      const extension = String(file.path).split('.').pop()?.toLowerCase()
      const contentType =
        extension === 'png' ? 'image/png' : extension === 'webp' ? 'image/webp' : 'image/jpeg'
      const digest = sha256(bytes)
      const presign = await defaultApi.presignMediaUpload({
        idempotencyKey: newIdempotencyKey(),
        mediaUploadPresignRequest: {
          fileName: file.name || `hamster-${animalId}.${extension || 'jpg'}`,
          contentType,
          sizeBytes,
          sha256: digest,
          purpose: 'hamster_profile'
        } as any
      })
      const session: any = presign.data
      const uploaded: any = await Taro.request({
        url: session.uploadUrl,
        method: session.method || 'PUT',
        data: bytes,
        header: { ...(session.headers || {}), 'Content-Type': contentType }
      })
      if (uploaded.statusCode < 200 || uploaded.statusCode >= 300) {
        throw new Error(`图片上传失败（${uploaded.statusCode}）`)
      }
      const headers = uploaded.header || uploaded.headers || {}
      const etagEntry = Object.entries(headers).find(([key]) => key.toLowerCase() === 'etag')
      const etag = etagEntry ? String(etagEntry[1]).trim() : ''
      if (!etag) throw new Error('图片已上传，但对象存储未返回校验标识')
      const completed = await defaultApi.completeMediaUpload({
        uploadId: session.id,
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(session.version ?? 0),
        mediaUploadCompleteRequest: {
          objectEtag: etag,
          sizeBytes,
          sha256: digest,
          timezone: 'Asia/Taipei'
        }
      })
      const mediaId = (completed.data as any)?.media?.id
      if (!mediaId) throw new Error('媒体完成响应缺少 media ID')
      await defaultApi.updateHamster({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(animal.version ?? 0),
        hamsterId: animalId,
        hamsterUpdateRequest: { coverMediaId: mediaId }
      })
      setMessage('头像已更新')
      await load(animalId)
    } catch (cause) {
      if ((cause as any)?.errMsg?.includes('cancel')) setMessage('已取消选择头像')
      else setMessage(await formatUserError(cause, '头像上传失败'))
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
      await defaultApi.updateHamster({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(animal.version ?? 0),
        hamsterId: animalId,
        hamsterUpdateRequest: { coverMediaId: null }
      })
      setAvatarUrl('')
      setMessage('头像已移除')
      await load(animalId)
    } catch (cause) {
      setMessage(await formatUserError(cause, '头像移除失败'))
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
      setMessage(await formatUserError(cause, '体重记录失败'))
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
      setMessage('档案已保存')
      await load(animalId)
    } catch (cause) {
      setMessage(await formatUserError(cause, '档案保存失败'))
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
          notes: note || '日常观察'
        }
      })
      setNote('')
      setMessage('健康观察已记录')
      await load(animalId)
    } catch (cause) {
      setMessage(await formatUserError(cause, '健康记录失败'))
    }
  }

  function resolveAnimalPhenotype(): { series: string; label: string } {
    const label = String(phenotypeLabel || animal?.corePhenotypeLabel || '').trim()
    const variety = String(animal?.varietyCode || animal?.variety_code || animalVarietyCode || '').trim()
    const decoded = variety ? decodePhenotype(variety) : null
    const series = String(decoded?.series || seriesCode || '').trim()
    return { series, label: label || decoded?.label || '' }
  }

  async function findBoundGeneticProfile(): Promise<any | null> {
    if (!animalId) return null
    try {
      const profilesRes = await p1Api.listGeneticProfiles()
      const raw = (profilesRes as any)?.data ?? profilesRes
      const list = Array.isArray(raw) ? raw : raw?.items || raw?.data || []
      return list.find((p: any) => String(p.hamsterId || p.hamster_id || '') === animalId) || null
    } catch {
      return null
    }
  }

  function openTrialPairing() {
    void (async () => {
      const { series, label } = resolveAnimalPhenotype()
      const sex = String(animal?.sex || '')
      const side: 'sire' | 'dam' = sex === 'female' ? 'dam' : 'sire'
      const match = await findBoundGeneticProfile()
      const key = String(match?.genotype?.key || '').trim()
      const phSeries = String(match?.phenotype?.series || match?.genotype?.series || series).trim()
      const phLabel = String(match?.phenotype?.label || label).trim()
      const q = [
        `side=${side}`,
        phSeries ? `series=${encodeURIComponent(phSeries)}` : '',
        key ? `${side}_key=${encodeURIComponent(key)}` : '',
        phLabel ? `${side}_ph=${encodeURIComponent(phLabel)}` : ''
      ]
        .filter(Boolean)
        .join('&')
      void Taro.navigateTo({
        url: q ? `${DOMAIN_HOME.geneticCreate}?${q}` : DOMAIN_HOME.geneticCreate
      })
    })()
  }

  async function createGeneticProfileForAnimal() {
    if (!animalId) return
    const existing = await findBoundGeneticProfile()
    if (existing) {
      setMessage('本个体已绑定遗传档案，可到档案列表查看')
      void Taro.showToast({ title: '已有绑定档案', icon: 'none' })
      return
    }
    const { series, label } = resolveAnimalPhenotype()
    if (!series || !label) {
      setMessage('请先在档案里填好系列和样子，再创建遗传档案')
      return
    }
    try {
      await p1Api.createGeneticProfile({
        idempotencyKey: newIdempotencyKey(),
        createGeneticProfileRequest: {
          name: `${animal?.name || animal?.internalCode || '个体'} · ${label}`,
          confidence: 'unknown',
          hamsterId: animalId,
          phenotype: { series, label, source: 'animal_profile' },
          genotype: { series },
          notes: '从个体档案创建'
        } as any
      } as any)
      setMessage('已创建遗传档案并绑定本个体')
      void Taro.showToast({ title: '遗传档案已建', icon: 'success' })
    } catch (cause) {
      setMessage(await formatUserError(cause, '创建遗传档案失败'))
    }
  }

  function manageGeneticProfile() {
    void (async () => {
      const existing = await findBoundGeneticProfile()
      const itemList = existing
        ? ['用这个体去试配', '打开遗传档案列表']
        : ['用这个体去试配', '创建并绑定遗传档案', '打开遗传档案列表']
      try {
        const res = await Taro.showActionSheet({ itemList })
        if (existing) {
          if (res.tapIndex === 0) openTrialPairing()
          else if (res.tapIndex === 1) void Taro.navigateTo({ url: DOMAIN_HOME.genetic })
          return
        }
        if (res.tapIndex === 0) openTrialPairing()
        else if (res.tapIndex === 1) void createGeneticProfileForAnimal()
        else if (res.tapIndex === 2) void Taro.navigateTo({ url: DOMAIN_HOME.genetic })
      } catch {
        // 用户取消 ActionSheet
      }
    })()
  }

  /** 族谱：经营端从窝次反推父母（个体档案不带 sireId/damId）。 */
  function openPedigree() {
    if (!animalId) return
    void Taro.navigateTo({
      url: `${DOMAIN_HOME.pedigree}?id=${encodeURIComponent(animalId)}`
    })
  }

  const navTitle = animal?.name || animal?.internalCode || '个体档案'

  return (
    <View
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: palette.systemBackground
      }}
    >
      <NavBar title={navTitle} back />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        {loading ? <Empty title="正在读取…" /> : null}
        {!loading && !animal ? <Empty title="档案暂不可用" description={message} /> : null}

        {animal ? (
          <View style={{ paddingBottom: metrics.bottomSafePadding }}>
            {/* 身份卡：对照 Flutter profile card，一眼看完关键信息 */}
            <View
              style={{
                margin: `${metrics.sectionGap}px ${metrics.pagePadding}px 0`,
                padding: '16px',
                borderRadius: `${metrics.continuousRadius}px`,
                backgroundColor: palette.secondaryGroupedBackground,
                border: `1px solid ${palette.separator}`
              }}
            >
              <View style={{ display: 'flex', flexDirection: 'row', alignItems: 'flex-start' }}>
                <View
                  onClick={() => {
                    if (canUseCapability('write_hamster') && !avatarBusy) void uploadAvatar()
                  }}
                  style={{
                    width: '88px',
                    height: '88px',
                    borderRadius: '44px',
                    overflow: 'hidden',
                    flexShrink: 0,
                    backgroundColor: palette.fill,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center'
                  }}
                >
                  {avatarUrl ? (
                    <Image src={avatarUrl} mode="aspectFill" style={{ width: '88px', height: '88px' }} />
                  ) : (
                    <Text style={{ ...typeStyle('bodySmall'), color: palette.tertiaryLabel }}>
                      {avatarBusy
                        ? '…'
                        : canUseCapability('write_hamster')
                          ? '点此上传'
                          : '暂无头像'}
                    </Text>
                  )}
                </View>
                <View style={{ flex: 1, marginLeft: '14px', minWidth: 0 }}>
                  <Text
                    style={{
                      fontSize: '20px',
                      fontWeight: 600,
                      letterSpacing: '-0.3px',
                      lineHeight: 1.3,
                      color: palette.label,
                      display: 'block'
                    }}
                  >
                    {animalScanTitle(animal)}
                  </Text>
                  {animal.name && animal.internalCode ? (
                    <Text
                      style={{
                        ...typeStyle('bodyMedium'),
                        color: palette.secondaryLabel,
                        display: 'block',
                        marginTop: '2px'
                      }}
                    >
                      {String(animal.internalCode)}
                    </Text>
                  ) : null}
                  {metaLine ? (
                    <Text
                      style={{
                        ...typeStyle('bodySmall'),
                        color: palette.secondaryLabel,
                        display: 'block',
                        marginTop: '6px'
                      }}
                    >
                      {metaLine}
                    </Text>
                  ) : null}
                  <View style={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', marginTop: '10px', gap: '8px' }}>
                    <Tag tone={lifecycleTone(animal.lifecycleStatus)}>
                      {lifecycleLabel(animal.lifecycleStatus || animal.status)}
                    </Tag>
                    {latestWeight ? (
                      <Tag>
                        {String(latestWeight.weightG ?? latestWeight.weight_g ?? '-')} g
                      </Tag>
                    ) : null}
                  </View>
                </View>
              </View>
              {message ? (
                <Text
                  style={{
                    ...typeStyle('bodySmall'),
                    color: palette.secondaryLabel,
                    display: 'block',
                    marginTop: '12px'
                  }}
                >
                  {message}
                </Text>
              ) : null}
            </View>

            <View style={{ padding: `12px ${metrics.pagePadding}px 0` }}>
              <SegmentedControl
                segments={[...SEGMENTS]}
                value={segment}
                onChange={setSegment}
              />
            </View>

            <SectionList>
              {segment === 0 ? (
                <>
                  <Section header="关键信息">
                    <Cell
                      title="日龄"
                      value={
                        ageLabel(animal.birthDate || animal.birth_date) ||
                        shortDate(animal.birthDate || animal.birth_date) ||
                        '未记录出生'
                      }
                    />
                    <Cell title="性别" value={sexLabel(animal.sex)} />
                    <Cell title="当前笼舍" value={enclosureLabel(animal)} />
                    <Cell
                      title="繁育状态"
                      value={humanShortLabel(animal.breedingStatus) || '未记录'}
                    />
                    {(phenotypeLabel || animal.corePhenotypeLabel) ? (
                      <Cell
                        title="样子"
                        value={String(phenotypeLabel || animal.corePhenotypeLabel)}
                      />
                    ) : null}
                    {animalNotes || animal.notes ? (
                      <Cell title="备注" subtitle={String(animalNotes || animal.notes)} />
                    ) : null}
                  </Section>
                  <Section header="快捷动作">
                    <Cell
                      title="试配模拟"
                      subtitle="带入样子；若已绑遗传档案则带基因型"
                      chevron
                      onClick={openTrialPairing}
                    />
                    <Cell
                      title="遗传档案"
                      subtitle="已绑则试配/列表；未绑可创建并绑定"
                      chevron
                      onClick={manageGeneticProfile}
                    />
                    <Cell
                      title="看族谱"
                      subtitle="父母与祖代（来自窝次记录）"
                      chevron
                      onClick={openPedigree}
                    />
                    {canUseCapability('write_hamster') ? (
                      <Cell
                        title={animal.coverMediaId ? '更换头像' : '上传头像'}
                        subtitle={avatarBusy ? '处理中…' : '相册或拍照'}
                        chevron
                        onClick={() => {
                          if (!avatarBusy) void uploadAvatar()
                        }}
                      />
                    ) : null}
                    {canUseCapability('write_hamster') && animal.coverMediaId ? (
                      <Cell
                        title="移除头像"
                        onClick={() => {
                          if (!avatarBusy) void removeAvatar()
                        }}
                      />
                    ) : null}
                    {canUseCapability('write_hamster') ? (
                      <Cell title="编辑档案" subtitle="编号、样子、出生日期" chevron onClick={() => setSegment(3)} />
                    ) : null}
                    {canUseCapability('write_weight') ? (
                      <Cell title="记体重" chevron onClick={() => setSegment(1)} />
                    ) : null}
                    {canUseCapability('write_health') ? (
                      <Cell title="健康观察" chevron onClick={() => setSegment(2)} />
                    ) : null}
                  </Section>
                </>
              ) : null}

              {segment === 1 ? (
                <>
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
                    <CapabilityButton capability="write_weight" block onClick={() => void saveWeight()}>
                      保存体重
                    </CapabilityButton>
                  </Section>
                  <Section header="最近体重" footer={weights.length ? `共 ${weights.length} 条` : undefined}>
                    {weights.length ? (
                      weights.slice(0, 10).map((item) => (
                        <Cell
                          key={item.id}
                          title={`${item.weightG ?? item.weight_g ?? '-'} g`}
                          subtitle={
                            shortDate(item.recordedAt || item.recorded_at) ||
                            String(item.recordedAt || item.recorded_at || '')
                          }
                          value={
                            <Tag>{humanShortLabel(item.source || 'manual') || '手记'}</Tag>
                          }
                        />
                      ))
                    ) : (
                      <Cell title="暂无体重记录" subtitle="快录一条即可开始跟踪" />
                    )}
                  </Section>
                </>
              ) : null}

              {segment === 2 ? (
                <>
                  <Section header="健康快录">
                    <FormRow label="备注">
                      <Input
                        placeholder="可选，例如精神状态"
                        placeholderStyle="color: rgba(255,255,255,0.35)"
                        value={note}
                        onInput={(event) => setNote(event.detail.value)}
                        style={{ color: '#FFFFFF' }}
                      />
                    </FormRow>
                    <CapabilityButton
                      capability="write_health"
                      block
                      variant="outlined"
                      onClick={() => void saveHealth()}
                    >
                      记录一次日常观察
                    </CapabilityButton>
                  </Section>
                  <Section header="健康记录" footer={health.length ? `共 ${health.length} 条` : undefined}>
                    {health.length ? (
                      health.slice(0, 10).map((item) => (
                        <Cell
                          key={item.id}
                          title={humanShortLabel(item.type) || item.type || '观察'}
                          subtitle={
                            item.notes ||
                            shortDate(item.observedAt || item.observed_at) ||
                            String(item.observedAt || item.observed_at || '')
                          }
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
                    ) : (
                      <Cell title="暂无健康记录" subtitle="日常观察会按时间列在这里" />
                    )}
                  </Section>
                </>
              ) : null}

              {segment === 3 ? (
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
                        setAnimalSex(
                          ['unknown', 'male', 'female'][Number(event.detail.value)] || 'unknown'
                        )
                      }
                    >
                      <Cell
                        title={sexLabel(animalSex)}
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
                          value={Math.max(
                            0,
                            seriesOptions.findIndex((item) => item.code === seriesCode)
                          )}
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
                    <Picker
                      mode="date"
                      value={animalBirthDate}
                      onChange={(event) => setAnimalBirthDate(event.detail.value)}
                    >
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
                  <CapabilityButton
                    capability="write_hamster"
                    block
                    disabled={savingProfile}
                    onClick={() => void saveProfile()}
                  >
                    {savingProfile ? '保存中…' : '保存档案'}
                  </CapabilityButton>
                </Section>
              ) : null}
            </SectionList>
          </View>
        ) : null}
      </ScrollView>
    </View>
  )
}
