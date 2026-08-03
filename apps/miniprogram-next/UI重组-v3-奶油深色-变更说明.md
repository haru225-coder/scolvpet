# UI 重组 v3 · 奶油深色骨架（源码层，2026-08-01）

范围：仅 UI 层。未动 API、契约、权限、分包路径、C 端混写页。

## 1. 主题：一个开关
- `packages/mp-ui/src/tokens.ts` 新增 `themeMode`（当前 `'dark'`）、`crayonLight` / `crayonDark`，`crayon` 改为按模式取值。
- `theme.ts` 的 `palette` 从硬绑 `paletteLight` 改为 `paletteOf(themeMode)`。
- 颜色零新增：全部取自已有的 `ScolvPalette.dark`（真源 ios_theme.dart）。
- 23 个引用 `crayon` 的页面零修改跟着变深；回滚只需把 `themeMode` 改回 `'light'`。
- `NavBar.tsx` 原硬编码 `rgba(251,242,227,0.96)` → `palette.navBarBackground`。

## 2. 三栏导航
- `app.config.ts` 新增 `tabBar { custom: true }`：今日 / 种群 / 经营。
- 自绘 TabBar：`src/custom-tab-bar/`（文字 + 活动态小圆点，不需 PNG 图标资产）。
- 「我的」不占底栏，收在主视窗右上角头像 → 新分包 `packages/profile`。
- 旧深链路径全部不变；跳转统一走 `src/utils/tab-routes.ts` 的 `openPage()`（Tab 页 switchTab，其余 navigateTo）。

## 3. 新组件（mp-ui）
- `Hero`：主视窗。徽章 + 一句话 + 一主一次按钮 + 右上角槽位；自带状态栏 inset，用它的页面不再放 NavBar。
- `Rail` / `PosterCard` / `MiniCard`：横滑行，右缘留 peek。
- 硬规矩：横滑只用于浏览型内容（个体/窝次/客户）；**必做待办一律竖排全展开**，横滑会漏项。
- Skyline 对 radial-gradient 支持不保证，渐变一律 linear-gradient。

## 4. 页面
- `pages/today`：删除 10 连排 `ENTRIES` 与账号区，换成 Hero；照护队列保持竖排 + 滑动操作不变。
- `pages/population`（新）：本周重点窝次 Hero + 个体/窝次横滑行 + 种群工具。
- `pages/business`（新）：「下一个要处理的人」Hero（不放数字）+ 概览横滑行 + 经营入口。
- `packages/profile`（新）：AI / 数据中心 / 遗传模拟 / 订阅消息 / 退出登录。

## 5. 本包未做（必须回 monorepo 做）
- 未编译、未跑 lint/vitest：沙箱无 `node_modules`、无 `generated/ts/scolvpet-api`、无网络。
- `dist/` 已废（未随 `src/` 更新），本包已排除。
- mp-ui 快照测试含颜色，深色化后需 `npx vitest -u` 重拍。
- 自绘 TabBar + Skyline 组合需真机验证（模拟器不算）。
- 种群/经营页的字段读取为防御式 `any`，真实字段对齐待 OpenAPI 客户端接线。
- 主视窗排序（超时 > 到点 > 今日 > 明日）是服务端接口，不在本包。

## 6. 验证命令
```
make miniprogram-next-test
make miniprogram-next-build
```
