import { Input, Picker, ScrollView, Textarea, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Cell, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { humanShortLabel } from '../../../utils/tab-routes'
import { sha256 } from '../../../utils/sha256'
import { formatUserError } from '../../../api/errors'

const TEMPLATE_OPTIONS = [
  { value: 'hamster', label: '个体档案' },
  { value: 'enclosure', label: '笼舍' },
  { value: 'weight', label: '体重记录' }
]

const DATASET_OPTIONS = [
  { value: 'hamsters', label: '个体' },
  { value: 'enclosures', label: '笼舍' },
  { value: 'weights', label: '体重' },
  { value: 'health', label: '健康' }
]

function readFile(path: string) {
  return new Promise<ArrayBuffer>((resolve, reject) => {
    Taro.getFileSystemManager().readFile({
      filePath: path,
      success: (result) => resolve(result.data as ArrayBuffer),
      fail: reject
    })
  })
}

function jobStatusLabel(raw: unknown) {
  return humanShortLabel(raw) || String(raw || '处理中')
}

export default function DataCenterActionsPage() {
  const [templateType, setTemplateType] = useState('hamster')
  const [templateVersion] = useState('1')
  const [importJobId, setImportJobId] = useState('')
  const [jobVersion, setJobVersion] = useState('0')
  const [batchKey, setBatchKey] = useState('')
  const [mappingText, setMappingText] = useState('')
  const [importRows, setImportRows] = useState<any[]>([])
  const [selectedDatasets, setSelectedDatasets] = useState<string[]>(['hamsters', 'enclosures', 'weights', 'health'])
  const [exportJobs, setExportJobs] = useState<any[]>([])
  const [backupJobs, setBackupJobs] = useState<any[]>([])
  const [status, setStatus] = useState('选好导入类型后，从聊天选 CSV，再按「预检 → 提交」')
  const [busy, setBusy] = useState(false)
  const [showAdvanced, setShowAdvanced] = useState(false)

  function applyImportJob(job: any) {
    setJobVersion(String(job.version ?? 0))
    setBatchKey(job.result?.batchKey || job.result?.batch_key || '')
    if (job.mapping && typeof job.mapping === 'object') {
      setMappingText(
        Object.entries(job.mapping)
          .map(([source, target]) => `${source}:${String(target)}:keep_null`)
          .join('\n')
      )
    }
  }

  async function refreshJobs() {
    try {
      const [exportsResponse, backupsResponse] = await Promise.all([
        defaultApi.listExportJobs({ limit: 20 }),
        defaultApi.listBackupJobs({ limit: 20 })
      ])
      setExportJobs(exportsResponse.data || [])
      setBackupJobs(backupsResponse.data || [])
    } catch (cause) {
      setStatus(await formatUserError(cause, '任务列表读取失败'))
    }
  }

  useEffect(() => {
    void refreshJobs()
  }, [])

  async function refreshImport() {
    if (!importJobId.trim()) {
      setStatus('还没有导入任务，请先上传 CSV')
      return
    }
    setBusy(true)
    try {
      const response = await defaultApi.getImportJob({ jobId: importJobId.trim() })
      const job: any = response.data
      applyImportJob(job)
      setStatus(
        `导入进度 ${job.progressPercent ?? 0}% · ${jobStatusLabel(job.phase || job.status)}`
      )
    } catch (cause) {
      setStatus(await formatUserError(cause, '导入任务读取失败'))
    } finally {
      setBusy(false)
    }
  }

  async function saveMapping() {
    if (!importJobId.trim()) {
      setStatus('请先上传 CSV 创建导入任务')
      return
    }
    const mappings = mappingText
      .split('\n')
      .map((line) => line.trim())
      .filter(Boolean)
      .map((line) => {
        const [sourceColumn, targetField, emptyValuePolicy = 'keep_null', formatHint] = line
          .split(':')
          .map((value) => value.trim())
        return { sourceColumn, targetField, emptyValuePolicy, formatHint: formatHint || null }
      })
      .filter((item) => item.sourceColumn && item.targetField)
    if (!mappings.length) {
      setStatus('高级映射至少填一行：源列:目标字段')
      return
    }
    setBusy(true)
    try {
      const response = await defaultApi.setImportMapping({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: jobVersion,
        jobId: importJobId.trim(),
        importMappingRequest: { timezone: 'Asia/Taipei', mappings } as any
      })
      applyImportJob(response.data)
      setStatus(`字段对应已保存：${mappings.length} 列`)
    } catch (cause) {
      setStatus(await formatUserError(cause, '字段对应保存失败'))
    } finally {
      setBusy(false)
    }
  }

  async function loadImportRows() {
    if (!importJobId.trim()) {
      setStatus('还没有导入任务')
      return
    }
    setBusy(true)
    try {
      const response = await defaultApi.listImportRowResults({ jobId: importJobId.trim(), limit: 50 })
      setImportRows(response.data || [])
      setStatus(`已读取 ${response.data?.length || 0} 行结果`)
    } catch (cause) {
      setStatus(await formatUserError(cause, '逐行结果读取失败'))
    } finally {
      setBusy(false)
    }
  }

  async function downloadRemoteFile(url: string, fileName: string) {
    await new Promise<void>((resolve, reject) => {
      Taro.downloadFile({
        url,
        success: (response) => {
          if (response.statusCode < 200 || response.statusCode >= 300) {
            reject(new Error(`文件下载失败（${response.statusCode}）`))
            return
          }
          Taro.getFileSystemManager().saveFile({
            tempFilePath: response.tempFilePath,
            success: () => {
              setStatus(`${fileName} 已保存到微信文件`)
              resolve()
            },
            fail: reject
          })
        },
        fail: reject
      })
    })
  }

  async function downloadImportErrorReport() {
    if (!importJobId.trim()) {
      setStatus('还没有导入任务')
      return
    }
    setBusy(true)
    try {
      const response = await defaultApi.getImportErrorReport({ jobId: importJobId.trim() })
      await downloadRemoteFile(response.data.downloadUrl, response.data.fileName || 'import-error-report.csv')
    } catch (cause) {
      setStatus(await formatUserError(cause, '错误报告下载失败'))
    } finally {
      setBusy(false)
    }
  }

  async function retryImport() {
    if (!importJobId.trim()) {
      setStatus('还没有导入任务')
      return
    }
    setBusy(true)
    try {
      const response = await defaultApi.retryImportJob({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: jobVersion,
        jobId: importJobId.trim(),
        retryImportRequest: { scope: 'all_failed_rows' } as any
      })
      applyImportJob(response.data)
      setStatus('失败行已重新排队')
    } catch (cause) {
      setStatus(await formatUserError(cause, '重试失败'))
    } finally {
      setBusy(false)
    }
  }

  async function handleJob(job: any, kind: 'export' | 'backup') {
    const id = String(job.id || '')
    if (!id) return
    setBusy(true)
    try {
      if (job.status === 'succeeded') {
        const response =
          kind === 'export'
            ? await defaultApi.getExportDownload({ jobId: id })
            : await defaultApi.getBackupDownload({ jobId: id })
        await downloadRemoteFile(response.data.downloadUrl, response.data.fileName || `${kind}-${id}`)
      } else if (job.retryable) {
        if (kind === 'export') {
          await defaultApi.retryExportJob({
            idempotencyKey: newIdempotencyKey(),
            ifMatch: String(job.version ?? 0),
            jobId: id,
            retryJobRequest: { reason: '小程序端重试' }
          })
        } else {
          await defaultApi.retryBackupJob({
            idempotencyKey: newIdempotencyKey(),
            ifMatch: String(job.version ?? 0),
            jobId: id,
            retryJobRequest: { reason: '小程序端重试' }
          })
        }
        setStatus(`${kind === 'export' ? '导出' : '备份'}已重新排队`)
        await refreshJobs()
      } else {
        setStatus(`${kind === 'export' ? '导出' : '备份'}当前：${jobStatusLabel(job.status)}`)
      }
    } catch (cause) {
      setStatus(await formatUserError(cause, '任务操作失败'))
    } finally {
      setBusy(false)
    }
  }

  async function chooseAndUpload() {
    setBusy(true)
    try {
      const result = await Taro.chooseMessageFile({ count: 1, type: 'file', extension: ['csv'] })
      const file = result.tempFiles[0]
      if (!file) return
      const content = await readFile(file.path)
      const digest = sha256(content)
      const uploadResponse = await defaultApi.createImportUpload({
        idempotencyKey: newIdempotencyKey(),
        importUploadCreateRequest: { fileName: file.name, sizeBytes: file.size, sha256: digest }
      })
      const session: any = uploadResponse.data
      const upload = await Taro.request({
        url: session.uploadUrl,
        method: session.method || 'PUT',
        data: content,
        header: session.headers || {}
      })
      if (upload.statusCode < 200 || upload.statusCode >= 300) {
        throw new Error(`文件上传失败（${upload.statusCode}）`)
      }
      const jobResponse = await defaultApi.createImportJob({
        idempotencyKey: newIdempotencyKey(),
        importJobCreateRequest: {
          uploadId: session.id,
          templateType,
          templateVersion,
          sourceEncoding: 'utf-8',
          timezone: 'Asia/Taipei'
        } as any
      })
      const job: any = jobResponse.data
      setImportJobId(job.id)
      applyImportJob(job)
      setStatus(`已上传，正在准备导入 · ${jobStatusLabel(job.phase || 'detecting')}`)
    } catch (cause) {
      setStatus(await formatUserError(cause, 'CSV 上传失败'))
    } finally {
      setBusy(false)
    }
  }

  async function preflight() {
    if (!importJobId) {
      setStatus('请先选择 CSV 并上传')
      return
    }
    setBusy(true)
    try {
      const response = await defaultApi.preflightImportJob({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: jobVersion,
        jobId: importJobId,
        importPreflightRequest: {
          strictReferences: true,
          duplicatePolicy: 'reject',
          historicalLitterPolicy: 'create_if_complete',
          parentageConflictPolicy: 'reject',
          existingFieldPolicy: 'preserve_non_null'
        } as any
      })
      const job: any = response.data
      applyImportJob(job)
      setStatus(
        `预检完成：有效 ${job.validRows ?? 0} 行，警告 ${job.warningRows ?? 0} 行，错误 ${job.invalidRows ?? 0} 行`
      )
    } catch (cause) {
      setStatus(await formatUserError(cause, '预检失败'))
    } finally {
      setBusy(false)
    }
  }

  async function commit() {
    if (!importJobId) {
      setStatus('请先上传并预检')
      return
    }
    if (!batchKey) {
      setStatus('请先完成预检，再提交导入')
      return
    }
    setBusy(true)
    try {
      const response = await defaultApi.commitImportJob({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: jobVersion,
        jobId: importJobId,
        importCommitRequest: {
          preflightVersion: Number(jobVersion),
          batchKey,
          partialFailurePolicy: 'continue_and_report'
        } as any
      })
      const job: any = response.data
      applyImportJob(job)
      setStatus(`导入完成：已写入 ${job.importedRows ?? 0} 行`)
    } catch (cause) {
      setStatus(await formatUserError(cause, '提交导入失败'))
    } finally {
      setBusy(false)
    }
  }

  async function exportData() {
    if (!selectedDatasets.length) {
      setStatus('请至少选一类要导出的数据')
      return
    }
    setBusy(true)
    try {
      const response = await defaultApi.createExportJob({
        idempotencyKey: newIdempotencyKey(),
        exportJobCreateRequest: {
          datasets: new Set(selectedDatasets),
          format: 'csv_zip',
          timezone: 'Asia/Taipei'
        } as any
      })
      setStatus(`导出任务已创建，完成后点列表下载`)
      void response
      await refreshJobs()
    } catch (cause) {
      setStatus(await formatUserError(cause, '导出创建失败'))
    } finally {
      setBusy(false)
    }
  }

  async function backup() {
    setBusy(true)
    try {
      await defaultApi.createBackupJob({
        idempotencyKey: newIdempotencyKey(),
        backupJobCreateRequest: {
          includeMediaManifest: true,
          includeChecksums: true,
          timezone: 'Asia/Taipei'
        } as any
      })
      setStatus('备份任务已创建，完成后点列表下载')
      await refreshJobs()
    } catch (cause) {
      setStatus(await formatUserError(cause, '备份创建失败'))
    } finally {
      setBusy(false)
    }
  }

  function toggleDataset(value: string) {
    setSelectedDatasets((prev) =>
      prev.includes(value) ? prev.filter((item) => item !== value) : [...prev, value]
    )
  }

  const templateIndex = Math.max(
    0,
    TEMPLATE_OPTIONS.findIndex((item) => item.value === templateType)
  )
  const templateLabel = TEMPLATE_OPTIONS[templateIndex]?.label || '个体档案'
  const canCommit = Boolean(importJobId && batchKey)

  return (
    <View
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: palette.systemBackground
      }}
    >
      <NavBar title="导入 / 导出 / 备份" back />
      <ScrollView
        scrollY
        type="list"
        bounces
        enhanced
        showScrollbar={false}
        style={{ flex: 1 }}
      >
        <SectionList>
          <Section header="导入 CSV" footer={status}>
            <FormRow label="导入类型">
              <Picker
                mode="selector"
                range={TEMPLATE_OPTIONS.map((item) => item.label)}
                value={templateIndex}
                onChange={(event) =>
                  setTemplateType(TEMPLATE_OPTIONS[Number(event.detail.value)]?.value || 'hamster')
                }
              >
                <Cell title={templateLabel} value={<Tag>选择</Tag>} />
              </Picker>
            </FormRow>
            <CapabilityButton
              capability="write_import"
              block
              disabled={busy}
              onClick={() => void chooseAndUpload()}
            >
              从聊天选择 CSV 并上传
            </CapabilityButton>
            <CapabilityButton
              capability="write_import"
              block
              variant="outlined"
              disabled={busy || !importJobId}
              onClick={() => void preflight()}
            >
              检查数据（预检）
            </CapabilityButton>
            <CapabilityButton
              capability="write_import"
              block
              disabled={busy || !canCommit}
              onClick={() => void commit()}
            >
              {canCommit ? '确认导入' : '预检通过后可导入'}
            </CapabilityButton>
            <CapabilityButton
              capability="read_data_center"
              block
              variant="outlined"
              disabled={busy || !importJobId}
              onClick={() => void refreshImport()}
            >
              刷新导入进度
            </CapabilityButton>
            <Cell
              title={importJobId ? '当前导入任务' : '还没有导入任务'}
              subtitle={importJobId ? '上传后自动生成，一般不用改' : '先选类型再上传 CSV'}
              value={
                <Tag tone={importJobId ? 'success' : 'warning'}>
                  {importJobId ? '已创建' : '待开始'}
                </Tag>
              }
            />
          </Section>

          <Section header="高级选项（一般不用）" footer="映射、任务号、批量键等给排障用">
            <Cell
              title={showAdvanced ? '收起高级选项' : '展开高级选项'}
              subtitle={showAdvanced ? '点此收起' : '字段对应、任务号、错误报告'}
              value={<Tag tone={showAdvanced ? 'accent' : 'warning'}>{showAdvanced ? '已展开' : '折叠中'}</Tag>}
              onClick={() => setShowAdvanced((v) => !v)}
            />
            {showAdvanced ? (
              <>
                <FormRow label="导入任务号" divider>
                  <Input
                    value={importJobId}
                    placeholder="一般自动填写"
                    placeholderStyle={`color: ${palette.tertiaryLabel}`}
                    onInput={(event) => setImportJobId(event.detail.value)}
                    style={{ color: '#FFFFFF' }}
                  />
                </FormRow>
                <FormRow label="任务版本" divider>
                  <Input
                    value={jobVersion}
                    placeholderStyle={`color: ${palette.tertiaryLabel}`}
                    onInput={(event) => setJobVersion(event.detail.value)}
                    style={{ color: '#FFFFFF' }}
                  />
                </FormRow>
                <FormRow label="字段对应" divider>
                  <Textarea
                    value={mappingText}
                    placeholder={'源列:目标字段:keep_null\n例如：编号:internal_code:reject_row'}
                    placeholderStyle={`color: ${palette.tertiaryLabel}`}
                    onInput={(event) => setMappingText(event.detail.value)}
                    style={{ minHeight: '120px', width: '100%', color: '#FFFFFF' }}
                  />
                </FormRow>
                <CapabilityButton
                  capability="write_import"
                  block
                  disabled={busy}
                  onClick={() => void saveMapping()}
                >
                  保存字段对应
                </CapabilityButton>
                <FormRow label="预检批次号" divider>
                  <Input
                    value={batchKey}
                    placeholder="预检成功后自动填写"
                    placeholderStyle={`color: ${palette.tertiaryLabel}`}
                    onInput={(event) => setBatchKey(event.detail.value)}
                    style={{ color: '#FFFFFF' }}
                  />
                </FormRow>
                <CapabilityButton
                  capability="read_data_center"
                  block
                  variant="outlined"
                  disabled={busy || !importJobId}
                  onClick={() => void loadImportRows()}
                >
                  查看逐行结果
                </CapabilityButton>
                {importRows.slice(0, 20).map((row) => (
                  <Cell
                    key={row.rowNumber}
                    title={`第 ${row.rowNumber} 行`}
                    subtitle={
                      (row.issues || []).map((issue: any) => issue.message || issue.code).join('；') ||
                      '无错误'
                    }
                    value={
                      <Tag
                        tone={
                          row.status === 'imported' || row.status === 'valid'
                            ? 'success'
                            : row.status === 'invalid'
                              ? 'danger'
                              : 'warning'
                        }
                      >
                        {jobStatusLabel(row.status)}
                      </Tag>
                    }
                  />
                ))}
                <CapabilityButton
                  capability="read_data_center"
                  block
                  variant="outlined"
                  disabled={busy || !importJobId}
                  onClick={() => void downloadImportErrorReport()}
                >
                  下载错误报告
                </CapabilityButton>
                <CapabilityButton
                  capability="write_import"
                  block
                  variant="outlined"
                  disabled={busy || !importJobId}
                  onClick={() => void retryImport()}
                >
                  重试失败行
                </CapabilityButton>
              </>
            ) : null}
          </Section>

          <Section header="导出与备份" footer="点已完成的任务可下载；失败可重试">
            <FormRow label="导出内容">
              <View>
                {DATASET_OPTIONS.map((item) => {
                  const on = selectedDatasets.includes(item.value)
                  return (
                    <Cell
                      key={item.value}
                      title={item.label}
                      value={<Tag tone={on ? 'success' : 'warning'}>{on ? '已选' : '未选'}</Tag>}
                      onClick={() => toggleDataset(item.value)}
                    />
                  )
                })}
              </View>
            </FormRow>
            <CapabilityButton
              capability="write_import"
              block
              disabled={busy}
              onClick={() => void exportData()}
            >
              创建导出
            </CapabilityButton>
            <CapabilityButton
              capability="write_import"
              block
              variant="outlined"
              disabled={busy}
              onClick={() => void backup()}
            >
              创建备份
            </CapabilityButton>
            <CapabilityButton
              capability="read_data_center"
              block
              variant="outlined"
              disabled={busy}
              onClick={() => void refreshJobs()}
            >
              刷新任务列表
            </CapabilityButton>
            {exportJobs.map((job) => (
              <Cell
                key={`export-${job.id}`}
                title="导出任务"
                subtitle={`${job.progressPercent ?? 0}% · ${job.fileName || '文件生成中'}`}
                value={
                  <Tag
                    tone={
                      job.status === 'succeeded' ? 'success' : job.status === 'failed' ? 'danger' : 'warning'
                    }
                  >
                    {jobStatusLabel(job.status)}
                  </Tag>
                }
                onClick={() => void handleJob(job, 'export')}
              />
            ))}
            {backupJobs.map((job) => (
              <Cell
                key={`backup-${job.id}`}
                title="备份任务"
                subtitle={`${job.progressPercent ?? 0}% · ${job.integrityStatus || '校验中'}`}
                value={
                  <Tag
                    tone={
                      job.status === 'succeeded' ? 'success' : job.status === 'failed' ? 'danger' : 'warning'
                    }
                  >
                    {jobStatusLabel(job.status)}
                  </Tag>
                }
                onClick={() => void handleJob(job, 'backup')}
              />
            ))}
          </Section>

          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>
      </ScrollView>
    </View>
  )
}
