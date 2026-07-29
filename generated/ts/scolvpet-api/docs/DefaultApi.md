# DefaultApi

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**adjustBreedingBaseline**](DefaultApi.md#adjustbreedingbaseline) | **POST** /breeding-plans/{plan_id}/adjust-baseline | 修正配对基准时间 |
| [**batchCreateHamsters**](DefaultApi.md#batchcreatehamsters) | **POST** /hamsters/batch | 批量创建仓鼠 |
| [**batchCreateWeightRecords**](DefaultApi.md#batchcreateweightrecords) | **POST** /weight-records/batch | 批量创建体重记录 |
| [**cancelTask**](DefaultApi.md#canceltask) | **POST** /tasks/{task_id}/cancel | 取消任务 |
| [**commitImportJob**](DefaultApi.md#commitimportjob) | **POST** /data-center/import-jobs/{job_id}/commit | 提交正式导入 |
| [**completeBreedingPlan**](DefaultApi.md#completebreedingplanoperation) | **POST** /breeding-plans/{plan_id}/complete | 完成繁育计划 |
| [**completeMediaUpload**](DefaultApi.md#completemediaupload) | **POST** /media/uploads/{upload_id}/complete | 完成媒体上传 |
| [**completeTask**](DefaultApi.md#completetaskoperation) | **POST** /tasks/{task_id}/complete | 完成任务或逐项完成任务成员 |
| [**confirmBirth**](DefaultApi.md#confirmbirthoperation) | **POST** /breeding-plans/{plan_id}/confirm-birth | 确认产仔并建立窝次 |
| [**confirmBirth_0**](DefaultApi.md#confirmbirth_0) | **POST** /breeding-plans/{plan_id}/confirm-birth | 确认产仔并建立窝次 |
| [**createBackupJob**](DefaultApi.md#createbackupjob) | **POST** /data-center/backup-jobs | 创建基础备份 |
| [**createBreederWechatBinding**](DefaultApi.md#createbreederwechatbindingoperation) | **POST** /auth/wechat-bindings | 短信验证并绑定 B 端微信身份 |
| [**createBreederWechatSession**](DefaultApi.md#createbreederwechatsessionoperation) | **POST** /auth/wechat-sessions | B 端微信 wx.login 登录 |
| [**createBreedingPlan**](DefaultApi.md#createbreedingplan) | **POST** /breeding-plans | 创建繁育计划草稿 |
| [**createEnclosure**](DefaultApi.md#createenclosure) | **POST** /enclosures | 创建笼盒 |
| [**createEnclosureCleaning**](DefaultApi.md#createenclosurecleaning) | **POST** /enclosures/{enclosure_id}/cleanings | 记录笼盒清洁或消毒 |
| [**createEnclosureStay**](DefaultApi.md#createenclosurestay) | **POST** /enclosures/{enclosure_id}/stays | 创建入住或移笼事实 |
| [**createExportJob**](DefaultApi.md#createexportjob) | **POST** /data-center/export-jobs | 创建数据导出 |
| [**createHamster**](DefaultApi.md#createhamster) | **POST** /hamsters | 创建仓鼠档案 |
| [**createHealthRecord**](DefaultApi.md#createhealthrecord) | **POST** /health-records | 创建健康记录 |
| [**createImportJob**](DefaultApi.md#createimportjob) | **POST** /data-center/import-jobs | 创建 CSV 导入任务 |
| [**createImportUpload**](DefaultApi.md#createimportupload) | **POST** /data-center/import-uploads | 创建 CSV 上传 |
| [**createLitterCountEvent**](DefaultApi.md#createlittercountevent) | **POST** /litters/{litter_id}/count-events | 追加窝仔数量事件 |
| [**createLitterParent**](DefaultApi.md#createlitterparent) | **POST** /litters/{litter_id}/parents | 新增或纠正窝次父母关系 |
| [**createMediaEditRecipe**](DefaultApi.md#createmediaeditrecipe) | **POST** /media/{media_id}/edit-recipes | 创建图片编辑配方 |
| [**createPedigreeParentage**](DefaultApi.md#createpedigreeparentage) | **POST** /pedigree-parentages | 新增父母关系断言 |
| [**createSession**](DefaultApi.md#createsession) | **POST** /auth/sessions | 使用手机验证码登录 |
| [**createShare**](DefaultApi.md#createshare) | **POST** /shares | 创建公开分享 |
| [**createSpeciesRuleVersion**](DefaultApi.md#createspeciesruleversion) | **POST** /species-rule-versions | 创建规则版本 |
| [**createTask**](DefaultApi.md#createtask) | **POST** /tasks | 创建手工任务 |
| [**createWeightRecord**](DefaultApi.md#createweightrecord) | **POST** /weight-records | 创建体重记录 |
| [**deleteBreederWechatBinding**](DefaultApi.md#deletebreederwechatbinding) | **DELETE** /auth/wechat-bindings/current | 解绑当前 B 端微信身份 |
| [**deleteCurrentSession**](DefaultApi.md#deletecurrentsession) | **DELETE** /auth/sessions/current | 退出当前会话 |
| [**endPedigreeParentage**](DefaultApi.md#endpedigreeparentage) | **POST** /pedigree-parentages/end | 解除当前有效父母关系 |
| [**getAsyncJob**](DefaultApi.md#getasyncjob) | **GET** /jobs/{job_id} | 获取通用异步作业 |
| [**getBackupDownload**](DefaultApi.md#getbackupdownload) | **GET** /data-center/backup-jobs/{job_id}/download | 获取备份下载链接 |
| [**getBackupJob**](DefaultApi.md#getbackupjob) | **GET** /data-center/backup-jobs/{job_id} | 获取备份任务 |
| [**getBreedingPlan**](DefaultApi.md#getbreedingplan) | **GET** /breeding-plans/{plan_id} | 获取繁育计划 |
| [**getCurrentAccount**](DefaultApi.md#getcurrentaccount) | **GET** /me | 获取当前账号 |
| [**getCurrentOrganization**](DefaultApi.md#getcurrentorganization) | **GET** /organizations/current | 获取当前熊舍 |
| [**getCurrentUsage**](DefaultApi.md#getcurrentusage) | **GET** /usage/current | 获取当前用量 |
| [**getDataCenterSummary**](DefaultApi.md#getdatacentersummary) | **GET** /data-center/summary | 获取数据中心摘要 |
| [**getEnclosure**](DefaultApi.md#getenclosure) | **GET** /enclosures/{enclosure_id} | 获取笼盒详情 |
| [**getEnclosureCleaning**](DefaultApi.md#getenclosurecleaning) | **GET** /enclosure-cleanings/{cleaning_id} | 获取清洁记录 |
| [**getExportDownload**](DefaultApi.md#getexportdownload) | **GET** /data-center/export-jobs/{job_id}/download | 获取导出下载链接 |
| [**getExportJob**](DefaultApi.md#getexportjob) | **GET** /data-center/export-jobs/{job_id} | 获取导出任务 |
| [**getHamster**](DefaultApi.md#gethamster) | **GET** /hamsters/{hamster_id} | 获取仓鼠详情 |
| [**getHamsterPedigree**](DefaultApi.md#gethamsterpedigree) | **GET** /hamsters/{hamster_id}/pedigree | 获取仓鼠家谱图 |
| [**getHealthRecord**](DefaultApi.md#gethealthrecord) | **GET** /health-records/{health_record_id} | 获取健康记录 |
| [**getImportErrorReport**](DefaultApi.md#getimporterrorreport) | **GET** /data-center/import-jobs/{job_id}/error-report | 下载 CSV 逐行错误报告 |
| [**getImportJob**](DefaultApi.md#getimportjob) | **GET** /data-center/import-jobs/{job_id} | 获取导入任务 |
| [**getImportTemplate**](DefaultApi.md#getimporttemplate) | **GET** /data-center/import-templates/{template_type} | 获取 CSV 导入模板 |
| [**getLitter**](DefaultApi.md#getlitter) | **GET** /litters/{litter_id} | 获取窝次详情 |
| [**getLitterIndividualizationEligibility**](DefaultApi.md#getlitterindividualizationeligibility) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set |
| [**getLitterIndividualizationEligibility_0**](DefaultApi.md#getlitterindividualizationeligibility_0) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set |
| [**getLitterIndividualizationEligibility_1**](DefaultApi.md#getlitterindividualizationeligibility_1) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set |
| [**getMediaAsset**](DefaultApi.md#getmediaasset) | **GET** /media/{media_id} | 获取媒体资产 |
| [**getMediaTranscodeStatus**](DefaultApi.md#getmediatranscodestatus) | **GET** /media/{media_id}/transcode-status | 获取转码状态 |
| [**getPairingAttempt**](DefaultApi.md#getpairingattempt) | **GET** /pairing-attempts/{attempt_id} | 获取配对尝试 |
| [**getPublicShare**](DefaultApi.md#getpublicshare) | **GET** /public/shares/{token} | 无需认证读取公开分享 |
| [**getPublicShareMedia**](DefaultApi.md#getpublicsharemedia) | **GET** /public/shares/{token}/media/{media_id} | 读取公开分享媒体 |
| [**getReminder**](DefaultApi.md#getreminder) | **GET** /reminders/{reminder_id} | 获取提醒 |
| [**getSpeciesRuleVersion**](DefaultApi.md#getspeciesruleversion) | **GET** /species-rule-versions/{rule_version_id} | 获取规则版本 |
| [**getTask**](DefaultApi.md#gettask) | **GET** /tasks/{task_id} | 获取任务 |
| [**individualizeLitter**](DefaultApi.md#individualizelitteroperation) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化 |
| [**individualizeLitter_0**](DefaultApi.md#individualizelitter_0) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化 |
| [**individualizeLitter_1**](DefaultApi.md#individualizelitter_1) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化 |
| [**listBackupJobs**](DefaultApi.md#listbackupjobs) | **GET** /data-center/backup-jobs | 列出备份任务 |
| [**listBreedingPlans**](DefaultApi.md#listbreedingplans) | **GET** /breeding-plans | 列出繁育计划 |
| [**listEnclosureCleanings**](DefaultApi.md#listenclosurecleanings) | **GET** /enclosures/{enclosure_id}/cleanings | 列出笼盒清洁历史 |
| [**listEnclosureStays**](DefaultApi.md#listenclosurestays) | **GET** /enclosures/{enclosure_id}/stays | 列出笼盒入住历史 |
| [**listEnclosures**](DefaultApi.md#listenclosures) | **GET** /enclosures | 列出笼盒 |
| [**listExportJobs**](DefaultApi.md#listexportjobs) | **GET** /data-center/export-jobs | 列出导出任务 |
| [**listHamsters**](DefaultApi.md#listhamsters) | **GET** /hamsters | 列出仓鼠 |
| [**listHealthRecords**](DefaultApi.md#listhealthrecords) | **GET** /health-records | 列出健康记录 |
| [**listImportJobs**](DefaultApi.md#listimportjobs) | **GET** /data-center/import-jobs | 列出导入任务 |
| [**listImportRowResults**](DefaultApi.md#listimportrowresults) | **GET** /data-center/import-jobs/{job_id}/rows | 获取逐行导入结果 |
| [**listLitterMembers**](DefaultApi.md#listlittermembers) | **GET** /litters/{litter_id}/members | 列出窝次成员 |
| [**listLitterMembers_0**](DefaultApi.md#listlittermembers_0) | **GET** /litters/{litter_id}/members | 列出窝次成员 |
| [**listLitterParents**](DefaultApi.md#listlitterparents) | **GET** /litters/{litter_id}/parents | 获取窝次父母关系 |
| [**listLitters**](DefaultApi.md#listlitters) | **GET** /litters | 列出窝次 |
| [**listPairingAttempts**](DefaultApi.md#listpairingattempts) | **GET** /breeding-plans/{plan_id}/pairing-attempts | 列出计划的配对尝试 |
| [**listPedigreeParentages**](DefaultApi.md#listpedigreeparentages) | **GET** /pedigree-parentages | 列出家谱父母边 |
| [**listPupIdentities**](DefaultApi.md#listpupidentities) | **GET** /litters/{litter_id}/pup-identities | 列出临时幼崽 |
| [**listReminders**](DefaultApi.md#listreminders) | **GET** /reminders | 列出提醒 |
| [**listShares**](DefaultApi.md#listshares) | **GET** /shares | 列出公开分享 |
| [**listSpeciesRuleTemplates**](DefaultApi.md#listspeciesruletemplates) | **GET** /species-rule-templates | 列出系统物种规则模板 |
| [**listSpeciesRuleVersions**](DefaultApi.md#listspeciesruleversions) | **GET** /species-rule-versions | 列出当前熊舍规则版本 |
| [**listTasks**](DefaultApi.md#listtasks) | **GET** /tasks | 列出任务 |
| [**listUsageSnapshots**](DefaultApi.md#listusagesnapshots) | **GET** /usage/snapshots | 列出用量快照 |
| [**listWechatSubscriptions**](DefaultApi.md#listwechatsubscriptions) | **GET** /wechat/subscriptions | 查看当前 B 端微信订阅授权 |
| [**listWeightRecords**](DefaultApi.md#listweightrecords) | **GET** /weight-records | 列出体重记录 |
| [**preflightImportJob**](DefaultApi.md#preflightimportjob) | **POST** /data-center/import-jobs/{job_id}/preflight | 全量预检 CSV |
| [**presignMediaUpload**](DefaultApi.md#presignmediaupload) | **POST** /media/uploads/presign | 创建媒体预签名上传 |
| [**previewShare**](DefaultApi.md#previewshare) | **GET** /shares/{share_id}/preview | 预览公开分享 |
| [**previewShareDraft**](DefaultApi.md#previewsharedraft) | **POST** /shares/preview | 创建前预览公开分享 |
| [**publishBreedingPlan**](DefaultApi.md#publishbreedingplanoperation) | **POST** /breeding-plans/{plan_id}/publish | 发布繁育计划 |
| [**recordPairingObservation**](DefaultApi.md#recordpairingobservation) | **POST** /pairing-attempts/{attempt_id}/record-observation | 记录配对观察 |
| [**refreshSession**](DefaultApi.md#refreshsessionoperation) | **POST** /auth/sessions/refresh | 刷新当前会话 |
| [**reopenTask**](DefaultApi.md#reopentask) | **POST** /tasks/{task_id}/reopen | 撤销任务的完成或取消 |
| [**retryBackupJob**](DefaultApi.md#retrybackupjob) | **POST** /data-center/backup-jobs/{job_id}/retry | 重试失败备份 |
| [**retryExportJob**](DefaultApi.md#retryexportjob) | **POST** /data-center/export-jobs/{job_id}/retry | 重试失败导出 |
| [**retryImportJob**](DefaultApi.md#retryimportjob) | **POST** /data-center/import-jobs/{job_id}/retry | 重试失败导入行 |
| [**retryMediaProcessing**](DefaultApi.md#retrymediaprocessing) | **POST** /media/{media_id}/retry-processing | 重试失败的媒体处理 |
| [**revokeShare**](DefaultApi.md#revokeshareoperation) | **POST** /shares/{share_id}/revoke | 撤销公开分享 |
| [**sendVerificationCode**](DefaultApi.md#sendverificationcodeoperation) | **POST** /auth/verification-codes | 发送手机验证码 |
| [**sendWechatSubscription**](DefaultApi.md#sendwechatsubscriptionoperation) | **POST** /wechat/subscriptions/send | 投递一条已授权的微信订阅消息 |
| [**separatePairing**](DefaultApi.md#separatepairingoperation) | **POST** /pairing-attempts/{attempt_id}/separate | 结束配对并完成分笼 |
| [**setImportMapping**](DefaultApi.md#setimportmapping) | **PUT** /data-center/import-jobs/{job_id}/mapping | 设置 CSV 字段映射 |
| [**setMediaCover**](DefaultApi.md#setmediacover) | **PUT** /media/{media_id}/cover | 设置媒体封面 |
| [**sexAndSeparateLitter**](DefaultApi.md#sexandseparatelitter) | **POST** /litters/{litter_id}/sex-and-separate | 分性并分笼 |
| [**startGestationMonitoring**](DefaultApi.md#startgestationmonitoring) | **POST** /breeding-plans/{plan_id}/start-gestation | 从分笼后进入孕期观察 |
| [**startPairing**](DefaultApi.md#startpairingoperation) | **POST** /breeding-plans/{plan_id}/start-pairing | 开始配对 |
| [**updateBreedingPlan**](DefaultApi.md#updatebreedingplan) | **PATCH** /breeding-plans/{plan_id} | 更新繁育计划资料 |
| [**updateCurrentOrganization**](DefaultApi.md#updatecurrentorganization) | **PATCH** /organizations/current | 更新当前熊舍 |
| [**updateEnclosure**](DefaultApi.md#updateenclosure) | **PATCH** /enclosures/{enclosure_id} | 更新笼盒资料 |
| [**updateEnclosureStay**](DefaultApi.md#updateenclosurestay) | **PATCH** /enclosure-stays/{stay_id} | 结束或修正入住事实 |
| [**updateHamster**](DefaultApi.md#updatehamster) | **PATCH** /hamsters/{hamster_id} | 更新仓鼠档案 |
| [**updateHealthRecord**](DefaultApi.md#updatehealthrecord) | **PATCH** /health-records/{health_record_id} | 更新健康记录 |
| [**updateSpeciesRuleVersion**](DefaultApi.md#updatespeciesruleversion) | **PATCH** /species-rule-versions/{rule_version_id} | 更新尚未冻结的规则版本 |
| [**updateTask**](DefaultApi.md#updatetask) | **PATCH** /tasks/{task_id} | 更新任务非状态字段 |
| [**upsertWechatSubscriptions**](DefaultApi.md#upsertwechatsubscriptionsoperation) | **PUT** /wechat/subscriptions | 保存当前 B 端微信订阅授权 |
| [**weanLitter**](DefaultApi.md#weanlitteroperation) | **POST** /litters/{litter_id}/wean | 完成断奶 |



## adjustBreedingBaseline

> AdjustBaselineResponse adjustBreedingBaseline(idempotencyKey, ifMatch, planId, adjustBaselineRequest)

修正配对基准时间

仅允许 gestation 或可恢复的 hold 状态。追加日期纠正事件，重算预产区间， 并将旧提醒标记为 superseded；客户端不得提交重算后的日期或提醒集合。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { AdjustBreedingBaselineRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    planId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // AdjustBaselineRequest
    adjustBaselineRequest: {"new_baseline_at":"2026-07-18T12:12:00Z","reason":"以明确交配观察作为新基准","timezone":"Asia/Shanghai"},
  } satisfies AdjustBreedingBaselineRequest;

  try {
    const data = await api.adjustBreedingBaseline(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **planId** | `string` |  | [Defaults to `undefined`] |
| **adjustBaselineRequest** | [AdjustBaselineRequest](AdjustBaselineRequest.md) |  | |

### Return type

[**AdjustBaselineResponse**](AdjustBaselineResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 基准时间及提醒已重算 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## batchCreateHamsters

> HamsterBatchCreateResponse batchCreateHamsters(idempotencyKey, hamsterBatchCreateRequest)

批量创建仓鼠

返回整体事务状态与逐项结果；每项使用 client_item_id 对齐客户端记录。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { BatchCreateHamstersRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // HamsterBatchCreateRequest
    hamsterBatchCreateRequest: ...,
  } satisfies BatchCreateHamstersRequest;

  try {
    const data = await api.batchCreateHamsters(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **hamsterBatchCreateRequest** | [HamsterBatchCreateRequest](HamsterBatchCreateRequest.md) |  | |

### Return type

[**HamsterBatchCreateResponse**](HamsterBatchCreateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 批处理已完成，可能全部成功或部分失败 |  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## batchCreateWeightRecords

> WeightRecordBatchCreateResponse batchCreateWeightRecords(idempotencyKey, weightRecordBatchCreateRequest)

批量创建体重记录

返回逐项成功、失败与告警结果，适用于整窝逐只称重。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { BatchCreateWeightRecordsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // WeightRecordBatchCreateRequest
    weightRecordBatchCreateRequest: ...,
  } satisfies BatchCreateWeightRecordsRequest;

  try {
    const data = await api.batchCreateWeightRecords(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **weightRecordBatchCreateRequest** | [WeightRecordBatchCreateRequest](WeightRecordBatchCreateRequest.md) |  | |

### Return type

[**WeightRecordBatchCreateResponse**](WeightRecordBatchCreateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 批量称重已处理 |  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## cancelTask

> CareTaskResponse cancelTask(idempotencyKey, ifMatch, taskId, taskCorrectionRequest)

取消任务

取消一个不会再执行的任务，必须填写原因。已完成或已取消的任务不能直接取消， 需先调用 reopen 撤销。原因写入 care_task.cancellation_reason 并记入 CARE_TASK_CANCELLED 领域事件，任务本身不物理删除。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CancelTaskRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    taskId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // TaskCorrectionRequest
    taskCorrectionRequest: {"reason":"该窝已转出，无需再称重"},
  } satisfies CancelTaskRequest;

  try {
    const data = await api.cancelTask(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **taskId** | `string` |  | [Defaults to `undefined`] |
| **taskCorrectionRequest** | [TaskCorrectionRequest](TaskCorrectionRequest.md) |  | |

### Return type

[**CareTaskResponse**](CareTaskResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 任务已取消 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## commitImportJob

> ImportJobResponse commitImportJob(idempotencyKey, ifMatch, jobId, importCommitRequest)

提交正式导入

使用幂等批次号正式写入；提交前重新校验 preflight_version、全部阻塞问题和逐项 更新确认。历史窝次先按预检计划原子创建，再建立成员与父母关系；部分失败时保留 逐行结果，但不允许产生缺父母、错窝次或悬空谱系引用。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CommitImportJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // ImportCommitRequest
    importCommitRequest: ...,
  } satisfies CommitImportJobRequest;

  try {
    const data = await api.commitImportJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **jobId** | `string` |  | [Defaults to `undefined`] |
| **importCommitRequest** | [ImportCommitRequest](ImportCommitRequest.md) |  | |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 正式导入已排队 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## completeBreedingPlan

> CompleteBreedingPlanResponse completeBreedingPlan(idempotencyKey, ifMatch, planId, completeBreedingPlanRequest)

完成繁育计划

仅允许 individualizing。 服务端确认数量、性别、笼位、家谱和阻塞任务全部闭合后推进到 completed， 客户端不得提交目标状态或自行计算的对账数。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CompleteBreedingPlanOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    planId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // CompleteBreedingPlanRequest
    completeBreedingPlanRequest: {"completed_at":"2026-09-05T03:00:00Z","timezone":"Asia/Shanghai","notes":"数量、分笼和谱系均已复核"},
  } satisfies CompleteBreedingPlanOperationRequest;

  try {
    const data = await api.completeBreedingPlan(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **planId** | `string` |  | [Defaults to `undefined`] |
| **completeBreedingPlanRequest** | [CompleteBreedingPlanRequest](CompleteBreedingPlanRequest.md) |  | |

### Return type

[**CompleteBreedingPlanResponse**](CompleteBreedingPlanResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 繁育计划已完成 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## completeMediaUpload

> MediaUploadCompleteResponse completeMediaUpload(idempotencyKey, ifMatch, uploadId, mediaUploadCompleteRequest)

完成媒体上传

校验对象元数据后创建 media_asset；视频转码异步执行。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CompleteMediaUploadRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    uploadId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // MediaUploadCompleteRequest
    mediaUploadCompleteRequest: ...,
  } satisfies CompleteMediaUploadRequest;

  try {
    const data = await api.completeMediaUpload(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **uploadId** | `string` |  | [Defaults to `undefined`] |
| **mediaUploadCompleteRequest** | [MediaUploadCompleteRequest](MediaUploadCompleteRequest.md) |  | |

### Return type

[**MediaUploadCompleteResponse**](MediaUploadCompleteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 上传完成，派生处理已排队 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## completeTask

> CompleteTaskResponse completeTask(idempotencyKey, ifMatch, taskId, completeTaskRequest)

完成任务或逐项完成任务成员

支持整窝任务逐只完成；全部 subject 完成或登记例外后任务自动关闭。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CompleteTaskOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    taskId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // CompleteTaskRequest
    completeTaskRequest: {"completed_at":"2026-08-10T02:00:00Z","subject_results":[{"subject_id":"018f47a2-73b3-762e-8498-07b13dc3b599","status":"completed","completion_record_id":"018f47a2-951e-7123-a5b3-1ade38a2b49e"},{"subject_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","status":"excepted","exception_reason":"当日医疗观察，延后称重"}],"notes":"本次完成 2 项"},
  } satisfies CompleteTaskOperationRequest;

  try {
    const data = await api.completeTask(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **taskId** | `string` |  | [Defaults to `undefined`] |
| **completeTaskRequest** | [CompleteTaskRequest](CompleteTaskRequest.md) |  | |

### Return type

[**CompleteTaskResponse**](CompleteTaskResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 任务进度已更新 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## confirmBirth

> ConfirmBirthResponse confirmBirth(idempotencyKey, ifMatch, planId, confirmBirthRequest)

确认产仔并建立窝次

仅允许 gestation 状态；同一计划只允许一个未撤销的生产事实。 N&gt;0 时幂等创建唯一有效 litter、初始数量流水及 N 条 pup_identity，并直接进入 litter_nursing。N&#x3D;0 时只记录无活仔生产结果并进入 no_litter_outcome，不创建 litter、litter_count_event、pup_identity 或窝仔阶段任务。 报喜卡或媒体任务失败不回滚产仔事实。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ConfirmBirthOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    planId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // ConfirmBirthRequest
    confirmBirthRequest: {"born_at":"2026-08-04T02:30:00Z","enclosure_id":"018f47a2-6450-7f54-8851-050a3d63846f","initial_alive_count":4,"initial_other_count":1,"dam_condition":{"status":"stable","notes":"精神与进食正常"},"temporary_code_prefix":"L240804","timezone":"Asia/Shanghai","outcome_reason":"live_pups_observed","notes":"发现 4 只活仔，另有 1 只死产"},
  } satisfies ConfirmBirthOperationRequest;

  try {
    const data = await api.confirmBirth(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **planId** | `string` |  | [Defaults to `undefined`] |
| **confirmBirthRequest** | [ConfirmBirthRequest](ConfirmBirthRequest.md) |  | |

### Return type

[**ConfirmBirthResponse**](ConfirmBirthResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 产仔事实、窝次和临时幼崽已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## confirmBirth_0

> ConfirmBirthResponse confirmBirth_0(idempotencyKey, ifMatch, planId, confirmBirthRequest)

确认产仔并建立窝次

仅允许 gestation 状态；同一计划只允许一个未撤销的生产事实。 N&gt;0 时幂等创建唯一有效 litter、初始数量流水及 N 条 pup_identity，并直接进入 litter_nursing。N&#x3D;0 时只记录无活仔生产结果并进入 no_litter_outcome，不创建 litter、litter_count_event、pup_identity 或窝仔阶段任务。 报喜卡或媒体任务失败不回滚产仔事实。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ConfirmBirth0Request } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    planId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // ConfirmBirthRequest
    confirmBirthRequest: {"born_at":"2026-08-04T02:30:00Z","enclosure_id":"018f47a2-6450-7f54-8851-050a3d63846f","initial_alive_count":4,"initial_other_count":1,"dam_condition":{"status":"stable","notes":"精神与进食正常"},"temporary_code_prefix":"L240804","timezone":"Asia/Shanghai","outcome_reason":"live_pups_observed","notes":"发现 4 只活仔，另有 1 只死产"},
  } satisfies ConfirmBirth0Request;

  try {
    const data = await api.confirmBirth_0(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **planId** | `string` |  | [Defaults to `undefined`] |
| **confirmBirthRequest** | [ConfirmBirthRequest](ConfirmBirthRequest.md) |  | |

### Return type

[**ConfirmBirthResponse**](ConfirmBirthResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 产仔事实、窝次和临时幼崽已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createBackupJob

> BackupJobResponse createBackupJob(idempotencyKey, backupJobCreateRequest)

创建基础备份

包含结构化数据、媒体清单和校验哈希。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateBackupJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // BackupJobCreateRequest
    backupJobCreateRequest: ...,
  } satisfies CreateBackupJobRequest;

  try {
    const data = await api.createBackupJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **backupJobCreateRequest** | [BackupJobCreateRequest](BackupJobCreateRequest.md) |  | |

### Return type

[**BackupJobResponse**](BackupJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 备份任务已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createBreederWechatBinding

> SessionResponse createBreederWechatBinding(idempotencyKey, createBreederWechatBindingRequest, xTimezone)

短信验证并绑定 B 端微信身份

消费 B 端 wx.login 下发的一次性票据，验证手机号后创建 staff Bearer 会话。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateBreederWechatBindingOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new DefaultApi();

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // CreateBreederWechatBindingRequest
    createBreederWechatBindingRequest: ...,
    // string | IANA 时区；缺省时使用当前熊舍 timezone。 (optional)
    xTimezone: Asia/Shanghai,
  } satisfies CreateBreederWechatBindingOperationRequest;

  try {
    const data = await api.createBreederWechatBinding(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **createBreederWechatBindingRequest** | [CreateBreederWechatBindingRequest](CreateBreederWechatBindingRequest.md) |  | |
| **xTimezone** | `string` | IANA 时区；缺省时使用当前熊舍 timezone。 | [Optional] [Defaults to `&#39;Asia/Shanghai&#39;`] |

### Return type

[**SessionResponse**](SessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 绑定成功并创建 B 端会话 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createBreederWechatSession

> BreederWechatSessionResponse createBreederWechatSession(idempotencyKey, createBreederWechatSessionRequest, xTimezone)

B 端微信 wx.login 登录

用 wx.login 的 js_code 换取 B 端身份：已绑定 openid 直接返回 staff Bearer 会话； 未绑定则返回一次性 bwt_* 票据，随后通过短信验证完成绑定。session_key 永不返回客户端， 且本端点不使用 C 端 ct_* 客户会话。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateBreederWechatSessionOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new DefaultApi();

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // CreateBreederWechatSessionRequest
    createBreederWechatSessionRequest: ...,
    // string | IANA 时区；缺省时使用当前熊舍 timezone。 (optional)
    xTimezone: Asia/Shanghai,
  } satisfies CreateBreederWechatSessionOperationRequest;

  try {
    const data = await api.createBreederWechatSession(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **createBreederWechatSessionRequest** | [CreateBreederWechatSessionRequest](CreateBreederWechatSessionRequest.md) |  | |
| **xTimezone** | `string` | IANA 时区；缺省时使用当前熊舍 timezone。 | [Optional] [Defaults to `&#39;Asia/Shanghai&#39;`] |

### Return type

[**BreederWechatSessionResponse**](BreederWechatSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | openid 已绑定，返回 B 端 Bearer 会话 |  -  |
| **200** | openid 未绑定，需短信验证绑定 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |
| **429** | 请求频率过高 |  * Retry-After - 建议重试等待秒数 <br>  |
| **503** | 微信登录暂不可用，降级短信登录 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createBreedingPlan

> BreedingPlanResponse createBreedingPlan(idempotencyKey, breedingPlanCreateRequest)

创建繁育计划草稿

新建计划固定为 draft；请求体不接受 state 或 owner_id。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateBreedingPlanRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // BreedingPlanCreateRequest
    breedingPlanCreateRequest: ...,
  } satisfies CreateBreedingPlanRequest;

  try {
    const data = await api.createBreedingPlan(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **breedingPlanCreateRequest** | [BreedingPlanCreateRequest](BreedingPlanCreateRequest.md) |  | |

### Return type

[**BreedingPlanResponse**](BreedingPlanResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 繁育计划草稿已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createEnclosure

> EnclosureResponse createEnclosure(idempotencyKey, enclosureCreateRequest)

创建笼盒

创建当前熊舍内唯一编号的笼盒。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateEnclosureRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // EnclosureCreateRequest
    enclosureCreateRequest: ...,
  } satisfies CreateEnclosureRequest;

  try {
    const data = await api.createEnclosure(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **enclosureCreateRequest** | [EnclosureCreateRequest](EnclosureCreateRequest.md) |  | |

### Return type

[**EnclosureResponse**](EnclosureResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 笼盒已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createEnclosureCleaning

> EnclosureCleaningResponse createEnclosureCleaning(idempotencyKey, ifMatch, enclosureId, enclosureCleaningCreateRequest)

记录笼盒清洁或消毒

追加清洁事实并更新笼盒清洁投影；纠错通过新记录引用原记录完成。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateEnclosureCleaningRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    enclosureId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // EnclosureCleaningCreateRequest
    enclosureCleaningCreateRequest: ...,
  } satisfies CreateEnclosureCleaningRequest;

  try {
    const data = await api.createEnclosureCleaning(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **enclosureId** | `string` |  | [Defaults to `undefined`] |
| **enclosureCleaningCreateRequest** | [EnclosureCleaningCreateRequest](EnclosureCleaningCreateRequest.md) |  | |

### Return type

[**EnclosureCleaningResponse**](EnclosureCleaningResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 清洁事实已记录 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createEnclosureStay

> EnclosureStayResponse createEnclosureStay(idempotencyKey, ifMatch, enclosureId, enclosureStayCreateRequest)

创建入住或移笼事实

校验目标笼盒容量、时段冲突和配对授权。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateEnclosureStayRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    enclosureId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // EnclosureStayCreateRequest
    enclosureStayCreateRequest: ...,
  } satisfies CreateEnclosureStayRequest;

  try {
    const data = await api.createEnclosureStay(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **enclosureId** | `string` |  | [Defaults to `undefined`] |
| **enclosureStayCreateRequest** | [EnclosureStayCreateRequest](EnclosureStayCreateRequest.md) |  | |

### Return type

[**EnclosureStayResponse**](EnclosureStayResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 入住事实已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createExportJob

> ExportJobResponse createExportJob(idempotencyKey, exportJobCreateRequest)

创建数据导出

支持仓鼠、笼舍、繁育、窝次、体重、健康和谱系的 CSV 或 JSON 导出。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateExportJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // ExportJobCreateRequest
    exportJobCreateRequest: ...,
  } satisfies CreateExportJobRequest;

  try {
    const data = await api.createExportJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **exportJobCreateRequest** | [ExportJobCreateRequest](ExportJobCreateRequest.md) |  | |

### Return type

[**ExportJobResponse**](ExportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 导出任务已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createHamster

> HamsterResponse createHamster(idempotencyKey, hamsterCreateRequest)

创建仓鼠档案

owner_id 从认证上下文解析；父母关系写入 pedigree_parentage。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateHamsterRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // HamsterCreateRequest
    hamsterCreateRequest: {"internal_code":"SY-2026-001","name":"小云","species_rule_version_id":"018f47a2-3e3b-7e40-9665-12cd57082cf0","variety_code":"syrian","sex":"female","birth_date":"2026-05-20","source_type":"introduced","notes":"引入种母"},
  } satisfies CreateHamsterRequest;

  try {
    const data = await api.createHamster(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **hamsterCreateRequest** | [HamsterCreateRequest](HamsterCreateRequest.md) |  | |

### Return type

[**HamsterResponse**](HamsterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 仓鼠已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createHealthRecord

> HealthRecordResponse createHealthRecord(idempotencyKey, healthRecordCreateRequest)

创建健康记录

仓鼠或窝次至少关联一项；通知副作用不影响记录落库。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateHealthRecordRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // HealthRecordCreateRequest
    healthRecordCreateRequest: ...,
  } satisfies CreateHealthRecordRequest;

  try {
    const data = await api.createHealthRecord(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **healthRecordCreateRequest** | [HealthRecordCreateRequest](HealthRecordCreateRequest.md) |  | |

### Return type

[**HealthRecordResponse**](HealthRecordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 健康记录已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createImportJob

> ImportJobResponse createImportJob(idempotencyKey, importJobCreateRequest)

创建 CSV 导入任务

识别编码、表头和列；后续通过映射、预检和提交推进。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateImportJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // ImportJobCreateRequest
    importJobCreateRequest: ...,
  } satisfies CreateImportJobRequest;

  try {
    const data = await api.createImportJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **importJobCreateRequest** | [ImportJobCreateRequest](ImportJobCreateRequest.md) |  | |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 导入识别任务已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createImportUpload

> ImportUploadResponse createImportUpload(idempotencyKey, importUploadCreateRequest)

创建 CSV 上传

返回预签名地址，上传完成后用 upload_id 创建导入任务。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateImportUploadRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // ImportUploadCreateRequest
    importUploadCreateRequest: ...,
  } satisfies CreateImportUploadRequest;

  try {
    const data = await api.createImportUpload(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **importUploadCreateRequest** | [ImportUploadCreateRequest](ImportUploadCreateRequest.md) |  | |

### Return type

[**ImportUploadResponse**](ImportUploadResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 导入上传已创建 |  * Location -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createLitterCountEvent

> AdjustLitterCountResponse createLitterCountEvent(idempotencyKey, ifMatch, litterId, adjustLitterCountRequest)

追加窝仔数量事件

追加数量流水；根据后补发现或关闭原因同步临时幼崽身份。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateLitterCountEventRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // AdjustLitterCountRequest
    adjustLitterCountRequest: {"event_type":"discovered","delta":1,"occurred_at":"2026-08-05T01:00:00Z","reason":"清点时后补发现一只","new_temporary_codes":["L240804-05"]},
  } satisfies CreateLitterCountEventRequest;

  try {
    const data = await api.createLitterCountEvent(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **litterId** | `string` |  | [Defaults to `undefined`] |
| **adjustLitterCountRequest** | [AdjustLitterCountRequest](AdjustLitterCountRequest.md) |  | |

### Return type

[**AdjustLitterCountResponse**](AdjustLitterCountResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 数量流水和临时身份已同步 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createLitterParent

> LitterParentResponse createLitterParent(idempotencyKey, ifMatch, litterId, litterParentCreateRequest)

新增或纠正窝次父母关系

校验角色和祖先环，并保留关系断言来源。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateLitterParentRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // LitterParentCreateRequest
    litterParentCreateRequest: ...,
  } satisfies CreateLitterParentRequest;

  try {
    const data = await api.createLitterParent(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **litterId** | `string` |  | [Defaults to `undefined`] |
| **litterParentCreateRequest** | [LitterParentCreateRequest](LitterParentCreateRequest.md) |  | |

### Return type

[**LitterParentResponse**](LitterParentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 窝次父母关系已创建 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createMediaEditRecipe

> MediaEditRecipeResponse createMediaEditRecipe(idempotencyKey, ifMatch, mediaId, mediaEditRecipeRequest)

创建图片编辑配方

保存裁剪、旋转、滤镜和标注配方，不覆盖原始文件。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateMediaEditRecipeRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    mediaId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // MediaEditRecipeRequest
    mediaEditRecipeRequest: ...,
  } satisfies CreateMediaEditRecipeRequest;

  try {
    const data = await api.createMediaEditRecipe(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **mediaId** | `string` |  | [Defaults to `undefined`] |
| **mediaEditRecipeRequest** | [MediaEditRecipeRequest](MediaEditRecipeRequest.md) |  | |

### Return type

[**MediaEditRecipeResponse**](MediaEditRecipeResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 编辑派生任务已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createPedigreeParentage

> PedigreeParentageResponse createPedigreeParentage(idempotencyKey, pedigreeParentageCreateRequest)

新增父母关系断言

服务端校验角色、性别和祖先环；关系修正保留审计链。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreatePedigreeParentageRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // PedigreeParentageCreateRequest
    pedigreeParentageCreateRequest: ...,
  } satisfies CreatePedigreeParentageRequest;

  try {
    const data = await api.createPedigreeParentage(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **pedigreeParentageCreateRequest** | [PedigreeParentageCreateRequest](PedigreeParentageCreateRequest.md) |  | |

### Return type

[**PedigreeParentageResponse**](PedigreeParentageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 父母关系已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createSession

> SessionResponse createSession(idempotencyKey, phoneCodeLoginRequest, xTimezone)

使用手机验证码登录

校验验证码并返回 Bearer 访问令牌、刷新令牌和当前个人熊舍。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateSessionRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new DefaultApi();

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // PhoneCodeLoginRequest
    phoneCodeLoginRequest: {"phone":"+8613800138000","verification_id":"018f47a2-2f7e-7f5d-a413-5bfe09a61f62","code":"482931","device":{"platform":"ios","device_name":"iPhone","app_version":"0.1.0"}},
    // string | IANA 时区；缺省时使用当前熊舍 timezone。 (optional)
    xTimezone: Asia/Shanghai,
  } satisfies CreateSessionRequest;

  try {
    const data = await api.createSession(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **phoneCodeLoginRequest** | [PhoneCodeLoginRequest](PhoneCodeLoginRequest.md) |  | |
| **xTimezone** | `string` | IANA 时区；缺省时使用当前熊舍 timezone。 | [Optional] [Defaults to `&#39;Asia/Shanghai&#39;`] |

### Return type

[**SessionResponse**](SessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 登录成功 |  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |
| **429** | 请求频率过高 |  * Retry-After - 建议重试等待秒数 <br>  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createShare

> SharePageResponse createShare(idempotencyKey, shareCreateRequest)

创建公开分享

为仓鼠或窝次生成随机公开令牌，只包含显式选择的字段和媒体。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateShareRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // ShareCreateRequest
    shareCreateRequest: ...,
  } satisfies CreateShareRequest;

  try {
    const data = await api.createShare(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **shareCreateRequest** | [ShareCreateRequest](ShareCreateRequest.md) |  | |

### Return type

[**SharePageResponse**](SharePageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 分享已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createSpeciesRuleVersion

> SpeciesRuleVersionResponse createSpeciesRuleVersion(idempotencyKey, speciesRuleVersionCreateRequest)

创建规则版本

可从系统模板复制并调整；历史繁育计划继续引用其原规则快照。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateSpeciesRuleVersionRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // SpeciesRuleVersionCreateRequest
    speciesRuleVersionCreateRequest: ...,
  } satisfies CreateSpeciesRuleVersionRequest;

  try {
    const data = await api.createSpeciesRuleVersion(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **speciesRuleVersionCreateRequest** | [SpeciesRuleVersionCreateRequest](SpeciesRuleVersionCreateRequest.md) |  | |

### Return type

[**SpeciesRuleVersionResponse**](SpeciesRuleVersionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 规则版本已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createTask

> CareTaskResponse createTask(idempotencyKey, careTaskCreateRequest)

创建手工任务

系统生成任务也使用同一资源模型；关闭系统通知不影响任务存在。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateTaskRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // CareTaskCreateRequest
    careTaskCreateRequest: ...,
  } satisfies CreateTaskRequest;

  try {
    const data = await api.createTask(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **careTaskCreateRequest** | [CareTaskCreateRequest](CareTaskCreateRequest.md) |  | |

### Return type

[**CareTaskResponse**](CareTaskResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 任务已创建 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## createWeightRecord

> WeightRecordResponse createWeightRecord(idempotencyKey, weightRecordCreateRequest)

创建体重记录

原始克值只追加；服务端保存出生和上次体重比较快照。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { CreateWeightRecordRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // WeightRecordCreateRequest
    weightRecordCreateRequest: ...,
  } satisfies CreateWeightRecordRequest;

  try {
    const data = await api.createWeightRecord(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **weightRecordCreateRequest** | [WeightRecordCreateRequest](WeightRecordCreateRequest.md) |  | |

### Return type

[**WeightRecordResponse**](WeightRecordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 体重记录已创建 |  * Location -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## deleteBreederWechatBinding

> deleteBreederWechatBinding()

解绑当前 B 端微信身份

保留 revoked_at 审计记录；解绑后下次 wx.login 重新进入短信绑定流程。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { DeleteBreederWechatBindingRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  try {
    const data = await api.deleteBreederWechatBinding();
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters

This endpoint does not need any parameter.

### Return type

`void` (Empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **204** | 已解绑 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## deleteCurrentSession

> deleteCurrentSession(idempotencyKey)

退出当前会话

使当前访问令牌与对应刷新令牌失效。登出是状态收敛操作，天然幂等： 服务端每次都真实执行撤销、不做重放（不发送 Idempotency-Replayed）。 Idempotency-Key 为兼容旧客户端的可选头，提供时原样回显。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { DeleteCurrentSessionRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 可选；仅回显，不参与重放。 (optional)
    idempotencyKey: idempotencyKey_example,
  } satisfies DeleteCurrentSessionRequest;

  try {
    const data = await api.deleteCurrentSession(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 可选；仅回显，不参与重放。 | [Optional] [Defaults to `undefined`] |

### Return type

`void` (Empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **204** | 会话已失效 |  * Idempotency-Key -  <br>  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## endPedigreeParentage

> PedigreeParentageResponse endPedigreeParentage(idempotencyKey, pedigreeParentageEndRequest)

解除当前有效父母关系

将 child+role 上当前 accepted 的 pedigree_parentage 标记为 superseded（valid_to&#x3D;now）， 保留审计链。必须提供 correction_reason。不物理删除。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { EndPedigreeParentageRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // PedigreeParentageEndRequest
    pedigreeParentageEndRequest: ...,
  } satisfies EndPedigreeParentageRequest;

  try {
    const data = await api.endPedigreeParentage(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **pedigreeParentageEndRequest** | [PedigreeParentageEndRequest](PedigreeParentageEndRequest.md) |  | |

### Return type

[**PedigreeParentageResponse**](PedigreeParentageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 父母关系已解除（superseded） |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getAsyncJob

> AsyncJobResponse getAsyncJob(jobId)

获取通用异步作业

查询导入、导出、备份、媒体派生、转码或报喜卡任务状态。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetAsyncJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetAsyncJobRequest;

  try {
    const data = await api.getAsyncJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **jobId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**AsyncJobResponse**](AsyncJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 异步作业 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getBackupDownload

> DownloadLinkResponse getBackupDownload(jobId)

获取备份下载链接

返回短时有效下载地址、文件大小和 SHA-256。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetBackupDownloadRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetBackupDownloadRequest;

  try {
    const data = await api.getBackupDownload(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **jobId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**DownloadLinkResponse**](DownloadLinkResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 备份下载信息 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getBackupJob

> BackupJobResponse getBackupJob(jobId)

获取备份任务

返回进度、大小、哈希、失败原因和可恢复状态。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetBackupJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetBackupJobRequest;

  try {
    const data = await api.getBackupJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **jobId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**BackupJobResponse**](BackupJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 备份任务 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getBreedingPlan

> BreedingPlanResponse getBreedingPlan(planId)

获取繁育计划

返回计划、规则快照、亲缘检查和当前版本。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetBreedingPlanRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    planId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetBreedingPlanRequest;

  try {
    const data = await api.getBreedingPlan(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **planId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**BreedingPlanResponse**](BreedingPlanResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 繁育计划详情 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getCurrentAccount

> CurrentAccountResponse getCurrentAccount()

获取当前账号

返回认证账号、当前熊舍和会话能力。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetCurrentAccountRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  try {
    const data = await api.getCurrentAccount();
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**CurrentAccountResponse**](CurrentAccountResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 当前账号 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getCurrentOrganization

> OrganizationResponse getCurrentOrganization()

获取当前熊舍

当前熊舍由认证上下文选择。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetCurrentOrganizationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  try {
    const data = await api.getCurrentOrganization();
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**OrganizationResponse**](OrganizationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 当前熊舍 |  * ETag -  <br>  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getCurrentUsage

> UsageResponse getCurrentUsage()

获取当前用量

返回活跃个体、窝次、笼盒、媒体、视频和备份用量及权益上限。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetCurrentUsageRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  try {
    const data = await api.getCurrentUsage();
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**UsageResponse**](UsageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 当前用量 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getDataCenterSummary

> DataCenterSummaryResponse getDataCenterSummary()

获取数据中心摘要

返回最近导入、导出、备份和当前用量。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetDataCenterSummaryRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  try {
    const data = await api.getDataCenterSummary();
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**DataCenterSummaryResponse**](DataCenterSummaryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 数据中心摘要 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getEnclosure

> EnclosureResponse getEnclosure(enclosureId)

获取笼盒详情

返回笼盒、当前占用和版本号。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetEnclosureRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    enclosureId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetEnclosureRequest;

  try {
    const data = await api.getEnclosure(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **enclosureId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**EnclosureResponse**](EnclosureResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 笼盒详情 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getEnclosureCleaning

> EnclosureCleaningResponse getEnclosureCleaning(cleaningId)

获取清洁记录

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetEnclosureCleaningRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    cleaningId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetEnclosureCleaningRequest;

  try {
    const data = await api.getEnclosureCleaning(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cleaningId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**EnclosureCleaningResponse**](EnclosureCleaningResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 清洁记录 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getExportDownload

> DownloadLinkResponse getExportDownload(jobId)

获取导出下载链接

仅成功且未过期的任务返回短时有效下载地址。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetExportDownloadRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetExportDownloadRequest;

  try {
    const data = await api.getExportDownload(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **jobId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**DownloadLinkResponse**](DownloadLinkResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 下载信息 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getExportJob

> ExportJobResponse getExportJob(jobId)

获取导出任务

返回进度、失败原因、过期时间和下载状态。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetExportJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetExportJobRequest;

  try {
    const data = await api.getExportJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **jobId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**ExportJobResponse**](ExportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 导出任务 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getHamster

> HamsterResponse getHamster(hamsterId)

获取仓鼠详情

返回档案、当前笼位和版本号。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetHamsterRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    hamsterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetHamsterRequest;

  try {
    const data = await api.getHamster(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **hamsterId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**HamsterResponse**](HamsterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 仓鼠详情 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getHamsterPedigree

> PedigreeGraphResponse getHamsterPedigree(hamsterId, generations)

获取仓鼠家谱图

返回 pedigree_parentage 边、窝次父母与窝次成员推导出的统一关系图。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetHamsterPedigreeRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    hamsterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // number (optional)
    generations: 56,
  } satisfies GetHamsterPedigreeRequest;

  try {
    const data = await api.getHamsterPedigree(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **hamsterId** | `string` |  | [Defaults to `undefined`] |
| **generations** | `number` |  | [Optional] [Defaults to `4`] |

### Return type

[**PedigreeGraphResponse**](PedigreeGraphResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 家谱图 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getHealthRecord

> HealthRecordResponse getHealthRecord(healthRecordId)

获取健康记录

返回结构化检查、用药、媒体和版本。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetHealthRecordRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    healthRecordId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetHealthRecordRequest;

  try {
    const data = await api.getHealthRecord(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **healthRecordId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**HealthRecordResponse**](HealthRecordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 健康记录 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getImportErrorReport

> DownloadLinkResponse getImportErrorReport(jobId)

下载 CSV 逐行错误报告

为完成预检或正式导入的任务生成短期签名下载地址。报告包含行号、列名、 错误码、严重级别、原值和修复建议；下载前再次校验认证 owner_id。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetImportErrorReportRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetImportErrorReportRequest;

  try {
    const data = await api.getImportErrorReport(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **jobId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**DownloadLinkResponse**](DownloadLinkResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 错误报告下载信息 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getImportJob

> ImportJobResponse getImportJob(jobId)

获取导入任务

返回编码识别、映射、预检、提交进度和汇总。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetImportJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetImportJobRequest;

  try {
    const data = await api.getImportJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **jobId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 导入任务 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getImportTemplate

> ImportTemplateResponse getImportTemplate(templateType)

获取 CSV 导入模板

首版提供 hamster、enclosure 和 weight 三类模板。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetImportTemplateRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // ImportTemplateType
    templateType: ...,
  } satisfies GetImportTemplateRequest;

  try {
    const data = await api.getImportTemplate(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **templateType** | `ImportTemplateType` |  | [Defaults to `undefined`] [Enum: hamster, enclosure, weight] |

### Return type

[**ImportTemplateResponse**](ImportTemplateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 模板下载信息和字段定义 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getLitter

> LitterResponse getLitter(litterId)

获取窝次详情

返回数量对账、临时幼崽摘要和版本号。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetLitterRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetLitterRequest;

  try {
    const data = await api.getLitter(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **litterId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**LitterResponse**](LitterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 窝次详情 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getLitterIndividualizationEligibility

> IndividualizationEligibilityResponse getLitterIndividualizationEligibility(litterId)

获取服务端个体化 eligible set

服务端根据窝次状态、数量账、幼崽存活状态、断奶、性别复核和有效笼位， 计算本次必须完整转换的 pup_identity 集合。返回的 eligible_set_token 绑定 当前 litter version 与有序身份集合；任何相关事实变化都会使旧 token 失效。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetLitterIndividualizationEligibilityRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetLitterIndividualizationEligibilityRequest;

  try {
    const data = await api.getLitterIndividualizationEligibility(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **litterId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**IndividualizationEligibilityResponse**](IndividualizationEligibilityResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 个体化资格集合与阻塞原因 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getLitterIndividualizationEligibility_0

> IndividualizationEligibilityResponse getLitterIndividualizationEligibility_0(litterId)

获取服务端个体化 eligible set

服务端根据窝次状态、数量账、幼崽存活状态、断奶、性别复核和有效笼位， 计算本次必须完整转换的 pup_identity 集合。返回的 eligible_set_token 绑定 当前 litter version 与有序身份集合；任何相关事实变化都会使旧 token 失效。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetLitterIndividualizationEligibility0Request } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetLitterIndividualizationEligibility0Request;

  try {
    const data = await api.getLitterIndividualizationEligibility_0(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **litterId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**IndividualizationEligibilityResponse**](IndividualizationEligibilityResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 个体化资格集合与阻塞原因 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getLitterIndividualizationEligibility_1

> IndividualizationEligibilityResponse getLitterIndividualizationEligibility_1(litterId)

获取服务端个体化 eligible set

服务端根据窝次状态、数量账、幼崽存活状态、断奶、性别复核和有效笼位， 计算本次必须完整转换的 pup_identity 集合。返回的 eligible_set_token 绑定 当前 litter version 与有序身份集合；任何相关事实变化都会使旧 token 失效。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetLitterIndividualizationEligibility1Request } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetLitterIndividualizationEligibility1Request;

  try {
    const data = await api.getLitterIndividualizationEligibility_1(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **litterId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**IndividualizationEligibilityResponse**](IndividualizationEligibilityResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 个体化资格集合与阻塞原因 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getMediaAsset

> MediaAssetResponse getMediaAsset(mediaId)

获取媒体资产

返回原始媒体、派生版本、转码状态与封面。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetMediaAssetRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    mediaId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetMediaAssetRequest;

  try {
    const data = await api.getMediaAsset(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **mediaId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**MediaAssetResponse**](MediaAssetResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 媒体资产 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getMediaTranscodeStatus

> AsyncJobResponse getMediaTranscodeStatus(mediaId)

获取转码状态

返回短视频转码、图片派生或编辑任务的异步状态。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetMediaTranscodeStatusRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    mediaId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetMediaTranscodeStatusRequest;

  try {
    const data = await api.getMediaTranscodeStatus(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **mediaId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**AsyncJobResponse**](AsyncJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 转码状态 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getPairingAttempt

> PairingAttemptResponse getPairingAttempt(attemptId)

获取配对尝试

返回配对时间、结果、分笼截止时间和版本。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetPairingAttemptRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    attemptId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetPairingAttemptRequest;

  try {
    const data = await api.getPairingAttempt(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **attemptId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**PairingAttemptResponse**](PairingAttemptResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 配对尝试详情 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getPublicShare

> PublicShareResponse getPublicShare(token)

无需认证读取公开分享

只返回舍主显式选择的字段和 share-scoped 媒体 URL；撤销或过期后返回 404。 MVP API 响应使用 no-store，确保撤销完成后不会由浏览器或 CDN 回放历史 JSON。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetPublicShareRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new DefaultApi();

  const body = {
    // string
    token: token_example,
  } satisfies GetPublicShareRequest;

  try {
    const data = await api.getPublicShare(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **token** | `string` |  | [Defaults to `undefined`] |

### Return type

[**PublicShareResponse**](PublicShareResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 公开分享内容 |  * Cache-Control - 公开内容缓存策略 <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getPublicShareMedia

> Blob getPublicShareMedia(token, mediaId)

读取公开分享媒体

仅允许读取当前 token 显式选择的媒体；分享撤销或过期后返回 404。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetPublicShareMediaRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new DefaultApi();

  const body = {
    // string
    token: token_example,
    // string
    mediaId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetPublicShareMediaRequest;

  try {
    const data = await api.getPublicShareMedia(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **token** | `string` |  | [Defaults to `undefined`] |
| **mediaId** | `string` |  | [Defaults to `undefined`] |

### Return type

**Blob**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/octet-stream`, `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 公开媒体二进制内容 |  * Cache-Control - 公开内容缓存策略 <br>  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getReminder

> ReminderResponse getReminder(reminderId)

获取提醒

返回提醒规则、基准事件和多通道投递状态。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetReminderRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    reminderId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetReminderRequest;

  try {
    const data = await api.getReminder(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **reminderId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**ReminderResponse**](ReminderResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 提醒详情 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getSpeciesRuleVersion

> SpeciesRuleVersionResponse getSpeciesRuleVersion(ruleVersionId)

获取规则版本

返回单个规则版本及来源。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetSpeciesRuleVersionRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    ruleVersionId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetSpeciesRuleVersionRequest;

  try {
    const data = await api.getSpeciesRuleVersion(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **ruleVersionId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**SpeciesRuleVersionResponse**](SpeciesRuleVersionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 规则版本 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getTask

> CareTaskResponse getTask(taskId)

获取任务

返回阶段进度、关联对象和版本。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { GetTaskRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    taskId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies GetTaskRequest;

  try {
    const data = await api.getTask(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **taskId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**CareTaskResponse**](CareTaskResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 任务详情 |  * ETag -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## individualizeLitter

> IndividualizeLitterResponse individualizeLitter(idempotencyKey, ifMatch, litterId, individualizeLitterRequest)

将临时幼崽个体化

仅允许 individualizing。服务端重新计算完整 eligible set，并要求请求 token、 items 的身份集合与该集合完全一致；缺项、多项、重复项、失效 token 或任一阻塞项 均拒绝整批请求。通过后原子一对一转换为 hamster，建立 litter_member 与 pedigree_parentage，并返回服务端数量对账。客户端不提交目标状态或目标数量。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { IndividualizeLitterOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // IndividualizeLitterRequest
    individualizeLitterRequest: {"individualized_at":"2026-09-01T02:00:00Z","timezone":"Asia/Shanghai","eligible_set_token":"elig_v4_2c54b21e2fdb6ad3","items":[{"pup_identity_id":"018f47a2-73b3-762e-8498-07b13dc3b599","internal_code":"SY-2026-L01-01","name":"星一","variety_code":"syrian"},{"pup_identity_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","internal_code":"SY-2026-L01-02","name":"星二","variety_code":"syrian"}]},
  } satisfies IndividualizeLitterOperationRequest;

  try {
    const data = await api.individualizeLitter(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **litterId** | `string` |  | [Defaults to `undefined`] |
| **individualizeLitterRequest** | [IndividualizeLitterRequest](IndividualizeLitterRequest.md) |  | |

### Return type

[**IndividualizeLitterResponse**](IndividualizeLitterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 个体化已原子完成 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## individualizeLitter_0

> IndividualizeLitterResponse individualizeLitter_0(idempotencyKey, ifMatch, litterId, individualizeLitterRequest)

将临时幼崽个体化

仅允许 individualizing。服务端重新计算完整 eligible set，并要求请求 token、 items 的身份集合与该集合完全一致；缺项、多项、重复项、失效 token 或任一阻塞项 均拒绝整批请求。通过后原子一对一转换为 hamster，建立 litter_member 与 pedigree_parentage，并返回服务端数量对账。客户端不提交目标状态或目标数量。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { IndividualizeLitter0Request } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // IndividualizeLitterRequest
    individualizeLitterRequest: {"individualized_at":"2026-09-01T02:00:00Z","timezone":"Asia/Shanghai","eligible_set_token":"elig_v4_2c54b21e2fdb6ad3","items":[{"pup_identity_id":"018f47a2-73b3-762e-8498-07b13dc3b599","internal_code":"SY-2026-L01-01","name":"星一","variety_code":"syrian"},{"pup_identity_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","internal_code":"SY-2026-L01-02","name":"星二","variety_code":"syrian"}]},
  } satisfies IndividualizeLitter0Request;

  try {
    const data = await api.individualizeLitter_0(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **litterId** | `string` |  | [Defaults to `undefined`] |
| **individualizeLitterRequest** | [IndividualizeLitterRequest](IndividualizeLitterRequest.md) |  | |

### Return type

[**IndividualizeLitterResponse**](IndividualizeLitterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 个体化已原子完成 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## individualizeLitter_1

> IndividualizeLitterResponse individualizeLitter_1(idempotencyKey, ifMatch, litterId, individualizeLitterRequest)

将临时幼崽个体化

仅允许 individualizing。服务端重新计算完整 eligible set，并要求请求 token、 items 的身份集合与该集合完全一致；缺项、多项、重复项、失效 token 或任一阻塞项 均拒绝整批请求。通过后原子一对一转换为 hamster，建立 litter_member 与 pedigree_parentage，并返回服务端数量对账。客户端不提交目标状态或目标数量。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { IndividualizeLitter1Request } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // IndividualizeLitterRequest
    individualizeLitterRequest: {"individualized_at":"2026-09-01T02:00:00Z","timezone":"Asia/Shanghai","eligible_set_token":"elig_v4_2c54b21e2fdb6ad3","items":[{"pup_identity_id":"018f47a2-73b3-762e-8498-07b13dc3b599","internal_code":"SY-2026-L01-01","name":"星一","variety_code":"syrian"},{"pup_identity_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","internal_code":"SY-2026-L01-02","name":"星二","variety_code":"syrian"}]},
  } satisfies IndividualizeLitter1Request;

  try {
    const data = await api.individualizeLitter_1(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **litterId** | `string` |  | [Defaults to `undefined`] |
| **individualizeLitterRequest** | [IndividualizeLitterRequest](IndividualizeLitterRequest.md) |  | |

### Return type

[**IndividualizeLitterResponse**](IndividualizeLitterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 个体化已原子完成 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listBackupJobs

> BackupJobListResponse listBackupJobs(cursor, limit)

列出备份任务

使用 cursor 分页返回备份、校验与可恢复状态。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListBackupJobsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
  } satisfies ListBackupJobsRequest;

  try {
    const data = await api.listBackupJobs(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |

### Return type

[**BackupJobListResponse**](BackupJobListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 备份任务列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listBreedingPlans

> BreedingPlanListResponse listBreedingPlans(cursor, limit, state, sireId, damId)

列出繁育计划

使用 cursor 分页并按状态、父本、母本或日期筛选。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListBreedingPlansRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // BreedingPlanState (optional)
    state: ...,
    // string (optional)
    sireId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string (optional)
    damId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies ListBreedingPlansRequest;

  try {
    const data = await api.listBreedingPlans(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **state** | `BreedingPlanState` |  | [Optional] [Defaults to `undefined`] [Enum: draft, pair_ready, pairing, post_pair, gestation, litter_nursing, weaning_due, sex_separation_due, individualizing, completed, no_litter_outcome, hold, unsuccessful, cancelled] |
| **sireId** | `string` |  | [Optional] [Defaults to `undefined`] |
| **damId** | `string` |  | [Optional] [Defaults to `undefined`] |

### Return type

[**BreedingPlanListResponse**](BreedingPlanListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 繁育计划列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listEnclosureCleanings

> EnclosureCleaningListResponse listEnclosureCleanings(enclosureId, cursor, limit)

列出笼盒清洁历史

返回清洁、消毒及纠错记录；历史记录只追加，不原地覆盖。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListEnclosureCleaningsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    enclosureId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
  } satisfies ListEnclosureCleaningsRequest;

  try {
    const data = await api.listEnclosureCleanings(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **enclosureId** | `string` |  | [Defaults to `undefined`] |
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |

### Return type

[**EnclosureCleaningListResponse**](EnclosureCleaningListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 清洁历史 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listEnclosureStays

> EnclosureStayListResponse listEnclosureStays(enclosureId, cursor, limit, active)

列出笼盒入住历史

返回指定笼盒的入住、移笼和离开历史。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListEnclosureStaysRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    enclosureId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // boolean (optional)
    active: true,
  } satisfies ListEnclosureStaysRequest;

  try {
    const data = await api.listEnclosureStays(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **enclosureId** | `string` |  | [Defaults to `undefined`] |
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **active** | `boolean` |  | [Optional] [Defaults to `undefined`] |

### Return type

[**EnclosureStayListResponse**](EnclosureStayListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 入住历史 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listEnclosures

> EnclosureListResponse listEnclosures(cursor, limit, state, rackCode, cleanlinessState)

列出笼盒

使用 cursor 分页并支持状态、笼架和清洁状态筛选。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListEnclosuresRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // EnclosureState (optional)
    state: ...,
    // string (optional)
    rackCode: rackCode_example,
    // CleanlinessState (optional)
    cleanlinessState: ...,
  } satisfies ListEnclosuresRequest;

  try {
    const data = await api.listEnclosures(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **state** | `EnclosureState` |  | [Optional] [Defaults to `undefined`] [Enum: vacant, occupied_single, pairing_temp, gestation, dam_with_litter, isolation, cleaning_due, disabled] |
| **rackCode** | `string` |  | [Optional] [Defaults to `undefined`] |
| **cleanlinessState** | `CleanlinessState` |  | [Optional] [Defaults to `undefined`] [Enum: clean, partial_due, full_due] |

### Return type

[**EnclosureListResponse**](EnclosureListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 笼盒列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listExportJobs

> ExportJobListResponse listExportJobs(cursor, limit)

列出导出任务

使用 cursor 分页返回导出状态。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListExportJobsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
  } satisfies ListExportJobsRequest;

  try {
    const data = await api.listExportJobs(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |

### Return type

[**ExportJobListResponse**](ExportJobListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 导出任务列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listHamsters

> HamsterListResponse listHamsters(cursor, limit, lifecycleStatus, sex, enclosureId, q)

列出仓鼠

使用 cursor 分页；支持按状态、性别、笼盒和关键词筛选。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListHamstersRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // HamsterLifecycleStatus (optional)
    lifecycleStatus: ...,
    // Sex (optional)
    sex: ...,
    // string (optional)
    enclosureId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 编号或昵称关键词 (optional)
    q: q_example,
  } satisfies ListHamstersRequest;

  try {
    const data = await api.listHamsters(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **lifecycleStatus** | `HamsterLifecycleStatus` |  | [Optional] [Defaults to `undefined`] [Enum: active, transferred, retired, deceased] |
| **sex** | `Sex` |  | [Optional] [Defaults to `undefined`] [Enum: male, female, unknown] |
| **enclosureId** | `string` |  | [Optional] [Defaults to `undefined`] |
| **q** | `string` | 编号或昵称关键词 | [Optional] [Defaults to `undefined`] |

### Return type

[**HamsterListResponse**](HamsterListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 仓鼠列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listHealthRecords

> HealthRecordListResponse listHealthRecords(cursor, limit, hamsterId, litterId, type)

列出健康记录

按仓鼠、窝次、类型和发生时间筛选。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListHealthRecordsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // string (optional)
    hamsterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string (optional)
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // HealthRecordType (optional)
    type: ...,
  } satisfies ListHealthRecordsRequest;

  try {
    const data = await api.listHealthRecords(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **hamsterId** | `string` |  | [Optional] [Defaults to `undefined`] |
| **litterId** | `string` |  | [Optional] [Defaults to `undefined`] |
| **type** | `HealthRecordType` |  | [Optional] [Defaults to `undefined`] [Enum: daily_check, anomaly, medication, follow_up, isolation, death] |

### Return type

[**HealthRecordListResponse**](HealthRecordListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 健康记录列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listImportJobs

> ImportJobListResponse listImportJobs(cursor, limit, status)

列出导入任务

使用 cursor 分页返回任务状态。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListImportJobsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // JobStatus (optional)
    status: ...,
  } satisfies ListImportJobsRequest;

  try {
    const data = await api.listImportJobs(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **status** | `JobStatus` |  | [Optional] [Defaults to `undefined`] [Enum: queued, running, succeeded, partially_succeeded, failed, cancelled] |

### Return type

[**ImportJobListResponse**](ImportJobListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 导入任务列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listImportRowResults

> ImportRowResultListResponse listImportRowResults(jobId, cursor, limit, status)

获取逐行导入结果

使用 cursor 分页返回每行映射值、状态、资源 ID 和错误。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListImportRowResultsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // ImportRowStatus (optional)
    status: ...,
  } satisfies ListImportRowResultsRequest;

  try {
    const data = await api.listImportRowResults(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **jobId** | `string` |  | [Defaults to `undefined`] |
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **status** | `ImportRowStatus` |  | [Optional] [Defaults to `undefined`] [Enum: pending, valid, invalid, imported, skipped, failed] |

### Return type

[**ImportRowResultListResponse**](ImportRowResultListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 逐行结果 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listLitterMembers

> LitterMemberListResponse listLitterMembers(litterId, cursor, limit)

列出窝次成员

返回 litter_member，对临时幼崽或正式 hamster 二选一关联。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListLitterMembersRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
  } satisfies ListLitterMembersRequest;

  try {
    const data = await api.listLitterMembers(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **litterId** | `string` |  | [Defaults to `undefined`] |
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |

### Return type

[**LitterMemberListResponse**](LitterMemberListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 窝次成员列表 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listLitterMembers_0

> LitterMemberListResponse listLitterMembers_0(litterId, cursor, limit)

列出窝次成员

返回 litter_member，对临时幼崽或正式 hamster 二选一关联。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListLitterMembers0Request } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
  } satisfies ListLitterMembers0Request;

  try {
    const data = await api.listLitterMembers_0(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **litterId** | `string` |  | [Defaults to `undefined`] |
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |

### Return type

[**LitterMemberListResponse**](LitterMemberListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 窝次成员列表 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listLitterParents

> LitterParentListResponse listLitterParents(litterId)

获取窝次父母关系

返回 litter_parent 关系。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListLitterParentsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies ListLitterParentsRequest;

  try {
    const data = await api.listLitterParents(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **litterId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**LitterParentListResponse**](LitterParentListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 窝次父母关系 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listLitters

> LitterListResponse listLitters(cursor, limit, state, bornFrom, bornTo)

列出窝次

使用 cursor 分页并支持状态、父母和出生日期筛选。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListLittersRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // LitterState (optional)
    state: ...,
    // Date (optional)
    bornFrom: 2013-10-20,
    // Date (optional)
    bornTo: 2013-10-20,
  } satisfies ListLittersRequest;

  try {
    const data = await api.listLitters(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **state** | `LitterState` |  | [Optional] [Defaults to `undefined`] [Enum: newborn, nursing, weaning_due, sexing_due, individualizing, closed, voided] |
| **bornFrom** | `Date` |  | [Optional] [Defaults to `undefined`] |
| **bornTo** | `Date` |  | [Optional] [Defaults to `undefined`] |

### Return type

[**LitterListResponse**](LitterListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 窝次列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listPairingAttempts

> PairingAttemptListResponse listPairingAttempts(planId, cursor, limit)

列出计划的配对尝试

返回多次配对尝试及当前版本。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListPairingAttemptsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    planId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
  } satisfies ListPairingAttemptsRequest;

  try {
    const data = await api.listPairingAttempts(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **planId** | `string` |  | [Defaults to `undefined`] |
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |

### Return type

[**PairingAttemptListResponse**](PairingAttemptListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 配对尝试列表 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listPedigreeParentages

> PedigreeParentageListResponse listPedigreeParentages(cursor, limit, childHamsterId, parentHamsterId)

列出家谱父母边

按子代、父母或有效期筛选 pedigree_parentage。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListPedigreeParentagesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // string (optional)
    childHamsterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string (optional)
    parentHamsterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies ListPedigreeParentagesRequest;

  try {
    const data = await api.listPedigreeParentages(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **childHamsterId** | `string` |  | [Optional] [Defaults to `undefined`] |
| **parentHamsterId** | `string` |  | [Optional] [Defaults to `undefined`] |

### Return type

[**PedigreeParentageListResponse**](PedigreeParentageListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 父母关系列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listPupIdentities

> PupIdentityListResponse listPupIdentities(litterId, cursor, limit, outcomeStatus, profileStatus)

列出临时幼崽

返回未个体化及已映射幼崽身份。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListPupIdentitiesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // PupOutcomeStatus (optional)
    outcomeStatus: ...,
    // PupProfileStatus (optional)
    profileStatus: ...,
  } satisfies ListPupIdentitiesRequest;

  try {
    const data = await api.listPupIdentities(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **litterId** | `string` |  | [Defaults to `undefined`] |
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **outcomeStatus** | `PupOutcomeStatus` |  | [Optional] [Defaults to `undefined`] [Enum: alive, deceased, transferred_out] |
| **profileStatus** | `PupProfileStatus` |  | [Optional] [Defaults to `undefined`] [Enum: unindividualized, individualized, voided] |

### Return type

[**PupIdentityListResponse**](PupIdentityListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 临时幼崽列表 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listReminders

> ReminderListResponse listReminders(cursor, limit, state, ruleCode)

列出提醒

返回站内提醒及各通知通道投递状态。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListRemindersRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // ReminderState (optional)
    state: ...,
    // string (optional)
    ruleCode: ruleCode_example,
  } satisfies ListRemindersRequest;

  try {
    const data = await api.listReminders(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **state** | `ReminderState` |  | [Optional] [Defaults to `undefined`] [Enum: pending, sent, read, failed, superseded, cancelled] |
| **ruleCode** | `string` |  | [Optional] [Defaults to `undefined`] |

### Return type

[**ReminderListResponse**](ReminderListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 提醒列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listShares

> SharePageListResponse listShares(cursor, limit, status)

列出公开分享

使用 cursor 分页返回当前熊舍创建的分享。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListSharesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // ShareStatus (optional)
    status: ...,
  } satisfies ListSharesRequest;

  try {
    const data = await api.listShares(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **status** | `ShareStatus` |  | [Optional] [Defaults to `undefined`] [Enum: active, expired, revoked] |

### Return type

[**SharePageListResponse**](SharePageListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 分享列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listSpeciesRuleTemplates

> SpeciesRuleVersionListResponse listSpeciesRuleTemplates(cursor, limit)

列出系统物种规则模板

返回系统维护的只读模板，可复制为当前熊舍规则版本。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListSpeciesRuleTemplatesRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
  } satisfies ListSpeciesRuleTemplatesRequest;

  try {
    const data = await api.listSpeciesRuleTemplates(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |

### Return type

[**SpeciesRuleVersionListResponse**](SpeciesRuleVersionListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 物种规则模板列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listSpeciesRuleVersions

> SpeciesRuleVersionListResponse listSpeciesRuleVersions(cursor, limit, speciesCode)

列出当前熊舍规则版本

按 cursor 分页返回当前熊舍复制或创建的历史规则版本。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListSpeciesRuleVersionsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // string | 按物种编码筛选 (optional)
    speciesCode: speciesCode_example,
  } satisfies ListSpeciesRuleVersionsRequest;

  try {
    const data = await api.listSpeciesRuleVersions(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **speciesCode** | `string` | 按物种编码筛选 | [Optional] [Defaults to `undefined`] |

### Return type

[**SpeciesRuleVersionListResponse**](SpeciesRuleVersionListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 规则版本列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listTasks

> CareTaskListResponse listTasks(cursor, limit, state, priority, targetType, dueBefore)

列出任务

使用 cursor 分页，支持状态、优先级、目标和时间范围筛选。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListTasksRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // TaskState (optional)
    state: ...,
    // TaskPriority (optional)
    priority: ...,
    // string (optional)
    targetType: targetType_example,
    // Date (optional)
    dueBefore: 2013-10-20T19:20:30+01:00,
  } satisfies ListTasksRequest;

  try {
    const data = await api.listTasks(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **state** | `TaskState` |  | [Optional] [Defaults to `undefined`] [Enum: pending, in_progress, completed, snoozed, cancelled, superseded] |
| **priority** | `TaskPriority` |  | [Optional] [Defaults to `undefined`] [Enum: low, normal, high, urgent, critical] |
| **targetType** | `string` |  | [Optional] [Defaults to `undefined`] |
| **dueBefore** | `Date` |  | [Optional] [Defaults to `undefined`] |

### Return type

[**CareTaskListResponse**](CareTaskListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 任务列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listUsageSnapshots

> UsageSnapshotListResponse listUsageSnapshots(cursor, limit, from, to)

列出用量快照

使用 cursor 分页返回历史计量快照。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListUsageSnapshotsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // Date (optional)
    from: 2013-10-20,
    // Date (optional)
    to: 2013-10-20,
  } satisfies ListUsageSnapshotsRequest;

  try {
    const data = await api.listUsageSnapshots(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **from** | `Date` |  | [Optional] [Defaults to `undefined`] |
| **to** | `Date` |  | [Optional] [Defaults to `undefined`] |

### Return type

[**UsageSnapshotListResponse**](UsageSnapshotListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 用量快照列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listWechatSubscriptions

> WechatSubscriptionListResponse listWechatSubscriptions()

查看当前 B 端微信订阅授权

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListWechatSubscriptionsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  try {
    const data = await api.listWechatSubscriptions();
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**WechatSubscriptionListResponse**](WechatSubscriptionListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 订阅模板授权列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listWeightRecords

> WeightRecordListResponse listWeightRecords(cursor, limit, hamsterId, pupIdentityId, litterId, recordedFrom, recordedTo)

列出体重记录

按仓鼠、临时幼崽、窝次和时间范围筛选，使用 cursor 分页。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ListWeightRecordsRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 上一页响应返回的不透明 next_cursor。 (optional)
    cursor: cursor_example,
    // number | 每页数量。 (optional)
    limit: 56,
    // string (optional)
    hamsterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string (optional)
    pupIdentityId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string (optional)
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // Date (optional)
    recordedFrom: 2013-10-20T19:20:30+01:00,
    // Date (optional)
    recordedTo: 2013-10-20T19:20:30+01:00,
  } satisfies ListWeightRecordsRequest;

  try {
    const data = await api.listWeightRecords(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **cursor** | `string` | 上一页响应返回的不透明 next_cursor。 | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | 每页数量。 | [Optional] [Defaults to `50`] |
| **hamsterId** | `string` |  | [Optional] [Defaults to `undefined`] |
| **pupIdentityId** | `string` |  | [Optional] [Defaults to `undefined`] |
| **litterId** | `string` |  | [Optional] [Defaults to `undefined`] |
| **recordedFrom** | `Date` |  | [Optional] [Defaults to `undefined`] |
| **recordedTo** | `Date` |  | [Optional] [Defaults to `undefined`] |

### Return type

[**WeightRecordListResponse**](WeightRecordListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 体重记录列表 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## preflightImportJob

> ImportJobResponse preflightImportJob(idempotencyKey, ifMatch, jobId, importPreflightRequest)

全量预检 CSV

全量检查缺列、重复编号、父母缺失、父母与既有窝次不一致、谱系环、笼位冲突 和非法体重。仓鼠模板可按窝次编号自动规划历史窝次，但只有同一窝次的出生时间、 双亲和物种规则全部一致时才允许创建；任何冲突均作为阻塞问题返回，不静默合并。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { PreflightImportJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // ImportPreflightRequest
    importPreflightRequest: ...,
  } satisfies PreflightImportJobRequest;

  try {
    const data = await api.preflightImportJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **jobId** | `string` |  | [Defaults to `undefined`] |
| **importPreflightRequest** | [ImportPreflightRequest](ImportPreflightRequest.md) |  | |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 预检任务已排队 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## presignMediaUpload

> MediaUploadPresignResponse presignMediaUpload(idempotencyKey, mediaUploadPresignRequest)

创建媒体预签名上传

生成对象存储上传地址；支持图片与短视频。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { PresignMediaUploadRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // MediaUploadPresignRequest
    mediaUploadPresignRequest: ...,
  } satisfies PresignMediaUploadRequest;

  try {
    const data = await api.presignMediaUpload(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **mediaUploadPresignRequest** | [MediaUploadPresignRequest](MediaUploadPresignRequest.md) |  | |

### Return type

[**MediaUploadPresignResponse**](MediaUploadPresignResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 预签名上传已创建 |  * Location -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## previewShare

> PublicShareResponse previewShare(shareId)

预览公开分享

认证态预览最终公开字段和媒体，不增加公开访问计数。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { PreviewShareRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    shareId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
  } satisfies PreviewShareRequest;

  try {
    const data = await api.previewShare(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **shareId** | `string` |  | [Defaults to `undefined`] |

### Return type

[**PublicShareResponse**](PublicShareResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 分享预览 |  -  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## previewShareDraft

> PublicShareResponse previewShareDraft(idempotencyKey, shareCreateRequest)

创建前预览公开分享

不持久化分享，不生成公开令牌；按当前 owner 校验主体、字段和媒体后返回 匿名访客将看到的精确投影。禁止输出健康备注、联系方式、任务和审计字段。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { PreviewShareDraftRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // ShareCreateRequest
    shareCreateRequest: ...,
  } satisfies PreviewShareDraftRequest;

  try {
    const data = await api.previewShareDraft(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **shareCreateRequest** | [ShareCreateRequest](ShareCreateRequest.md) |  | |

### Return type

[**PublicShareResponse**](PublicShareResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 未持久化的公开投影预览 |  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## publishBreedingPlan

> PublishBreedingPlanResponse publishBreedingPlan(idempotencyKey, ifMatch, planId, publishBreedingPlanRequest)

发布繁育计划

校验父母资格、并行计划、规则版本与亲缘风险后，将 draft 推进到 pair_ready。 仅允许当前状态为 draft；客户端不提交目标 state。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { PublishBreedingPlanOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    planId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // PublishBreedingPlanRequest
    publishBreedingPlanRequest: {"planned_pairing_at":"2026-07-18T12:00:00Z","pairing_enclosure_id":"018f47a2-4b10-77eb-a297-ad0e32886a35","timezone":"Asia/Shanghai","kinship_override_reason":null},
  } satisfies PublishBreedingPlanOperationRequest;

  try {
    const data = await api.publishBreedingPlan(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **planId** | `string` |  | [Defaults to `undefined`] |
| **publishBreedingPlanRequest** | [PublishBreedingPlanRequest](PublishBreedingPlanRequest.md) |  | |

### Return type

[**PublishBreedingPlanResponse**](PublishBreedingPlanResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 计划已发布 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## recordPairingObservation

> RecordObservationResponse recordPairingObservation(idempotencyKey, ifMatch, attemptId, recordObservationRequest)

记录配对观察

在有效配对时间段内追加观察，不覆盖已有观察。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { RecordPairingObservationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    attemptId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // RecordObservationRequest
    recordObservationRequest: {"observed_at":"2026-07-18T12:12:00Z","type":"mating","duration_seconds":14,"severity":"info","confidence":0.9,"media_ids":["018f47a2-5e60-7fc7-b29c-1f2d435f49cd"],"notes":"观察到一次明确交配"},
  } satisfies RecordPairingObservationRequest;

  try {
    const data = await api.recordPairingObservation(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **attemptId** | `string` |  | [Defaults to `undefined`] |
| **recordObservationRequest** | [RecordObservationRequest](RecordObservationRequest.md) |  | |

### Return type

[**RecordObservationResponse**](RecordObservationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 观察已记录 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## refreshSession

> SessionResponse refreshSession(idempotencyKey, refreshSessionRequest, xTimezone)

刷新当前会话

使用刷新令牌轮换访问令牌和刷新令牌，供客户端恢复认证 owner 上下文。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { RefreshSessionOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new DefaultApi();

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // RefreshSessionRequest
    refreshSessionRequest: ...,
    // string | IANA 时区；缺省时使用当前熊舍 timezone。 (optional)
    xTimezone: Asia/Shanghai,
  } satisfies RefreshSessionOperationRequest;

  try {
    const data = await api.refreshSession(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **refreshSessionRequest** | [RefreshSessionRequest](RefreshSessionRequest.md) |  | |
| **xTimezone** | `string` | IANA 时区；缺省时使用当前熊舍 timezone。 | [Optional] [Defaults to `&#39;Asia/Shanghai&#39;`] |

### Return type

[**SessionResponse**](SessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | 会话刷新成功 |  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## reopenTask

> CareTaskResponse reopenTask(idempotencyKey, ifMatch, taskId, taskCorrectionRequest)

撤销任务的完成或取消

把已完成或已取消的任务退回 pending，用于纠正误点完成/误取消，必须填写原因。 subject 级完成痕迹一并清除，否则任务显示待办而每个成员仍标记已完成。 原因记入 CARE_TASK_REOPENED 领域事件。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { ReopenTaskRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    taskId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // TaskCorrectionRequest
    taskCorrectionRequest: {"reason":"误点完成，实际尚未称重"},
  } satisfies ReopenTaskRequest;

  try {
    const data = await api.reopenTask(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **taskId** | `string` |  | [Defaults to `undefined`] |
| **taskCorrectionRequest** | [TaskCorrectionRequest](TaskCorrectionRequest.md) |  | |

### Return type

[**CareTaskResponse**](CareTaskResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 任务已退回待办 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## retryBackupJob

> BackupJobResponse retryBackupJob(idempotencyKey, ifMatch, jobId, retryJobRequest)

重试失败备份

保留原失败记录并创建新的执行尝试。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { RetryBackupJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // RetryJobRequest
    retryJobRequest: ...,
  } satisfies RetryBackupJobRequest;

  try {
    const data = await api.retryBackupJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **jobId** | `string` |  | [Defaults to `undefined`] |
| **retryJobRequest** | [RetryJobRequest](RetryJobRequest.md) |  | |

### Return type

[**BackupJobResponse**](BackupJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 备份重试已创建 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## retryExportJob

> ExportJobResponse retryExportJob(idempotencyKey, ifMatch, jobId, retryJobRequest)

重试失败导出

从相同导出快照创建新执行尝试。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { RetryExportJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // RetryJobRequest
    retryJobRequest: ...,
  } satisfies RetryExportJobRequest;

  try {
    const data = await api.retryExportJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **jobId** | `string` |  | [Defaults to `undefined`] |
| **retryJobRequest** | [RetryJobRequest](RetryJobRequest.md) |  | |

### Return type

[**ExportJobResponse**](ExportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 导出重试已创建 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## retryImportJob

> ImportJobResponse retryImportJob(idempotencyKey, ifMatch, jobId, retryImportRequest)

重试失败导入行

可重试全部失败行或指定行号，已成功行不会重复写入。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { RetryImportJobRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // RetryImportRequest
    retryImportRequest: ...,
  } satisfies RetryImportJobRequest;

  try {
    const data = await api.retryImportJob(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **jobId** | `string` |  | [Defaults to `undefined`] |
| **retryImportRequest** | [RetryImportRequest](RetryImportRequest.md) |  | |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 导入重试已排队 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## retryMediaProcessing

> MediaProcessingRetryResponse retryMediaProcessing(idempotencyKey, ifMatch, mediaId, mediaProcessingRetryRequest)

重试失败的媒体处理

仅允许原始媒体已完成校验且目标派生处于 failed。保留原失败作业， 幂等创建新的图片派生或短视频转码作业；业务记录和原始媒体事实不回滚。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { RetryMediaProcessingRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    mediaId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // MediaProcessingRetryRequest
    mediaProcessingRetryRequest: ...,
  } satisfies RetryMediaProcessingRequest;

  try {
    const data = await api.retryMediaProcessing(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **mediaId** | `string` |  | [Defaults to `undefined`] |
| **mediaProcessingRetryRequest** | [MediaProcessingRetryRequest](MediaProcessingRetryRequest.md) |  | |

### Return type

[**MediaProcessingRetryResponse**](MediaProcessingRetryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 新的媒体处理作业已排队 |  * Location -  <br>  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## revokeShare

> ShareRevocationResponse revokeShare(idempotencyKey, ifMatch, shareId, revokeShareRequest)

撤销公开分享

同一事务内标记令牌已撤销并写入 CDN purge Outbox，事务提交后立即返回 200； 公开 API 的下一次请求立即失效，HTML/JSON 使用 no-store。share-scoped 公开媒体 的边缘 TTL 不超过 60 秒，最迟 60 秒不再返回；内部资源和原始私有媒体不受影响。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { RevokeShareOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    shareId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // RevokeShareRequest
    revokeShareRequest: ...,
  } satisfies RevokeShareOperationRequest;

  try {
    const data = await api.revokeShare(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **shareId** | `string` |  | [Defaults to `undefined`] |
| **revokeShareRequest** | [RevokeShareRequest](RevokeShareRequest.md) |  | |

### Return type

[**ShareRevocationResponse**](ShareRevocationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 分享已撤销 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## sendVerificationCode

> VerificationCodeChallengeResponse sendVerificationCode(idempotencyKey, sendVerificationCodeRequest, xTimezone)

发送手机验证码

为登录目的发送验证码；相同手机号和用途受冷却时间与频率限制。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { SendVerificationCodeOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const api = new DefaultApi();

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // SendVerificationCodeRequest
    sendVerificationCodeRequest: {"phone":"+8613800138000","purpose":"login"},
    // string | IANA 时区；缺省时使用当前熊舍 timezone。 (optional)
    xTimezone: Asia/Shanghai,
  } satisfies SendVerificationCodeOperationRequest;

  try {
    const data = await api.sendVerificationCode(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **sendVerificationCodeRequest** | [SendVerificationCodeRequest](SendVerificationCodeRequest.md) |  | |
| **xTimezone** | `string` | IANA 时区；缺省时使用当前熊舍 timezone。 | [Optional] [Defaults to `&#39;Asia/Shanghai&#39;`] |

### Return type

[**VerificationCodeChallengeResponse**](VerificationCodeChallengeResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | 验证码已受理发送 |  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |
| **429** | 请求频率过高 |  * Retry-After - 建议重试等待秒数 <br>  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## sendWechatSubscription

> WechatSubscriptionDeliveryResponse sendWechatSubscription(idempotencyKey, sendWechatSubscriptionRequest)

投递一条已授权的微信订阅消息

供任务提醒和预订状态变更编排复用；模板字段由微信模板定义，服务端只转发字符串值。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { SendWechatSubscriptionOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // SendWechatSubscriptionRequest
    sendWechatSubscriptionRequest: ...,
  } satisfies SendWechatSubscriptionOperationRequest;

  try {
    const data = await api.sendWechatSubscription(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **sendWechatSubscriptionRequest** | [SendWechatSubscriptionRequest](SendWechatSubscriptionRequest.md) |  | |

### Return type

[**WechatSubscriptionDeliveryResponse**](WechatSubscriptionDeliveryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 投递成功 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |
| **503** | 微信订阅消息通道暂未配置 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## separatePairing

> SeparatePairingResponse separatePairing(idempotencyKey, ifMatch, attemptId, separatePairingRequest)

结束配对并完成分笼

仅允许 active 或 safety_hold 的配对尝试。 原子关闭临时配对占用、登记双方去向并创建新入住事实。 若笼盒冲突或只登记一方，整体失败且不释放配对笼。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { SeparatePairingOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    attemptId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // SeparatePairingRequest
    separatePairingRequest: {"ended_at":"2026-07-18T12:25:00Z","separated_at":"2026-07-18T12:26:00Z","result":"effective","sire_destination_enclosure_id":"018f47a2-6338-7952-9753-052621e1858e","dam_destination_enclosure_id":"018f47a2-6450-7f54-8851-050a3d63846f","safety_stop":false,"timezone":"Asia/Shanghai","notes":"双方状态正常"},
  } satisfies SeparatePairingOperationRequest;

  try {
    const data = await api.separatePairing(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **attemptId** | `string` |  | [Defaults to `undefined`] |
| **separatePairingRequest** | [SeparatePairingRequest](SeparatePairingRequest.md) |  | |

### Return type

[**SeparatePairingResponse**](SeparatePairingResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 分笼闭环已完成 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## setImportMapping

> ImportJobResponse setImportMapping(idempotencyKey, ifMatch, jobId, importMappingRequest)

设置 CSV 字段映射

保存源列到目标字段的映射、空值策略和时区。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { SetImportMappingRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    jobId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // ImportMappingRequest
    importMappingRequest: ...,
  } satisfies SetImportMappingRequest;

  try {
    const data = await api.setImportMapping(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **jobId** | `string` |  | [Defaults to `undefined`] |
| **importMappingRequest** | [ImportMappingRequest](ImportMappingRequest.md) |  | |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 字段映射已保存 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## setMediaCover

> MediaAssetResponse setMediaCover(idempotencyKey, ifMatch, mediaId, mediaCoverRequest)

设置媒体封面

视频可选择时间点或已有媒体作为封面。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { SetMediaCoverRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    mediaId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // MediaCoverRequest
    mediaCoverRequest: ...,
  } satisfies SetMediaCoverRequest;

  try {
    const data = await api.setMediaCover(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **mediaId** | `string` |  | [Defaults to `undefined`] |
| **mediaCoverRequest** | [MediaCoverRequest](MediaCoverRequest.md) |  | |

### Return type

[**MediaAssetResponse**](MediaAssetResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 封面已设置 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## sexAndSeparateLitter

> SexAndSeparateResponse sexAndSeparateLitter(idempotencyKey, ifMatch, litterId, sexAndSeparateRequest)

分性并分笼

仅允许 sexing_due；逐项提交性别、置信度和目标笼盒。服务端验证完整在管集合、 异性混笼、容量和待复核安排，客户端不得提交目标状态。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { SexAndSeparateLitterRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // SexAndSeparateRequest
    sexAndSeparateRequest: {"separated_at":"2026-08-27T02:00:00Z","timezone":"Asia/Shanghai","items":[{"pup_identity_id":"018f47a2-73b3-762e-8498-07b13dc3b599","sex":"male","sex_confidence":0.98,"destination_enclosure_id":"018f47a2-8620-73ef-823e-03f187be47a2","requires_recheck":false},{"pup_identity_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","sex":"unknown","sex_confidence":0.45,"destination_enclosure_id":"018f47a2-8712-7863-ab76-9a6614ef3e2b","requires_recheck":true}]},
  } satisfies SexAndSeparateLitterRequest;

  try {
    const data = await api.sexAndSeparateLitter(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **litterId** | `string` |  | [Defaults to `undefined`] |
| **sexAndSeparateRequest** | [SexAndSeparateRequest](SexAndSeparateRequest.md) |  | |

### Return type

[**SexAndSeparateResponse**](SexAndSeparateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 分性分笼已完成或进入待复核安排 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## startGestationMonitoring

> StartGestationResponse startGestationMonitoring(idempotencyKey, ifMatch, planId, startGestationRequest)

从分笼后进入孕期观察

仅允许 post_pair。服务端校验至少一次 pairing_attempt 已闭环、结果为有效或待定、 配对笼已释放，再计算预产区间、创建提醒并推进到 gestation。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { StartGestationMonitoringRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    planId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // StartGestationRequest
    startGestationRequest: ...,
  } satisfies StartGestationMonitoringRequest;

  try {
    const data = await api.startGestationMonitoring(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **planId** | `string` |  | [Defaults to `undefined`] |
| **startGestationRequest** | [StartGestationRequest](StartGestationRequest.md) |  | |

### Return type

[**StartGestationResponse**](StartGestationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 已进入孕期观察并生成预产区间 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## startPairing

> StartPairingResponse startPairing(idempotencyKey, ifMatch, planId, startPairingRequest)

开始配对

仅允许当前状态为 pair_ready。原子创建 pairing_attempt、占用临时配对笼 并推进到 pairing；任一父母资格或笼位守卫失败时不产生部分事实。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { StartPairingOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    planId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // StartPairingRequest
    startPairingRequest: {"enclosure_id":"018f47a2-4b10-77eb-a297-ad0e32886a35","started_at":"2026-07-18T12:03:00Z","timezone":"Asia/Shanghai","notes":"现场扫码开始"},
  } satisfies StartPairingOperationRequest;

  try {
    const data = await api.startPairing(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **planId** | `string` |  | [Defaults to `undefined`] |
| **startPairingRequest** | [StartPairingRequest](StartPairingRequest.md) |  | |

### Return type

[**StartPairingResponse**](StartPairingResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 配对已开始 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## updateBreedingPlan

> BreedingPlanResponse updateBreedingPlan(idempotencyKey, ifMatch, planId, breedingPlanUpdateRequest)

更新繁育计划资料

只更新非状态字段；客户端不得直接 PATCH state。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { UpdateBreedingPlanRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    planId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // BreedingPlanUpdateRequest
    breedingPlanUpdateRequest: ...,
  } satisfies UpdateBreedingPlanRequest;

  try {
    const data = await api.updateBreedingPlan(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **planId** | `string` |  | [Defaults to `undefined`] |
| **breedingPlanUpdateRequest** | [BreedingPlanUpdateRequest](BreedingPlanUpdateRequest.md) |  | |

### Return type

[**BreedingPlanResponse**](BreedingPlanResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/merge-patch+json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 繁育计划已更新 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## updateCurrentOrganization

> OrganizationResponse updateCurrentOrganization(idempotencyKey, ifMatch, organizationUpdateRequest)

更新当前熊舍

仅更新熊舍资料；owner_id 由认证上下文解析且不在请求体中出现。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { UpdateCurrentOrganizationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // OrganizationUpdateRequest
    organizationUpdateRequest: {"name":"星河熊舍二号馆","timezone":"Asia/Shanghai"},
  } satisfies UpdateCurrentOrganizationRequest;

  try {
    const data = await api.updateCurrentOrganization(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **organizationUpdateRequest** | [OrganizationUpdateRequest](OrganizationUpdateRequest.md) |  | |

### Return type

[**OrganizationResponse**](OrganizationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/merge-patch+json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 熊舍已更新 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## updateEnclosure

> EnclosureResponse updateEnclosure(idempotencyKey, ifMatch, enclosureId, enclosureUpdateRequest)

更新笼盒资料

修改编号、位置、笼内设施（跑轮、饮水器、食盆、躲避屋、垫材等）和清洁资料；占用事实通过入住资源维护。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { UpdateEnclosureRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    enclosureId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // EnclosureUpdateRequest
    enclosureUpdateRequest: ...,
  } satisfies UpdateEnclosureRequest;

  try {
    const data = await api.updateEnclosure(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **enclosureId** | `string` |  | [Defaults to `undefined`] |
| **enclosureUpdateRequest** | [EnclosureUpdateRequest](EnclosureUpdateRequest.md) |  | |

### Return type

[**EnclosureResponse**](EnclosureResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/merge-patch+json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 笼盒已更新 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## updateEnclosureStay

> EnclosureStayResponse updateEnclosureStay(idempotencyKey, ifMatch, stayId, enclosureStayUpdateRequest)

结束或修正入住事实

可填写结束时间与修正原因；历史修正保留审计信息。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { UpdateEnclosureStayRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    stayId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // EnclosureStayUpdateRequest
    enclosureStayUpdateRequest: ...,
  } satisfies UpdateEnclosureStayRequest;

  try {
    const data = await api.updateEnclosureStay(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **stayId** | `string` |  | [Defaults to `undefined`] |
| **enclosureStayUpdateRequest** | [EnclosureStayUpdateRequest](EnclosureStayUpdateRequest.md) |  | |

### Return type

[**EnclosureStayResponse**](EnclosureStayResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/merge-patch+json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 入住事实已更新 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## updateHamster

> HamsterResponse updateHamster(idempotencyKey, ifMatch, hamsterId, hamsterUpdateRequest)

更新仓鼠档案

请求体不接受 owner_id、state 或父母快捷字段；父母变更走家谱关系接口。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { UpdateHamsterRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    hamsterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // HamsterUpdateRequest
    hamsterUpdateRequest: ...,
  } satisfies UpdateHamsterRequest;

  try {
    const data = await api.updateHamster(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **hamsterId** | `string` |  | [Defaults to `undefined`] |
| **hamsterUpdateRequest** | [HamsterUpdateRequest](HamsterUpdateRequest.md) |  | |

### Return type

[**HamsterResponse**](HamsterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/merge-patch+json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 仓鼠已更新 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## updateHealthRecord

> HealthRecordResponse updateHealthRecord(idempotencyKey, ifMatch, healthRecordId, healthRecordUpdateRequest)

更新健康记录

通过 If-Match 修正备注、结构化检查、媒体或复查时间。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { UpdateHealthRecordRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    healthRecordId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // HealthRecordUpdateRequest
    healthRecordUpdateRequest: ...,
  } satisfies UpdateHealthRecordRequest;

  try {
    const data = await api.updateHealthRecord(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **healthRecordId** | `string` |  | [Defaults to `undefined`] |
| **healthRecordUpdateRequest** | [HealthRecordUpdateRequest](HealthRecordUpdateRequest.md) |  | |

### Return type

[**HealthRecordResponse**](HealthRecordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/merge-patch+json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 健康记录已更新 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## updateSpeciesRuleVersion

> SpeciesRuleVersionResponse updateSpeciesRuleVersion(idempotencyKey, ifMatch, ruleVersionId, speciesRuleVersionUpdateRequest)

更新尚未冻结的规则版本

已被繁育计划引用的规则版本保持只读，应创建新版本。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { UpdateSpeciesRuleVersionRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    ruleVersionId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // SpeciesRuleVersionUpdateRequest
    speciesRuleVersionUpdateRequest: ...,
  } satisfies UpdateSpeciesRuleVersionRequest;

  try {
    const data = await api.updateSpeciesRuleVersion(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **ruleVersionId** | `string` |  | [Defaults to `undefined`] |
| **speciesRuleVersionUpdateRequest** | [SpeciesRuleVersionUpdateRequest](SpeciesRuleVersionUpdateRequest.md) |  | |

### Return type

[**SpeciesRuleVersionResponse**](SpeciesRuleVersionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/merge-patch+json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 规则版本已更新 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## updateTask

> CareTaskResponse updateTask(idempotencyKey, ifMatch, taskId, careTaskUpdateRequest)

更新任务非状态字段

可修改计划时间、优先级、标题和备注；完成状态走 complete 动作。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { UpdateTaskRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    taskId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // CareTaskUpdateRequest
    careTaskUpdateRequest: ...,
  } satisfies UpdateTaskRequest;

  try {
    const data = await api.updateTask(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **taskId** | `string` |  | [Defaults to `undefined`] |
| **careTaskUpdateRequest** | [CareTaskUpdateRequest](CareTaskUpdateRequest.md) |  | |

### Return type

[**CareTaskResponse**](CareTaskResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/merge-patch+json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 任务已更新 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## upsertWechatSubscriptions

> WechatSubscriptionListResponse upsertWechatSubscriptions(idempotencyKey, upsertWechatSubscriptionsRequest)

保存当前 B 端微信订阅授权

记录 wx.requestSubscribeMessage 返回的模板状态；只有 accept 状态会进入后端投递队列。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { UpsertWechatSubscriptionsOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // UpsertWechatSubscriptionsRequest
    upsertWechatSubscriptionsRequest: ...,
  } satisfies UpsertWechatSubscriptionsOperationRequest;

  try {
    const data = await api.upsertWechatSubscriptions(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **upsertWechatSubscriptionsRequest** | [UpsertWechatSubscriptionsRequest](UpsertWechatSubscriptionsRequest.md) |  | |

### Return type

[**WechatSubscriptionListResponse**](WechatSubscriptionListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 授权状态已保存 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## weanLitter

> WeanLitterResponse weanLitter(idempotencyKey, ifMatch, litterId, weanLitterRequest)

完成断奶

仅允许 weaning_due；对服务端计算的当前在管幼崽逐项提交生存/离舍结果并校验去向。 断奶动作不接受或修改 profile_status，个体化进度仅由 individualize 动作推进。 缺少当前在管身份、包含已关闭身份或笼位冲突时整体不推进状态。

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '@scolvpet/scolvpet-api';
import type { WeanLitterOperationRequest } from '@scolvpet/scolvpet-api';

async function example() {
  console.log("🚀 Testing @scolvpet/scolvpet-api SDK...");
  const config = new Configuration({
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
    idempotencyKey: 018f47a2-281b-79e2-b861-bf785ab6fba7,
    // string | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
    ifMatch: "7",
    // string
    litterId: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // WeanLitterRequest
    weanLitterRequest: {"weaned_at":"2026-08-25T02:00:00Z","timezone":"Asia/Shanghai","items":[{"pup_identity_id":"018f47a2-73b3-762e-8498-07b13dc3b599","outcome_status":"alive","destination_enclosure_id":"018f47a2-81bf-72b2-8990-79310bde2638"},{"pup_identity_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","outcome_status":"alive","destination_enclosure_id":"018f47a2-81bf-72b2-8990-79310bde2638"}]},
  } satisfies WeanLitterOperationRequest;

  try {
    const data = await api.weanLitter(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  | [Defaults to `undefined`] |
| **ifMatch** | `string` | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 | [Defaults to `undefined`] |
| **litterId** | `string` |  | [Defaults to `undefined`] |
| **weanLitterRequest** | [WeanLitterRequest](WeanLitterRequest.md) |  | |

### Return type

[**WeanLitterResponse**](WeanLitterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | 断奶已完成 |  * ETag -  <br>  * Idempotency-Key -  <br>  * Idempotency-Replayed -  <br>  |
| **404** | 资源不存在、已撤销或不属于当前 owner |  -  |
| **409** | 版本、状态、幂等键或资源占用冲突 |  * ETag -  <br>  |
| **422** | 字段格式或领域规则校验失败 |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

