import test from 'node:test';
import assert from 'node:assert/strict';
import { buildPublicShareUrl, createServer, renderShareBoundary } from '../src/server.mjs';

async function listen(server) {
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  return server.address().port;
}

function jsonResponse(value, status = 200) {
  return { status, json: async () => value };
}

test('SSR health and invalid share boundary', async (t) => {
  const server = createServer({ fetchImpl: async () => jsonResponse({}, 404) });
  const port = await listen(server);
  t.after(() => server.close());

  const health = await fetch(`http://127.0.0.1:${port}/healthz`);
  assert.equal(health.status, 200);
  assert.deepEqual(await health.json(), { status: 'ok', service: 'scolvpet-web-ssr' });

  const share = await fetch(`http://127.0.0.1:${port}/s/TOKEN`);
  assert.equal(share.status, 404);
  assert.equal(share.headers.get('cache-control'), 'no-store');
  assert.match(await share.text(), /分享链接已失效/);
  assert.doesNotMatch(renderShareBoundary(), /TOKEN/);
});

test('SSR fetches a public share from the injected API base and renders only public projection', async (t) => {
  let requestedUrl;
  const server = createServer({
    apiBaseUrl: 'https://api.example.test/root/',
    fetchImpl: async (url, options) => {
      requestedUrl = String(url);
      assert.equal(options.headers.Accept, 'application/json');
      return jsonResponse({
        data: {
          share_id: 'private-share-id',
          subject_type: 'hamster',
          display: {
            title: '小云',
            name: '云朵',
            sex: 'female',
            variety: '银狐',
            owner_email: 'owner@example.test',
            internal_code: 'H-SECRET',
          },
          media: [
            { id: 'thumbnail-id', kind: 'thumbnail', status: 'ready', url: 'https://cdn.example.test/cloud.webp' },
            { id: 'failed-id', kind: 'thumbnail', status: 'failed', url: 'https://cdn.example.test/failed.webp' },
          ],
        },
      });
    },
  });
  const port = await listen(server);
  t.after(() => server.close());

  const response = await fetch(`http://127.0.0.1:${port}/s/TOKEN`);
  const html = await response.text();
  assert.equal(response.status, 200);
  assert.equal(response.headers.get('cache-control'), 'no-store');
  assert.equal(requestedUrl, 'https://api.example.test/root/v1/public/shares/TOKEN');
  assert.match(html, /<h1>小云<\/h1>/);
  assert.match(html, /主题对象/);
  assert.match(html, /仓鼠/);
  assert.match(html, /云朵/);
  assert.match(html, /https:\/\/cdn\.example\.test\/cloud\.webp/);
  assert.doesNotMatch(html, /owner@example\.test|H-SECRET|private-share-id|failed\.webp|TOKEN/);
});

test('WEB_API_BASE_URL is read when the server is created', async (t) => {
  const original = process.env.WEB_API_BASE_URL;
  let requestedUrl;
  process.env.WEB_API_BASE_URL = 'https://env-api.example.test';
  t.after(() => {
    if (original === undefined) delete process.env.WEB_API_BASE_URL;
    else process.env.WEB_API_BASE_URL = original;
  });

  const server = createServer({
    fetchImpl: async (url) => {
      requestedUrl = String(url);
      return jsonResponse({
        data: { subject_type: 'litter', display: { title: '春日窝次' }, media: [] },
      });
    },
  });
  const port = await listen(server);
  t.after(() => server.close());

  const response = await fetch(`http://127.0.0.1:${port}/s/ENV_TOKEN`);
  assert.equal(response.status, 200);
  assert.equal(requestedUrl, 'https://env-api.example.test/v1/public/shares/ENV_TOKEN');
});

test('404, revoked data, and network errors render the same clear invalid page', async (t) => {
  const cases = [
    { fetchImpl: async () => jsonResponse({}, 404) },
    { fetchImpl: async () => jsonResponse({ data: { subject_type: 'hamster', display: {}, media: [], revoked: true } }) },
    { fetchImpl: async () => { throw new Error('upstream unavailable'); } },
  ];
  const servers = [];

  for (const options of cases) {
    const server = createServer({ apiBaseUrl: 'https://api.example.test', ...options });
    servers.push(server);
    const port = await listen(server);
    const response = await fetch(`http://127.0.0.1:${port}/s/FAILURE_TOKEN`);
    const html = await response.text();
    assert.equal(response.status, 404);
    assert.match(html, /分享链接已失效/);
    assert.doesNotMatch(html, /FAILURE_TOKEN|upstream unavailable/);
  }

  t.after(() => Promise.all(servers.map((server) => new Promise((resolve) => server.close(resolve)))));
});

test('builds the public share endpoint under the configured API base', () => {
  assert.equal(
    buildPublicShareUrl('http://api.example.test/', 'a token'),
    'http://api.example.test/v1/public/shares/a%20token',
  );
});
