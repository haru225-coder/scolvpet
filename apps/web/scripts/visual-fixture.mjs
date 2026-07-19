import { readFile } from 'node:fs/promises';

import { createServer } from '../src/server.mjs';

const cover = await readFile(
  new URL('../../mobile/assets/brand/login_hero.png', import.meta.url),
);

const catalog = {
  data: {
    site: {
      slug: 'snow-cattery',
      title: '雪团熊舍',
      organization_name: '雪团熊舍',
      tagline: '认真记录每一只金丝熊的成长，也认真回答领养前的每一个问题。',
      about:
        '这里展示正在接受咨询的仓鼠与公开资料。提交咨询后，熊舍会结合饲养经验和当前状态与你沟通。',
      contact_wechat: 'snow-house',
      contact_phone: '138 0013 8000',
    },
    campaign: {
      campaign_code: 'c_summer',
      title: '夏日成长记录',
      platform: 'wechat_channels',
    },
    hamsters: [
      {
        hamster_id: 'h-milk-tea',
        public_name: '奶茶',
        variety: '长毛金丝熊',
        sex: 'female',
        birth_date: '2026-04-18',
        summary: '亲人，作息稳定，适合愿意每天互动的新手家庭。',
        traits: ['亲人', '作息稳定', '接受咨询'],
        media: [
          {
            id: 'media-cover',
            kind: 'cover',
            status: 'ready',
            url: '/v1/public/sites/snow-cattery/media/media-cover',
          },
        ],
      },
      {
        hamster_id: 'h-cocoa',
        public_name: '可可',
        variety: '短毛金丝熊',
        sex: 'male',
        birth_date: '2026-05-02',
        summary: '好奇心强，喜欢探索，正在持续记录体重与作息。',
        traits: ['活泼', '爱探索'],
        media: [],
      },
    ],
  },
};

const fetchImpl = async (input) => {
  const url = String(input);
  if (url.includes('/media/media-cover')) {
    return {
      status: 200,
      headers: new Headers({
        'content-type': 'image/png',
        etag: '"visual-fixture-cover"',
      }),
      arrayBuffer: async () =>
        cover.buffer.slice(cover.byteOffset, cover.byteOffset + cover.byteLength),
    };
  }
  if (url.includes('/catalog')) {
    return { status: 200, json: async () => catalog };
  }
  if (url.includes('/consult')) {
    return {
      status: 200,
      json: async () => ({
        data: {
          answer: '奶茶的互动习惯更适合第一次饲养金丝熊的家庭。',
          session_token: 'visual-session',
          recommendations: [
            {
              hamster_id: 'h-milk-tea',
              public_name: '奶茶',
              reason: '亲人、作息稳定，公开资料较完整。',
            },
          ],
        },
      }),
    };
  }
  if (url.includes('/leads')) {
    return {
      status: 201,
      json: async () => ({ data: { contact_id: 'visual-contact' } }),
    };
  }
  return { status: 404, json: async () => ({}) };
};

const port = Number(process.env.WEB_PORT || 3100);
const server = createServer({
  apiBaseUrl: 'http://visual-fixture.local',
  fetchImpl,
});

server.listen(port, '127.0.0.1', () => {
  console.log(`Visual fixture: http://127.0.0.1:${port}/p/snow-cattery`);
});
