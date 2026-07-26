import http from 'node:http';
import { randomUUID } from 'node:crypto';
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

export function renderShell(title, body, options = {}) {
  const description = options.description || '查看熊舍公开资料，并向熊舍提交咨询。';
  return `<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="description" content="${escapeHtml(description)}">
    <meta name="robots" content="index,follow,max-image-preview:large">
    <meta property="og:type" content="website">
    <meta property="og:title" content="${escapeHtml(title)}">
    <meta property="og:description" content="${escapeHtml(description)}">
    <meta name="twitter:card" content="summary_large_image">
    <meta name="theme-color" content="#f3f0ec" media="(prefers-color-scheme: light)">
    <meta name="theme-color" content="#111415" media="(prefers-color-scheme: dark)">
    <title>${escapeHtml(title)}</title>
    <style>
      :root {
        color-scheme: light dark;
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "PingFang SC", "Noto Sans SC", sans-serif;
        --page: #f3f0ec;
        --page-glow: #f8e8de;
        --surface: #fffdfa;
        --surface-muted: #f4f1ed;
        --text: #292522;
        --muted: #6f6862;
        --quiet: #8b837c;
        --line: #d9d2cc;
        --accent: #ad5e3d;
        --accent-strong: #874329;
        --accent-soft: #f5dfd2;
        --success-soft: #e3efe8;
        --success-text: #2f6550;
        --danger: #a23d36;
        --shadow: rgba(76, 54, 43, .13);
        --radius: 18px;
      }
      * { box-sizing: border-box; }
      html { background: var(--page); }
      body {
        margin: 0;
        min-height: 100dvh;
        padding: clamp(12px, 3vw, 32px);
        color: var(--text);
        background:
          radial-gradient(circle at 8% 0%, var(--page-glow), transparent 36rem),
          var(--page);
      }
      main {
        width: min(980px, 100%);
        min-height: calc(100dvh - clamp(24px, 6vw, 64px));
        margin: 0 auto;
        padding: clamp(24px, 6vw, 64px);
        background: color-mix(in srgb, var(--surface) 96%, transparent);
        border: 1px solid var(--line);
        border-radius: var(--radius);
        box-shadow: 0 24px 72px var(--shadow);
      }
      h1 { max-width: 16ch; margin: 0; font-size: clamp(34px, 7vw, 62px); line-height: 1.03; letter-spacing: -.045em; }
      h2 { margin: 48px 0 16px; font-size: clamp(20px, 3vw, 26px); letter-spacing: -.02em; }
      h3 { letter-spacing: -.015em; }
      p { margin: 0; color: var(--muted); line-height: 1.72; }
      a { color: var(--accent-strong); }
      .brand-line { margin-bottom: 18px; color: var(--accent-strong); font-size: 14px; font-weight: 720; }
      .site-header { display: grid; gap: 16px; max-width: 720px; }
      .site-lead { max-width: 58ch; font-size: clamp(16px, 2.2vw, 20px); }
      .subject-type { display: inline-flex; width: fit-content; margin-top: 16px; padding: 7px 11px; color: var(--success-text); background: var(--success-soft); border-radius: 999px; font-size: 13px; font-weight: 720; }
      .subject-fields { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin: 0; }
      .subject-field { margin: 0; padding: 16px; background: var(--surface-muted); border-radius: 14px; }
      .subject-field dt { color: var(--quiet); font-size: 12px; }
      .subject-field dd { margin: 5px 0 0; color: var(--text); line-height: 1.5; overflow-wrap: anywhere; }
      .media-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; }
      .media-grid img { display: block; width: 100%; aspect-ratio: 1; object-fit: cover; border-radius: 14px; background: var(--surface-muted); }
      .muted { color: var(--quiet); font-size: 14px; }
      .about { max-width: 64ch; }
      .contact-row { display: flex; flex-wrap: wrap; gap: 10px 18px; margin-top: 18px; color: var(--muted); font-size: 14px; }
      .growth-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 14px; align-items: start; }
      .growth-card { overflow: hidden; background: var(--surface-muted); border: 1px solid var(--line); border-radius: var(--radius); }
      .growth-card__media { display: block; width: 100%; aspect-ratio: 4 / 3; object-fit: cover; background: var(--accent-soft); }
      .growth-card__media-empty { display: grid; width: 100%; aspect-ratio: 4 / 3; place-items: center; padding: 24px; color: var(--accent-strong); background: var(--accent-soft); font-size: 14px; font-weight: 680; text-align: center; }
      .growth-card__body { padding: 18px; }
      .growth-card h3 { margin: 0 0 8px; font-size: 19px; }
      .growth-card p { margin-top: 6px; }
      .traits { margin-top: 10px; color: var(--accent-strong); font-size: 13px; font-weight: 650; }
      .growth-card__title-row { display: flex; gap: 10px; align-items: flex-start; justify-content: space-between; }
      .growth-card__title-row h3 { margin: 0; flex: 1; }
      .status-badge { display: inline-flex; flex-shrink: 0; padding: 5px 9px; border-radius: 999px; background: var(--surface); color: var(--quiet); border: 1px solid var(--line); font-size: 12px; font-weight: 700; }
      .status-badge--ok { color: var(--success-text); background: var(--success-soft); border-color: transparent; }
      .growth-card__reserve { margin-top: 14px; padding: 14px; }
      .price { margin-top: 6px; color: var(--accent-strong); font-weight: 700; }
      .campaign { display: grid; grid-template-columns: 1fr auto; gap: 12px; align-items: start; margin-top: 28px; padding: 18px; color: var(--accent-strong); background: var(--accent-soft); border-radius: var(--radius); }
      .campaign span { color: var(--muted); font-size: 13px; }
      .answer { margin-bottom: 16px; padding: 18px; background: var(--surface-muted); border-left: 4px solid var(--accent); border-radius: 0 14px 14px 0; }
      .answer strong { color: var(--accent-strong); }
      .recommendations { display: grid; gap: 8px; margin-top: 12px; }
      .form-panel { padding: clamp(18px, 4vw, 28px); background: var(--surface-muted); border-radius: var(--radius); }
      .doc-body { margin: 0; white-space: pre-wrap; word-break: break-word; color: var(--text); font: inherit; line-height: 1.7; }
      .form-error { margin: 0 0 12px; padding: 12px 14px; color: var(--danger); background: color-mix(in srgb, var(--danger) 10%, transparent); border-radius: 12px; }
      form { display: grid; gap: 10px; }
      label { color: var(--text); font-size: 13px; font-weight: 650; }
      .helper { margin: -4px 0 4px; color: var(--quiet); font-size: 12px; }
      input, textarea { width: 100%; padding: 12px 13px; color: var(--text); border: 1px solid var(--line); border-radius: 12px; font: inherit; background: var(--surface); }
      input::placeholder, textarea::placeholder { color: var(--quiet); opacity: 1; }
      textarea { min-height: 90px; resize: vertical; }
      button { width: fit-content; margin-top: 6px; padding: 12px 18px; border: 0; border-radius: 999px; color: #fffaf6; background: var(--accent-strong); font: inherit; font-weight: 720; cursor: pointer; }
      button:active { transform: scale(.98); }
      :focus-visible { outline: 3px solid color-mix(in srgb, var(--accent) 72%, transparent); outline-offset: 3px; }
      @media (prefers-color-scheme: dark) {
        :root {
          --page: #111415;
          --page-glow: #34241e;
          --surface: #191c1d;
          --surface-muted: #222627;
          --text: #f3ece6;
          --muted: #bbb2aa;
          --quiet: #958b84;
          --line: #3c4142;
          --accent: #d4926a;
          --accent-strong: #efb18a;
          --accent-soft: #3b2922;
          --success-soft: #20362d;
          --success-text: #a8d4be;
          --danger: #f09a92;
          --shadow: rgba(3, 5, 5, .42);
        }
        button { color: #28170f; background: #efb18a; }
      }
      @media (prefers-reduced-motion: no-preference) {
        main { animation: page-enter .42s cubic-bezier(.16, 1, .3, 1) both; }
        button { transition: transform .16s ease, filter .16s ease; }
        button:hover { filter: brightness(1.05); }
        @keyframes page-enter { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
      }
      @media (prefers-reduced-motion: reduce) {
        *, *::before, *::after { scroll-behavior: auto !important; animation-duration: .01ms !important; animation-iteration-count: 1 !important; transition-duration: .01ms !important; }
      }
      @media (max-width: 640px) {
        body { padding: 10px; }
        main { min-height: calc(100dvh - 20px); padding: 24px 18px; border-radius: 16px; }
        h1 { max-width: none; }
        .campaign { grid-template-columns: 1fr; }
        .growth-grid { grid-template-columns: 1fr; }
        button { width: 100%; }
      }
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
    '<div class="brand-line">熊舍管家公开分享</div><h1>分享链接已失效</h1><p class="site-lead">该公开分享可能已撤销、已过期，或当前暂时不可读取。请向分享者索取新的链接。</p>',
    { description: '这个熊舍管家公开分享链接当前不可用。' },
  );
}

export function renderInvalidDocument() {
  return renderShell(
    '单据不可用',
    '<div class="brand-line">熊舍管家客户单据</div><h1>单据链接不可用</h1><p class="site-lead">该合同或回执可能尚未签发、链接有误，或已停止公开。请向熊舍索取新的链接。</p>',
    { description: '合同或回执公开链接当前不可用。' },
  );
}

export function renderPublicDocument(data) {
  const kindLabel = data?.kind_label || (data?.kind === 'receipt' ? '回执' : '合同');
  const title = typeof data?.title === 'string' && data.title.trim() ? data.title : kindLabel;
  const body = typeof data?.body_filled === 'string' ? data.body_filled : '';
  const contact = typeof data?.contact_name === 'string' ? data.contact_name : '';
  const amount = typeof data?.amount_label === 'string' ? data.amount_label : '';
  const issued = typeof data?.issued_at === 'string' ? data.issued_at : '';
  const metaBits = [
    kindLabel,
    contact ? `客户 ${contact}` : '',
    amount ? `金额 ${amount}` : '',
    issued ? `签发 ${issued.slice(0, 10)}` : '',
  ].filter(Boolean);
  return renderShell(
    title,
    `<div class="brand-line">熊舍管家 · 客户${escapeHtml(kindLabel)}</div>
     <header class="site-header">
       <h1>${escapeHtml(title)}</h1>
       ${metaBits.length ? `<p class="site-lead">${escapeHtml(metaBits.join(' · '))}</p>` : ''}
     </header>
     <section aria-labelledby="doc-body-heading">
       <h2 id="doc-body-heading">正文</h2>
       <div class="form-panel"><pre class="doc-body">${escapeHtml(body)}</pre></div>
     </section>
     <p class="muted">本页仅供查看已签发内容，业务状态以熊舍后台为准。</p>`,
    { description: `${title}的客户只读${kindLabel}。` },
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
    `<div class="brand-line">熊舍管家公开分享</div>
     <div class="site-header"><h1>${escapeHtml(title)}</h1>
     <div class="subject-type">${escapeHtml(subjectType)}</div>
     </div>
     <section aria-labelledby="subject-heading"><h2 id="subject-heading">主题对象</h2>${fields}</section>
     <section aria-labelledby="media-heading"><h2 id="media-heading">媒体</h2>${media}</section>`,
    { description: `${title}的公开资料与媒体。` },
  );
}

export function renderGrowthBoundary() {
  return renderShell(
    '公开主页暂时不可用',
    '<div class="brand-line">熊舍公开主页</div><h1>公开主页暂时不可用</h1><p class="site-lead">这个链接可能尚未发布，或当前暂时不可读取。请向熊舍索取新的链接。</p>',
    { description: '这个熊舍公开主页当前不可用。' },
  );
}

export function renderNotFound() {
  return renderShell(
    '页面不存在',
    '<div class="brand-line">熊舍管家公开页</div><h1>这里没有可访问的页面</h1><p class="site-lead">请检查链接是否完整，或返回熊舍发送给你的公开主页。</p>',
    { description: '请求的熊舍管家公开页面不存在。' },
  );
}

export function renderPublicGrowthPage(catalog, state = {}) {
  const site = isRecord(catalog?.site) ? catalog.site : {};
  const hamsters = Array.isArray(catalog?.hamsters) ? catalog.hamsters : [];
  const campaign = isRecord(catalog?.campaign) ? catalog.campaign : null;
  const slug = typeof site.slug === 'string' ? site.slug : '';
  const campaignCode = typeof state.campaignCode === 'string' ? state.campaignCode : campaign?.campaign_code || '';
  const recommendations = Array.isArray(state.recommendations) ? state.recommendations : [];
  const recommendationHtml = recommendations.length
    ? `<div class="recommendations">${recommendations.map((item) => `<div class="subject-field"><strong>${escapeHtml(item.public_name || '公开仓鼠')}</strong><p>${escapeHtml(item.reason || item.summary || '当前资料已公开并接受咨询。')}</p></div>`).join('')}</div>`
    : '';
  const answerHtml = state.answer
    ? `<div class="answer" role="status"><strong>AI 顾问</strong><p>${escapeHtml(state.answer)}</p>${recommendationHtml}</div>`
    : '';
  const leadMessage = state.leadSuccess
    ? '<div class="answer" role="status"><strong>已收到你的联系方式</strong><p>熊舍会根据你的咨询尽快联系你。</p></div>'
    : '';
  const reserveMessage = state.reserveSuccess
    ? `<div class="answer" role="status"><strong>预订已提交</strong><p>熊舍已收到你对「${escapeHtml(state.reserveTitle || '仓鼠')}」的预订，会尽快联系确认。</p></div>`
    : '';
  const consultError = state.form === 'consult' && state.error
    ? `<p class="form-error" role="alert">${escapeHtml(state.error)}</p>`
    : '';
  const leadError = state.form === 'lead' && state.error
    ? `<p class="form-error" role="alert">${escapeHtml(state.error)}</p>`
    : '';
  const reserveError = state.form === 'reserve' && state.error
    ? `<p class="form-error" role="alert">${escapeHtml(state.error)}</p>`
    : '';
  const consultValues = isRecord(state.consultValues) ? state.consultValues : {};
  const leadValues = isRecord(state.leadValues) ? state.leadValues : {};
  const reserveValues = isRecord(state.reserveValues) ? state.reserveValues : {};
  const consultationToken = state.sessionToken || state.consultationToken || '';
  const interestID = state.interestedHamsterId || '';
  const contacts = [
    site.contact_wechat ? `微信 ${site.contact_wechat}` : '',
    site.contact_phone ? `电话 ${site.contact_phone}` : '',
  ].filter(Boolean);
  const hamsterCardsWithForms = hamsters.length
    ? hamsters.map((item, index) => renderGrowthHamsterCard(item, {
      slug,
      index,
      campaignCode,
      reserveValues: interestID && item?.hamster_id === interestID ? reserveValues : {},
      reserveError: interestID && item?.hamster_id === interestID ? reserveError : '',
    })).join('')
    : '<p class="muted">当前暂无公开且接受咨询的仓鼠。</p>';
  return renderShell(
    site.title || '熊舍公开主页',
    `<header class="site-header">
       <div class="brand-line">${escapeHtml(site.organization_name || '熊舍公开主页')}</div>
       <h1>${escapeHtml(site.title || '熊舍公开主页')}</h1>
       ${site.tagline ? `<p class="site-lead">${escapeHtml(site.tagline)}</p>` : ''}
       ${site.about ? `<p class="about">${escapeHtml(site.about)}</p>` : ''}
       ${contacts.length ? `<div class="contact-row">${contacts.map((item) => `<span>${escapeHtml(item)}</span>`).join('')}</div>` : ''}
     </header>
     ${campaign ? `<div class="campaign"><strong>${escapeHtml(campaign.title || '本次内容')}</strong><span>${escapeHtml(platformLabel(campaign.platform))}</span></div>` : ''}
     ${reserveMessage}
     <section aria-labelledby="catalog-heading"><h2 id="catalog-heading">公开仓鼠</h2><div class="growth-grid">${hamsterCardsWithForms}</div></section>
     <section aria-labelledby="consult-heading"><h2 id="consult-heading">问问 AI 顾问</h2>${answerHtml}
       <div class="form-panel">${consultError}
       <form method="post" action="/p/${encodeURIComponent(slug)}/consult">
         <input type="hidden" name="campaign_code" value="${escapeHtml(campaignCode)}">
         <input type="hidden" name="session_token" value="${escapeHtml(state.sessionToken || '')}">
         <input type="hidden" name="interested_hamster_id" value="${escapeHtml(interestID)}">
         <label for="message">你想了解什么</label>
         <textarea id="message" name="message" maxlength="2000" required placeholder="例如：新手适合哪只？">${escapeHtml(consultValues.message || '')}</textarea>
         <button type="submit">获取建议</button>
       </form></div>
     </section>
     <section aria-labelledby="lead-heading"><h2 id="lead-heading">留下联系方式</h2>${leadMessage}
       <div class="form-panel">${leadError}
       <form method="post" action="/p/${encodeURIComponent(slug)}/lead">
         <input type="hidden" name="campaign_code" value="${escapeHtml(campaignCode)}">
         <input type="hidden" name="consultation_token" value="${escapeHtml(consultationToken)}">
         <input type="hidden" name="interested_hamster_id" value="${escapeHtml(interestID)}">
         <label for="lead-name">怎么称呼</label><input id="lead-name" name="name" maxlength="120" autocomplete="name" required value="${escapeHtml(leadValues.name || '')}">
         <label for="lead-phone">手机号</label><input id="lead-phone" name="phone" maxlength="32" inputmode="tel" autocomplete="tel" value="${escapeHtml(leadValues.phone || '')}">
         <label for="lead-wechat">微信</label><input id="lead-wechat" name="wechat" maxlength="64" autocomplete="off" value="${escapeHtml(leadValues.wechat || '')}">
         <p class="helper">手机号和微信至少填写一项。</p>
         <label for="lead-intent">补充说明</label><textarea id="lead-intent" name="intent_summary" maxlength="2000">${escapeHtml(leadValues.intent_summary || '')}</textarea>
         <button type="submit">提交联系方式</button>
       </form></div>
     </section>`,
    {
      description: site.tagline || site.about || `查看${site.title || '熊舍'}的公开仓鼠资料并提交咨询。`,
    },
  );
}

export function createServer(options = {}) {
  const apiBaseUrl = options.apiBaseUrl ?? process.env.WEB_API_BASE_URL;
  const fetchImpl = options.fetchImpl ?? globalThis.fetch;
  const flashes = new Map();

  const rememberFlash = (slug, state) => {
    const now = Date.now();
    for (const [key, value] of flashes) {
      if (value.expiresAt <= now) flashes.delete(key);
    }
    while (flashes.size >= 256) flashes.delete(flashes.keys().next().value);
    const id = randomUUID();
    flashes.set(id, { slug, state, expiresAt: now + 5 * 60 * 1000 });
    return id;
  };

  const readFlash = (id, slug) => {
    if (!id) return null;
    const flash = flashes.get(id);
    if (!flash || flash.slug !== slug || flash.expiresAt <= Date.now()) {
      flashes.delete(id);
      return null;
    }
    return flash.state;
  };

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

    if (request.method === 'GET' && /^\/d\/[^/]+$/.test(url.pathname)) {
      const token = readDocumentToken(url.pathname);
      if (!token) {
        return sendHtml(response, 404, renderInvalidDocument());
      }
      try {
        const doc = await fetchPublicDocument({ apiBaseUrl, fetchImpl, token });
        if (!doc) {
          return sendHtml(response, 404, renderInvalidDocument());
        }
        return sendHtml(response, 200, renderPublicDocument(doc));
      } catch {
        return sendHtml(response, 404, renderInvalidDocument());
      }
    }

    const growthPath = url.pathname.match(/^\/p\/([^/]+)$/);
    const growthAction = url.pathname.match(/^\/p\/([^/]+)\/(consult|lead|reserve)$/);
    const growthMedia = url.pathname.match(/^\/p\/([^/]+)\/media\/([^/]+)$/);
    if (growthMedia && request.method === 'GET') {
      const slug = decodePathPart(growthMedia[1]);
      const mediaId = decodePathPart(growthMedia[2]);
      const media = await fetchPublicGrowthMedia({ apiBaseUrl, fetchImpl, slug, mediaId });
      if (!media) return sendText(response, 404, '图片不存在或已停止公开');
      return sendBinary(response, 200, media.body, media.contentType, media.etag);
    }
    if (growthPath && request.method === 'GET') {
      const slug = decodePathPart(growthPath[1]);
      try {
        const campaignCode = url.searchParams.get('campaign') || '';
        const catalog = await fetchPublicGrowthCatalog({ apiBaseUrl, fetchImpl, slug, campaignCode });
        const flash = readFlash(url.searchParams.get('result'), slug);
        return catalog
          ? sendHtml(response, 200, renderPublicGrowthPage(catalog, { campaignCode, ...flash }))
          : sendHtml(response, 404, renderGrowthBoundary());
      } catch {
        return sendHtml(response, 404, renderGrowthBoundary());
      }
    }
    if (growthAction && request.method === 'POST') {
      const slug = decodePathPart(growthAction[1]);
      const form = await readFormBody(request);
      if (!form) return sendHtml(response, 413, renderGrowthBoundary());
      const campaignCode = form.campaign_code || '';
      const action = growthAction[2];
      // Web no longer accepts reservation POSTs — official trade is miniprogram.
      if (action === 'reserve') {
        let catalog = null;
        try { catalog = await fetchPublicGrowthCatalog({ apiBaseUrl, fetchImpl, slug, campaignCode }); } catch { /* boundary */ }
        if (!catalog) return sendHtml(response, 404, renderGrowthBoundary());
        return sendHtml(response, 409, renderPublicGrowthPage(catalog, {
          campaignCode,
          form: 'reserve',
          error: '请使用微信小程序完成验证后预订。Web 已停止直接提交预订。',
          interestedHamsterId: form.hamster_id,
        }));
      }
      const endpoint = action === 'consult' ? 'consult' : 'leads';
      let catalog = null;
      try { catalog = await fetchPublicGrowthCatalog({ apiBaseUrl, fetchImpl, slug, campaignCode }); } catch { /* friendly boundary below */ }
      if (!catalog) return sendHtml(response, 404, renderGrowthBoundary());
      const result = await proxyPublicGrowthAction({ apiBaseUrl, fetchImpl, slug, endpoint, form });
      if (!result.ok && (result.status === 400 || result.status === 409 || result.status === 422)) {
        const state = endpoint === 'consult'
          ? { campaignCode, form: 'consult', error: publicFormError(result, '请检查咨询内容后再提交。'), consultValues: form, sessionToken: form.session_token, interestedHamsterId: form.interested_hamster_id }
          : { campaignCode, form: 'lead', error: publicFormError(result, '请检查联系方式后再提交。'), leadValues: form, consultationToken: form.consultation_token, interestedHamsterId: form.interested_hamster_id };
        return sendHtml(response, result.status === 409 ? 409 : result.status, renderPublicGrowthPage(catalog, state));
      }
      if (!result.ok) {
        return sendHtml(response, result.status === 404 ? 404 : 502, renderGrowthBoundary());
      }
      const data = result.data?.data || {};
      const state = endpoint === 'consult'
        ? { campaignCode, answer: data.answer, recommendations: data.recommendations, sessionToken: data.session_token, interestedHamsterId: data.recommendations?.[0]?.hamster_id }
        : { campaignCode, leadSuccess: true, consultationToken: form.consultation_token };
      const resultId = rememberFlash(slug, state);
      const query = new URLSearchParams();
      if (campaignCode) query.set('campaign', campaignCode);
      query.set('result', resultId);
      return sendRedirect(response, `/p/${encodeURIComponent(slug)}?${query}`);
    }

    return sendHtml(response, 404, renderNotFound());
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

/** Strip trailing /v1 from API root so builders never emit /v1/v1/... */
export function normalizeApiRoot(apiBaseUrl) {
  const base = new URL(String(apiBaseUrl));
  let path = base.pathname.replace(/\/+$/, '');
  if (path === '/v1' || path.endsWith('/v1')) {
    path = path.slice(0, -3);
  }
  base.pathname = path || '/';
  base.search = '';
  base.hash = '';
  return base;
}

function joinV1Path(apiBaseUrl, suffixPath) {
  const base = new URL(String(apiBaseUrl));
  let root = base.pathname.replace(/\/+$/, '');
  if (root === '/v1' || root.endsWith('/v1')) {
    root = root.slice(0, -3);
  }
  const suffix = suffixPath.startsWith('/') ? suffixPath : `/${suffixPath}`;
  // root may be '' after stripping bare /v1.
  base.pathname = `${root}/v1${suffix}`.replace(/\/{2,}/g, '/');
  if (!base.pathname.startsWith('/')) {
    base.pathname = `/${base.pathname}`;
  }
  base.search = '';
  base.hash = '';
  return base;
}

export function buildPublicShareUrl(apiBaseUrl, token) {
  const base = joinV1Path(apiBaseUrl, `/public/shares/${encodeURIComponent(token)}`);
  base.search = '';
  base.hash = '';
  return base.toString();
}

export function buildPublicDocumentUrl(apiBaseUrl, token) {
  const base = joinV1Path(apiBaseUrl, `/public/documents/${encodeURIComponent(token)}`);
  base.search = '';
  base.hash = '';
  return base.toString();
}

export async function fetchPublicDocument({ apiBaseUrl, fetchImpl = globalThis.fetch, token }) {
  if (!apiBaseUrl || typeof fetchImpl !== 'function' || !token) return null;
  try {
    const response = await fetchImpl(buildPublicDocumentUrl(apiBaseUrl, token), {
      headers: { Accept: 'application/json' },
    });
    if (!response || response.status !== 200) return null;
    const payload = await response.json();
    return isRecord(payload?.data) ? payload.data : null;
  } catch {
    return null;
  }
}

function readDocumentToken(pathname) {
  if (!pathname.startsWith('/d/')) return null;
  const rawToken = pathname.slice('/d/'.length);
  try {
    const token = decodeURIComponent(rawToken);
    return token && !/[\\/]/.test(token) && token.length <= 64 ? token : null;
  } catch {
    return null;
  }
}

export function buildPublicGrowthCatalogUrl(apiBaseUrl, slug, campaignCode = '') {
  const base = joinV1Path(apiBaseUrl, `/public/sites/${encodeURIComponent(slug)}/catalog`);
  base.search = campaignCode ? `?campaign=${encodeURIComponent(campaignCode)}` : '';
  base.hash = '';
  return base.toString();
}

export function buildPublicGrowthMediaUrl(apiBaseUrl, slug, mediaId) {
  const base = joinV1Path(apiBaseUrl, `/public/sites/${encodeURIComponent(slug)}/media/${encodeURIComponent(mediaId)}`);
  base.search = '';
  base.hash = '';
  return base.toString();
}

export async function fetchPublicGrowthCatalog({ apiBaseUrl, fetchImpl = globalThis.fetch, slug, campaignCode = '' }) {
  if (!apiBaseUrl || typeof fetchImpl !== 'function') return null;
  const response = await fetchImpl(buildPublicGrowthCatalogUrl(apiBaseUrl, slug, campaignCode), { headers: { Accept: 'application/json' } });
  if (!response || response.status !== 200) return null;
  const payload = await response.json();
  const data = payload?.data;
  if (!isRecord(data) || !isRecord(data.site) || !Array.isArray(data.hamsters)) return null;
  return data;
}

export const PROXYABLE_IMAGE_TYPES = new Set([
  'image/avif',
  'image/webp',
  'image/png',
  'image/jpeg',
  'image/gif',
]);

export async function fetchPublicGrowthMedia({ apiBaseUrl, fetchImpl = globalThis.fetch, slug, mediaId }) {
  if (!apiBaseUrl || typeof fetchImpl !== 'function' || !slug || !mediaId) return null;
  try {
    const response = await fetchImpl(buildPublicGrowthMediaUrl(apiBaseUrl, slug, mediaId), {
      headers: { Accept: 'image/avif,image/webp,image/*,*/*;q=0.8' },
    });
    const contentType = response?.headers?.get?.('content-type') || '';
    // Raster whitelist only: image/svg+xml is a script-capable document and
    // must never be proxied onto this origin.
    const mediaType = contentType.split(';')[0].trim().toLowerCase();
    if (!response || response.status !== 200 || !PROXYABLE_IMAGE_TYPES.has(mediaType) || typeof response.arrayBuffer !== 'function') {
      return null;
    }
    return {
      body: Buffer.from(await response.arrayBuffer()),
      contentType: mediaType,
      etag: response.headers?.get?.('etag') || '',
    };
  } catch {
    return null;
  }
}

async function proxyPublicGrowthAction({ apiBaseUrl, fetchImpl = globalThis.fetch, slug, endpoint, form }) {
  if (!apiBaseUrl || typeof fetchImpl !== 'function') return { ok: false, status: 503, data: null };
  const base = joinV1Path(apiBaseUrl, `/public/sites/${encodeURIComponent(slug)}/${endpoint}`);
  base.search = '';
  base.hash = '';
  const body = endpoint === 'consult'
    ? { message: form.message || '', session_token: form.session_token || '', campaign_code: form.campaign_code || '', interested_hamster_id: form.interested_hamster_id || '', landing_path: `/p/${slug}` }
    : endpoint === 'reservations'
      ? { hamster_id: form.hamster_id || '', name: form.name || '', phone: form.phone || '', wechat: form.wechat || '', notes: form.notes || '' }
      : { name: form.name || '', phone: form.phone || '', wechat: form.wechat || '', campaign_code: form.campaign_code || '', consultation_token: form.consultation_token || '', interested_hamster_id: form.interested_hamster_id || '', intent_summary: form.intent_summary || '', landing_path: `/p/${slug}` };
  try {
    const response = await fetchImpl(base.toString(), {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'Idempotency-Key': `web-${randomUUID()}`,
      },
      body: JSON.stringify(body),
    });
    let data = null;
    try { data = await response.json(); } catch { /* friendly boundary below */ }
    return { ok: response.status === 200 || response.status === 201, status: response.status, data };
  } catch {
    return { ok: false, status: 503, data: null };
  }
}

function renderGrowthHamsterCard(item, {
  slug,
  index,
  campaignCode = '',
  reserveValues = {},
  reserveError = '',
} = {}) {
  const traits = Array.isArray(item.traits) ? item.traits.filter(Boolean).join(' · ') : '';
  const facts = [item.variety, SEX_LABELS[item.sex] || item.sex, item.birth_date].filter(Boolean).join(' · ');
  const title = item.public_name || '公开仓鼠';
  const hamsterId = typeof item.hamster_id === 'string' ? item.hamster_id : '';
  const mediaUrl = publicGrowthMediaUrl(item.media, slug);
  const media = mediaUrl
    ? `<img class="growth-card__media" src="${escapeHtml(mediaUrl)}" alt="${escapeHtml(`${title}的公开照片`)}" width="720" height="540" loading="${index === 0 ? 'eager' : 'lazy'}"${index === 0 ? ' fetchpriority="high"' : ''}>`
    : `<div class="growth-card__media-empty" role="img" aria-label="${escapeHtml(`${title}暂无公开照片`)}"><span>暂无公开照片</span></div>`;
  const price = item.price_label ? `<p class="price">${escapeHtml(item.price_label)}</p>` : '';
  const reservable = item.reservable === true;
  const statusBadge = reservable
    ? '<span class="status-badge status-badge--ok">可预订</span>'
    : '<span class="status-badge">暂不可订</span>';
  // Official trade entry is WeChat miniprogram (verified customer session).
  // Web must not POST unauthenticated /reservations (backend returns 401).
  const reserveForm = reservable && hamsterId
    ? `<div class="form-panel growth-card__reserve">
         <p class="helper"><strong>预订请用微信小程序</strong>完成手机号验证后提交，可同步「我的预订」与合同回执。</p>
         <p class="helper">熊舍公开路径：<code>${escapeHtml(slug)}</code></p>
         <p class="helper muted">本页仅支持浏览、咨询与留资。</p>
       </div>`
    : '';
  return `<article class="growth-card" data-hamster-id="${escapeHtml(hamsterId)}" data-reservable="${reservable ? 'true' : 'false'}">${media}<div class="growth-card__body"><div class="growth-card__title-row"><h3>${escapeHtml(title)}</h3>${statusBadge}</div>${facts ? `<p>${escapeHtml(facts)}</p>` : ''}${price}${item.summary ? `<p>${escapeHtml(item.summary)}</p>` : ''}${traits ? `<div class="traits">${escapeHtml(traits)}</div>` : ''}${reserveForm}</div></article>`;
}

function publicGrowthMediaUrl(media, slug) {
  if (!Array.isArray(media)) return null;
  const preferred = [...media].sort((left, right) => mediaKindPriority(left?.kind) - mediaKindPriority(right?.kind));
  for (const item of preferred) {
    if (!isRecord(item) || (item.status && item.status !== 'ready')) continue;
    // 同源 /p 代理优先，避免把 API 路径直接暴露给浏览器。
    const id = typeof item.id === 'string' ? item.id : '';
    if (id && slug) return `/p/${encodeURIComponent(slug)}/media/${encodeURIComponent(id)}`;
    const absolute = safeMediaUrl(item.url);
    if (absolute) return absolute;
  }
  return null;
}

function mediaKindPriority(kind) {
  return kind === 'cover' ? 0 : kind === 'thumbnail' ? 1 : kind === 'preview' ? 2 : 3;
}

function platformLabel(value) {
  return value === 'wechat_channels'
    ? '视频号'
    : value === 'douyin'
      ? '抖音'
      : value === 'xiaohongshu'
        ? '小红书'
        : value || '公开活动';
}

function publicFormError(result, fallback) {
  const message = result?.data?.error?.message;
  return typeof message === 'string' && message.trim() && message.length <= 240
    ? message.trim()
    : fallback;
}

function decodePathPart(value) {
  try { return decodeURIComponent(value); } catch { return ''; }
}

async function readFormBody(request) {
  let raw = '';
  for await (const chunk of request) {
    raw += chunk;
    if (raw.length > 65536) return null;
  }
  return Object.fromEntries(new URLSearchParams(raw));
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
  // Relative media paths are valid; the browser resolves them against the page host.
  if (value.startsWith('/v1/') || value.startsWith('/p/') || value.startsWith('/s/')) {
    return value;
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

function sendRedirect(response, location) {
  response.writeHead(303, {
    'Cache-Control': 'no-store',
    Location: location,
  });
  response.end();
}

function sendText(response, status, value) {
  response.writeHead(status, {
    'Cache-Control': 'no-store',
    'Content-Type': 'text/plain; charset=utf-8',
  });
  response.end(value);
}

function sendBinary(response, status, value, contentType, etag = '') {
  const headers = {
    'Cache-Control': 'public, no-store, max-age=0',
    'Content-Type': contentType,
    'X-Content-Type-Options': 'nosniff',
  };
  if (etag) headers.ETag = etag;
  response.writeHead(status, headers);
  response.end(value);
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
