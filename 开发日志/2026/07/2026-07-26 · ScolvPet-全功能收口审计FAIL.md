# 2026-07-26 · ScolvPet 全功能收口审计（FAIL）

## 判定

报告：`docs/31-ScolvPet-全功能收口审计-20260726.md`

**FULL CLOSURE GATE：FAIL**

## 结果摘要

- 测试门禁全部重跑全绿（Go 19 包 / miniprogram 15 / Flutter 215 / Web 15 / conformance 214 ops）。
- docs/29 的 7 项修复声明**全部属实**（含发现"登出停留账号页"已被后续修复、docs/29 §14 标注过时）。
- 发布层 P1/P2 声明 10 属实 / **2 不实**：
  1. `.env.production.example` 缺 `WECHAT_PROVIDER`（照模板部署生产启动即失败）、smoke 无 wechat 断言；
  2. `build-miniprogram.sh` 缺 AppID `wx` 前缀/长度校验（任务书明文项）。
- docs/29 遗留 **12 项确认未修复**（SVG XSS、RBAC GET 全放行、token 明文落库、XFF、外键 SET NULL×7 等）。
- docs/28 产品闭环 P0：**4 项未处置**（CSV 导入内存 session 且入口开放、繁育状态机 UI、模拟历史链、健康/CRM/财务纠错）。
- LA1 实地检查：staging 库 67 表**无迁移账本**，0035–0040 未上，二进制停在 07-21——近一周全部工作在 staging 不生效；无 web 容器；本地 37 提交未 push。
- 新发现 ⚠️：`app_config.dart` staging 默认值只有 Android 单路径守卫，iOS 构建无 fail-closed。

## 待办入口

收口清单见报告 §8（A 声明回收 / B 发布前必修 / C 产品决策 / D 工程面）。

## 方法

只读审计：主会话 + 2 个并行核查代理，全部结论落 文件:行号；LA1 SSH 只读检查。
