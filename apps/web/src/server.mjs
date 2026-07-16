import http from 'node:http';
import { URL } from 'node:url';

const port = Number(process.env.WEB_PORT || 3000);

export function renderShell(title, body) {
  return `<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${escapeHtml(title)}</title>
    <style>
      :root { color-scheme: light; font-family: Inter, -apple-system, BlinkMacSystemFont, "Noto Sans SC", sans-serif; color: #1f2928; background: #f7f5ef; }
      body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: #eceae4; }
      main { width: min(640px, calc(100% - 40px)); padding: 48px 32px; background: #fff; border: 1px solid #c8cecb; border-radius: 8px; box-sizing: border-box; }
      h1 { margin: 0 0 12px; font-size: 28px; }
      p { margin: 0; color: #6c7774; line-height: 1.7; }
      .eyebrow { margin-bottom: 16px; color: #9f5737; font-size: 12px; font-weight: 700; letter-spacing: .08em; }
    </style>
  </head>
  <body><main>${body}</main></body>
</html>`;
}

export function renderShareBoundary() {
  return renderShell('公开分享', '<div class="eyebrow">WEB-01 · I1</div><h1>分享页边界已就绪</h1><p>公开分享数据读取将在后续迭代接入。当前链接不会返回任何业务数据。</p>');
}

export function createServer() {
  return http.createServer((request, response) => {
    const url = new URL(request.url, `http://${request.headers.host || 'localhost'}`);
    if (request.method === 'GET' && url.pathname === '/healthz') {
      return sendJson(response, 200, { status: 'ok', service: 'scolvpet-web-ssr' });
    }
    if (request.method === 'GET' && /^\/s\/[^/]+$/.test(url.pathname)) {
      response.writeHead(404, {
        'Cache-Control': 'no-store',
        'Content-Type': 'text/html; charset=utf-8',
      });
      response.end(renderShareBoundary());
      return;
    }
    response.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    response.end('Not Found');
  });
}

function sendJson(response, status, value) {
  response.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
  response.end(JSON.stringify(value));
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[character]));
}

if (import.meta.url === `file://${process.argv[1]}`) {
  createServer().listen(port, () => console.log(`scolvpet web SSR listening on :${port}`));
}

