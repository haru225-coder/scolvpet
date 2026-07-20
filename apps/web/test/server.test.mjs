import test from 'node:test';
import assert from 'node:assert/strict';
import {
  buildPublicGrowthCatalogUrl,
  buildPublicGrowthMediaUrl,
  buildPublicShareUrl,
  createServer,
  renderGrowthBoundary,
  renderNotFound,
  renderPublicGrowthPage,
  renderShareBoundary,
} from '../src/server.mjs';

async function listen(server) {
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  return server.address().port;
}

function jsonResponse(value, status = 200) {
  return { status, json: async () => value };
}

function binaryResponse(value, contentType = 'image/webp', status = 200) {
  const body = Buffer.from(value);
  return {
    status,
    headers: new Headers({ 'content-type': contentType, etag: '"media-etag"' }),
    arrayBuffer: async () => body.buffer.slice(body.byteOffset, body.byteOffset + body.byteLength),
  };
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
  assert.match(renderShareBoundary(), /prefers-color-scheme: dark/);
  assert.match(renderShareBoundary(), /:focus-visible/);
  assert.match(renderShareBoundary(), /100dvh/);
  assert.match(renderShareBoundary(), /meta name="description"/);
  assert.doesNotMatch(renderShareBoundary(), /WEB-01|GROWTH/);
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
  assert.doesNotMatch(html, /owner@example\.test|H-SECRET|private-share-id|failed\.webp|TOKEN|WEB-01/);
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

test('builds the public growth catalog endpoint with campaign query', () => {
  assert.equal(
    buildPublicGrowthCatalogUrl('http://api.example.test/', 'snow-cattery', 'c_demo'),
    'http://api.example.test/v1/public/sites/snow-cattery/catalog?campaign=c_demo',
  );
});

test('builds the public growth media endpoint', () => {
  assert.equal(
    buildPublicGrowthMediaUrl('http://api.example.test/root/', 'snow-cattery', 'media 1'),
    'http://api.example.test/root/v1/public/sites/snow-cattery/media/media%201',
  );
});

test('SSR growth page fetches catalog, hides internals, and proxies consult/lead', async (t) => {
  const requests = [];
  const catalog = {
    data: {
      site: {
        slug: 'snow-cattery',
        title: '雪团熊舍',
        tagline: '认真繁育',
        about: '专注金丝熊',
        contact_wechat: 'snow-house',
      },
      campaign: {
        campaign_code: 'c_demo',
        title: '奶茶｜成长记录',
        platform: 'wechat_channels',
      },
      hamsters: [
        {
          hamster_id: 'h1',
          public_name: '奶茶',
          variety: '金丝熊',
          sex: 'female',
          birth_date: '2026-04-18',
          summary: '亲人、活动规律',
          traits: ['亲人', '活动规律'],
          published: true,
          consultable: true,
          reservable: true,
          media: [{ id: 'media-1', kind: 'cover', status: 'ready', url: '/v1/public/sites/snow-cattery/media/media-1' }],
        },
      ],
    },
  };
  const server = createServer({
    apiBaseUrl: 'https://api.example.test',
    fetchImpl: async (url, options = {}) => {
      requests.push({ url: String(url), method: options.method || 'GET', body: options.body });
      if (String(url).includes('/catalog')) return jsonResponse(catalog);
      if (String(url).includes('/consult')) {
        return jsonResponse({
          data: {
            answer: '比较匹配的是：奶茶。',
            session_token: 'sess-1',
            recommendations: [{ hamster_id: 'h1', public_name: '奶茶', reason: '亲人' }],
          },
        });
      }
      if (String(url).includes('/leads')) {
        return jsonResponse({ data: { contact_id: 'c1', attribution_id: 'a1' } }, 201);
      }
      if (String(url).includes('/reservations')) {
        return jsonResponse({
          data: {
            reservation_id: 'r1',
            contact_id: 'c1',
            hamster_id: 'h1',
            status: 'held',
            title: '预订 奶茶',
          },
        }, 201);
      }
      return jsonResponse({}, 404);
    },
  });
  const port = await listen(server);
  t.after(() => server.close());

  const page = await fetch(`http://127.0.0.1:${port}/p/snow-cattery?campaign=c_demo`);
  const html = await page.text();
  assert.equal(page.status, 200);
  assert.match(html, /雪团熊舍/);
  assert.match(html, /奶茶/);
  assert.match(html, /奶茶｜成长记录/);
  assert.match(html, /snow-house/);
  assert.match(html, /src="\/p\/snow-cattery\/media\/media-1"/);
  assert.match(html, /可预订/);
  assert.match(html, /action="\/p\/snow-cattery\/reserve"/);
  assert.match(html, /name="hamster_id" value="h1"/);
  assert.doesNotMatch(html, /internal_code|owner_id|H-SECRET|postgres|api\.example\.test|WEB-01|GROWTH/);
  assert.ok(requests.some((item) => item.url.includes('/catalog?campaign=c_demo')));

  const consult = await fetch(`http://127.0.0.1:${port}/p/snow-cattery/consult`, {
    method: 'POST',
    redirect: 'manual',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'message=新手适合哪只&campaign_code=c_demo',
  });
  assert.equal(consult.status, 303);
  const consultPage = await fetch(new URL(consult.headers.get('location'), `http://127.0.0.1:${port}`));
  const consultHtml = await consultPage.text();
  assert.equal(consultPage.status, 200);
  assert.match(consultHtml, /比较匹配的是：奶茶/);
  assert.match(consultHtml, /AI 顾问/);

  const lead = await fetch(`http://127.0.0.1:${port}/p/snow-cattery/lead`, {
    method: 'POST',
    redirect: 'manual',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'name=阿雪&wechat=snow123&campaign_code=c_demo&consultation_token=sess-1&interested_hamster_id=h1',
  });
  assert.equal(lead.status, 303);
  const leadPage = await fetch(new URL(lead.headers.get('location'), `http://127.0.0.1:${port}`));
  const leadHtml = await leadPage.text();
  assert.equal(leadPage.status, 200);
  assert.match(leadHtml, /已收到你的联系方式/);

  const reserve = await fetch(`http://127.0.0.1:${port}/p/snow-cattery/reserve`, {
    method: 'POST',
    redirect: 'manual',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'name=阿雪&wechat=snow123&hamster_id=h1&campaign_code=c_demo',
  });
  assert.equal(reserve.status, 303);
  assert.ok(requests.some((item) => item.url.includes('/reservations') && item.method === 'POST'));
  const reserveBody = requests.find((item) => item.url.includes('/reservations'))?.body;
  assert.match(String(reserveBody), /"hamster_id":"h1"/);
  assert.doesNotMatch(String(reserveBody), /variety|毛色|金丝熊/);
  const reservePage = await fetch(new URL(reserve.headers.get('location'), `http://127.0.0.1:${port}`));
  const reserveHtml = await reservePage.text();
  assert.equal(reservePage.status, 200);
  assert.match(reserveHtml, /预订已提交/);
  assert.match(reserveHtml, /预订 奶茶/);

  const rendered = renderPublicGrowthPage(catalog.data, { campaignCode: 'c_demo' });
  assert.match(rendered, /name="campaign_code" value="c_demo"/);
  assert.doesNotMatch(renderGrowthBoundary(), /api\.example|token|postgres/i);
});

test('growth validation errors keep submitted values and do not redirect', async (t) => {
  const catalog = {
    data: {
      site: { slug: 'snow-cattery', title: '雪团熊舍' },
      hamsters: [],
    },
  };
  const server = createServer({
    apiBaseUrl: 'https://api.example.test',
    fetchImpl: async (url) => String(url).includes('/catalog')
      ? jsonResponse(catalog)
      : jsonResponse({ error: { message: '手机号或微信至少填写一项' } }, 422),
  });
  const port = await listen(server);
  t.after(() => server.close());

  const response = await fetch(`http://127.0.0.1:${port}/p/snow-cattery/lead`, {
    method: 'POST',
    redirect: 'manual',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'name=阿雪&intent_summary=想了解奶茶',
  });
  const html = await response.text();
  assert.equal(response.status, 422);
  assert.match(html, /手机号或微信至少填写一项/);
  assert.match(html, /name="name"[^>]+value="阿雪"/);
  assert.match(html, />想了解奶茶<\/textarea>/);
});

test('growth media is proxied without exposing the API origin', async (t) => {
  let requestedUrl;
  const server = createServer({
    apiBaseUrl: 'https://api.example.test/root',
    fetchImpl: async (url) => {
      requestedUrl = String(url);
      return binaryResponse('image-bytes');
    },
  });
  const port = await listen(server);
  t.after(() => server.close());

  const response = await fetch(`http://127.0.0.1:${port}/p/snow-cattery/media/media-1`);
  assert.equal(response.status, 200);
  assert.equal(response.headers.get('content-type'), 'image/webp');
  assert.equal(Buffer.from(await response.arrayBuffer()).toString(), 'image-bytes');
  assert.equal(requestedUrl, 'https://api.example.test/root/v1/public/sites/snow-cattery/media/media-1');
});

test('unknown routes use the Chinese 404 page', async (t) => {
  const server = createServer();
  const port = await listen(server);
  t.after(() => server.close());
  const response = await fetch(`http://127.0.0.1:${port}/missing`);
  assert.equal(response.status, 404);
  assert.match(await response.text(), /这里没有可访问的页面/);
  assert.match(renderNotFound(), /页面不存在/);
});

test('growth upstream failures render friendly boundary without secrets', async (t) => {
  const server = createServer({
    apiBaseUrl: 'https://api.example.test/secret-path',
    fetchImpl: async () => {
      throw new Error('upstream unavailable with token=abc');
    },
  });
  const port = await listen(server);
  t.after(() => server.close());
  const response = await fetch(`http://127.0.0.1:${port}/p/missing-cattery?campaign=c_bad`);
  const html = await response.text();
  assert.equal(response.status, 404);
  assert.match(html, /公开主页暂时不可用/);
  assert.doesNotMatch(html, /secret-path|token=abc|upstream unavailable/);
});
