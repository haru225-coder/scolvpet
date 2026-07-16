# R3 启动阻断复现报告

> 证据等级：**B**（阻断层已复现）+ **D** 片段（系统日志/LaunchServices 错误码）  
> 采集时间：2026-07-17  
> 目标版本：`2.15.0 (73)` / `com.fanmeowy.catterytool`

## 1. 环境

| 项 | 值 |
|---|---|
| 主机 | MacBook Air M1 (arm64) |
| macOS | 26.5.2 (25F84) |
| SIP | **disabled** |
| Gatekeeper | assessments enabled |
| 样本路径 | `/Applications/Cattery Manager.app` |
| App.framework/App SHA-256 | `8bb590bb7a059f7d4078c3fafe4a366938f3ae9f359fa462f29c030bbadd69b8` |
| Runner cryptid | `1`（FairPlay，4KB 标记） |
| App AOT cryptid | `0` |

对照 2026-07-14 动态报告：当时 macOS 26.5.1、SIP disabled；本次 26.5.2，**阻断仍在**。

## 2. 启动尝试矩阵

| ID | 方法 | 结果 | 关键错误 |
|---|---|---|---|
| A | `open -a "Cattery Manager"` | 失败 exit=1 | LaunchServices **`-10671`** |
| B | `open …/Wrapper/Runner.app` | 失败 exit=1 | `incorrect executable format` |
| C | `open -n -a "Cattery Manager"` | 失败 exit=1 | **`-10671`** |
| D | 直接 exec `Runner` | 立即返回，无常驻进程 | 无 stderr；未进入 Flutter |
| E | 重复 `open -a` | 失败 exit=1 | **`-10671`** |

进程探测：启动窗口内 **无** `Cattery Manager` / `Runner` 业务进程常驻。

原始 stderr 见：

- `attempts/A-open-wrapper/stderr.txt`
- `attempts/B-open-runner/stderr.txt`
- `attempts/C-open-n-new-instance/stderr.txt`
- `attempts/E-open-wrapper-repeat/stderr.txt`

## 3. 阻断层结论

```text
iOS-on-Mac Wrapper 注册存在
  → lsd/appinstalld 构建 bundle record
  → runningboardd 创建 app<com.fanmeowy.catterytool> 作业
  → launchd WILL_SPAWN / xpcproxy
  → kernel fairplayOpen() failed, error -42004
  → EXEC_EXIT_REASON_FAIRPLAY_DECRYPT (namespace 9 code 0xa)
  → job state = spawn failed
  → open(1) 返回 NSOSStatus -10671
```

本轮日志原句（`logs/log-show-launch-errors.txt`）：

```text
AppleFairplayTextCrypterSession::fairplayOpen() failed, error -42004
xpcproxy exited due to EXEC_EXIT_REASON_FAIRPLAY_DECRYPT
exited with exit reason (namespace: 9 code: 0xa) - EXEC_EXIT_REASON_FAIRPLAY_DECRYPT
job state = spawn failed
```

这不是 Flutter 运行时崩溃：

- Runner 业务执行次数：0
- Flutter 运行时事件：0
- WebKit / Widget 扩展业务进程：0
- 应用相关业务网络：0

与 2026-07-14 根因链一致（当时另见 ASDError 502 / Permissive Security 提示）；本轮在 26.5.2 上用 `-42004` + `FAIRPLAY_DECRYPT` 再次闭环。

## 4. 容器差异

启动前后容器文件清单与哈希**无业务侧变化**：

- 仍仅有容器元数据 + StoreKit receipt
- **未创建** `group.com.cattery.widgets` App Group
- 无 SQLite / 无账号 / 无 Token / 无业务偏好

见 `snapshots/container-before.txt`、`container-after.txt`、`container-diff.txt`。

## 5. 替代运行目标状态

| 目标 | 状态 | 说明 |
|---|---|---|
| 本机 iOS-on-Mac 安装包 | **B** | FairPlay + SIP 策略阻断 |
| iOS Simulator | **B** | 无法安装 App Store 已签名 iOS-on-Mac 包；无可用 IPA 重签样本 |
| 物理 iPhone/iPad | **B** | xctrace 显示 Offline（本轮不可达） |

## 6. 补证条件（解除 B 所需）

满足任一路径后，R3 的「未登录 / 已登录 / 离线 / 重启」可升为 **D**：

1. **本机**：Recovery 将安全策略改为 Full/Reduced Security，并恢复 SIP 至 FairPlay 可修复状态后重装/修复 App；或  
2. **真机**：连接在线物理设备，使用 App Store 安装同版本 `2.15.0 (73)` 后做干净基线；或  
3. **合法测试包**：官方提供的可调试/TestFlight 构建（非 FairPlay 零售壳），安装至模拟器或设备。

补证后必须：

- 仍冻结版本 `2.15.0 (73)` 或另开差异任务；
- 仅使用合成测试账号与本轮夹具；
- 日志/截图脱敏后写入 `runtime/r3/`。

## 7. 公开 Web 替代观察（非 App 运行时）

在 App 进程不可用时，对公开页面做只读连通性核验（**不能**替代未登录/登录 App 基线）：

| URL | HTTP |
|---|---|
| https://www.fanmeowy.com/pricing | 200 |
| https://www.fanmeowy.com/pricing/trade | 200 |
| https://www.fanmeowy.com/editor | 200 |

本地已归档生产 JS：`reverse-evidence/web/cattery-admin.js`、`cattery-editor.js`。

## 8. 敏感信息

- 设备 UDID 已替换为 `<REDACTED_UDID>`
- 未采集、未写入任何账号、验证码、Token、Cookie 或用户业务数据
