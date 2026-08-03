# 小程序全功能迭代真机证据

本目录记录 `docs/superpowers/plans/2026-07-31-miniprogram-full-iteration.md` 的逐页验收。只有真实设备执行并附证据的行可以标记为“已验证”；静态测试或模拟器结果只能写“已写入”。

## 每次回归记录

在 `YYYY-MM-DD/route-matrix.md` 为每个已测路由填写一行，并将截图或录屏保存到同一日期目录。

| 路由 | 提交 | 设备/系统 | 微信版本 | 账号角色 | 网络 | 关键路径 | 结果 | 证据文件 | 回归人 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `packages/animals/detail/index` | `<commit>` | `<device / OS>` | `<version>` | `<owner/viewer/customer>` | `<Wi-Fi/4G/离线>` | `<上传头像 → 保存 → 刷新>` | `已验证 / 待确认 / 失败` | `<relative path>` | `<name>` |

## 出口判据

- B 端：iOS、Android、低端 Android 各有登录、分包首次加载、读写、会话过期、返回手势和下拉刷新证据。
- C 端：客户 A/B 双机完成“目录 → 预订 → B 端 CRM → 客户预订/合同更新”闭环。
- 传输边界：头像预签上传、CSV 上传、错误报告下载、导出/备份下载均记录正式合法域名验证结果。
- 页面若不适配 Skyline，记录失败原因、对应 `renderer` 回退与复测结果。
