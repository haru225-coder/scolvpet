# 熊舍管家 MVP OpenAPI

本目录提供 Flutter 客户端与模块化单体服务端共同使用的 OpenAPI 3.1 契约。

- 契约文件：`openapi.yaml`
- API 基地址：`/v1`
- 当前契约版本：`1.0.0`
- 时间传输：UTC `date-time`
- 业务时区：IANA timezone，默认 `Asia/Shanghai`

## 1. 账号隔离

除匿名公开分享读取外，所有请求都从 Bearer 令牌解析 `owner_id`。客户端请求体和查询参数不接受 `owner_id`；响应中的 `owner_id` 仅为只读投影。

服务端必须先在认证 `owner_id` 范围内解析资源 ID。资源不存在、已撤销或属于其他 owner 时统一返回 `404 RESOURCE_NOT_FOUND`，不得在错误消息、字段错误、恢复动作或审计投影中泄露其他账号数据。

导入、导出、备份、媒体签名、异步作业、分享和用量同样执行该范围约束。

## 2. 写入、幂等与并发

所有写请求要求 `Idempotency-Key`。唯一域为 `owner_id + action_code + resource_id + key`；相同规范化载荷回放首次结果，不同载荷返回 `409 IDEMPOTENCY_PAYLOAD_MISMATCH`。结果至少保留 24 小时，`confirm-birth`、`individualize` 和分享撤销保留至业务记录归档。

修改既有资源或执行状态动作时同时要求 `If-Match`。值为资源 `version` 对应的 ETag，例如 `"7"`。版本过期返回 `409 VERSION_CONFLICT`、最新 `current_version` 和恢复动作。

状态由服务端动作接口推进，客户端不得 PATCH `state`，也不得提交服务端派生的目标数量、目标状态、谱系边或用量值。

| 动作 | 允许状态/事实 | 服务端原子结果 |
|---|---|---|
| `publish` | `draft` | 校验父母、规则、并行计划与亲缘后进入 `pair_ready` |
| `start-pairing` | `pair_ready` | 创建配对尝试、占用配对笼并进入 `pairing` |
| `separate` | active / safety-hold 配对尝试 | 同时关闭配对占用并写入双方去向 |
| `start-gestation` | `post_pair` | 校验分笼闭环与有效/待定结果，计算预产区间并进入 `gestation` |
| `adjust-baseline` | `gestation` 或可恢复 `hold` | 追加纠正事件、重算窗口、替换提醒 |
| `confirm-birth` | `gestation` | N>0 创建窝次/数量/身份并进入 `litter_nursing`；N=0 进入 `no_litter_outcome` |
| `count-events` | 有效窝次 | 追加数量事实并同步身份与服务端数量投影 |
| `wean` | `weaning_due` | 校验完整在管集合与去向后推进 |
| `sex-and-separate` | `sexing_due` | 校验完整集合、性别、容量与待复核安排 |
| `individualize` | `individualizing` | 按服务端 eligible set 原子创建正式个体、成员和父母边 |
| `complete` | `individualizing` | 对账与阻塞任务闭合后进入 `completed` |

## 3. 产仔与个体化

`confirm-birth` 有两个互斥的原子结果。N>0 时写入生产事实、唯一 litter、`initial_alive` 数量事件、父母/窝次关系和 N 条 `pup_identity`，计划直接进入 `litter_nursing`。

N=0 时只写入 `BIRTH_CONFIRMED_NO_LIVE_PUPS` 生产结果、实际时间、其他结果数、原因和母鼠状态，计划进入终态 `no_litter_outcome`；该分支不创建 litter、litter_count_event、pup_identity 或窝仔阶段任务。报喜卡等媒体副作用在两种结果中都不阻塞核心事务。

个体化前先调用：

```text
GET /litters/{litter_id}/individualization-eligibility
```

服务端返回完整 eligible 身份集合、阻塞项和 `eligible_set_token`。`individualize` 请求必须提交该 token，且 `items` 身份集合与服务端重新计算的 eligible set 完全一致；缺项、多项、重复、过期 token 或任一阻塞项都拒绝整批请求。字段覆盖只允许昵称、内部编号、品系、封面和备注等建档字段。

## 4. 媒体与公开分享

图片编辑保存配方与派生文件，不覆盖原图。短视频上传完成后异步转码；失败通过 `POST /media/{media_id}/retry-processing` 创建新作业，原失败作业和业务记录保留。

分享创建前使用 `POST /shares/preview` 预览匿名投影。公开字段来自固定白名单，媒体 ID 必须属于当前 owner 且生成 share-scoped URL。

撤销分享在同一事务内使 token 失效并写入 CDN purge Outbox，事务提交后立即返回 `200`；公开 API 的下一次请求立即失效。HTML/JSON 使用 `Cache-Control: no-store`，share-scoped 公开媒体的边缘 TTL 不超过 60 秒，最迟 60 秒不再返回；撤销或过期访问统一返回 404。

## 5. CSV、导出、备份与用量

CSV 支持 hamster、enclosure、weight 三类模板，流程为上传、识别、映射、全量预检、冲突确认、正式导入和逐行结果。

- 历史窝次仅在同一窝次编号的出生时间、双亲和物种规则一致时自动规划创建。
- 导入父母与既有有效谱系或窝次父母不一致时为阻塞错误。
- 已有非空字段默认保留；更新候选需逐行、逐字段确认并带 `expected_version`。
- 错误报告通过 `/data-center/import-jobs/{job_id}/error-report` 下载，包含行号、列名、原值、错误码、严重级别和修复建议。

导出与备份均为异步作业。备份详情明确返回大小、SHA-256、完整性状态和可恢复依据；下载地址短时有效并再次校验 owner。

用量接口固定返回六项指标各一项：`active_hamsters`、`active_litters`、`enclosures`、`media_bytes`、`video_minutes`、`backup_bytes`。`metering_status=updating|delayed` 只影响展示，MVP 的 `entitlement.enforcement` 固定为 `none`。

## 6. 校验

在仓库根目录运行：

```bash
npx --yes @redocly/cli@1.34.5 lint specs/api/openapi.yaml
```

发布前还应由服务端契约测试覆盖：跨 owner 资源、幂等回放、旧 ETag、零活仔、eligible set 变化、CSV 父母冲突、分享撤销和备份校验失败。

## 7. Flutter 客户端生成

推荐使用 OpenAPI Generator 的 `dart-dio` 生成器。项目应在 CI 或工具链文件中固定 `${OPENAPI_GENERATOR_VERSION}`，不要依赖浮动 latest。

```bash
export OPENAPI_GENERATOR_VERSION='<项目锁定版本>'
docker run --rm \
  -v "$PWD:/local" \
  "openapitools/openapi-generator-cli:${OPENAPI_GENERATOR_VERSION}" generate \
  -i /local/specs/api/openapi.yaml \
  -g dart-dio \
  -o /local/generated/dart/scolvpet_api \
  --additional-properties=pubName=scolvpet_api,pubVersion=1.0.0
```

生成代码只负责传输模型与 API 调用。以下逻辑保留在应用层封装中：

1. 为每个写请求生成并持久化 `Idempotency-Key`，网络重试复用同一键。
2. 从响应 ETag 保存版本，动作请求发送 `If-Match`。
3. 将 `409` 与 `422` 的 `recovery_actions` 映射为刷新、改笼、修正行、补录数量或重试作业入口。
4. 不在客户端推导繁育状态、窝仔数量、eligible set、谱系边或账号用量。
5. 生成目录视为构建产物；修改契约后重新生成，不手改生成文件。
