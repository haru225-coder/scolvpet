# R3 运行时基线报告

> 采集：2026-07-17  
> 版本冻结：`2.15.0 (73)`  
> 总状态：**B（启动阻断）** — 四类核心场景均记录为受阻，并附补证条件

## 1. 验收对照

| 验收项 | 结果 | 证据 |
|---|---|---|
| 未登录基线 | **B** | `scenario-matrix.csv` SCN-0001；`launch-block-report.md` |
| 已登录基线 | **B** | SCN-0002；无进程/无会话 |
| 离线基线 | **B** | SCN-0003 |
| 重启基线 | **B** | SCN-0004；attempt A/C/E 重复失败 |
| 阻断记录完整 | **通过** | 阻断层 + 已尝试路径 + 补证条件 |
| 无真实用户数据/凭据 | **通过** | 见 `test-fixture-policy.md`；日志已过滤 PII 噪声 |

计划允许：若启动阻断仍存在，**必须**记录阻断层与补证条件（本报告满足）。

## 2. 关键动态证据（D）

系统日志链路（`logs/log-show-launch-errors.txt`）：

1. `appinstalld` / `lsd` 识别 `com.fanmeowy.catterytool` 于 `/Applications/Cattery Manager.app`
2. `runningboardd`：`Launch request for app<com.fanmeowy.catterytool>` / `Creating and launching job`
3. `launchd`：`WILL_SPAWN` → `xpcproxy spawned`
4. `kernel`：`AppleFairplayTextCrypterSession::fairplayOpen() failed, error -42004`
5. `launchd`：`EXEC_EXIT_REASON_FAIRPLAY_DECRYPT`（namespace 9 code 0xa），`job state = spawn failed`
6. 用户态：`open` → `_LSOpenURLsWithCompletionHandler ... error -10671`

环境：macOS 26.5.2，**SIP disabled**（与 2026-07-14 根因一致）。

## 3. 场景与权限/生命周期

因进程未进入 UI：

- 权限弹窗、隐私确认、初始化、维护/更新提示、异常恢复 UI：**均未观察**（B）
- 前后台、断网业务态、令牌过期、版本更新提示：**均未观察**（B）

容器侧可观察结论（D）：

- 启动前后无业务文件变化
- App Group 未创建
- 无 SQLite / 无登录态痕迹

## 4. 公开 Web 替代（W，非 App 基线）

`snapshots/web-substitute-check.txt`：pricing / trade / editor 均为 HTTP 200。  
用途：在 App 阻断期间支撑 R9 Web 逆向，**不能**计为未登录 App 动态基线。

## 5. 目录索引

```text
runtime/r3/
├── launch-block-report.md      # 阻断复现与补证条件
├── runtime-baseline-report.md  # 本文件
├── scenario-matrix.csv         # 四类场景 + 扩展场景状态
├── test-fixture-policy.md      # 合成夹具策略（无真实凭据）
├── session.txt
├── attempts/                   # A–E 启动尝试
├── logs/                       # 脱敏后系统日志摘录
└── snapshots/                  # 主机/容器/设备/网络/Web
```

## 6. 下一步（解除 B 后的 R3 续作）

1. 按 `launch-block-report.md` §6 恢复可运行环境  
2. 执行 FIX-AUTH-01/02、OFFLINE、RESTART 夹具  
3. 将 SCN-0001–0004 从 B 升级为 D，并绑定截图/录像步号  
4. 再进入 R4 全页面交互采集
