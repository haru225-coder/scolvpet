# 熊舍管家 MVP 数据库说明

> 基线：`docs/05-熊舍管家-MVP-产品需求文档.md` v1.1、统一设计规格、`docs/03-核心实体关系与字段字典.md`  
> 数据库：PostgreSQL 15+  
> 交付：`schema.sql` 为可执行事实源，`schema.dbml` 为同结构关系图

## 1. 关键假设

1. `account` 是认证主体，不是租户业务表；除此之外，全部业务表都带 `owner_id`。`species_rule_version` 是唯一例外形态：系统模板为 `scope=system, owner_id=NULL`，舍主副本为 `scope=owner, owner_id!=NULL`。
2. 普通跨业务实体引用均使用 `(owner_id, id)` 复合外键。规则版本因同时支持系统模板和舍主版本，使用普通主键外加 `validate_species_rule_owner` / `validate_species_rule_copy_owner` 触发器阻止跨 owner 引用。
3. MVP 只有单舍主。`created_by`、`operator_id`、`assignee_id` 等账号列为未来成员模型预留；服务层仍须从认证上下文校验操作者属于当前 owner。首版不引入成员表或 RBAC。
4. `version` 是乐观锁计数器，更新触发器只负责递增；服务端必须用 `UPDATE ... WHERE owner_id=? AND id=? AND version=?` 或等价 `If-Match` 条件检查旧版本。
5. 多态引用（任务、媒体、分享、关系断言）由 owner-aware 触发器校验。公开令牌只保存摘要，原始令牌仅在创建响应返回一次。

## 2. 生产结果两分支

### N > 0：建立窝次

`confirm-birth` 必须在单一事务中：

1. 锁定 `breeding_plan` 并校验 owner、`state=gestation`、提交 version 和幂等记录。
2. 写入唯一 `BIRTH_CONFIRMED` 领域事件及 Outbox。
3. 创建 `origin=breeding` 的 `litter`、两条 `litter_parent`。
4. 创建一条 `initial_alive, delta=N` 的不可变数量事件；`N` 必须大于 0。
5. 创建 N 条 `pup_identity` 和 N 条临时 `litter_member`。
6. 写入后续任务，把计划直接更新为 `litter_nursing`，并保存统一的生产结果字段。

提交时，延迟约束同时检查唯一生产事件、唯一有效窝次、父母角色、`initial=N`、N 条在管身份和缓存投影。任一步失败均回滚。

### N = 0：不建立窝次

同一动作只写入 `BIRTH_CONFIRMED_NO_LIVE_PUPS`、生产结果字段和必要 Outbox，将计划更新为 `no_litter_outcome`。该分支禁止出现 `litter`、`litter_count_event`、`pup_identity` 或窝仔阶段任务。`birth_recorded` 只保留为事件语义，不是数据库状态。

## 3. 数量账与 individualize

数量事实为：

```text
initial_alive + discovered - death - transferred_out + correction
= unindividualized_alive + individualized_alive
```

`litter_count_event`、体重、健康、清洁和用量快照为追加事实；纠错通过新事实引用原记录完成。`litter` 上的数量字段只是触发器维护的缓存投影。

个体化预览由服务端按同一 owner 和 litter version 计算完整 eligible set。集合至少要求：在管、存活、未个体化、已断奶、性别已确认、笼位有效、已完成分性分笼且没有阻塞异常。token/hash 应覆盖排序后的 identity id、identity version、litter version、允许覆盖键和过期时间。

提交 `individualize` 时必须：

1. 锁定 litter、全部 eligible pup、目标笼位和父母关系，重新计算集合并核对 token；
2. 为完整集合创建 N 条 `hamster`；
3. 关闭临时 `litter_member`，创建带 `origin_pup_identity_id` 的正式成员；
4. 从 `litter_parent` 建立每只子代的两条 `pedigree_parentage`；
5. 回填 N 条 `pup_identity.individualized_hamster_id`；
6. 写领域事件、Outbox 和幂等响应后提交。

延迟约束禁止同一 breeding litter 在提交后同时存在存活的未个体化与已个体化身份，因此 MVP 的部分个体化事务会失败。

## 4. CSV 历史窝次

导入使用 `import_job`、`import_row`、`import_issue` 和关联 `async_job`。`ready/applying/succeeded` 等状态受预检时间、阻塞行数和应用时间约束。

仓鼠 CSV 按 `owner_id + litter_code` 分组。全组父母和出生事实一致后，在一个组级事务中创建：

- `origin=import, state=closed` 且不关联 breeding plan/enclosure 的历史 litter；
- 两条 `litter_parent`；
- 一条正数 initial 数量事件；
- 正式 hamster `litter_member` 和 `pedigree_parentage`。

历史导入窝次不生成当前任务，也不计入 `active_litters`。核心事实冲突进入 `import_issue`，不由普通 CSV 覆盖。

## 5. 媒体、分享、异步与计量

- `media_asset` 保存原始文件，`media_variant` 保存编辑配方、图片派生、视频封面和转码结果；失败不回滚业务事实。
- `share_page` 保存字段白名单、token hash、撤销时间和 CDN purge 时间；`public_cache_ttl_seconds` 上限为 60。撤销事务需同步写领域事件/Outbox，公开 API 先查撤销事实再返回内容。
- `outbox_message` 是领域事件的可靠发布队列；`async_job` 承载导入、导出、备份、媒体变换、用量快照和分享渲染。Worker 使用 `FOR UPDATE SKIP LOCKED`、`locked_at/locked_by` 和重试计数领任务。
- `usage_meter` 每个 owner/metric 一行，`usage_snapshot` 按时间追加。六项指标为 active_hamsters、active_litters、enclosures、media_bytes、video_minutes、backup_bytes。

## 6. 幂等与迁移顺序

幂等唯一域在应用层规范化为 `action_code + resource_id + Idempotency-Key` 后写入 `idempotency_record.idempotency_key`；相同 key 但不同 `request_hash` 返回载荷冲突。正式导入另有批次键，数量事件、任务、提醒、Outbox 和异步任务各有业务去重约束。

建议迁移顺序：

1. 扩展与枚举；
2. account、organization、规则；
3. 事件、Outbox、任务队列；
4. 媒体、笼舍、仓鼠、繁育与窝次；
5. 谱系、数量、体重、健康、任务提醒；
6. 分享、导入导出、备份、权益、用量与幂等；
7. 普通函数和触发器；
8. 延迟一致性约束与索引；
9. 系统物种规则种子数据。

## 7. 本地验证

完整建库命令：

```bash
initdb -D /tmp/scolvpet-pg15/data --no-locale --encoding=UTF8
pg_ctl -D /tmp/scolvpet-pg15/data -o "-p 55432 -k /tmp/scolvpet-pg15" start
createdb -h /tmp/scolvpet-pg15 -p 55432 scolvpet
psql -X -v ON_ERROR_STOP=1 -h /tmp/scolvpet-pg15 -p 55432 -d scolvpet \
  -f specs/database/schema.sql
```

2026-07-16 使用 PostgreSQL 15.17 完整执行成功：冻结 `schema.sql` 基线为 38 张表、60 个枚举；叠加增量迁移 0010–0012 后，实际运行库为 41 张表、60 个枚举。已实际提交并核对 N>0 confirm-birth、N=0 no_litter_outcome、完整 individualize、CSV 历史窝次事务和认证持久化链路；SQL/DBML 的冻结基线仍按 38 张表逐项一致。
