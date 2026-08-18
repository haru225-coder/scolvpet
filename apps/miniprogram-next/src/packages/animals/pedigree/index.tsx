import { Input, ScrollView, View, Text } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useCallback, useState } from 'react'
import {
  ActionPanel,
  Cell,
  Empty,
  FormRow,
  NavBar,
  Section,
  SectionList,
  Tag,
  metrics,
  palette
} from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { formatUserError } from '../../../api/errors'
import { requireBreederSession } from '../../../auth/dev-session'
import { canUseCapability } from '../../../auth/permissions'
import { CapabilityButton } from '../../../components/CapabilityButton'
import {
  buildCreateParentageBody,
  buildEndParentageBody,
  parentRoleFromCard,
  parentRoleLabel,
  requireCorrectionReason,
  type ParentRole
} from '../../../utils/record-correction'
import { buildPedigreeRows, type PedigreeRow, type PedigreeRowNode } from '../../../utils/pedigree'
import {
  litterMemberIds,
  pedigreeDataFromApiGraph,
  pedigreeDataFromLitters,
  type HamsterLike,
  type LineageCoverage,
  type LitterLike
} from '../../../utils/pedigree-from-litters'

/**
 * 经营端族谱（客户验收三件事之三）。
 *
 * 数据源：个体档案不带 sireId/damId，父母关系在窝次上，所以这里
 * listLitters + listLitterMembers 反推 childId -> (sire, dam)，
 * 再交给 utils/pedigree.js 的 buildPedigreeRows 排版（与 C 端公开谱系同一份逻辑）。
 * 公开谱系接口要求 public === true，经营端自用库大多不公开，因此不能复用。
 */

/** 窝次成员拉取上限：小熊舍计量级，封顶避免 N+1 失控。 */
const MAX_LITTERS_TO_EXPAND = 40

export default function AnimalPedigreePage() {
  const [rootId, setRootId] = useState('')
  const [rootName, setRootName] = useState('')
  const [rows, setRows] = useState<PedigreeRow[]>([])
  const [coverage, setCoverage] = useState<LineageCoverage | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [menuNode, setMenuNode] = useState<PedigreeRowNode | null>(null)
  const [correctRole, setCorrectRole] = useState<ParentRole | null>(null)
  const [correctMode, setCorrectMode] = useState<'end' | 'replace' | null>(null)
  const [correctReason, setCorrectReason] = useState('')
  const [candidates, setCandidates] = useState<Array<Record<string, unknown>>>([])
  const [busy, setBusy] = useState(false)
  const [status, setStatus] = useState('')

  const load = useCallback(async (id: string) => {
    setLoading(true)
    setError('')
    try {
      // 验收路径：种群 → 个体 → 族谱；冷启分包须先 require 会话
      const session = await requireBreederSession()
      if (!session) {
        setError('请先登录经营账号')
        setRows([])
        return
      }
      const [hamsterResponse, hamstersResponse, littersResponse] = await Promise.all([
        defaultApi.getHamster({ hamsterId: id }),
        defaultApi.listHamsters({ limit: 100 } as any).catch(() => ({ data: [] as any[] })),
        defaultApi.listLitters({ limit: 100 } as any).catch(() => ({ data: [] as any[] }))
      ])

      const root = ((hamsterResponse as any)?.data ?? hamsterResponse) as HamsterLike
      const hamsters = (((hamstersResponse as any)?.data || []) as HamsterLike[]).slice()
      if (root && !hamsters.some((h) => String(h?.id ?? '') === id)) hamsters.push({ ...root, id })

      const litters = (((littersResponse as any)?.data || []) as LitterLike[]).filter(
        (litter) => litter?.sireId || litter?.damId || (litter as any)?.sire_id || (litter as any)?.dam_id
      )

      // 窝次列表不带成员，逐窝补一次；单窝失败不拖垮整页。
      const expanded: LitterLike[] = await Promise.all(
        litters.slice(0, MAX_LITTERS_TO_EXPAND).map(async (litter) => {
          if (litterMemberIds(litter).length) return litter
          const litterId = String(litter?.id ?? '')
          if (!litterId) return litter
          try {
            const members = await defaultApi.listLitterMembers({ litterId, limit: 100 } as any)
            return { ...litter, members: ((members as any)?.data || []) as any[] }
          } catch {
            return litter
          }
        })
      )

      let { data, coverage: cov } = pedigreeDataFromLitters({
        rootId: id,
        litters: expanded,
        hamsters,
        generations: 3
      })

      // 窝次反推不到父母时：走经营端统一家谱图（parentage 边），避免客户只看到空态
      if (!cov.hasAnyParent) {
        try {
          const graphResponse = await defaultApi.getHamsterPedigree({
            hamsterId: id,
            generations: 3
          } as any)
          const graph = ((graphResponse as any)?.data ?? graphResponse) as any
          const fromApi = pedigreeDataFromApiGraph({ rootId: id, graph })
          if (fromApi.coverage.hasAnyParent) {
            data = fromApi.data
            cov = fromApi.coverage
          }
        } catch {
          // 保留窝次空态文案
        }
      }

      setRootName(data.root_public_name)
      setCoverage(cov)
      setRows(cov.hasAnyParent ? buildPedigreeRows(data, id) : [])
    } catch (cause) {
      setError(await formatUserError(cause, '族谱读不到，请稍后重试'))
    } finally {
      setLoading(false)
    }
  }, [])

  useLoad((query) => {
    const id = String(query?.id ?? '')
    setRootId(id)
    if (!id) {
      setLoading(false)
      setError('缺个体编号，请从个体档案进入')
      return
    }
    void load(id)
  })

  /** 点祖辈：以它为根重新看（navigateTo 保留返回栈，与 C 端一致）。 */
  function reRoot(id: string) {
    if (!id || id === rootId) return
    void Taro.navigateTo({ url: `/packages/animals/pedigree/index?id=${encodeURIComponent(id)}` })
  }

  function openNode(node: PedigreeRowNode) {
    const role = parentRoleFromCard(node.role)
    if (role && canUseCapability('write_hamster')) {
      setMenuNode(node)
      return
    }
    if (node.tappable && node.id && node.id !== rootId) reRoot(node.id)
  }

  async function loadCandidates(role: ParentRole) {
    try {
      const response = await defaultApi.listHamsters({ limit: 100 } as any)
      const raw = (response as { data?: unknown }).data
      const list = (Array.isArray(raw) ? raw : []).filter((item): item is Record<string, unknown> => {
        if (!item || typeof item !== 'object') return false
        const id = String((item as { id?: unknown }).id || '')
        const sex = String((item as { sex?: unknown }).sex || '')
        if (!id || id === rootId) return false
        return role === 'sire' ? sex === 'male' : sex === 'female'
      })
      setCandidates(list)
    } catch {
      setCandidates([])
    }
  }

  function startCorrect(mode: 'end' | 'replace', node: PedigreeRowNode) {
    const role = parentRoleFromCard(node.role)
    if (!role) return
    setCorrectRole(role)
    setCorrectMode(mode)
    setCorrectReason('')
    setStatus('')
    if (mode === 'replace') void loadCandidates(role)
  }

  async function submitEnd() {
    if (!correctRole || !rootId) return
    setBusy(true)
    try {
      const reason = requireCorrectionReason(correctReason)
      await defaultApi.endPedigreeParentage({
        idempotencyKey: newIdempotencyKey(),
        pedigreeParentageEndRequest: buildEndParentageBody({
          childHamsterId: rootId,
          role: correctRole,
          correctionReason: reason
        })
      })
      setStatus(`已解除${parentRoleLabel(correctRole)}`)
      setCorrectMode(null)
      await load(rootId)
    } catch (cause) {
      setStatus(
        cause instanceof Error && cause.message.includes('原因')
          ? cause.message
          : await formatUserError(cause, '解除父母失败')
      )
    } finally {
      setBusy(false)
    }
  }

  async function submitReplace(parentId: string) {
    if (!correctRole || !rootId || !parentId) return
    setBusy(true)
    try {
      const hasCurrent = Boolean(menuNode?.id)
      const reason = hasCurrent ? requireCorrectionReason(correctReason) : correctReason.trim()
      await defaultApi.createPedigreeParentage({
        idempotencyKey: newIdempotencyKey(),
        pedigreeParentageCreateRequest: buildCreateParentageBody({
          childHamsterId: rootId,
          parentHamsterId: parentId,
          role: correctRole,
          correctionReason: reason
        })
      })
      setStatus(`已登记${parentRoleLabel(correctRole)}`)
      setCorrectMode(null)
      setMenuNode(null)
      await load(rootId)
    } catch (cause) {
      setStatus(
        cause instanceof Error && cause.message.includes('原因')
          ? cause.message
          : await formatUserError(cause, '登记父母失败')
      )
    } finally {
      setBusy(false)
    }
  }

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <NavBar title={rootName ? `族谱 · ${rootName}` : '族谱'} back />
      <ScrollView scrollY type="list" enhanced bounces showScrollbar={false} style={{ flex: 1 }}>
        {loading ? <Empty title="正在拼族谱…" description="从窝次记录里找父母" /> : null}

        {!loading && error ? (
          error.includes('登录') ? (
            <SectionList>
              <Section header="需要处理">
                <Cell
                  title={error}
                  subtitle="点这里去登录"
                  chevron
                  onClick={() => void Taro.navigateTo({ url: '/pages/login/index' })}
                />
              </Section>
            </SectionList>
          ) : (
            <Empty title={error} description="返回上一页重试，或先检查网络" />
          )
        ) : null}

        {!loading && !error && !rows.length ? (
          <Empty title="还看不到族谱" description={coverage?.note || '登记窝次的公母后，这里会自动长出来'} />
        ) : null}

        {!loading && !error && rows.length ? (
          <SectionList>
            {rows.map((row) => (
              <Section key={row.label} header={row.label}>
                {row.nodes.map((node) => {
                  const canCorrect = row.label === '父母' && canUseCapability('write_hamster')
                  return (
                    <Cell
                      key={`${row.label}-${node.role}-${node.id || 'none'}`}
                      title={node.name}
                      subtitle={canCorrect ? `${node.role} · 点这里纠正` : node.role}
                      value={
                        node.sex === 'male' ? <Tag>公</Tag> : node.sex === 'female' ? <Tag>母</Tag> : undefined
                      }
                      chevron={canCorrect || (node.tappable && node.id !== rootId)}
                      onClick={() => openNode(node)}
                    />
                  )
                })}
              </Section>
            ))}
            <Section footer={coverage?.note || '父母关系来自窝次或家谱登记'}>
              <Cell
                title="回到这只的档案"
                chevron
                onClick={() =>
                  void Taro.navigateTo({
                    url: `/packages/animals/detail/index?id=${encodeURIComponent(rootId)}`
                  })
                }
              />
            </Section>
          </SectionList>
        ) : null}

        {!loading && !error && rows.length ? (
          <Text
            style={{
              display: 'block',
              padding: `0 ${metrics.pagePadding}px ${metrics.space24}px`,
              fontSize: '12px',
              color: 'rgba(255,255,255,0.4)'
            }}
          >
            父母可以纠正；带「›」的祖辈可以点进去往上看。
          </Text>
        ) : null}

        {correctMode && correctRole ? (
          <SectionList>
            <Section
              header={correctMode === 'end' ? `解除${parentRoleLabel(correctRole)}` : `登记${parentRoleLabel(correctRole)}`}
              footer="原关系不删，只记一条纠错审计。"
            >
              <FormRow label="原因">
                <Input
                  placeholder="为什么要改"
                  placeholderStyle={`color: ${palette.tertiaryLabel}`}
                  value={correctReason}
                  onInput={(event) => setCorrectReason(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              {correctMode === 'end' ? (
                <CapabilityButton capability="write_hamster" block disabled={busy} onClick={() => void submitEnd()}>
                  {busy ? '提交中…' : '确认解除'}
                </CapabilityButton>
              ) : null}
              {status ? <Cell title={status} /> : null}
            </Section>
            {correctMode === 'replace' ? (
              <Section header="选一只" footer={candidates.length ? undefined : '没有符合性别的候选'}>
                {candidates.map((item) => {
                  const id = String(item.id || '')
                  const name = String(item.name || item.internalCode || id)
                  const code = typeof item.internalCode === 'string' ? item.internalCode : ''
                  return (
                    <Cell
                      key={id}
                      title={name}
                      subtitle={code && item.name ? code : undefined}
                      chevron
                      onClick={() => void submitReplace(id)}
                    />
                  )
                })}
              </Section>
            ) : null}
          </SectionList>
        ) : null}
        <View style={{ height: '32px' }} />
      </ScrollView>
      <ActionPanel
        open={Boolean(menuNode)}
        title={menuNode ? `${menuNode.role} · ${menuNode.name}` : '纠正父母'}
        actions={[
          ...(menuNode?.id
            ? [{ text: '解除这段关系', danger: true, onClick: () => startCorrect('end', menuNode) }]
            : []),
          {
            text: menuNode?.id ? '换成另一只' : '补登记',
            onClick: () => menuNode && startCorrect('replace', menuNode)
          }
        ]}
        onClose={() => setMenuNode(null)}
      />
    </View>
  )
}
