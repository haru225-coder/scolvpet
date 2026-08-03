# C 端开发一键测试登录 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在开发构建的 C 端“我的预订”页提供显式的一键测试登录，避免桌面小程序助手因缺失 `getPhoneNumber` code 而无法完成验证。

**Architecture:** 原生页面直接复用既有客户短信请求与 Customer Session API；入口同时由 `APP_ENV === 'development'` 和两项开发凭据控制。测试通过 Node VM 加载真实页面定义，替换页面依赖，验证请求顺序、保存状态及生产环境 fail-closed。

**Tech Stack:** 微信小程序原生 Page/WXML、CommonJS、Node `node:test`、staging Customer API。

---

## 文件结构

| 文件 | 责任 |
| --- | --- |
| `apps/miniprogram-next/src/pages/my-reservations/my-reservations.js` | 计算开发入口可用性，并创建、保存、加载临时 Customer Session。 |
| `apps/miniprogram-next/src/pages/my-reservations/my-reservations.wxml` | 仅开发态未登录页面渲染一键测试登录按钮。 |
| `apps/miniprogram-next/test/customer-dev-quick-login.test.mjs` | 在不启动微信工具的条件下回归页面真实登录行为与生产隔离。 |

### Task 1: C 端开发会话入口

**Files:**

- Create: `apps/miniprogram-next/test/customer-dev-quick-login.test.mjs`
- Modify: `apps/miniprogram-next/src/pages/my-reservations/my-reservations.js`
- Modify: `apps/miniprogram-next/src/pages/my-reservations/my-reservations.wxml`

- [ ] **Step 1: 写失败测试**

创建 VM harness，捕获页面定义并注入开发配置、API 与 `getApp()`。测试期望页面存在 `showDevelopmentQuickLogin`，且一键路径先请求验证码、再创建 session、保存 customer token、最后加载列表：

```js
test('开发构建的一键测试登录创建客户会话并加载预约列表', async () => {
  const { page, calls, app } = loadPage({
    config: { APP_ENV: 'development', DEV_LOGIN_PHONE: '13800138000', DEV_LOGIN_CODE: '123456' },
  });
  assert.equal(page.data.showDevelopmentQuickLogin, true);
  const ctx = pageContext();
  await page.developmentQuickLogin.call(ctx);
  assert.deepEqual(calls, [
    ['sendCustomerCode', '+8613800138000'],
    ['createCustomerSession', { phone: '+8613800138000', verification_id: 'vid_1', code: '123456' }],
    ['loadList'],
  ]);
  assert.deepEqual(app.saved, [{ phone: '+8613800138000', customerToken: 'ct_fixture' }]);
  assert.equal(ctx.data.token, 'ct_fixture');
});

test('生产构建不暴露一键测试登录', () => {
  const { page } = loadPage({ config: { APP_ENV: 'production', DEV_LOGIN_PHONE: '', DEV_LOGIN_CODE: '' } });
  assert.equal(page.data.showDevelopmentQuickLogin, false);
  assert.equal(typeof page.developmentQuickLogin, 'function');
});
```

- [ ] **Step 2: 确认 RED**

Run: `cd apps/miniprogram-next && node --test test/customer-dev-quick-login.test.mjs`

Expected: FAIL，因为当前页面没有 `showDevelopmentQuickLogin` 与 `developmentQuickLogin`。

- [ ] **Step 3: 写最小实现**

在页面模块顶部引入 `config` 并固定门禁：

```js
const config = require('../../utils/config');
const showDevelopmentQuickLogin =
  config.APP_ENV === 'development' &&
  Boolean(config.DEV_LOGIN_PHONE) &&
  Boolean(config.DEV_LOGIN_CODE);
```

在 `data` 中保存 `showDevelopmentQuickLogin`。新增 `developmentQuickLogin()`：先 return 掉非开发态和 loading 状态；调用 `api.sendCustomerCode(config.DEV_LOGIN_PHONE)`，取 `res.data.verification_id`，调用 `api.createCustomerSession({ phone, verification_id, code })`；取 `access_token` 后用 `getApp().saveCustomer({ phone, customerToken: token })` 保存，清掉短信备用提示并调用既有 `loadList()`。catch 只写入页面 `error`。

在 WXML 的未登录区添加：

```xml
<view
  wx:if="{{!token && showDevelopmentQuickLogin}}"
  class="btn-primary"
  style="margin-top:12rpx;background:#4a5d73;"
  bindtap="developmentQuickLogin"
>一键测试登录</view>
```

- [ ] **Step 4: 确认 GREEN**

Run: `cd apps/miniprogram-next && node --test test/customer-dev-quick-login.test.mjs`

Expected: PASS，两个测试都成功。

- [ ] **Step 5: 验证完整小程序**

Run:

```bash
cd apps/miniprogram-next
npm run test:native
npm run build:weapp
```

Expected: 两条命令 exit 0。开发者工具重新编译后，C 端“我的预订”未登录页出现“一键测试登录”；点击后真实 staging 预约接口返回列表或“暂无预订记录”。随后点击退出登录，撤销临时会话。

- [ ] **Step 6: 提交**

```bash
git add apps/miniprogram-next/src/pages/my-reservations/my-reservations.js \
  apps/miniprogram-next/src/pages/my-reservations/my-reservations.wxml \
  apps/miniprogram-next/test/customer-dev-quick-login.test.mjs \
  docs/superpowers/plans/2026-07-31-customer-dev-quick-login.md
git commit -m "feat(miniprogram): add customer dev quick login"
```

## 自检

- 设计的四项验收标准均由 Task 1 覆盖：门禁、真实调用顺序、生产隐藏、既有短信与微信入口不改。
- 已检查计划中没有未完成占位符或未命名的实现步骤。
- `showDevelopmentQuickLogin`、`developmentQuickLogin` 与测试中的同名断言保持一致。
