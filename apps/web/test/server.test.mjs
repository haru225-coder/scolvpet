import test from 'node:test';
import assert from 'node:assert/strict';
import { createServer, renderShareBoundary } from '../src/server.mjs';

test('SSR health and share boundary', async (t) => {
  const server = createServer();
  await new Promise((resolve) => server.listen(0, resolve));
  t.after(() => server.close());
  const { port } = server.address();

  const health = await fetch(`http://127.0.0.1:${port}/healthz`);
  assert.equal(health.status, 200);
  assert.deepEqual(await health.json(), { status: 'ok', service: 'scolvpet-web-ssr' });

  const share = await fetch(`http://127.0.0.1:${port}/s/TOKEN`);
  assert.equal(share.status, 404);
  assert.equal(share.headers.get('cache-control'), 'no-store');
  assert.match(await share.text(), /WEB-01/);
  assert.match(renderShareBoundary(), /当前链接不会返回任何业务数据/);
});

