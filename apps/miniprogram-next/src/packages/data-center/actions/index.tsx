import { Input, ScrollView, Textarea, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Cell, FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { sha256 } from '../../../utils/sha256'

// SHA-256 implementation moved to src/utils/sha256.ts.
function readFile(path: string) {
  return new Promise<ArrayBuffer>((resolve, reject) => {
    Taro.getFileSystemManager().readFile({ filePath: path, success: (result) => resolve(result.data as ArrayBuffer), fail: reject })
  })
}

export default function DataCenterActionsPage() {
  const [templateType, setTemplateType] = useState('hamster')
  const [templateVersion, setTemplateVersion] = useState('1')
  const [importJobId, setImportJobId] = useState('')
  const [jobVersion, setJobVersion] = useState('0')
  const [batchKey, setBatchKey] = useState('')
  const [mappingText, setMappingText] = useState('')
  const [importRows, setImportRows] = useState<any[]>([])
  const [datasetText, setDatasetText] = useState('hamsters,enclosures,weights,health')
  const [exportJobs, setExportJobs] = useState<any[]>([])
  const [backupJobs, setBackupJobs] = useState<any[]>([])
  const [status, setStatus] = useState('支持从聊天选择 CSV，上传后按“映射 → 预检 → 提交”推进')
  const [busy, setBusy] = useState(false)

  function applyImportJob(job: any) {
    setJobVersion(String(job.version ?? 0))
    setBatchKey(job.result?.batchKey || job.result?.batch_key || '')
    if (job.mapping && typeof job.mapping === 'object') {
      setMappingText(Object.entries(job.mapping).map(([source, target]) => `${source}:${String(target)}:keep_null`).join('\n'))
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
      setStatus(cause instanceof Error ? cause.message : '数据中心任务读取失败')
    }
  }

  useEffect(() => { void refreshJobs() }, [])

  async function refreshImport() {
    if (!importJobId.trim()) { setStatus('请先填写导入任务 ID'); return }
    setBusy(true)
    try {
      const response = await defaultApi.getImportJob({ jobId: importJobId.trim() })
      const job: any = response.data
      applyImportJob(job)
      setStatus(`导入任务 ${job.id}：${job.phase || job.status || '处理中'}，进度 ${job.progressPercent ?? 0}%`)
    } catch (cause) { setStatus(cause instanceof Error ? cause.message : '导入任务读取失败') } finally { setBusy(false) }
  }

  async function saveMapping() {
    if (!importJobId.trim()) { setStatus('请先创建或填写导入任务 ID'); return }
    const mappings = mappingText.split('\n').map((line) => line.trim()).filter(Boolean).map((line) => {
      const [sourceColumn, targetField, emptyValuePolicy = 'keep_null', formatHint] = line.split(':').map((value) => value.trim())
      return { sourceColumn, targetField, emptyValuePolicy, formatHint: formatHint || null }
    }).filter((item) => item.sourceColumn && item.targetField)
    if (!mappings.length) { setStatus('请按“源列:目标字段:keep_null|use_default|reject_row”填写至少一条映射'); return }
    setBusy(true)
    try {
      const response = await defaultApi.setImportMapping({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: jobVersion,
        jobId: importJobId.trim(),
        importMappingRequest: { timezone: 'Asia/Taipei', mappings } as any
      })
      applyImportJob(response.data)
      setStatus(`字段映射已保存：${mappings.length} 列`)
    } catch (cause) { setStatus(cause instanceof Error ? cause.message : '字段映射保存失败') } finally { setBusy(false) }
  }

  async function loadImportRows() {
    if (!importJobId.trim()) { setStatus('请先填写导入任务 ID'); return }
    setBusy(true)
    try {
      const response = await defaultApi.listImportRowResults({ jobId: importJobId.trim(), limit: 50 })
      setImportRows(response.data || [])
      setStatus(`已读取 ${response.data?.length || 0} 行导入结果`)
    } catch (cause) { setStatus(cause instanceof Error ? cause.message : '逐行结果读取失败') } finally { setBusy(false) }
  }

  async function downloadRemoteFile(url: string, fileName: string) {
    await new Promise<void>((resolve, reject) => {
      Taro.downloadFile({
        url,
        success: (response) => {
          if (response.statusCode < 200 || response.statusCode >= 300) { reject(new Error(`文件下载失败（${response.statusCode}）`)); return }
          Taro.getFileSystemManager().saveFile({
            tempFilePath: response.tempFilePath,
            success: () => { setStatus(`${fileName} 已保存到微信文件管理`); resolve() },
            fail: reject
          })
        },
        fail: reject
      })
    })
  }

  async function downloadImportErrorReport() {
    if (!importJobId.trim()) { setStatus('请先填写导入任务 ID'); return }
    setBusy(true)
    try {
      const response = await defaultApi.getImportErrorReport({ jobId: importJobId.trim() })
      await downloadRemoteFile(response.data.downloadUrl, response.data.fileName || 'import-error-report.csv')
    } catch (cause) { setStatus(cause instanceof Error ? cause.message : '错误报告下载失败') } finally { setBusy(false) }
  }

  async function retryImport() {
    if (!importJobId.trim()) { setStatus('请先填写导入任务 ID'); return }
    setBusy(true)
    try {
      const response = await defaultApi.retryImportJob({ idempotencyKey: newIdempotencyKey(), ifMatch: jobVersion, jobId: importJobId.trim(), retryImportRequest: { scope: 'all_failed_rows' } as any })
      applyImportJob(response.data)
      setStatus('失败行已重新排队')
    } catch (cause) { setStatus(cause instanceof Error ? cause.message : '导入重试失败') } finally { setBusy(false) }
  }

  async function handleJob(job: any, kind: 'export' | 'backup') {
    const id = String(job.id || '')
    if (!id) return
    setBusy(true)
    try {
      if (job.status === 'succeeded') {
        const response = kind === 'export' ? await defaultApi.getExportDownload({ jobId: id }) : await defaultApi.getBackupDownload({ jobId: id })
        await downloadRemoteFile(response.data.downloadUrl, response.data.fileName || `${kind}-${id}`)
      } else if (job.retryable) {
        if (kind === 'export') await defaultApi.retryExportJob({ idempotencyKey: newIdempotencyKey(), ifMatch: String(job.version ?? 0), jobId: id, retryJobRequest: { reason: '小程序端重试' } })
        else await defaultApi.retryBackupJob({ idempotencyKey: newIdempotencyKey(), ifMatch: String(job.version ?? 0), jobId: id, retryJobRequest: { reason: '小程序端重试' } })
        setStatus(`${kind === 'export' ? '导出' : '备份'}任务已重新排队`)
        await refreshJobs()
      } else setStatus(`${kind === 'export' ? '导出' : '备份'}任务当前状态：${job.status || '未知'}`)
    } catch (cause) { setStatus(cause instanceof Error ? cause.message : '任务操作失败') } finally { setBusy(false) }
  }

  async function chooseAndUpload() {
    setBusy(true)
    try {
      const result = await Taro.chooseMessageFile({ count: 1, type: 'file', extension: ['csv'] })
      const file = result.tempFiles[0]
      if (!file) return
      const content = await readFile(file.path)
      const digest = sha256(content)
      const uploadResponse = await defaultApi.createImportUpload({ idempotencyKey: newIdempotencyKey(), importUploadCreateRequest: { fileName: file.name, sizeBytes: file.size, sha256: digest } })
      const session: any = uploadResponse.data
      const upload = await Taro.request({ url: session.uploadUrl, method: session.method || 'PUT', data: content, header: session.headers || {} })
      if (upload.statusCode < 200 || upload.statusCode >= 300) throw new Error(`文件上传失败（${upload.statusCode}）`)
      const jobResponse = await defaultApi.createImportJob({ idempotencyKey: newIdempotencyKey(), importJobCreateRequest: { uploadId: session.id, templateType, templateVersion, sourceEncoding: 'utf-8', timezone: 'Asia/Taipei' } as any })
      const job: any = jobResponse.data
      setImportJobId(job.id)
      applyImportJob(job)
      setStatus(`文件已上传，导入任务 ${job.id} 已创建；当前阶段 ${job.phase || 'detecting'}`)
    } catch (cause) {
      setStatus(cause instanceof Error ? cause.message : 'CSV 上传失败')
    } finally {
      setBusy(false)
    }
  }

  async function preflight() {
    if (!importJobId) { setStatus('请先选择 CSV 并创建导入任务'); return }
    setBusy(true)
    try {
      const response = await defaultApi.preflightImportJob({ idempotencyKey: newIdempotencyKey(), ifMatch: jobVersion, jobId: importJobId, importPreflightRequest: { strictReferences: true, duplicatePolicy: 'reject', historicalLitterPolicy: 'create_if_complete', parentageConflictPolicy: 'reject', existingFieldPolicy: 'preserve_non_null' } as any })
      const job: any = response.data
      applyImportJob(job)
      setStatus(`预检完成：有效 ${job.validRows ?? 0} 行，警告 ${job.warningRows ?? 0} 行，错误 ${job.invalidRows ?? 0} 行`)
    } catch (cause) { setStatus(cause instanceof Error ? cause.message : 'CSV 预检失败') } finally { setBusy(false) }
  }

  async function commit() {
    if (!importJobId || !batchKey) { setStatus('预检返回 batch key 后才可提交'); return }
    setBusy(true)
    try {
      const response = await defaultApi.commitImportJob({ idempotencyKey: newIdempotencyKey(), ifMatch: jobVersion, jobId: importJobId, importCommitRequest: { preflightVersion: Number(jobVersion), batchKey, partialFailurePolicy: 'continue_and_report' } as any })
      const job: any = response.data
      applyImportJob(job)
      setStatus(`导入提交完成：已导入 ${job.importedRows ?? 0} 行`)
    } catch (cause) { setStatus(cause instanceof Error ? cause.message : 'CSV 提交失败') } finally { setBusy(false) }
  }

  async function exportData() {
    setBusy(true)
    try {
      const datasets = new Set(datasetText.split(',').map((item) => item.trim()).filter(Boolean))
      const response = await defaultApi.createExportJob({ idempotencyKey: newIdempotencyKey(), exportJobCreateRequest: { datasets, format: 'csv_zip', timezone: 'Asia/Taipei' } as any })
      setStatus(`导出任务 ${String((response.data as any)?.id || '')} 已创建，可在数据中心查看状态`)
      await refreshJobs()
    } catch (cause) { setStatus(cause instanceof Error ? cause.message : '导出任务创建失败') } finally { setBusy(false) }
  }

  async function backup() {
    setBusy(true)
    try {
      const response = await defaultApi.createBackupJob({ idempotencyKey: newIdempotencyKey(), backupJobCreateRequest: { includeMediaManifest: true, includeChecksums: true, timezone: 'Asia/Taipei' } as any })
      setStatus(`备份任务 ${String((response.data as any)?.id || '')} 已创建`)
      await refreshJobs()
    } catch (cause) { setStatus(cause instanceof Error ? cause.message : '备份任务创建失败') } finally { setBusy(false) }
  }

  return <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: crayon.paper, backgroundImage: paperGrain }}><NavBar title="数据中心操作" back right={<Tag tone="accent">M4</Tag>} /><ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}><SectionList>
    <Section header="CSV 导入" footer={status}>
      <FormRow label="模板类型"><Input value={templateType} placeholder="hamster / enclosure / weight" onInput={(event) => setTemplateType(event.detail.value)} /></FormRow>
      <FormRow label="模板版本" divider><Input value={templateVersion} onInput={(event) => setTemplateVersion(event.detail.value)} /></FormRow>
      <CapabilityButton capability="write_import" block disabled={busy} onClick={() => void chooseAndUpload()}>从聊天选择 CSV 并上传</CapabilityButton>
      <FormRow label="导入任务 ID" divider><Input value={importJobId} placeholder="上传后自动填写" onInput={(event) => setImportJobId(event.detail.value)} /></FormRow>
      <FormRow label="任务版本" divider><Input value={jobVersion} onInput={(event) => setJobVersion(event.detail.value)} /></FormRow>
      <CapabilityButton capability="read_data_center" block variant="outlined" disabled={busy} onClick={() => void refreshImport()}>刷新导入任务</CapabilityButton>
      <FormRow label="字段映射" divider><Textarea value={mappingText} placeholder="源列:目标字段:keep_null\n例如：编号:internal_code:reject_row" onInput={(event) => setMappingText(event.detail.value)} style={{ minHeight: '120px', width: '100%' }} /></FormRow>
      <CapabilityButton capability="write_import" block disabled={busy} onClick={() => void saveMapping()}>保存字段映射</CapabilityButton>
      <FormRow label="Batch Key" divider><Input value={batchKey} placeholder="预检返回后自动填写" onInput={(event) => setBatchKey(event.detail.value)} /></FormRow>
      <CapabilityButton capability="write_import" block variant="outlined" disabled={busy} onClick={() => void preflight()}>执行全量预检</CapabilityButton>
      <CapabilityButton capability="write_import" block disabled={busy} onClick={() => void commit()}>提交导入</CapabilityButton>
      <CapabilityButton capability="read_data_center" block variant="outlined" disabled={busy} onClick={() => void loadImportRows()}>查看逐行结果</CapabilityButton>
      {importRows.slice(0, 20).map((row) => <Cell key={row.rowNumber} title={`第 ${row.rowNumber} 行`} subtitle={(row.issues || []).map((issue: any) => issue.message || issue.code).join('；') || '无错误'} value={<Tag tone={row.status === 'imported' || row.status === 'valid' ? 'success' : row.status === 'invalid' ? 'danger' : 'warning'}>{row.status}</Tag>} />)}
      <CapabilityButton capability="read_data_center" block variant="outlined" disabled={busy || !importJobId} onClick={() => void downloadImportErrorReport()}>下载错误报告</CapabilityButton>
      <CapabilityButton capability="write_import" block variant="outlined" disabled={busy || !importJobId} onClick={() => void retryImport()}>重试失败行</CapabilityButton>
    </Section>
    <Section header="导出与备份" footer="点击已完成任务下载；失败任务点击重试">
      <FormRow label="导出数据集"><Input value={datasetText} onInput={(event) => setDatasetText(event.detail.value)} /></FormRow>
      <CapabilityButton capability="write_import" block disabled={busy} onClick={() => void exportData()}>创建 CSV 导出任务</CapabilityButton>
      <CapabilityButton capability="write_import" block variant="outlined" disabled={busy} onClick={() => void backup()}>创建备份任务</CapabilityButton>
      <CapabilityButton capability="read_data_center" block variant="outlined" disabled={busy} onClick={() => void refreshJobs()}>刷新导出 / 备份任务</CapabilityButton>
      {exportJobs.map((job) => <Cell key={`export-${job.id}`} title={`导出 ${job.id}`} subtitle={`${job.progressPercent ?? 0}% · ${job.fileName || '未生成文件'}`} value={<Tag tone={job.status === 'succeeded' ? 'success' : job.status === 'failed' ? 'danger' : 'warning'}>{job.status}</Tag>} onClick={() => void handleJob(job, 'export')} />)}
      {backupJobs.map((job) => <Cell key={`backup-${job.id}`} title={`备份 ${job.id}`} subtitle={`${job.progressPercent ?? 0}% · ${job.integrityStatus || '校验中'}`} value={<Tag tone={job.status === 'succeeded' ? 'success' : job.status === 'failed' ? 'danger' : 'warning'}>{job.status}</Tag>} onClick={() => void handleJob(job, 'backup')} />)}
    </Section>
    <Section header="当前任务"><Cell title="导入任务" subtitle={importJobId || '尚未创建'} value={<Tag tone={importJobId ? 'success' : 'warning'}>{importJobId ? '已创建' : '待开始'}</Tag>} /></Section>
    <View style={{ height: `${metrics.bottomSafePadding}px` }} />
  </SectionList></ScrollView></View>
  }
