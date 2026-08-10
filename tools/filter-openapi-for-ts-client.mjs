#!/usr/bin/env node
/**
 * 为 TS 小程序客户端收窄 OpenAPI 输入面。
 *
 * 权威契约仍是 specs/api/openapi.yaml（全量，给 Go/Dart/漂移/文档）。
 * 本脚本从 apps/miniprogram-next 源码与测试扫描实际调用的 operationId，
 * 产出只含这些 operation + 可达 components 的子集，供 typescript-fetch 生成，
 * 避免 DefaultApi 等把未用端点整包打进小程序。
 *
 * 用法:
 *   node tools/filter-openapi-for-ts-client.mjs <in.json|in.yaml> <out.json>
 *   OPENAPI_TS_OPS_EXTRA=op1,op2  # 可选额外 operationId
 *   OPENAPI_TS_FULL=1             # 原样写出（不收窄）
 */
import fs from 'node:fs'
import path from 'node:path'
import { createRequire } from 'node:module'
import { fileURLToPath } from 'node:url'
import { spawnSync } from 'node:child_process'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const ROOT = path.resolve(__dirname, '..')
const MP_ROOT = path.join(ROOT, 'apps/miniprogram-next')

const HTTP_METHODS = new Set(['get', 'post', 'put', 'patch', 'delete', 'options', 'head', 'trace'])

const API_IDENT_RE =
  /\b(?:defaultApi|p1Api|p1CrmApi|p2Api|geneticApi|customerApi)\.([A-Za-z][A-Za-z0-9]*)/g
const SPY_RE =
  /spyOn\(\s*(?:defaultApi|p1Api|p1CrmApi|p2Api|geneticApi|customerApi)\s*,\s*['"]([A-Za-z][A-Za-z0-9]*)['"]/g
function walkFiles(dir, out = []) {
  if (!fs.existsSync(dir)) return out
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name === 'node_modules' || entry.name === 'dist' || entry.name.startsWith('.')) continue
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) walkFiles(full, out)
    else if (/\.(ts|tsx|js|mjs)$/.test(entry.name)) out.push(full)
  }
  return out
}

function scanUsedOperationIds() {
  const used = new Set()
  const roots = [path.join(MP_ROOT, 'src'), path.join(MP_ROOT, 'tests'), path.join(MP_ROOT, 'packages')]
  for (const root of roots) {
    for (const file of walkFiles(root)) {
      const text = fs.readFileSync(file, 'utf8')
      for (const re of [API_IDENT_RE, SPY_RE]) {
        re.lastIndex = 0
        let m
        while ((m = re.exec(text))) used.add(m[1])
      }
    }
  }
  const extra = String(process.env.OPENAPI_TS_OPS_EXTRA || '')
    .split(/[,\s]+/)
    .map((s) => s.trim())
    .filter(Boolean)
  for (const op of extra) used.add(op)

  // 手写 allowlist 可选：tools/mp-ts-client-operations.extra
  const extraFile = path.join(ROOT, 'tools/mp-ts-client-operations.extra')
  if (fs.existsSync(extraFile)) {
    for (const line of fs.readFileSync(extraFile, 'utf8').split('\n')) {
      const t = line.replace(/#.*$/, '').trim()
      if (t) used.add(t)
    }
  }
  return used
}

function loadDocument(inputPath) {
  const raw = fs.readFileSync(inputPath, 'utf8')
  if (/\.json$/i.test(inputPath)) return JSON.parse(raw)
  // YAML: prefer local yaml if present, else npx yaml CLI → JSON
  try {
    const require = createRequire(import.meta.url)
    const YAML = require('yaml')
    return YAML.parse(raw)
  } catch {
    /* fall through */
  }
  const res = spawnSync(
    'npx',
    ['--yes', 'yaml@2.7.1', '--json', '--single'],
    { input: raw, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 }
  )
  if (res.status !== 0) {
    throw new Error(`yaml parse failed: ${res.stderr || res.stdout || res.status}`)
  }
  return JSON.parse(res.stdout)
}

function collectRefs(node, into = new Set()) {
  if (!node || typeof node !== 'object') return into
  if (Array.isArray(node)) {
    for (const item of node) collectRefs(item, into)
    return into
  }
  if (typeof node.$ref === 'string' && node.$ref.startsWith('#/')) {
    into.add(node.$ref)
  }
  for (const value of Object.values(node)) collectRefs(value, into)
  return into
}

function refParts(ref) {
  // #/components/schemas/Foo
  const body = ref.replace(/^#\//, '')
  const parts = body.split('/')
  return parts
}

function resolveComponent(doc, ref) {
  const parts = refParts(ref)
  let cur = doc
  for (const p of parts) {
    if (!cur || typeof cur !== 'object') return undefined
    cur = cur[p]
  }
  return cur
}

function pruneComponents(doc, seedNodes) {
  const keep = new Set()
  const queue = []
  for (const node of seedNodes) {
    for (const ref of collectRefs(node)) queue.push(ref)
  }
  // security schemes always kept if present
  if (doc.components?.securitySchemes) {
    for (const name of Object.keys(doc.components.securitySchemes)) {
      keep.add(`#/components/securitySchemes/${name}`)
    }
  }
  while (queue.length) {
    const ref = queue.pop()
    if (keep.has(ref)) continue
    keep.add(ref)
    const target = resolveComponent(doc, ref)
    if (target) {
      for (const nested of collectRefs(target)) queue.push(nested)
    }
  }

  if (!doc.components) return
  for (const section of Object.keys(doc.components)) {
    const bag = doc.components[section]
    if (!bag || typeof bag !== 'object' || Array.isArray(bag)) continue
    for (const name of Object.keys(bag)) {
      const ref = `#/components/${section}/${name}`
      if (!keep.has(ref)) delete bag[name]
    }
    if (Object.keys(bag).length === 0) delete doc.components[section]
  }
}

function filterDocument(doc, usedOps) {
  if (process.env.OPENAPI_TS_FULL === '1') {
    return { doc, kept: [...usedOps], dropped: [], missing: [] }
  }

  const kept = []
  const dropped = []
  const present = new Set()

  const paths = doc.paths || {}
  for (const [p, item] of Object.entries(paths)) {
    if (!item || typeof item !== 'object') continue
    // path-level parameters / servers stay only if any method remains
    const pathLevel = {}
    for (const [k, v] of Object.entries(item)) {
      if (!HTTP_METHODS.has(k.toLowerCase())) pathLevel[k] = v
    }
    const next = { ...pathLevel }
    let methodsLeft = 0
    for (const [method, op] of Object.entries(item)) {
      if (!HTTP_METHODS.has(method.toLowerCase())) continue
      const oid = op?.operationId
      if (oid) present.add(oid)
      if (oid && usedOps.has(oid)) {
        next[method] = op
        methodsLeft++
        kept.push(oid)
      } else if (oid) {
        dropped.push(oid)
      } else {
        // 无 operationId 的操作：默认丢掉（TS 客户端用不到）
        dropped.push(`${method.toUpperCase()} ${p}`)
      }
    }
    if (methodsLeft === 0) delete paths[p]
    else paths[p] = next
  }

  const missing = [...usedOps].filter((op) => !present.has(op)).sort()

  // tags：只留仍被引用的
  if (Array.isArray(doc.tags)) {
    const usedTags = new Set()
    for (const item of Object.values(paths)) {
      for (const [method, op] of Object.entries(item || {})) {
        if (!HTTP_METHODS.has(method.toLowerCase())) continue
        for (const t of op.tags || []) usedTags.add(t)
      }
    }
    doc.tags = doc.tags.filter((t) => usedTags.has(t.name))
  }

  pruneComponents(doc, [
    paths,
    doc.security,
    ...(doc.tags || []),
    doc.components?.securitySchemes
  ])

  // 标注子集，避免误当全量契约
  doc.info = {
    ...(doc.info || {}),
    title: `${doc.info?.title || 'API'} (miniprogram TS client subset)`,
    description: [
      doc.info?.description || '',
      '',
      'NOTE: Filtered subset for apps/miniprogram-next typescript-fetch generation only.',
      'Authoritative full contract: specs/api/openapi.yaml',
      `Kept operationIds: ${kept.length}`
    ]
      .filter(Boolean)
      .join('\n')
  }

  return { doc, kept: kept.sort(), dropped: dropped.sort(), missing }
}

function main() {
  const [,, inputArg, outputArg] = process.argv
  if (!inputArg || !outputArg) {
    console.error('usage: node tools/filter-openapi-for-ts-client.mjs <in.yaml|in.json> <out.json>')
    process.exit(2)
  }
  const inputPath = path.resolve(inputArg)
  const outputPath = path.resolve(outputArg)
  const usedOps = scanUsedOperationIds()
  if (usedOps.size === 0 && process.env.OPENAPI_TS_FULL !== '1') {
    console.error('filter-openapi-for-ts-client: scanned 0 operations from miniprogram-next; refusing to emit empty client')
    process.exit(1)
  }

  const doc = loadDocument(inputPath)
  const { doc: filtered, kept, dropped, missing } = filterDocument(doc, usedOps)

  if (missing.length) {
    console.error(
      `filter-openapi-for-ts-client: ${missing.length} scanned method(s) not found as operationId in OpenAPI:\n  - ${missing.join('\n  - ')}`
    )
    process.exit(1)
  }

  fs.mkdirSync(path.dirname(outputPath), { recursive: true })
  fs.writeFileSync(outputPath, `${JSON.stringify(filtered, null, 2)}\n`)

  const schemaCount = Object.keys(filtered.components?.schemas || {}).length
  const pathCount = Object.keys(filtered.paths || {}).length
  console.log(
    `filter-openapi-for-ts-client: kept ${kept.length} ops, dropped ${dropped.length}, paths ${pathCount}, schemas ${schemaCount} → ${outputPath}`
  )
}

main()
