# 熊舍管家 MVP Figma 低保真交付说明

## 正式设计文件

- 文件名：熊舍管家 MVP 低保真原型 · 2026-07-16
- Figma File Key：`6OGPqHOc92K3QMgaxa2ojo`
- 地址：`https://www.figma.com/design/6OGPqHOc92K3QMgaxa2ojo`
- 正式交付介质：Figma Design；不以 HTML 作为原型交付。

## 三页结构

1. `00 · 基础与组件`
   - 设计声明、色彩比例、Z-space、字体、动效和无障碍约定。
   - Button、Input、Badge、Card、List Row、Bottom Nav、Bottom Sheet 的低保真参考。
   - `WEB-01 · 公开卡片 SSR` 桌面 Web 画框。
2. `01 · MVP 主页面`
   - `P01` 至 `P28` 共 28 个移动端顶层 Frame，尺寸为 390 × 844。
   - 固定五导航：今日、仓鼠、笼舍、繁育、我的。
3. `02 · 动作面板与流程`
   - `A01` 至 `A12` 共 12 个动作面板顶层 Frame。
   - 10 条端到端流程、动作接口状态守卫和关键演示路径说明。

## 已写入的点击路径

### F01 · 登录初始化

`P01 → P02 → P03 → P04 → P05`

已在 Figma Preview 中逐屏点击到 P05“今日总览”。

### F04 · 仓鼠建档

`P08 建档入口 → P09 仓鼠详情`

### F05 · 笼舍流转

`P14 入住/移笼或清洁/隔离 → P15 入住与清洁历史`

### F06–F09 · 繁育闭环

`P16 → P17 → P18 → P19 → P20 → P21 → P22 → P23 → P24`

其中 `P21 → P22`、`P22 → P23` 使用画布端点拖拽写入，并从 Figma 交互面板回读目标名称校验。

当前共 15 条页面交互；动作面板单独保留在 `02` 页，用于研发评审和后续 Overlay 连线扩展。

## 本地可重复生成素材

- `generate-figma-boards.mjs`：生成三张 SVG 导入画板。
- `00-foundations-components.svg`
- `01-mvp-main-pages.svg`
- `02-action-panels-flows.svg`
- `*.preview.png`：本地视觉校验预览，不是正式原型。

重新生成：

```bash
node prototype/figma-import/generate-figma-boards.mjs
```

结构校验：

```bash
for f in prototype/figma-import/*.svg; do xmllint --noout "$f"; done
rg -o 'id="P[0-9]{2} ·' prototype/figma-import/01-mvp-main-pages.svg | wc -l
rg -o 'id="A[0-9]{2} ·' prototype/figma-import/02-action-panels-flows.svg | wc -l
```

预期分别为 28 与 12。

## 设计约定

- Archetype：Console HUD，服务于高密度养殖运营和状态控制。
- 色彩：Base 75%、Depth 20%、Accent 不超过 5%。
- 层级：L0 环境、L1 业务对象、L2 动作面板、L3 文本与控件。
- 字体：Noto Sans SC；已有文本样式与变量集合继续保留在 Figma 文件中。
- 动效：页面建议 300ms、动作面板 220ms、确认反馈 120ms；低保真阶段只验证顺序和返回路径。
- 状态事实：数量、目标状态、eligible set、笼位冲突和谱系边均由服务端返回，客户端不自行计算。

## 待高保真阶段处理

- 将低保真参考组整理为正式 Figma Component Set 与 Variant，并逐页替换为实例。
- 将 `02` 页动作面板按研发优先级追加 Overlay 原型连线。
- 依据真实品牌资产、无障碍对比度和双端组件实现细化视觉，不改变当前信息架构与状态机。
