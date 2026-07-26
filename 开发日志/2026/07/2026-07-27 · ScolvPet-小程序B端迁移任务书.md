# 2026-07-27 · ScolvPet 小程序 B 端全量迁移任务书(docs/32)

## 背景

核心客户(熊舍主,双手机场景)要求以小程序为**主要管理入口**,全部经营动作在小程序完成,手感接近现有 iOS(Flutter)端。这与既有定位(小程序=客户侧薄切片,docs/27 §8)相反,属产品级决策变更,故立任务书留痕。

## 现状盘点(本窗口调查结论)

- 「App」实为 **Flutter** 应用(`apps/mobile`,v0.0.4+6),iOS 仅 Runner 壳 + WidgetKit 小组件;B 端 20+ 功能模块。
- 现有小程序(`apps/miniprogram`)为**手写原生 WXML 的 C 端切片**:7 页(入口/目录/详情+预订/血统/模拟/我的预订/合同),15 单测过,fail-closed 构建就绪;覆盖 Flutter 功能面约 10–15%,全部消费侧。
- 三端零代码共享,唯一真源是 `specs/api/openapi.yaml`;小程序现为手写 `utils/api.js`,未消费生成客户端。
- Web 端已下线交易能力,交易入口单一指向小程序(维持不变)。

## 决策(docs/32 锁定)

1. **技术路线:Taro(React/TS)+ Skyline 渲染,原生页面混写**——新建 `apps/miniprogram-next`,C 端 7 页混入不重写;否决继续手写 WXML(成本失控)与 MPFlutter(成熟度/包体/审核风险)。
2. **design-first**:M0 先出仿 iOS 设计规范(token 从 `ios_theme.dart` 导出)+ `@scolvpet/mp-ui` 组件库 + 样例页真机手感 Gate,再开业务页。
3. **分期 M0–M4**,每期独立上线、双机真机 Gate;不迁:付费墙/IAP、桌面小组件、APNs(App 专属)。
4. **后端仅三项解冻评估**:B 端 wx.login 绑定、服务端 PDF、订阅消息;冻结域不动。
5. 发布层 docs/30 P4/P5 **不被阻断**:C 端切片先走完 RELEASE GATE,B 端分期叠加。

## 产出

- `docs/32-ScolvPet-小程序B端全量迁移任务书.md`(新)

## 状态

- **已写入**:docs/32 任务书(设计文档,无代码改动,无可执行验证)。
- **待确认**(外部,需用户发起):正式 AppID 申请时核对 B 端类目、微信认证、订阅消息模板;ICP 备案照旧为总关键路径。
- 下一步:用户确认 docs/32 范围与分期后,开 M0 窗口(Taro 工程 + 设计规范 + 组件库)。
