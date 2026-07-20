# UI V2 P0 · 视觉 Gate 检查表

日期：2026-07-20  
依据：`docs/19-ScolvPet-UI-V2-繁殖者工作台重构任务书.md` §18 / §21  
范围：**P0 信息架构与核心四页**（不含 P1 Design Tokens / 图标资产全量替换）  
设备：Snow’s 16 Pro Max · Bundle `cn.scolvpet.dev` · API `https://p.scolv.com:8443`

---

## 0. 基线与工作区快照（已本机核验）

| 项 | 状态 |
|----|------|
| 分支 | `codex/openapi-p1-p2-contracts` |
| HEAD | `8447ad1` — `feat(mobile): P0-5 breeding workflow hub (progress over menu)` |
| UI V2 P0 commits 齐全 | `041ec24` → `531fcbc` → `8c5bf99` → `8c2e821` → `8447ad1` |
| 工程收敛 / API 冻结 commits 在历史中 | 是（`49aafd8`…`4682768` 均为 HEAD 祖先） |
| 真机 App | 已安装 `cn.scolvpet.dev` **0.0.3 (3)**；`devicectl process launch` **成功** |
| 版本号 | `pubspec` 仍为 `0.0.3+3`（目标产品名 0.0.4 UI V2 未改 version，不阻塞 P0-GATE） |

### 工作区脏文件（**勿与视觉 Gate / P1 混 commit**）

```text
M  api/internal/httpapi/i6_media_share.go
M  api/internal/httpapi/i6_media_share_test.go
M  api/internal/i6media/service.go
M  apps/mobile/ios/Runner.xcodeproj/project.pbxproj
M  apps/mobile/ios/Runner/Info.plist
M  apps/mobile/lib/core/app_state.dart
M  apps/mobile/lib/data/i1_repository.dart
M  apps/mobile/lib/data/i2_repository.dart
M  apps/mobile/lib/features/growth/growth_repository.dart
M  apps/web/src/server.mjs
?? apps/mobile/lib/core/media_url.dart
?? apps/mobile/test/media_url_test.dart
```

> P0 UI commits **未**包含上述文件。视觉 Gate 只验已装 Release / 已提交 baseline，不依赖这些脏改。

---

## 1. 截图目录约定

在本机建立（相对仓库根）：

```text
docs/evidence/ui-v2-p0-gate/2026-07-20/
  01-工作台.png
  02-仓鼠列表.png
  03-仓鼠详情.png
  04-繁育-进度.png
  05-账号入口.png          # 工作台右上角头像 / Account
  06-AI入口.png            # ✦ 或等价入口（有则截）
  可选/
    04b-繁育-窝次.png
    04c-繁育-计划.png
    03b-仓鼠详情-二级导航.png
```

Before 图若已有历史截图可放 `before/`；无 Before 时在报告注明「P0 前无同设备归档，仅 After」。

### 推荐截图方式（本机已无 idevicescreenshot / tidevice）

1. 手机解锁，打开已装 App（或：`xcrun devicectl device process launch --device 742A394E-28CF-5C4D-88A4-5B0D2A440071 cn.scolvpet.dev`）
2. 系统截图：侧键 + 音量上
3. AirDrop / 隔空投送进 Mac → 移入上述目录
4. **优先 USB** 调试；无线易再踩 xattr/codesign（见开发日志真机留痕）

---

## 2. 强制截图清单（任务书 §18）

| # | 画面 | 文件名 | 拍完 |
|---|------|--------|------|
| 1 | 工作台 | `01-工作台.png`（源 `IMG_6130`） | ☑ |
| 2 | 仓鼠列表 | `02-仓鼠列表.png`（源 `IMG_6131`） | ☑ |
| 3 | 仓鼠详情（个体档案） | `03-仓鼠详情.png`（源 `IMG_6132`） | ☑ |
| 4 | 繁育（默认进度） | `04-繁育-进度.png`（源 `IMG_6133`） | ☑ |
| 5 | 账号入口可达 | `05-账号入口.png`（源 `IMG_6137`） | ☑ |
| 6 | AI 入口可达（有则） | `06-AI入口-问问管家.png`（源 `IMG_6136`） | ☑ |
| 附 | 繁育向导 / 窝次 | `04b` `04c` | ☑ |

---

## 3. P0 功能 / 信息架构验收（对照任务书 §21）

逐项勾选。全部 PASS 才算视觉+IA Gate 关闭；单项 FAIL 记 P0-FIX 编号，不进 P1。

### 3.1 导航 Shell（P0-1）

| 检查项 | 期望 | 结果 |
|--------|------|------|
| 底部 Tab 数量 | **仅 3 个**：工作台 / 仓鼠 / 繁育 | **PASS** |
| 无「今日」「管家」「我的」一级 Tab | 功能降级入口，不删除能力 | **PASS** |
| 当前 Tab 状态明确 | selected 清晰、非大面积胶囊抢视觉 | **PASS**（浅底 + 标签色） |
| 手绘插画不当导航 icon | 线性/统一 icon 即可（P1 再精修） | **COND** — 多数 Tab/`?` 占位，进 P1 |

### 3.2 工作台（P0-2）

| 检查项 | 期望 | 结果 |
|--------|------|------|
| 标题语义 | 「工作台」而非「今日」作一级产品概念 | **PASS** |
| 信息优先级 | **今日待办** 在首屏优先于纯统计 | **PASS** |
| 经营概览 | 可读，不抢待办 | **PASS**（在养 2 / 窝次 0 / 孕期 0 / 需关注 0） |
| 繁育动态 | 可读 | **PASS**（空态 + 打开繁育） |
| Header | 日期/称呼轻量；右上可进账号/通知 | **PASS**（晚上好，演示舍主一 · 7月20日） |
| CTA | 精简，无堆满大胶囊 | **PASS**（新建仓鼠 / 全部任务） |

### 3.3 仓鼠列表（P0-3）

| 检查项 | 期望 | 结果 |
|--------|------|------|
| 布局 | 扫描型 row，非卡片堆砌失控 | **PASS** |
| 一眼字段 | 头像 / 编号 / 品系 / 状态 / 笼盒 等可读 | **PASS**（哈利 A02 / 哈鲁 A01） |
| 搜索 | 仅 name/code（领域字段未乱扩） | **PASS**（「搜索名称或编号」） |
| Avatar fallback | 品牌 fallback，非仅「哈」字 CRM 首字母当主方案 | **PASS**（手绘仓鼠 avatar） |
| 领域字段 | 品种/毛色/波利色等**未因 UI 改权威模型** | **PASS**（鸽灰/肉桂波利原文展示） |

### 3.4 个体档案（P0-4）

| 检查项 | 期望 | 结果 |
|--------|------|------|
| 无 Dark HUD | 无黑底黄绿游戏 HUD | **PASS** |
| 气质 | 暖色专业档案，非 ERP 冷屏、非纯可爱 | **PASS** |
| 二级结构 | 基本档案 / 繁育 / 健康 / 记录 等可导航 | **PASS**（截图见基本档案+繁育；可滚动） |
| 能力保留 | 谱系/记录等入口仍在（可降级层级） | **PASS**（查看谱系 / 配对推算） |

### 3.5 繁育工作流（P0-5）

| 检查项 | 期望 | 结果 |
|--------|------|------|
| 非双菜单 Hub | 进入不是「向导 + 窝次」两张菜单卡为主 | **PASS** |
| 默认页 | **进度**（或等价生命周期视图） | **PASS**（进度选中） |
| 分段 | 进度 / 窝次 / 计划（或任务书等价） | **PASS**（顶栏 进度\|计划；窝次为子页 `04c`） |
| 生命周期可见 | 配对/孕期/待产/育仔等进度可读 | **PASS**（空态文案已说明阶段结构） |
| 窝次/向导 | 为入口/子路径，非唯一一级内容 | **PASS**（`04b` 向导 / `04c` 窝次） |

### 3.6 账号与 AI 迁移

| 检查项 | 期望 | 结果 |
|--------|------|------|
| 账号 | 右上角头像/菜单可达：资料/团队/经营/数据/设置等 | **PASS**（数据中心/成员权限/客户/合同/财务/遗传/套餐…） |
| AI | 非一级 Tab；全局/上下文入口可点开 | **PASS**（问问管家独立页；非底栏） |
| 禁止 | 未新建 AI 五件套架构 | **PASS**（沿用既有能力面） |

### 3.7 工程红线（P0 范围）

| 检查项 | 期望 | 结果 |
|--------|------|------|
| 表现层 only | 无业务架构借机升级（go_router / 新状态管理等） | **PASS**（baseline 提交） |
| 遗传权威层 | 变更 = 0 | **PASS** |
| Media 契约 | P0 未扩第二套 URL/DTO/上传架构 | **PASS**（脏文件未进 P0 commit） |
| 隔离脏文件 | pbxproj / Info.plist 等未混入 **已提交** P0 commit | **PASS** |

---

## 4. 自动化门禁（可复跑）

在干净工作区或 stash 脏文件后：

```bash
cd apps/mobile
flutter analyze
flutter test test/widget_test.dart \
  test/home_overview_test.dart \
  test/i2_widget_test.dart \
  test/hamster_care_hub_test.dart \
  test/breeding_wizard_test.dart \
  test/today_care_queue_test.dart
```

（测试文件名以仓库实际为准；开发日志记载上述套件在 P0-GATE 时已 PASS。）

| 套件 | 结果 |
|------|------|
| analyze | ☐ |
| 相关 widget / home / i2 / breeding / care tests | ☐ |

---

## 5. Gate 裁决

| 结论 | 条件 |
|------|------|
| **P0-GATE PASS** | §3 全 PASS + §2 四页（+账号）截图已归档 + §4 自动化绿 |
| **P0-GATE CONDITIONAL** | 功能 IA PASS，仅缺 Before 图或次要视觉毛刺 → 可开 P1，毛刺进 P1 backlog |
| **P0-FIX** | 导航/进度/Dark HUD/能力丢失等结构性 FAIL → **禁止开 P1** |

### 当前裁决（2026-07-20 截图核验后）

| 维度 | 状态 |
|------|------|
| 代码 baseline | **对齐** HEAD=`8447ad1` |
| 自动化（历史） | **PASS** |
| 真机可进入 | **PASS** |
| 四页 + 账号 + AI 截图 | **已归档** `docs/evidence/ui-v2-p0-gate/2026-07-20/` |
| 并排 Before/After | **缺 Before**（无同设备 P0 前归档）→ 不阻塞 |
| **综合** | **P0-GATE = CONDITIONAL PASS** → **允许开 P1** |

**COND 原因（进 P1 backlog，非 P0-FIX）：**

1. 全库大量 `?` 图标占位（底栏/快捷/账号行）— 任务书明确 P1-2 Assets  
2. 个体档案繁育状态展示英文 `candidate` — 文案本地化，P1 顺手  
3. AI 页「助手请求失败」— 运行时/后端，非信息架构 FAIL  
4. 工作台称呼「演示舍主一」vs 账号页「龙之介」— 数据展示不一致，非 IA  

**无结构性 P0-FIX**（三 Tab、待办优先、扫描列表、无 Dark HUD、繁育进度默认、账号/AI 降级可达）。

---

## 6. 截完图后的最小动作

1. 将 PNG 放入 `docs/evidence/ui-v2-p0-gate/2026-07-20/`
2. 在本表 §2 / §3 勾选
3. 在本文末「裁决」改为 PASS 或 CONDITIONAL，并写 1 句原因
4. 更新远端留痕：`开发日志/2026/07/` + 当月 `INDEX.md`
5. **仅当裁决 ≥ CONDITIONAL** 再开 P1-1 Design Tokens（任务书 §10 / §17）

---

## 7. 与 P1 的边界（防止抢跑）

P0 Gate **不要求**消灭全部 `?` icon、不要求 Design Token 全库收敛、不要求手绘资产齐套——那些是 **P1**。

P0 只要求：三 Tab、四页信息架构对、无 Dark HUD、繁育见进度、账号/AI 可达、红线未破、截图可核验。
