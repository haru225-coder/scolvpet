// Silent WeChat login decision logic (pure functions; wx APIs are injected).
// 三态：session（已绑定直接发 token）/ bind_required（存 ticket 待短信绑定）/
// fallback（任何失败都静默降级到现有短信流程）。

const WECHAT_TICKET_TTL_MS = 10 * 60 * 1000; // 服务端 ticket 10 分钟有效、一次性

/** Classify a wechat-sessions response into one of the three states. */
function resolveWechatSession(res) {
  const data = (res && res.data) || {};
  if (data.access_token) {
    return { state: 'session', token: data.access_token, phone: data.phone || '' };
  }
  if (data.bind_required === true && data.wechat_ticket) {
    return { state: 'bind_required', ticket: data.wechat_ticket };
  }
  return { state: 'fallback' };
}

/** Ticket freshness by the timestamp (ms) it was obtained at. */
function isTicketFresh(ticket, obtainedAt, now) {
  if (!ticket || !obtainedAt) return false;
  const t = typeof now === 'number' ? now : Date.now();
  return t - obtainedAt < WECHAT_TICKET_TTL_MS;
}

/**
 * Page-side branch decision:
 * 'token'   → 已有有效 session，跳过验证码；
 * 'binding' → 无 token 但持有未过期 ticket，短信验证后走 wechat-bindings；
 * 'session' → 维持现有 createCustomerSession 短信流程。
 */
function resolveLoginPath({ token, ticket, ticketObtainedAt, now }) {
  if (token) return 'token';
  if (isTicketFresh(ticket, ticketObtainedAt, now)) return 'binding';
  return 'session';
}

/**
 * App-launch silent login. All side effects go through injected callbacks so
 * this stays testable without the wx runtime. Never throws: any wx.login or
 * network failure degrades silently to the existing SMS flow.
 */
async function performSilentLogin({ wxLogin, createSession, onToken, onTicket, now }) {
  try {
    const jsCode = await wxLogin();
    if (!jsCode) return { state: 'fallback' };
    const outcome = resolveWechatSession(await createSession(jsCode));
    if (outcome.state === 'session') {
      onToken({ token: outcome.token, phone: outcome.phone });
    } else if (outcome.state === 'bind_required') {
      onTicket({
        ticket: outcome.ticket,
        obtainedAt: typeof now === 'number' ? now : Date.now(),
      });
    }
    return outcome;
  } catch (_) {
    return { state: 'fallback' };
  }
}

/**
 * SMS-verified login step for pages: bind with a fresh ticket when present,
 * otherwise fall back to the legacy customer session. Binding failure (e.g.
 * expired/consumed ticket) also drops through to the session retry so the
 * user is never stuck.
 */
async function loginWithSms({
  phone,
  verificationId,
  code,
  ticket,
  ticketObtainedAt,
  bindFn,
  sessionFn,
  onTicketConsumed,
  now,
}) {
  const path = resolveLoginPath({ token: '', ticket, ticketObtainedAt, now });
  if (path === 'binding') {
    try {
      const res = await bindFn({
        wechat_ticket: ticket,
        phone,
        verification_id: verificationId,
        code,
      });
      if (onTicketConsumed) onTicketConsumed();
      return { res, mode: 'binding' };
    } catch (_) {
      // ticket 一次性/已过期等绑定失败：丢弃 ticket，降级重试现有 session
      if (onTicketConsumed) onTicketConsumed();
    }
  }
  const res = await sessionFn({ phone, verification_id: verificationId, code });
  return { res, mode: 'session' };
}

module.exports = {
  WECHAT_TICKET_TTL_MS,
  resolveWechatSession,
  isTicketFresh,
  resolveLoginPath,
  performSilentLogin,
  loginWithSms,
};
