import http from 'node:http';
import { URL } from 'node:url';

const port = Number(process.env.WEB_PORT || 3000);
const PUBLIC_DISPLAY_FIELDS = new Set([
  'name',
  'sex',
  'birth_date',
  'variety',
  'pedigree_summary',
  'litter_code',
  'born_at',
  'parents',
  'member_count',
]);
const PUBLIC_NESTED_FIELDS = new Set(['name', 'sex', 'birth_date', 'born_at', 'variety', 'litter_code']);
const PUBLIC_MEDIA_KINDS = new Set(['cover', 'thumbnail', 'preview']);
const FIELD_LABELS = {
  name: '名称',
  sex: '性别',
  birth_date: '出生日期',
  variety: '品种',
  pedigree_summary: '谱系摘要',
  litter_code: '窝次编号',
  born_at: '出生时间',
  parents: '父母',
  member_count: '成员数量',
};
const SEX_LABELS = { male: '公', female: '母', unknown: '未知' };

export function renderShell(title, body) {
  return `<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${escapeHtml(title)}</title>
    <style>
      :root { color-scheme: light; font-family: Inter, -apple-system, BlinkMacSystemFont, "Noto Sans SC", sans-serif; color: #1f2928; background: #f7f5ef; }
      * { box-sizing: border-box; }
      body { margin: 0; min-height: 100vh; padding: 24px; display: grid; place-items: center; background: radial-gradient(circle at top left, #f8efe4 0, #eceae4 48%, #e2e8e4 100%); }
      main { width: min(720px, 100%); padding: clamp(28px, 7vw, 56px); background: rgba(255, 255, 255, .94); border: 1px solid #c8cecb; border-radius: 20px; box-shadow: 0 20px 60px rgba(31, 41, 40, .12); }
      h1 { margin: 0 0 12px; font-size: clamp(28px, 6vw, 44px); line-height: 1.15; letter-spacing: -.03em; }
      h2 { margin: 36px 0 14px; font-size: 18px; }
      p { margin: 0; color: #6c7774; line-height: 1.7; }
      .eyebrow { margin-bottom: 16px; color: #9f5737; font-size: 12px; font-weight: 700; letter-spacing: .08em; }
      .subject-type { display: inline-flex; margin-top: 8px; padding: 6px 10px; color: #35635c; background: #e4f0eb; border-radius: 999px; font-size: 13px; font-weight: 700; }
      .subject-fields { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin: 0; }
      .subject-field { margin: 0; padding: 14px 16px; background: #f7f8f5; border-radius: 12px; }
      .subject-field dt { color: #7b8581; font-size: 12px; }
      .subject-field dd { margin: 5px 0 0; color: #263532; line-height: 1.5; overflow-wrap: anywhere; }
      .media-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; }
      .media-grid img { display: block; width: 100%; aspect-ratio: 1; object-fit: cover; border-radius: 14px; background: #edf0ed; }
      .muted { color: #8a9490; font-size: 14px; }
      @media (max-width: 480px) { body { padding: 12px; } main { border-radius: 16px; } }
    </style>
  </head>
  <body><main>${body}</main></body>
</html>`;
}

export function renderShareBoundary() {
  return renderInvalidShare();
}

export function renderInvalidShare() {
  return renderShell(
    '分享链接已失效',
    '<div class="eyebrow">WEB-01 · 公开分享</div><h1>分享链接已失效</h1><p>该公开分享可能已被撤销、已过期，或当前暂时无法读取。请向分享者索取新的链接。</p>',
  );
}

export function renderPublicShare(data) {
  const subjectType = subjectTypeLabel(data.subject_type);
  const display = isRecord(data.display) ? data.display : {};
  const title = firstDisplayValue(display, ['title', 'name', 'litter_code']) || `${subjectType}公开分享`;
  const fields = renderSubjectFields(display);
  const media = renderMedia(data.media, title);

  return renderShell(
    title,
    `<div class="eyebrow">WEB-01 · 公开分享</div>
     <h1>${escapeHtml(title)}</h1>
     <div class="subject-type">${escapeHtml(subjectType)}</div>
     <section aria-labelledby="subject-heading"><h2 id="subject-heading">主题对象</h2>${fields}</section>
     <section aria-labelledby="media-heading"><h2 id="media-heading">媒体</h2>${media}</section>`,
  );
}

export function createServer(options = {}) {
  const apiBaseUrl = options.apiBaseUrl ?? process.env.WEB_API_BASE_URL;
  const fetchImpl = options.fetchImpl ?? globalThis.fetch;

  return http.createServer(async (request, response) => {
    const url = new URL(request.url, `http://${request.headers.host || 'localhost'}`);

    if (request.method === 'GET' && url.pathname === '/healthz') {
      return sendJson(response, 200, { status: 'ok', service: 'scolvpet-web-ssr' });
    }

    if (request.method === 'GET' && /^\/s\/[^/]+$/.test(url.pathname)) {
      const token = readShareToken(url.pathname);
      if (!token) {
        return sendHtml(response, 404, renderInvalidShare());
      }

      try {
        const share = await fetchPublicShare({ apiBaseUrl, fetchImpl, token });
        if (!share) {
          return sendHtml(response, 404, renderInvalidShare());
        }
        return sendHtml(response, 200, renderPublicShare(share));
      } catch {
        return sendHtml(response, 404, renderInvalidShare());
      }
    }

    response.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    response.end('Not Found');
  });
}

export async function fetchPublicShare({ apiBaseUrl, fetchImpl = globalThis.fetch, token }) {
  if (!apiBaseUrl || typeof fetchImpl !== 'function') {
    return null;
  }

  const apiUrl = buildPublicShareUrl(apiBaseUrl, token);
  const response = await fetchImpl(apiUrl, {
    headers: { Accept: 'application/json' },
  });

  if (!response || response.status !== 200) {
    return null;
  }

  const payload = await response.json();
  const data = payload?.data;
  if (!isRecord(data) || !isRecord(data.display) || !Array.isArray(data.media)) {
    return null;
  }
  if (data.revoked === true || data.revoked_at || ['revoked', 'expired', 'inactive'].includes(data.status)) {
    return null;
  }
  if (data.expires_at && Date.parse(data.expires_at) <= Date.now()) {
    return null;
  }

  return data;
}

export function buildPublicShareUrl(apiBaseUrl, token) {
  const base = new URL(String(apiBaseUrl));
  const basePath = base.pathname.replace(/\/+$/, '');
  base.pathname = `${basePath}/v1/public/shares/${encodeURIComponent(token)}`;
  base.search = '';
  base.hash = '';
  return base.toString();
}

function renderSubjectFields(display) {
  const fields = Object.entries(display)
    .filter(([key, value]) => PUBLIC_DISPLAY_FIELDS.has(key) && key !== 'cover' && value !== null && value !== undefined && value !== '')
    .map(([key, value]) => {
      const text = formatPublicValue(key, value);
      if (!text) {
        return '';
      }
      return `<div class="subject-field"><dt>${escapeHtml(FIELD_LABELS[key])}</dt><dd>${escapeHtml(text)}</dd></div>`;
    })
    .filter(Boolean)
    .join('');

  return fields ? `<dl class="subject-fields">${fields}</dl>` : '<p class="muted">分享者未选择更多公开字段。</p>';
}

function renderMedia(media, title) {
  const images = media
    .filter((item) => isRecord(item) && item.status === 'ready' && PUBLIC_MEDIA_KINDS.has(item.kind))
    .map((item) => safeMediaUrl(item.url))
    .filter(Boolean)
    .slice(0, 12)
    .map((url, index) => `<img src="${escapeHtml(url)}" alt="${escapeHtml(`${title}媒体缩略图 ${index + 1}`)}" loading="lazy">`)
    .join('');

  return images ? `<div class="media-grid">${images}</div>` : '<p class="muted">暂无公开媒体。</p>';
}

function formatPublicValue(key, value) {
  if (key === 'sex' && typeof value === 'string') {
    return SEX_LABELS[value] || value;
  }
  return formatNestedValue(value);
}

function formatNestedValue(value) {
  if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') {
    return String(value);
  }
  if (Array.isArray(value)) {
    return value.map(formatNestedValue).filter(Boolean).join('、');
  }
  if (isRecord(value)) {
    return Object.entries(value)
      .filter(([key, nestedValue]) => PUBLIC_NESTED_FIELDS.has(key) && nestedValue !== null && nestedValue !== undefined && nestedValue !== '')
      .map(([key, nestedValue]) => `${FIELD_LABELS[key] || key}：${formatNestedValue(nestedValue)}`)
      .filter((entry) => !entry.endsWith('：'))
      .join('；');
  }
  return '';
}

function firstDisplayValue(display, keys) {
  for (const key of keys) {
    if (typeof display[key] === 'string' && display[key].trim()) {
      return display[key].trim();
    }
  }
  return '';
}

function subjectTypeLabel(subjectType) {
  return subjectType === 'hamster' ? '仓鼠' : subjectType === 'litter' ? '窝次' : '公开对象';
}

function safeMediaUrl(value) {
  if (typeof value !== 'string' || !value) {
    return null;
  }
  try {
    const url = new URL(value);
    return url.protocol === 'http:' || url.protocol === 'https:' ? url.toString() : null;
  } catch {
    return null;
  }
}

function readShareToken(pathname) {
  const rawToken = pathname.slice('/s/'.length);
  try {
    const token = decodeURIComponent(rawToken);
    return token && !/[\\/]/.test(token) && token.length <= 512 ? token : null;
  } catch {
    return null;
  }
}

function isRecord(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function sendHtml(response, status, html) {
  response.writeHead(status, {
    'Cache-Control': 'no-store',
    'Content-Type': 'text/html; charset=utf-8',
  });
  response.end(html);
}

function sendJson(response, status, value) {
  response.writeHead(status, {
    'Cache-Control': 'no-store',
    'Content-Type': 'application/json; charset=utf-8',
  });
  response.end(JSON.stringify(value));
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[character]));
}

if (import.meta.url === `file://${process.argv[1]}`) {
  createServer().listen(port, () => console.log(`scolvpet web SSR listening on :${port}`));
}
