# cattery-full-reverse 采集与验证

只读导入既有 `reverse-evidence/` 静态清单，生成 `reverse-evidence/full/` 统一目录。

## 命令

```bash
# R0/R1：从既有 path/route 列表生成 catalogs + manifest + SHA256SUMS
python3 scripts/cattery-full-reverse/collect_catalogs.py

# R2：Mach-O / 插件 / 通道 / 配置标记 / 静态关联图（需本机已安装样本 App）
python3 scripts/cattery-full-reverse/collect_static_r2.py

# R9：公开管理端/编辑器 Web 逆向、Bridge、App×Web API 交叉映射
python3 scripts/cattery-full-reverse/collect_web_r9.py

# R10：API 合并/方法/认证/P0 契约与 docs/11
python3 scripts/cattery-full-reverse/collect_api_r10.py

# R11：架构/ER/安全边界文档见 docs/12（由会话汇总写入）

# 验收计数、版本冻结、样本哈希、脱敏、R2/R3/R9 产物与 SHA256
python3 scripts/cattery-full-reverse/validate_catalogs.py
```

可选：设置 `CATERTY_COLLECTED_AT` 固定 `manifest.json` 的采集时间，便于幂等对比。

## 约束

- 不访问业务 API，不写入令牌/手机号/用户业务数据。
- 目标版本冻结为 `2.15.0 (73)`；发现新版本另开差异任务。
- 权威知识报告引用远端 LA1：`/root/ScolvAtom/开发日志/2026/07/` 下两份 2026-07-14 报告。

## R13

最终验收：`validate_catalogs.py` + `git diff --check` + `make ci`；交接见 `docs/14-全量逆向R13交接.md`。
