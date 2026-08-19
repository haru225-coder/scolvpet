import { Input, ScrollView, View, Text } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useCallback, useRef, useState } from 'react'
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
import { type LineageCoverage } from '../../../utils/pedigree-from-litters'
import { loadOperatingPedigree } from '../../../utils/pedigree-load'
import { hamsterSearchLabel, searchHamsters } from '../../../utils/search-hamsters'

/**
 * 经营端族谱（客户验收三件事之三）。
 *
 * 数据源：先 GET /hamsters/{id}/pedigree（图里已含 parentage + 窝次父母/成员），
 * 没有父母边才退回 listLitters。排版仍走 utils/pedigree.js（与 C 端公开谱系同一份）。
 */

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
  const [candidateQuery, setCandidateQuery] = useState('')
  const [busy, setBusy] = useState(false)
  const [status, setStatus] = useState('')
  const candidateTimer = useRef<ReturnType<typeof setTimeout>>()

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
      const { data, coverage: cov } = await loadOperatingPedigree(defaultApi, id)
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

  async function loadCandidates(role: ParentRole, q = '') {
    try {
      setCandidates(
        await searchHamsters(defaultApi, {
          q,
          sex: role === 'sire' ? 'male' : 'female',
          excludeId: rootId
        })
      )
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
    setCandidateQuery('')
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
        {loading ? <Empty title="正在拼族谱…" description="先读家谱图，没有再从窝次反推" /> : null}

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
              <Section
                header="选一只"
                footer={candidates.length ? '先列出同性别最近 20 只，可搜名字或编号' : '没有符合性别的候选，换个关键词再搜'}
              >
                <FormRow label="搜索">
                  <Input
                    placeholder="名字或编号"
                    placeholderStyle={`color: ${palette.tertiaryLabel}`}
                    value={candidateQuery}
                    onInput={(event) => {
                      const next = event.detail.value
                      setCandidateQuery(next)
                      if (candidateTimer.current) clearTimeout(candidateTimer.current)
                      candidateTimer.current = setTimeout(() => {
                        if (correctRole) void loadCandidates(correctRole, next)
                      }, 350)
                    }}
                    style={{ color: '#FFFFFF' }}
                  />
                </FormRow>
                {candidates.map((item) => {
                  const id = String(item.id || '')
                  return (
                    <Cell
                      key={id}
                      title={hamsterSearchLabel(item)}
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
