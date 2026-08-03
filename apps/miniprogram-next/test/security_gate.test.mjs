import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import vm from 'node:vm';

const repoRoot = path.resolve(new URL('../../..', import.meta.url).pathname);
const appRoot = path.join(repoRoot, 'apps', 'miniprogram-next');
const packageScript = path.join(repoRoot, 'scripts', 'package-miniprogram-next.sh');

test('源码交付包排除 dist、私有配置和 node_modules', (t) => {
  const source = fs.mkdtempSync(path.join(os.tmpdir(), 'mp-next-package-source-'));
  const output = path.join(os.tmpdir(), `mp-next-package-${Date.now()}.zip`);
  fs.mkdirSync(path.join(source, 'dist'), { recursive: true });
  fs.mkdirSync(path.join(source, 'node_modules', 'secret-package'), { recursive: true });
  fs.writeFileSync(path.join(source, 'src.ts'), 'export const ok = true;\n');
  fs.writeFileSync(path.join(source, 'dist', 'common.js'), 'DEV_LOGIN_PHONE=13800138000');
  fs.writeFileSync(path.join(source, 'project.private.config.json'), '{"setting":{"urlCheck":false}}');
  fs.writeFileSync(path.join(source, 'node_modules', 'secret-package', 'index.js'), 'module.exports = 1;');
  t.after(() => {
    fs.rmSync(source, { recursive: true, force: true });
    fs.rmSync(output, { force: true });
  });

  const result = spawnSync('bash', [packageScript, output, source], { encoding: 'utf8' });
  assert.equal(result.status, 0, result.stderr);
  const entries = spawnSync('unzip', ['-Z1', output], { encoding: 'utf8' });
  assert.equal(entries.status, 0, entries.stderr);
  assert.match(entries.stdout, /src\.ts/);
  assert.doesNotMatch(entries.stdout, /(^|\/)dist\//);
  assert.doesNotMatch(entries.stdout, /project\.private\.config\.json$/);
  assert.doesNotMatch(entries.stdout, /(^|\/)node_modules\//);
});

test('开发默认关闭 urlCheck，避免 staging 端口域名被微信本地门禁掐死', () => {
  // staging 是 https://p.scolv.com:8443；微信合法域名不支持自定义端口。
  // 本地开发必须 urlCheck=false；正式发布由 build-miniprogram-next.sh 注入 true。
  const project = JSON.parse(fs.readFileSync(path.join(appRoot, 'project.config.json'), 'utf8'));
  assert.equal(project.setting.urlCheck, false);
  const privatePath = path.join(appRoot, 'project.private.config.json');
  if (fs.existsSync(privatePath)) {
    const privateConfig = JSON.parse(fs.readFileSync(privatePath, 'utf8'));
    assert.equal(privateConfig.setting.urlCheck, false);
  }
  const gitignore = fs.readFileSync(path.join(appRoot, '.gitignore'), 'utf8');
  assert.match(gitignore, /^project\.private\.config\.json\s*$/m);
});

function loadApi({ response }) {
  const source = fs.readFileSync(path.join(appRoot, 'src/utils/api.js'), 'utf8');
  const context = vm.createContext({
    getApp: () => ({ globalData: { apiBase: 'https://api.example.test', customerToken: '' } }),
    wx: { request: (options) => options.success(response) },
    module: { exports: {} },
    require: (request) => {
      if (request === './config') return { API_BASE: 'https://api.example.test' };
      throw new Error(`unexpected require: ${request}`);
    },
  });
  vm.runInContext(`(function (require, module, exports) {\n${source}\n})(require, module, module.exports);`, context);
  return context.module.exports;
}

test('原生 API 错误保留 HTTP 状态码供会话层判断', async () => {
  const api = loadApi({ response: { statusCode: 401, data: { error: { code: 'UNAUTHORIZED', message: 'expired' } } } });
  await assert.rejects(
    api.listMyReservations('ct_fixture'),
    (error) => error.statusCode === 401 && error.code === 'UNAUTHORIZED',
  );
});

function loadReservationsPage({ api, app }) {
  const source = fs.readFileSync(path.join(appRoot, 'src/pages/my-reservations/my-reservations.js'), 'utf8');
  let definition;
  const sandbox = {
    console,
    setInterval,
    clearInterval,
    getApp: () => app,
    wx: {},
    Page: (page) => { definition = page; },
  };
  const localRequire = (request) => {
    if (request === '../../utils/api') return api;
    if (request === '../../utils/wechat_login') return {};
    throw new Error(`unexpected require: ${request}`);
  };
  vm.runInNewContext(`(function (require, module, exports) {\n${source}\n})(require, module, module.exports);`, vm.createContext({
    ...sandbox,
    require: localRequire,
    module: { exports: {} },
  }));
  return definition;
}

function pageContext(page, token) {
  return {
    data: { ...page.data, token },
    setData(next) { Object.assign(this.data, next); },
  };
}

test('我的预订网络错误不清除客户 token', async () => {
  const saved = [];
  const app = { saveCustomer: (partial) => saved.push(partial) };
  const page = loadReservationsPage({
    app,
    api: { listMyReservations: async () => { throw new Error('network down'); } },
  });
  const context = pageContext(page, 'ct_fixture');
  await page.loadList.call(context);
  assert.equal(context.data.token, 'ct_fixture');
  assert.deepEqual(saved, []);
});

test('我的预订 401 才清除客户 token', async () => {
  const saved = [];
  const app = { saveCustomer: (partial) => saved.push(partial) };
  const unauthorized = Object.assign(new Error('expired'), { statusCode: 401 });
  const page = loadReservationsPage({
    app,
    api: { listMyReservations: async () => { throw unauthorized; } },
  });
  const context = pageContext(page, 'ct_fixture');
  await page.loadList.call(context);
  assert.equal(context.data.token, '');
  assert.equal(saved.length, 1);
  assert.equal(saved[0].customerToken, '');
});
