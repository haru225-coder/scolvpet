#!/usr/bin/env node
/**
 * ScolvPet demo 塞货脚本（客户验收 · 族谱链）
 *
 * 用法（默认 pet.scolv.com 演示号）：
 *   node scripts/seed-demo.mjs
 *   API_BASE=https://p.scolv.com PHONE=13800138000 CODE=123456 node scripts/seed-demo.mjs
 *
 * 做的事：
 * 1. 开发 Mock 登录
 * 2. 确保有中文名个体（已有则复用）
 * 3. 创建子女 + pedigree_parentage 父母边（公母齐全）
 * 4. 自检 GET /hamsters/{id}/pedigree 有 parentages，且 hasAnyParent 为真
 *
 * 说明：staging 上繁育计划 publish 常 409（资源冲突），窝次链路不稳，
 * 故用家谱 parentage 边保证「看族谱」能出树；小程序页已支持窝次优先、parentage 兜底。
 */

import { randomUUID } from 'node:crypto'

const API_BASE = String(process.env.API_BASE || 'https://pet.scolv.com').replace(/\/$/, '')
const PHONE_RAW = String(process.env.PHONE || '13800138000').replace(/\D/g, '')
const PHONE = PHONE_RAW.startsWith('86') ? `+${PHONE_RAW}` : `+86${PHONE_RAW}`
const CODE = String(process.env.CODE || '123456')

function log(...args) {
  console.log('[seed-demo]', ...args)
}

async function http(method, path, { token, body, ifMatch } = {}) {
  const headers = {
    'Content-Type': 'application/json',
    'Idempotency-Key': randomUUID()
  }
  if (token) headers.Authorization = `Bearer ${token}`
  if (ifMatch != null) {
    const etag = String(ifMatch)
    headers['If-Match'] = etag.startsWith('"') ? etag : `"${etag}"`
  }
  const res = await fetch(`${API_BASE}${path}`, {
    method,
    headers,
    body: body == null ? undefined : JSON.stringify(body)
  })
  const text = await res.text()
  let json
  try {
    json = text ? JSON.parse(text) : {}
  } catch {
    json = { raw: text }
  }
  if (!res.ok) {
    const msg = json?.error?.message || res.statusText || `HTTP ${res.status}`
    const err = new Error(`${method} ${path} → ${res.status}: ${msg}`)
    err.status = res.status
    err.body = json
    throw err
  }
  return json
}

async function login() {
  const codeRes = await http('POST', '/v1/auth/verification-codes', {
    body: { phone: PHONE, purpose: 'login' }
  })
  const verificationId = codeRes?.data?.verification_id
  if (!verificationId) throw new Error('no verification_id (rate limited?)')
  const session = await http('POST', '/v1/auth/sessions', {
    body: {
      phone: PHONE,
      verification_id: verificationId,
      code: CODE,
      device: { platform: 'script', app_version: 'seed-demo' }
    }
  })
  const token = session?.data?.access_token || session?.data?.token
  if (!token) throw new Error('no access_token')
  return token
}

async function main() {
  log('API', API_BASE, 'phone', PHONE)
  const token = await login()
  log('login ok, token len', token.length)

  const hamsters = (await http('GET', '/v1/hamsters?limit=100', { token }))?.data || []
  log('hamsters existing', hamsters.length)
  for (const h of hamsters.slice(0, 8)) {
    log(' -', h.name || h.internal_code, h.sex, String(h.id).slice(0, 8))
  }

  const rules = (await http('GET', '/v1/species-rule-versions?limit=5', { token }))?.data || []
  const ruleId = rules[0]?.id
  if (!ruleId) throw new Error('no species_rule_version')

  // 优先固定演示名，避免把刚建的子女误当成公母
  let sire =
    hamsters.find((h) => h.name === '哈鲁') ||
    hamsters.find((h) => h.sex === 'male' && h.name && !String(h.internal_code || '').startsWith('SEED-CHILD'))
  let dam =
    hamsters.find((h) => h.name === '哈尔') ||
    hamsters.find((h) => h.sex === 'female' && h.name && !String(h.internal_code || '').startsWith('SEED-CHILD'))

  async function createNamed({ name, sex, code }) {
    const res = await http('POST', '/v1/hamsters', {
      token,
      body: {
        internal_code: code,
        name,
        species_rule_version_id: ruleId,
        sex,
        source_type: 'born_here',
        birth_date: '2026-05-01',
        notes: 'seed-demo'
      }
    })
    return res.data
  }

  if (!sire) {
    sire = await createNamed({ name: '哈鲁', sex: 'male', code: `SEED-SIRE-${Date.now().toString(36)}` })
    log('created sire', sire.name, sire.id)
  }
  if (!dam) {
    dam = await createNamed({ name: '哈尔', sex: 'female', code: `SEED-DAM-${Date.now().toString(36)}` })
    log('created dam', dam.name, dam.id)
  }
  log('parents', sire.name, dam.name)

  // 再造 2–3 只子女（中文名）并挂父母边
  const childNames = ['哈豆', '哈米', '哈糖']
  const children = []
  for (const name of childNames) {
    let child = hamsters.find((h) => h.name === name)
    if (!child) {
      try {
        child = await createNamed({
          name,
          sex: name === '哈豆' ? 'male' : 'female',
          code: `SEED-${name}-${Date.now().toString(36).slice(-4)}`
        })
        log('created child', name, child.id)
      } catch (e) {
        log('create child fail', name, e.message)
        continue
      }
    } else {
      log('reuse child', name, child.id)
    }
    children.push(child)

    for (const [role, parent] of [
      ['sire', sire],
      ['dam', dam]
    ]) {
      try {
        await http('POST', '/v1/pedigree-parentages', {
          token,
          body: {
            child_hamster_id: child.id,
            parent_hamster_id: parent.id,
            role,
            evidence_type: 'manual',
            confidence: 1,
            valid_from: '2026-06-01T00:00:00Z',
            notes: 'seed-demo parentage'
          }
        })
        log('parentage', name, role, '←', parent.name)
      } catch (e) {
        // 已有边可能 409；继续
        log('parentage skip', name, role, e.message.slice(0, 80))
      }
    }
  }

  if (!children.length) throw new Error('no children seeded')

  // 自检：API 图 + 本地 hasAnyParent 语义
  const focus = children[0]
  const graph = (await http('GET', `/v1/hamsters/${focus.id}/pedigree?generations=3`, { token }))?.data
  const parentages = graph?.parentages || []
  const hasAnyParent = parentages.some(
    (p) => p.child_hamster_id === focus.id && (p.role === 'sire' || p.role === 'dam') && !p.valid_to
  )
  log('verify child', focus.name, focus.id)
  log('parentages', parentages.length, 'hasAnyParent', hasAnyParent)
  log(
    'nodes',
    (graph?.nodes || []).map((n) => n.name || n.internal_code).join(', ')
  )

  if (!hasAnyParent) {
    console.error('[seed-demo] FAIL: hasAnyParent=false — 不要交给 Snow 点')
    process.exit(2)
  }

  // 列出 litters 仅作信息
  const litters = (await http('GET', '/v1/litters?limit=20', { token }))?.data || []
  log('litters count', litters.length, '(publish 常 409，族谱用 parentage 兜底)')

  console.log('\n=== SEED OK ===')
  console.log(
    JSON.stringify(
      {
        api: API_BASE,
        focus_child: { id: focus.id, name: focus.name },
        parents: { sire: sire.name, dam: dam.name },
        children: children.map((c) => ({ id: c.id, name: c.name })),
        hasAnyParent: true,
        open_in_mp: `/packages/animals/pedigree/index?id=${focus.id}`
      },
      null,
      2
    )
  )
}

main().catch((err) => {
  console.error('[seed-demo] ERROR', err.message)
  if (err.body) console.error(JSON.stringify(err.body, null, 2).slice(0, 800))
  process.exit(1)
})
