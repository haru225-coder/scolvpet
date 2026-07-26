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
  resolveLoginPath,
  performSilentLogin,
  loginWithSms,
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

test('resolveLoginPath: token skips SMS, fresh ticket binds, otherwise session', () => {
  const now = 1700000000000;
  assert.equal(
    resolveLoginPath({ token: 'ct_x', ticket: 'wt_x', ticketObtainedAt: now, now }),
    'token',
  );
  assert.equal(
    resolveLoginPath({ token: '', ticket: 'wt_x', ticketObtainedAt: now - 1000, now }),
    'binding',
  );
  assert.equal(
    resolveLoginPath({
      token: '',
      ticket: 'wt_x',
      ticketObtainedAt: now - WECHAT_TICKET_TTL_MS,
      now,
    }),
    'session',
  );
  assert.equal(resolveLoginPath({ token: '', ticket: '', ticketObtainedAt: 0, now }), 'session');
});

test('loginWithSms: fresh ticket goes through wechat-bindings and consumes it', async () => {
  const now = 1700000000000;
  const bindCalls = [];
  let consumed = 0;
  const { res, mode } = await loginWithSms({
    phone: '+8613800138000',
    verificationId: 'vid_1',
    code: '123456',
    ticket: 'wt_fixture_ticket',
    ticketObtainedAt: now - 1000,
    now,
    bindFn: async (body) => {
      bindCalls.push(body);
      return BOUND_RESPONSE;
    },
    sessionFn: async () => assert.fail('session must not be used when binding succeeds'),
    onTicketConsumed: () => {
      consumed += 1;
    },
  });
  assert.equal(mode, 'binding');
  assert.equal(res.data.access_token, 'ct_fixture_token');
  assert.equal(consumed, 1);
  assert.deepEqual(bindCalls, [
    {
      wechat_ticket: 'wt_fixture_ticket',
      phone: '+8613800138000',
      verification_id: 'vid_1',
      code: '123456',
    },
  ]);
});

test('loginWithSms: binding failure falls back to createCustomerSession', async () => {
  const now = 1700000000000;
  const sessionCalls = [];
  let consumed = 0;
  const { res, mode } = await loginWithSms({
    phone: '+8613800138000',
    verificationId: 'vid_2',
    code: '654321',
    ticket: 'wt_expired_on_server',
    ticketObtainedAt: now - 1000,
    now,
    bindFn: async () => {
      throw new Error('ticket expired');
    },
    sessionFn: async (body) => {
      sessionCalls.push(body);
      return { data: { access_token: 'ct_session_token' } };
    },
    onTicketConsumed: () => {
      consumed += 1;
    },
  });
  assert.equal(mode, 'session');
  assert.equal(res.data.access_token, 'ct_session_token');
  assert.equal(consumed, 1, 'failed ticket must be dropped so retries do not loop');
  assert.deepEqual(sessionCalls, [
    { phone: '+8613800138000', verification_id: 'vid_2', code: '654321' },
  ]);
});

test('loginWithSms: missing or expired ticket keeps the legacy session flow', async () => {
  const now = 1700000000000;
  const sessionCalls = [];
  const { mode } = await loginWithSms({
    phone: '+8613800138000',
    verificationId: 'vid_3',
    code: '111222',
    ticket: 'wt_stale',
    ticketObtainedAt: now - WECHAT_TICKET_TTL_MS - 1,
    now,
    bindFn: async () => assert.fail('expired ticket must not hit wechat-bindings'),
    sessionFn: async (body) => {
      sessionCalls.push(body);
      return { data: { access_token: 'ct_session_token' } };
    },
    onTicketConsumed: () => assert.fail('nothing to consume on the session path'),
  });
  assert.equal(mode, 'session');
  assert.equal(sessionCalls.length, 1);
});
