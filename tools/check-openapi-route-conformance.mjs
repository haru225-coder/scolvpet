#!/usr/bin/env node
/**
 * Bidirectional OpenAPI operation ↔ Go ServeMux route conformance.
 *
 * PASS only when:
 *   OpenAPI − Go = 0
 *   Go − OpenAPI − allowlist = 0
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const openapiPath = path.join(root, 'specs/api/openapi.yaml');
const httpapiDir = path.join(root, 'api/internal/httpapi');

/** Transport / health probes not required in OpenAPI business contract. */
const GO_ALLOWLIST = new Set([
  'GET /healthz',
  'GET /readyz',
  'GET /v1/media/{}/content',
  'PUT /v1/data-center/import-uploads/{}/content',
  'PUT /v1/media/uploads/{}/content',
]);

function normalizePath(p) {
  return p
    .replace(/\{[^}]+\}/g, '{}')
    .replace(/\/+/g, '/')
    .replace(/\/$/, '') || '/';
}

function withV1(p) {
  if (p.startsWith('/v1/') || p === '/v1' || p.startsWith('/healthz') || p.startsWith('/readyz')) {
    return p;
  }
  return '/v1' + (p.startsWith('/') ? p : `/${p}`);
}

function parseOpenAPIOps(yaml) {
  const ops = new Set();
  const lines = yaml.split('\n');
  let inPaths = false;
  let currentPath = null;
  for (const raw of lines) {
    if (/^paths:\s*$/.test(raw)) {
      inPaths = true;
      currentPath = null;
      continue;
    }
    if (!inPaths) continue;
    if (/^[A-Za-z]/.test(raw) && !raw.startsWith(' ') && raw.includes(':')) {
      break;
    }
    const pathMatch = raw.match(/^  ("?\/[^"]+"?):\s*$/);
    if (pathMatch) {
      currentPath = pathMatch[1].replace(/^"|"$/g, '');
      continue;
    }
    const methodMatch = raw.match(/^    (get|post|put|patch|delete):\s*$/i);
    if (methodMatch && currentPath) {
      const method = methodMatch[1].toUpperCase();
      ops.add(`${method} ${normalizePath(withV1(currentPath))}`);
    }
  }
  return ops;
}

function parseGoOps(dir) {
  const ops = new Set();
  for (const name of fs.readdirSync(dir)) {
    if (!name.endsWith('.go') || name.endsWith('_test.go')) continue;
    const src = fs.readFileSync(path.join(dir, name), 'utf8');
    for (const m of src.matchAll(/HandleFunc\(\s*"([A-Z]+)\s+([^"]+)"/g)) {
      ops.add(`${m[1]} ${normalizePath(m[2])}`);
    }
  }
  return ops;
}

const openapiOps = parseOpenAPIOps(fs.readFileSync(openapiPath, 'utf8'));
const goOps = parseGoOps(httpapiDir);

const missingInGo = [...openapiOps].filter((op) => !goOps.has(op)).sort();
const extraInGo = [...goOps]
  .filter((op) => !openapiOps.has(op) && !GO_ALLOWLIST.has(op))
  .sort();

console.log(`openapi operations: ${openapiOps.size}`);
console.log(`go mux ops: ${goOps.size}`);
console.log(`go allowlist: ${GO_ALLOWLIST.size}`);

let failed = false;
if (missingInGo.length) {
  failed = true;
  console.error('OpenAPI operations missing from Go mux:');
  for (const op of missingInGo) console.error('  -', op);
}
if (extraInGo.length) {
  failed = true;
  console.error('Go mux operations missing from OpenAPI (not allowlisted):');
  for (const op of extraInGo) console.error('  -', op);
}
if (failed) process.exit(1);

console.log('openapi ↔ mux conformance: PASS (bidirectional, 0 gaps outside allowlist)');
