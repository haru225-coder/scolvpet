const config = require('./config');

function request({ path, method = 'GET', data, header = {}, token }) {
  const app = getApp();
  const base = (app && app.globalData && app.globalData.apiBase) || config.API_BASE;
  const authToken = token || (app && app.globalData && app.globalData.customerToken) || '';
  return new Promise((resolve, reject) => {
    wx.request({
      url: `${base.replace(/\/$/, '')}${path}`,
      method,
      data,
      header: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'Idempotency-Key': header['Idempotency-Key'] || `mp-${Date.now()}-${Math.random().toString(16).slice(2)}`,
        ...(authToken ? { Authorization: `Bearer ${authToken}` } : {}),
        ...header,
      },
      success(res) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(res.data);
          return;
        }
        const message =
          (res.data && res.data.error && res.data.error.message) ||
          `请求失败 (${res.statusCode})`;
        const error = new Error(message);
        error.statusCode = res.statusCode;
        if (res.data && res.data.error && res.data.error.code) {
          error.code = res.data.error.code;
        }
        reject(error);
      },
      fail(err) {
        reject(err);
      },
    });
  });
}

function apiRoot() {
  const app = getApp();
  return ((app && app.globalData && app.globalData.apiBase) || config.API_BASE).replace(/\/$/, '');
}

function absoluteMediaUrl(relativeOrAbsolute) {
  if (!relativeOrAbsolute) return '';
  const u = String(relativeOrAbsolute);
  if (/^https?:\/\//i.test(u)) return u;
  return `${apiRoot()}${u.startsWith('/') ? u : `/${u}`}`;
}

function getSite(slug) {
  return request({ path: `/v1/public/sites/${encodeURIComponent(slug)}` });
}

function getCatalog(slug) {
  return request({ path: `/v1/public/sites/${encodeURIComponent(slug)}/catalog` });
}

function getPublicPedigree(slug, hamsterId, generations = 3) {
  return request({
    path: `/v1/public/sites/${encodeURIComponent(slug)}/hamsters/${encodeURIComponent(hamsterId)}/pedigree?generations=${generations}`,
  });
}

function postPublicSimulate(slug, body) {
  return request({
    path: `/v1/public/sites/${encodeURIComponent(slug)}/simulate`,
    method: 'POST',
    data: body || {},
  });
}

function createReservation(slug, body, token) {
  return request({
    path: `/v1/public/sites/${encodeURIComponent(slug)}/reservations`,
    method: 'POST',
    data: body,
    token,
  });
}

function sendCustomerCode(phone) {
  return request({
    path: '/v1/public/customer/verification-codes',
    method: 'POST',
    data: { phone, purpose: 'login' },
  });
}

function createCustomerSession(body) {
  return request({
    path: '/v1/public/customer/sessions',
    method: 'POST',
    data: body,
  });
}

function createWechatSession(jsCode) {
  return request({
    path: '/v1/public/customer/wechat-sessions',
    method: 'POST',
    data: { js_code: jsCode },
  });
}

function bindWechatIdentity({ wechat_ticket, phone, verification_id, code }) {
  return request({
    path: '/v1/public/customer/wechat-bindings',
    method: 'POST',
    data: { wechat_ticket, phone, verification_id, code },
  });
}

function unbindWechat(token) {
  return request({
    path: '/v1/customer/wechat-bindings/current',
    method: 'DELETE',
    token,
  });
}

function listMyReservations(token) {
  return request({ path: '/v1/customer/reservations', token });
}

function cancelMyReservation(id, token) {
  return request({
    path: `/v1/customer/reservations/${encodeURIComponent(id)}/cancel`,
    method: 'POST',
    token,
  });
}

function getPublicDocument(token) {
  return request({ path: `/v1/public/documents/${encodeURIComponent(token)}` });
}

function logoutCustomer(token) {
  return request({
    path: '/v1/customer/sessions/current',
    method: 'DELETE',
    token,
  });
}

/** Contract fixture: public hamster projection fields used by UI. */
function normalizePublicHamster(raw) {
  if (!raw || typeof raw !== 'object') return null;
  const hamsterId = String(raw.hamster_id || '').trim();
  if (!hamsterId) return null;
  const media = Array.isArray(raw.media) ? raw.media : [];
  const cover = media.find((m) => m && (m.kind === 'cover' || m.url)) || media[0];
  const coverUrl = cover && cover.url ? absoluteMediaUrl(cover.url) : '';
  return {
    hamster_id: hamsterId,
    public_name: raw.public_name || raw.name || '',
    summary: raw.summary || '',
    price_label: raw.price_label || '',
    reservable: raw.reservable === true,
    traits: Array.isArray(raw.traits) ? raw.traits : [],
    sex: raw.sex || '',
    variety: raw.variety || '',
    cover_url: coverUrl,
    media,
  };
}

/** Parse mini-program scene / query into { slug, hamsterId }. */
function parseEntryQuery(query) {
  const q = query || {};
  let slug = String(q.slug || q.s || '').trim();
  let hamsterId = String(q.id || q.h || q.hamster_id || '').trim();
  // scene from 小程序码: "s=my-cattery&h=uuid" or "my-cattery"
  const scene = q.scene != null ? decodeURIComponent(String(q.scene)) : '';
  if (scene) {
    if (scene.includes('=')) {
      scene.split('&').forEach((part) => {
        const [k, v] = part.split('=');
        if (k === 's' || k === 'slug') slug = decodeURIComponent(v || '');
        if (k === 'h' || k === 'id' || k === 'hamster_id') hamsterId = decodeURIComponent(v || '');
      });
    } else if (!slug) {
      slug = scene.trim();
    }
  }
  return { slug, hamsterId };
}

module.exports = {
  request,
  apiRoot,
  absoluteMediaUrl,
  getSite,
  getCatalog,
  getPublicPedigree,
  postPublicSimulate,
  createReservation,
  sendCustomerCode,
  createCustomerSession,
  createWechatSession,
  bindWechatIdentity,
  unbindWechat,
  listMyReservations,
  cancelMyReservation,
  getPublicDocument,
  logoutCustomer,
  normalizePublicHamster,
  parseEntryQuery,
};
