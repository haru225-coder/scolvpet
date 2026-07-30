import test from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';

// utils/wechat_login.js is CommonJS (mini-program runtime); load it the same way.
const require = createRequire(import.meta.url);
const wechatLogin = require('../src/utils/wechat_login.js');

const {
  WECHAT_TICKET_TTL_MS,
  resolveWechatSession,
  isTicketFresh,
  performSilentLogin,
  resolvePhoneAuthorizationState,
} = wechatLogin;

// Contract fixtures: wechat-sessions / wechat-bindings response shapes.
const BOUND_RESPONSE = {
  data: {
    token_type: 'Bearer',
    access_token: 'ct_fixture_token',
    expires_in_seconds: 2592000,
    phone: '+8613800138000',
  },
};
const BIND_REQUIRED_RESPONSE = {
  data: { bind_required: true, wechat_ticket: 'wt_fixture_ticket' },
};

test('resolveWechatSession classifies the three contract states', () => {
  const bound = resolveWechatSession(BOUND_RESPONSE);
  assert.deepEqual(bound, {
    state: 'session',
    token: 'ct_fixture_token',
    phone: '+8613800138000',
  });

  const bind = resolveWechatSession(BIND_REQUIRED_RESPONSE);
  assert.deepEqual(bind, { state: 'bind_required', ticket: 'wt_fixture_ticket' });

  // Malformed / empty payloads must degrade, never throw.
  assert.equal(resolveWechatSession(null).state, 'fallback');
  assert.equal(resolveWechatSession({}).state, 'fallback');
  assert.equal(resolveWechatSession({ data: { bind_required: true } }).state, 'fallback');
});

test('performSilentLogin: bound state saves token + phone', async () => {
  const saved = [];
  const outcome = await performSilentLogin({
    wxLogin: async () => 'js_code_1',
    createSession: async (jsCode) => {
      assert.equal(jsCode, 'js_code_1');
      return BOUND_RESPONSE;
    },
    onToken: (t) => saved.push(t),
    onTicket: () => assert.fail('onTicket must not fire in bound state'),
  });
  assert.equal(outcome.state, 'session');
  assert.deepEqual(saved, [{ token: 'ct_fixture_token', phone: '+8613800138000' }]);
});

test('performSilentLogin: bind_required stores ticket with timestamp', async () => {
  const now = 1700000000000;
  const tickets = [];
  const outcome = await performSilentLogin({
    wxLogin: async () => 'js_code_2',
    createSession: async () => BIND_REQUIRED_RESPONSE,
    onToken: () => assert.fail('onToken must not fire in bind_required state'),
    onTicket: (t) => tickets.push(t),
    now,
  });
  assert.equal(outcome.state, 'bind_required');
  assert.deepEqual(tickets, [{ ticket: 'wt_fixture_ticket', obtainedAt: now }]);
});

test('performSilentLogin: wx.login or API failure degrades silently', async () => {
  // wx.login yields no code (fail path resolves empty).
  const noCode = await performSilentLogin({
    wxLogin: async () => '',
    createSession: async () => assert.fail('must not call API without js_code'),
    onToken: () => assert.fail('no side effects on fallback'),
    onTicket: () => assert.fail('no side effects on fallback'),
  });
  assert.equal(noCode.state, 'fallback');

  // API rejection must be swallowed, not thrown to the caller.
  const apiDown = await performSilentLogin({
    wxLogin: async () => 'js_code_3',
    createSession: async () => {
      throw new Error('network down');
    },
    onToken: () => assert.fail('no side effects on fallback'),
    onTicket: () => assert.fail('no side effects on fallback'),
  });
  assert.equal(apiDown.state, 'fallback');
});

test('isTicketFresh enforces the 10-minute one-shot window', () => {
  const obtainedAt = 1700000000000;
  assert.equal(isTicketFresh('wt_x', obtainedAt, obtainedAt + 1000), true);
  assert.equal(isTicketFresh('wt_x', obtainedAt, obtainedAt + WECHAT_TICKET_TTL_MS - 1), true);
  assert.equal(isTicketFresh('wt_x', obtainedAt, obtainedAt + WECHAT_TICKET_TTL_MS), false);
  assert.equal(isTicketFresh('', obtainedAt, obtainedAt), false);
  assert.equal(isTicketFresh('wt_x', 0, obtainedAt), false);
});

test('手机号凭证失效时清空整段授权并要求重新授权，不自动展示短信', () => {
  assert.equal(typeof resolvePhoneAuthorizationState, 'function');
  assert.deepEqual(resolvePhoneAuthorizationState({ code: 'WECHAT_PHONE_REAUTHORIZE' }), {
    showSmsFallback: false,
    reauthorize: true,
    message: '授权已超时，请重新授权手机号',
  });
});

test('手机号冲突和境外号码按既定口径展示引导', () => {
  assert.equal(typeof resolvePhoneAuthorizationState, 'function');
  assert.deepEqual(resolvePhoneAuthorizationState({ code: 'PHONE_ALREADY_BOUND' }), {
    showSmsFallback: false,
    reauthorize: false,
    message: '该手机号已绑定其他微信号，请先在原微信号解绑',
  });
  assert.deepEqual(resolvePhoneAuthorizationState({ code: 'UNSUPPORTED_PHONE_COUNTRY' }), {
    showSmsFallback: true,
    reauthorize: false,
    message: '暂不支持非中国大陆手机号，请使用短信验证',
  });
  assert.deepEqual(resolvePhoneAuthorizationState({ code: 'WECHAT_PHONE_UNAVAILABLE' }), {
    showSmsFallback: true,
    reauthorize: false,
    message: '微信手机号授权暂不可用，请使用短信验证码登录',
  });
  assert.deepEqual(resolvePhoneAuthorizationState({ code: 'RATE_LIMITED' }), {
    showSmsFallback: false,
    reauthorize: false,
    message: '请求过于频繁，请稍后再试',
  });
});
