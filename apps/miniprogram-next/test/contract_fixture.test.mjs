import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const configSource = fs.readFileSync(
  new URL('../src/utils/config.js', import.meta.url),
  'utf8',
);

test('mini-program runtime config exposes an explicit environment gate', () => {
  assert.match(configSource, /const APP_ENV = 'development';/);
  assert.match(configSource, /const API_BASE = /);
  assert.match(configSource, /function assertRuntimeConfig\(\)/);
  assert.match(configSource, /APP_ENV === 'production'/);
});

// Mirror of utils/api.js normalizePublicHamster — keep in sync.
function normalizePublicHamster(raw) {
  if (!raw || typeof raw !== 'object') return null;
  const hamsterId = String(raw.hamster_id || '').trim();
  if (!hamsterId) return null;
  return {
    hamster_id: hamsterId,
    public_name: raw.public_name || raw.name || '',
    summary: raw.summary || '',
    price_label: raw.price_label || '',
    reservable: raw.reservable === true,
    traits: Array.isArray(raw.traits) ? raw.traits : [],
  };
}

test('public hamster projection uses hamster_id not id', () => {
  const ok = normalizePublicHamster({
    hamster_id: '11111111-1111-1111-1111-111111111111',
    public_name: '奶茶',
    reservable: true,
    summary: '亲人',
    price_label: '咨询',
  });
  assert.equal(ok.hamster_id, '11111111-1111-1111-1111-111111111111');
  assert.equal(ok.public_name, '奶茶');
  assert.equal(ok.reservable, true);

  const bad = normalizePublicHamster({ id: 'not-valid', public_name: 'x' });
  assert.equal(bad, null);
});
