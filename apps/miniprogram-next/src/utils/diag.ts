// 真机诊断：把最近几步登录/请求结果写进 storage，页面可一键复制。
import Taro from '@tarojs/taro'
import { storageGet, storageSet } from './storage'
import config from './config'

const KEY = 'scolvpet_diag_log'
const MAX = 40

export type DiagLine = { t: number; msg: string }

export function diag(msg: string) {
  try {
    const prev = (storageGet(KEY) as DiagLine[] | undefined) || []
    const next = [...prev, { t: Date.now(), msg: String(msg).slice(0, 500) }].slice(-MAX)
    storageSet(KEY, next)
    // 开发构建：控制台也能看到
    if ((config as { APP_ENV?: string }).APP_ENV === 'development') {
      // eslint-disable-next-line no-console
      console.info('[scolv-diag]', msg)
    }
  } catch {
    // ignore
  }
}

export function readDiag(): DiagLine[] {
  return ((storageGet(KEY) as DiagLine[] | undefined) || []).slice()
}

export function formatDiagText(): string {
  const api = String((config as { API_BASE?: string }).API_BASE || '')
  const env = String((config as { APP_ENV?: string }).APP_ENV || '')
  const lines = readDiag()
  const body = lines
    .map((l) => {
      const ts = new Date(l.t).toISOString().slice(11, 19)
      return `${ts} ${l.msg}`
    })
    .join('\n')
  return `API=${api}\nENV=${env}\n---\n${body || '(暂无日志)'}`
}

export async function copyDiag(): Promise<boolean> {
  const text = formatDiagText()
  try {
    await Taro.setClipboardData({ data: text })
    return true
  } catch {
    return false
  }
}
