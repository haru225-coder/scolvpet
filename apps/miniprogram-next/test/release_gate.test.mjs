import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

// Runs scripts/build-miniprogram-next.sh against a scratch copy (MP_TARGET_DIR)
// so the repo working tree is never dirtied by the tests.
// 迁移自 apps/miniprogram/test/release_gate.test.mjs,布局适配:
// config 在 src/utils/config.js,project.config.json 在工程根。

const sourceDir = fileURLToPath(new URL('..', import.meta.url));
const script = path.join(sourceDir, '..', '..', 'scripts', 'build-miniprogram-next.sh');

const GOOD_ENV = {
  MP_APP_ENV: 'production',
  MP_APPID: 'wx1234567890abcdef',
  MP_API_BASE: 'https://api.scolv.example',
};

function makeScratchCopy(t) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'mp-next-build-'));
  fs.mkdirSync(path.join(dir, 'src', 'utils'), { recursive: true });
  fs.copyFileSync(
    path.join(sourceDir, 'src', 'utils', 'config.js'),
    path.join(dir, 'src', 'utils', 'config.js'),
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

test('release build script is present', () => {
  assert.equal(
    fs.existsSync(script),
    true,
    'scripts/build-miniprogram-next.sh must be reachable from the monorepo root',
  );
});

test('production build fails closed on bad values', (t) => {
  const dir = makeScratchCopy(t);
  const badCases = [
    ['empty appid', { ...GOOD_ENV, MP_APPID: '' }],
    ['touristappid', { ...GOOD_ENV, MP_APPID: 'touristappid' }],
    ['appid without wx prefix', { ...GOOD_ENV, MP_APPID: 'ab1234567890abcdef' }],
    ['appid wrong length', { ...GOOD_ENV, MP_APPID: 'wx1234' }],
    ['appid non-hex tail', { ...GOOD_ENV, MP_APPID: 'wx1234567890abcdeZ' }],
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
    fs.readFileSync(path.join(dir, 'src', 'utils', 'config.js'), 'utf8'),
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

  const configJs = fs.readFileSync(path.join(dir, 'src', 'utils', 'config.js'), 'utf8');
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
  const targetProject = JSON.parse(fs.readFileSync(path.join(dir, 'project.config.json'), 'utf8'));
  // The target may contain a user-specific DevTools AppID that differs from the
  // repository root. Restore must preserve that exact target file.
  targetProject.appid = 'wxabcdef0123456789';
  fs.writeFileSync(path.join(dir, 'project.config.json'), `${JSON.stringify(targetProject, null, 2)}\n`);
  const devConfig = fs.readFileSync(
    path.join(sourceDir, 'src', 'utils', 'config.js'),
    'utf8',
  );
  const devProject = fs.readFileSync(path.join(dir, 'project.config.json'), 'utf8');

  assert.equal(runBuild(dir, GOOD_ENV).status, 0);
  const restore = runBuild(dir, {}, ['--restore']);
  assert.equal(restore.status, 0, restore.stderr);

  assert.equal(
    fs.readFileSync(path.join(dir, 'src', 'utils', 'config.js'), 'utf8'),
    devConfig,
  );
  assert.equal(fs.readFileSync(path.join(dir, 'project.config.json'), 'utf8'), devProject);
  assert.equal(fs.existsSync(path.join(dir, '.project.config.json.release-backup')), false);
});
