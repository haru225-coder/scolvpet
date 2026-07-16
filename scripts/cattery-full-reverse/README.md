# cattery-full-reverse 采集与验证

只读导入既有 `reverse-evidence/` 静态清单，生成 `reverse-evidence/full/` 统一目录。

## 命令

```bash
# R0/R1：从既有 path/route 列表生成 catalogs + manifest + SHA256SUMS
python3 scripts/cattery-full-reverse/collect_catalogs.py

# R2：Mach-O / 插件 / 通道 / 配置标记 / 静态关联图（需本机已安装样本 App）
python3 scripts/cattery-full-reverse/collect_static_r2.py

# 验收计数、版本冻结、样本哈希、脱敏、R2 产物与 SHA256
python3 scripts/cattery-full-reverse/validate_catalogs.py
```

可选：设置 `CATERTY_COLLECTED_AT` 固定 `manifest.json` 的采集时间，便于幂等对比。

## 约束

- 不访问业务 API，不写入令牌/手机号/用户业务数据。
- 目标版本冻结为 `2.15.0 (73)`；发现新版本另开差异任务。
- 权威知识报告引用远端 LA1：`/root/ScolvAtom/开发日志/2026/07/` 下两份 2026-07-14 报告。
