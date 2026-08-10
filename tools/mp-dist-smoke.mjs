#!/usr/bin/env node
// 编译产物冒烟(docs/33 M0 功能收口):在 Node VM 里以 wx/App/Page 桩执行
// apps/miniprogram-next/dist 的真实 bundle,验证 —
//   1) App() 注册且 onLaunch 全路径不抛(缓存/深链/静默登录降级);
//   2) 全部 9 个主包页面 + 6 个分包页 Page()/Component() 注册成功;
//   3) 原生混写页 onLoad 可执行(getApp 胶水可用)。
// 不替代真机:渲染层(Skyline/WXML)不在本冒烟范围。
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import process from 'node:process';

const dist = path.resolve(process.argv[2] || 'apps/miniprogram-next/dist');
const appJson = JSON.parse(fs.readFileSync(path.join(dist, 'app.json'), 'utf8'));

const registered = { pages: [], components: 0, appConfig: null };
const failures = [];

// 冒烟故意让 request/login fail；业务里若有未 catch 的 Promise，Node 会 UnhandledRejection 直接崩。
// 只吞掉桩错误，其它拒绝仍记入 failures，避免把真回归藏掉。
process.on('unhandledRejection', (reason) => {
  const msg =
    (reason && typeof reason === 'object' && (reason.errMsg || reason.message)) ||
    String(reason || '')
  if (String(msg).includes('smoke:')) return
  failures.push(`unhandledRejection: ${msg}`)
})

// wx 桩:未覆写的 API 一律记录并返回 no-op;同步取值类给出合理返回。
const wxCalls = [];
const wxOverrides = {
  getStorageSync: () => ({}),
  setStorageSync: () => {},
  removeStorageSync: () => {},
  getSystemInfoSync: () => ({ statusBarHeight: 44, windowWidth: 375, windowHeight: 812, platform: 'devtools', SDKVersion: '3.8.12' }),
  getWindowInfo: () => ({ statusBarHeight: 44, windowWidth: 375, windowHeight: 812, safeArea: { bottom: 778 } }),
  getDeviceInfo: () => ({ platform: 'devtools' }),
  getAppBaseInfo: () => ({ SDKVersion: '3.8.12', theme: 'light' }),
  getMenuButtonBoundingClientRect: () => ({ top: 48, bottom: 80, left: 281, right: 368, width: 87, height: 32 }),
  login: (o) => o && o.fail && o.fail({ errMsg: 'smoke: no wx session' }),
  request: (o) => o && o.fail && o.fail({ errMsg: 'smoke: network disabled' }),
  showToast: () => {},
  navigateTo: () => {},
  redirectTo: () => {},
  navigateBack: () => {},
  nextTick: (fn) => setTimeout(fn, 0),
  canIUse: () => true,
  onError: () => {},
  onUnhandledRejection: () => {},
  onAppShow: () => {},
  onAppHide: () => {},
  onThemeChange: () => {}
};
// webpack runtime 把 chunk 注册表挂在 wx.webpackJsonp 上,必须是真实数组
wxOverrides.webpackJsonp = [];
const wx = new Proxy(wxOverrides, {
  get(target, prop) {
    if (prop in target) return target[prop];
    return (...args) => {
      wxCalls.push(String(prop));
      return undefined;
    };
  },
  set(target, prop, value) {
    target[prop] = value;
    return true;
  }
});

let appInstance = null;

const sandbox = {
  wx,
  console,
  setTimeout,
  clearTimeout,
  setInterval,
  clearInterval,
  Promise,
  Date,
  Math,
  JSON,
  Symbol,
  Reflect,
  Proxy,
  Object,
  Array,
  RegExp,
  Error,
  TypeError,
  performance: globalThis.performance,
  requestAnimationFrame: (fn) => setTimeout(fn, 16),
  cancelAnimationFrame: (id) => clearTimeout(id),
  App(config) {
    registered.appConfig = config;
    appInstance = config;
    try {
      config.onLaunch &&
        config.onLaunch.call(config, { path: 'pages/today/index', query: { scene: 's%3Dbear-house%26h%3Dh1' } });
    } catch (e) {
      failures.push(`App.onLaunch threw: ${e && e.message ? e.message : e}`);
    }
  },
  Page(config) {
    registered.pages.push(config);
  },
  Component(config) {
    registered.components += 1;
    return config;
  },
  Behavior: (b) => b,
  getApp: () => appInstance,
  getCurrentPages: () => [],
  requirePlugin: () => ({}),
  globalThis: null
};
sandbox.globalThis = sandbox;
sandbox.self = sandbox;
const ctx = vm.createContext(sandbox);

// 微信运行时为每个文件提供 CommonJS require(相对路径);VM 里等价实现。
const moduleCache = new Map();
function loadModule(rel) {
  rel = rel.replace(/\\/g, '/');
  if (!rel.endsWith('.js')) rel += '.js';
  if (moduleCache.has(rel)) return moduleCache.get(rel).exports;
  const file = path.join(dist, rel);
  const code = fs.readFileSync(file, 'utf8');
  const mod = { exports: {} };
  moduleCache.set(rel, mod);
  const requireFn = (spec) => loadModule(path.posix.join(path.posix.dirname(rel), spec));
  const fn = vm.runInContext(
    `(function (require, module, exports) {\n${code}\n})`,
    ctx,
    { filename: rel }
  );
  fn(requireFn, mod, mod.exports);
  return mod.exports;
}

function runFile(rel) {
  try {
    loadModule(rel);
  } catch (e) {
    failures.push(`${rel} threw: ${e && e.message ? e.message : e}`);
  }
}

// 加载顺序 = 微信运行时顺序:webpack runtime → 公共 chunk → app → 各页面
for (const rel of ['runtime.js', 'vendors.js', 'taro.js', 'common.js', 'app.js']) {
  if (fs.existsSync(path.join(dist, rel))) runFile(rel);
}
const allPages = [
  ...appJson.pages,
  ...(appJson.subPackages || []).flatMap((p) => p.pages.map((pg) => `${p.root}/${pg}`))
];
for (const page of allPages) runFile(`${page}.js`);

// 微任务/定时器沉降后再判定(Taro 启动链路含异步)
await new Promise((r) => setTimeout(r, 50));

// 断言
if (!registered.appConfig) failures.push('App() was never registered');

// getApp() 桥接契约:原生混写页依赖的三件套必须出现在全局 app 对象上
// (Taro 只桥接 taroGlobalData 内的键 —— 本冒烟即为防这一层回归)
if (appInstance) {
  if (!appInstance.globalData) failures.push('getApp().globalData missing (taroGlobalData bridge broken)');
  else if (appInstance.globalData.slug !== 'bear-house') {
    failures.push(`getApp().globalData.slug expected bear-house, got "${appInstance.globalData.slug}"`);
  }
  if (typeof appInstance.saveCustomer !== 'function') failures.push('getApp().saveCustomer missing');
  if (!appInstance._launchEntry || appInstance._launchEntry.slug !== 'bear-house') {
    failures.push('getApp()._launchEntry missing or wrong');
  }
}
const nativePages = registered.pages.filter((p) => p.onLoad || p.onShow);
if (registered.pages.length + registered.components < allPages.length) {
  failures.push(
    `page registrations (${registered.pages.length} pages + ${registered.components} components) < declared ${allPages.length}`
  );
}

// 原生混写页 onLoad 冒烟:入口页深链自动跳转路径
const indexPage = registered.pages.find((p) => p.enterCatalog);
if (!indexPage) {
  failures.push('native pages/index page config not found (blended compile broken?)');
} else {
  try {
    const inst = Object.create(indexPage);
    inst.data = { ...indexPage.data };
    inst.setData = function (partial) {
      this.data = { ...this.data, ...partial };
    };
    inst.onLoad({});
    if (inst.data.slug !== 'bear-house') {
      failures.push(`native index onLoad did not pick up launch slug, got "${inst.data.slug}"`);
    }
  } catch (e) {
    failures.push(`native index onLoad threw: ${e && e.message ? e.message : e}`);
  }
}

// 静默登录降级不悬挂
if (appInstance && appInstance._silentLoginPromise) {
  try {
    const outcome = await appInstance._silentLoginPromise;
    if (!outcome || outcome.state !== 'fallback') {
      failures.push(`silent login expected fallback, got ${JSON.stringify(outcome)}`);
    }
  } catch (e) {
    failures.push(`silent login rejected: ${e}`);
  }
}

const summary = `dist smoke: app=${registered.appConfig ? 'ok' : 'MISSING'} pages=${registered.pages.length} components=${registered.components} native-onLoad=${nativePages.length}`;
if (failures.length) {
  console.error(`${summary}\nFAIL:\n- ${failures.join('\n- ')}`);
  process.exit(1);
}
console.log(`${summary} — PASS`);
