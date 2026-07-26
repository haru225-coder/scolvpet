import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

// Runs scripts/build-miniprogram.sh against a scratch copy (MP_TARGET_DIR)
// so the repo working tree is never dirtied by the tests.

const sourceDir = fileURLToPath(new URL('..', import.meta.url));
const script = path.join(sourceDir, '..', '..', 'scripts', 'build-miniprogram.sh');

const GOOD_ENV = {
  MP_APP_ENV: 'production',
  MP_APPID: 'wx1234567890abcdef',
  MP_API_BASE: 'https://api.scolv.example',
};

function makeScratchCopy(t) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'mp-build-'));
  fs.mkdirSync(path.join(dir, 'utils'));
  fs.copyFileSync(
    path.join(sourceDir, 'utils', 'config.js'),
    path.join(dir, 'utils', 'config.js'),
  );
  fs.copyFileSync(
    path.join(sourceDir, 'project.config.json'),
    path.join(dir, 'project.config.json'),
  );
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));
  return dir;
}

function runBuild(targetDir, env, args = []) {
  return spawnSync('bash', [script, ...args], {
    env: { ...process.env, MP_TARGET_DIR: targetDir, ...env },
    encoding: 'utf8',
  });
}

test('production build fails closed on bad values', (t) => {
  const dir = makeScratchCopy(t);
  const badCases = [
    ['empty appid', { ...GOOD_ENV, MP_APPID: '' }],
    ['touristappid', { ...GOOD_ENV, MP_APPID: 'touristappid' }],
    ['staging host', { ...GOOD_ENV, MP_API_BASE: 'https://p.scolv.com' }],
    ['explicit port', { ...GOOD_ENV, MP_API_BASE: 'https://api.scolv.example:8443' }],
    ['plain http', { ...GOOD_ENV, MP_API_BASE: 'http://api.scolv.example' }],
  ];
  for (const [label, env] of badCases) {
    const res = runBuild(dir, env);
    assert.notEqual(res.status, 0, `${label} must exit non-zero`);
    assert.match(res.stderr, /release gate:/, `${label} must print a gate reason`);
  }
  // Gate must not have touched the scratch copy on failure paths.
  assert.match(
    fs.readFileSync(path.join(dir, 'utils', 'config.js'), 'utf8'),
    /const APP_ENV = 'development';/,
  );
});

test('development build passes without strict validation', (t) => {
  const dir = makeScratchCopy(t);
  const res = runBuild(dir, {
    MP_APP_ENV: 'development',
    MP_APPID: 'touristappid',
    MP_API_BASE: 'https://p.scolv.com:8443',
  });
  assert.equal(res.status, 0, res.stderr);
});

test('production build with good values injects config and appid', (t) => {
  const dir = makeScratchCopy(t);
  const res = runBuild(dir, GOOD_ENV);
  assert.equal(res.status, 0, res.stderr);

  const configJs = fs.readFileSync(path.join(dir, 'utils', 'config.js'), 'utf8');
  assert.match(configJs, /const APP_ENV = 'production';/);
  assert.match(configJs, /const API_BASE = 'https:\/\/api\.scolv\.example';/);
  // No staging traces outside the runtime guard's own regex literal.
  assert.ok(
    !configJs.replace(/\/\(\^\|\\\.\)p\\\.scolv\\\.com[^\n]*/, '').includes('p.scolv.com'),
    'built config.js must not reference p.scolv.com',
  );

  const projectJson = JSON.parse(
    fs.readFileSync(path.join(dir, 'project.config.json'), 'utf8'),
  );
  assert.equal(projectJson.appid, 'wx1234567890abcdef');
});

test('--restore returns the scratch copy to development defaults byte-for-byte', (t) => {
  const dir = makeScratchCopy(t);
  const devConfig = fs.readFileSync(path.join(sourceDir, 'utils', 'config.js'), 'utf8');
  const devProject = fs.readFileSync(path.join(sourceDir, 'project.config.json'), 'utf8');

  assert.equal(runBuild(dir, GOOD_ENV).status, 0);
  const restore = runBuild(dir, {}, ['--restore']);
  assert.equal(restore.status, 0, restore.stderr);

  assert.equal(fs.readFileSync(path.join(dir, 'utils', 'config.js'), 'utf8'), devConfig);
  assert.equal(fs.readFileSync(path.join(dir, 'project.config.json'), 'utf8'), devProject);
});
