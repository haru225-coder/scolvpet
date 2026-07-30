// Silent WeChat login decision logic (pure functions; wx APIs are injected).
// 三态：session（已绑定直接发 token）/ bind_required（私有保存 ticket，待
// getPhoneNumber）/ fallback（静默登录失败，页面仍提供微信授权入口）。

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

/** Map public WeChat phone-binding errors to customer-facing page state. */
function resolvePhoneAuthorizationState({ code } = {}) {
  switch (code) {
    case 'WECHAT_PHONE_REAUTHORIZE':
      return {
        showSmsFallback: false,
        reauthorize: true,
        message: '授权已超时，请重新授权手机号',
      };
    case 'UNSUPPORTED_PHONE_COUNTRY':
      return {
        showSmsFallback: true,
        reauthorize: false,
        message: '暂不支持非中国大陆手机号，请使用短信验证',
      };
    case 'PHONE_ALREADY_BOUND':
      return {
        showSmsFallback: false,
        reauthorize: false,
        message: '该手机号已绑定其他微信号，请先在原微信号解绑',
      };
    case 'WECHAT_PHONE_QUOTA_EXHAUSTED':
      return {
        showSmsFallback: false,
        reauthorize: false,
        message: '微信手机号授权服务繁忙，请稍后再试',
      };
    case 'WECHAT_PHONE_UNAVAILABLE':
      return {
        showSmsFallback: true,
        reauthorize: false,
        message: '微信手机号授权暂不可用，请使用短信验证码登录',
      };
    case 'RATE_LIMITED':
      return {
        showSmsFallback: false,
        reauthorize: false,
        message: '请求过于频繁，请稍后再试',
      };
    default:
      return {
        showSmsFallback: false,
        reauthorize: false,
        message: '微信手机号授权暂不可用，请稍后再试',
      };
  }
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

module.exports = {
  WECHAT_TICKET_TTL_MS,
  resolveWechatSession,
  isTicketFresh,
  resolvePhoneAuthorizationState,
  performSilentLogin,
};
