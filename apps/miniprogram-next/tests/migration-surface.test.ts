import fs from 'node:fs'
import path from 'node:path'
import { describe, expect, it } from 'vitest'

type Surface = { route: string; source: string; needsWriteGate?: boolean }

const projectRoot = path.resolve(__dirname, '..')
const appConfig = fs.readFileSync(path.join(projectRoot, 'src/app.config.ts'), 'utf8')
const generatedApi = /defaultApi|p1Api|p1CrmApi|p2Api|geneticApi/
const permissionOrAction = /CapabilityButton|actionCapability|canUseCapability|readBreederSession/
const staleSampleMarker = /TODO|FIXME|假数据|样例页/
const directRequestMarker = /\b(?:Taro|wx)\.request\s*\(/
const directRequestAllowlist = [
  'src/api/taro-fetch.ts',
  // 开发真机：登录前探测 API 是否可达（域名/证书），必须用裸 request 才能看到微信 errMsg
  'src/auth/dev-session.ts',
  'src/packages/animals/detail/index.tsx',
  'src/packages/data-center/actions/index.tsx'
]

function sourceFiles(directory: string): string[] {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const entryPath = path.join(directory, entry.name)
    if (entry.isDirectory()) return sourceFiles(entryPath)
    return /\.tsx?$/.test(entry.name) ? [entryPath] : []
  })
}

function withoutComments(source: string): string {
  return source.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/.*$/gm, '')
}

function isRouteRegistered(route: string) {
  if (route.startsWith('pages/')) return appConfig.includes(`'${route}'`)
  const parts = route.split('/')
  const root = parts.slice(0, 2).join('/')
  const page = parts.slice(2).join('/')
  return appConfig.includes(`root: '${root}'`) && appConfig.includes(`'${page}'`)
}

const surfaces: Record<string, Surface[]> = {
  M1: [
    { route: 'pages/login/index', source: 'src/pages/login/index.tsx' },
    { route: 'pages/today/index', source: 'src/pages/today/index.tsx', needsWriteGate: true },
    { route: 'packages/animals/index/index', source: 'src/packages/animals/index/index.tsx', needsWriteGate: true },
    { route: 'packages/animals/detail/index', source: 'src/packages/animals/detail/index.tsx', needsWriteGate: true }
  ],
  M2: [
    { route: 'packages/animals/create/index', source: 'src/packages/animals/create/index.tsx', needsWriteGate: true },
    { route: 'packages/animals/batch-create/index', source: 'src/packages/animals/batch-create/index.tsx', needsWriteGate: true },
    { route: 'packages/litters/index/index', source: 'src/packages/litters/index/index.tsx' },
    { route: 'packages/litters/detail/index', source: 'src/packages/litters/detail/index.tsx', needsWriteGate: true },
    { route: 'packages/breeding/index/index', source: 'src/packages/breeding/index/index.tsx', needsWriteGate: true },
    { route: 'packages/breeding/create/index', source: 'src/packages/breeding/create/index.tsx', needsWriteGate: true },
    { route: 'packages/breeding/detail/index', source: 'src/packages/breeding/detail/index.tsx', needsWriteGate: true },
    { route: 'packages/reminders/index/index', source: 'src/packages/reminders/index/index.tsx', needsWriteGate: true },
    { route: 'packages/reminders/create/index', source: 'src/packages/reminders/create/index.tsx', needsWriteGate: true },
    { route: 'packages/reminders/calendar/index', source: 'src/packages/reminders/calendar/index.tsx' },
    { route: 'packages/reminders/subscriptions/index', source: 'src/packages/reminders/subscriptions/index.tsx', needsWriteGate: true }
  ],
  M3: [
    { route: 'packages/crm/index/index', source: 'src/packages/crm/index/index.tsx', needsWriteGate: true },
    { route: 'packages/crm/create/index', source: 'src/packages/crm/create/index.tsx', needsWriteGate: true },
    { route: 'packages/crm/detail/index', source: 'src/packages/crm/detail/index.tsx', needsWriteGate: true },
    { route: 'packages/contracts/index/index', source: 'src/packages/contracts/index/index.tsx', needsWriteGate: true },
    { route: 'packages/contracts/create/index', source: 'src/packages/contracts/create/index.tsx', needsWriteGate: true },
    { route: 'packages/contracts/detail/index', source: 'src/packages/contracts/detail/index.tsx', needsWriteGate: true },
    { route: 'packages/contracts/templates/index', source: 'src/packages/contracts/templates/index.tsx', needsWriteGate: true },
    { route: 'packages/finance/index/index', source: 'src/packages/finance/index/index.tsx', needsWriteGate: true },
    { route: 'packages/finance/create/index', source: 'src/packages/finance/create/index.tsx', needsWriteGate: true },
    { route: 'packages/finance/categories/index', source: 'src/packages/finance/categories/index.tsx', needsWriteGate: true },
    { route: 'packages/data-center/index/index', source: 'src/packages/data-center/index/index.tsx' },
    { route: 'packages/data-center/actions/index', source: 'src/packages/data-center/actions/index.tsx', needsWriteGate: true }
  ],
  M4: [
    { route: 'packages/ai/index/index', source: 'src/packages/ai/index/index.tsx', needsWriteGate: true },
    { route: 'packages/genetic/index/index', source: 'src/packages/genetic/index/index.tsx' },
    { route: 'packages/genetic/create/index', source: 'src/packages/genetic/create/index.tsx', needsWriteGate: true }
  ]
}

describe('M1–M4 migration surface gate', () => {
  for (const [milestone, entries] of Object.entries(surfaces)) {
    it(`${milestone} routes are registered and backed by generated API pages`, () => {
      for (const entry of entries) {
        const sourcePath = path.join(projectRoot, entry.source)
        expect(fs.existsSync(sourcePath), `${milestone} source missing: ${entry.source}`).toBe(true)
        expect(isRouteRegistered(entry.route), `${milestone} route missing: ${entry.route}`).toBe(true)

        const source = fs.readFileSync(sourcePath, 'utf8')
        expect(source, `${entry.source} must consume a generated API client`).toMatch(generatedApi)
        if (entry.needsWriteGate) {
          expect(source, `${entry.source} must expose a permission/write gate`).toMatch(permissionOrAction)
        }
        expect(source, `${entry.source} still looks like a static sample`).not.toMatch(staleSampleMarker)
      }
    })
  }

  it('关键业务闭环使用对应的真实生成接口', () => {
    const criticalOperations: Record<string, string[]> = {
      'src/packages/data-center/actions/index.tsx': [
        'setImportMapping', 'listImportRowResults', 'getImportErrorReport', 'retryImportJob',
        'listExportJobs', 'getExportDownload', 'listBackupJobs', 'getBackupDownload'
      ],
      'src/packages/animals/create/index.tsx': ['speciesRuleVersionId', 'birthDate', 'notes', 'sex', 'encodePhenotype', 'listGeneticPhenotypeCatalog'],
      'src/packages/animals/detail/index.tsx': ['presignMediaUpload', 'completeMediaUpload', 'coverMediaId', 'internalCode', 'birthDate', 'varietyCode', 'notes', 'encodePhenotype'],
      'src/packages/breeding/detail/index.tsx': ['separatePairing'],
      'src/packages/contracts/templates/index.tsx': ['listContractTemplates', 'listReceiptTemplates', 'createContractTemplate', 'createReceiptTemplate'],
      'src/packages/finance/categories/index.tsx': ['listAccountingCategories', 'createAccountingCategory'],
      'src/packages/ai/index/index.tsx': ['chatAssistant', 'confirmAssistantAction', 'cancelAssistantAction', 'task_draft'],
      'src/packages/genetic/create/index.tsx': [
        'listGeneticPhenotypeCatalog', 'listGeneticTargetCrosses', 'compareGeneticActual', 'listGeneticFeedbackSummary'
      ]
    }
    for (const [source, operations] of Object.entries(criticalOperations)) {
      const content = fs.readFileSync(path.join(projectRoot, source), 'utf8')
      for (const operation of operations) expect(content, `${source} missing ${operation}`).toContain(operation)
    }
  })

  it('B 端业务不新增直接 HTTP，请求仅经 adapter 或预签二进制例外', () => {
    const directRequestFiles = sourceFiles(path.join(projectRoot, 'src'))
      .filter((sourcePath) => directRequestMarker.test(withoutComments(fs.readFileSync(sourcePath, 'utf8'))))
      .map((sourcePath) => path.relative(projectRoot, sourcePath))
      .sort()

    expect(directRequestFiles).toEqual([...directRequestAllowlist].sort())
  })
})
