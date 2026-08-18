# DefaultApi

All URIs are relative to *https://api.scolvpet.cn/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**batchCreateHamsters**](DefaultApi.md#batchcreatehamsters) | **POST** /hamsters/batch | 批量创建仓鼠 |
| [**cancelTask**](DefaultApi.md#canceltask) | **POST** /tasks/{task_id}/cancel | 取消任务 |
| [**commitImportJob**](DefaultApi.md#commitimportjob) | **POST** /data-center/import-jobs/{job_id}/commit | 提交正式导入 |
| [**completeMediaUpload**](DefaultApi.md#completemediaupload) | **POST** /media/uploads/{upload_id}/complete | 完成媒体上传 |
| [**completeTask**](DefaultApi.md#completetaskoperation) | **POST** /tasks/{task_id}/complete | 完成任务或逐项完成任务成员 |
| [**createBreederWechatBinding**](DefaultApi.md#createbreederwechatbindingoperation) | **POST** /auth/wechat-bindings | 短信验证并绑定 B 端微信身份 |
| [**createBreederWechatSession**](DefaultApi.md#createbreederwechatsessionoperation) | **POST** /auth/wechat-sessions | B 端微信 wx.login 登录 |
| [**createHamster**](DefaultApi.md#createhamster) | **POST** /hamsters | 创建仓鼠档案 |
| [**createHealthRecord**](DefaultApi.md#createhealthrecord) | **POST** /health-records | 创建健康记录 |
| [**createImportJob**](DefaultApi.md#createimportjob) | **POST** /data-center/import-jobs | 创建 CSV 导入任务 |
| [**createImportUpload**](DefaultApi.md#createimportupload) | **POST** /data-center/import-uploads | 创建 CSV 上传 |
| [**createLitterCountEvent**](DefaultApi.md#createlittercountevent) | **POST** /litters/{litter_id}/count-events | 追加窝仔数量事件 |
| [**createPedigreeParentage**](DefaultApi.md#createpedigreeparentage) | **POST** /pedigree-parentages | 新增父母关系断言 |
| [**createSession**](DefaultApi.md#createsession) | **POST** /auth/sessions | 使用手机验证码登录 |
| [**createTask**](DefaultApi.md#createtask) | **POST** /tasks | 创建手工任务 |
| [**createWeightRecord**](DefaultApi.md#createweightrecord) | **POST** /weight-records | 创建体重记录 |
| [**endPedigreeParentage**](DefaultApi.md#endpedigreeparentage) | **POST** /pedigree-parentages/end | 解除当前有效父母关系 |
| [**getDataCenterSummary**](DefaultApi.md#getdatacentersummary) | **GET** /data-center/summary | 获取数据中心摘要 |
| [**getHamster**](DefaultApi.md#gethamster) | **GET** /hamsters/{hamster_id} | 获取仓鼠详情 |
| [**getHamsterPedigree**](DefaultApi.md#gethamsterpedigree) | **GET** /hamsters/{hamster_id}/pedigree | 获取仓鼠家谱图 |
| [**getHealthRecord**](DefaultApi.md#gethealthrecord) | **GET** /health-records/{health_record_id} | 获取健康记录 |
| [**getImportErrorReport**](DefaultApi.md#getimporterrorreport) | **GET** /data-center/import-jobs/{job_id}/error-report | 下载 CSV 逐行错误报告 |
| [**getImportJob**](DefaultApi.md#getimportjob) | **GET** /data-center/import-jobs/{job_id} | 获取导入任务 |
| [**getLitter**](DefaultApi.md#getlitter) | **GET** /litters/{litter_id} | 获取窝次详情 |
| [**getLitterIndividualizationEligibility**](DefaultApi.md#getlitterindividualizationeligibility) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set |
| [**getLitterIndividualizationEligibility_0**](DefaultApi.md#getlitterindividualizationeligibility_0) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set |
| [**getLitterIndividualizationEligibility_1**](DefaultApi.md#getlitterindividualizationeligibility_1) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set |
| [**getMediaAsset**](DefaultApi.md#getmediaasset) | **GET** /media/{media_id} | 获取媒体资产 |
| [**individualizeLitter**](DefaultApi.md#individualizelitteroperation) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化 |
| [**individualizeLitter_0**](DefaultApi.md#individualizelitter_0) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化 |
| [**individualizeLitter_1**](DefaultApi.md#individualizelitter_1) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化 |
| [**listEnclosures**](DefaultApi.md#listenclosures) | **GET** /enclosures | 列出笼盒 |
| [**listHamsters**](DefaultApi.md#listhamsters) | **GET** /hamsters | 列出仓鼠 |
| [**listHealthRecords**](DefaultApi.md#listhealthrecords) | **GET** /health-records | 列出健康记录 |
| [**listImportRowResults**](DefaultApi.md#listimportrowresults) | **GET** /data-center/import-jobs/{job_id}/rows | 获取逐行导入结果 |
| [**listLitterMembers**](DefaultApi.md#listlittermembers) | **GET** /litters/{litter_id}/members | 列出窝次成员 |
| [**listLitterMembers_0**](DefaultApi.md#listlittermembers_0) | **GET** /litters/{litter_id}/members | 列出窝次成员 |
| [**listLitters**](DefaultApi.md#listlitters) | **GET** /litters | 列出窝次 |
| [**listPedigreeParentages**](DefaultApi.md#listpedigreeparentages) | **GET** /pedigree-parentages | 列出家谱父母边 |
| [**listReminders**](DefaultApi.md#listreminders) | **GET** /reminders | 列出提醒 |
| [**listSpeciesRuleVersions**](DefaultApi.md#listspeciesruleversions) | **GET** /species-rule-versions | 列出当前熊舍规则版本 |
| [**listTasks**](DefaultApi.md#listtasks) | **GET** /tasks | 列出任务 |
| [**listWechatSubscriptions**](DefaultApi.md#listwechatsubscriptions) | **GET** /wechat/subscriptions | 查看当前 B 端微信订阅授权 |
| [**listWeightRecords**](DefaultApi.md#listweightrecords) | **GET** /weight-records | 列出体重记录 |
| [**preflightImportJob**](DefaultApi.md#preflightimportjob) | **POST** /data-center/import-jobs/{job_id}/preflight | 全量预检 CSV |
| [**presignMediaUpload**](DefaultApi.md#presignmediaupload) | **POST** /media/uploads/presign | 创建媒体预签名上传 |
| [**refreshSession**](DefaultApi.md#refreshsessionoperation) | **POST** /auth/sessions/refresh | 刷新当前会话 |
| [**reopenTask**](DefaultApi.md#reopentask) | **POST** /tasks/{task_id}/reopen | 撤销任务的完成或取消 |
| [**retryImportJob**](DefaultApi.md#retryimportjob) | **POST** /data-center/import-jobs/{job_id}/retry | 重试失败导入行 |
| [**sendVerificationCode**](DefaultApi.md#sendverificationcodeoperation) | **POST** /auth/verification-codes | 发送手机验证码 |
| [**setImportMapping**](DefaultApi.md#setimportmapping) | **PUT** /data-center/import-jobs/{job_id}/mapping | 设置 CSV 字段映射 |
| [**sexAndSeparateLitter**](DefaultApi.md#sexandseparatelitter) | **POST** /litters/{litter_id}/sex-and-separate | 分性并分笼 |
| [**updateHamster**](DefaultApi.md#updatehamster) | **PATCH** /hamsters/{hamster_id} | 更新仓鼠档案 |
| [**updateHealthRecord**](DefaultApi.md#updatehealthrecord) | **PATCH** /health-records/{health_record_id} | 更新健康记录 |
| [**upsertWechatSubscriptions**](DefaultApi.md#upsertwechatsubscriptionsoperation) | **PUT** /wechat/subscriptions | 保存当前 B 端微信订阅授权 |
| [**weanLitter**](DefaultApi.md#weanlitteroperation) | **POST** /litters/{litter_id}/wean | 完成断奶 |



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
| **200** | openid 未绑定，需短信验证绑定 |  -  |
| **201** | openid 已绑定，返回 B 端 Bearer 会话 |  -  |
| **401** | 访问令牌缺失、无效或过期 |  -  |
| **422** | 字段格式或领域规则校验失败 |  -  |
| **429** | 请求频率过高 |  * Retry-After - 建议重试等待秒数 <br>  |
| **503** | 微信登录暂不可用，降级短信登录 |  -  |

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

