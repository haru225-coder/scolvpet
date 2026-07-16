# scolvpet_api.api.DefaultApi

## Load the API package
```dart
import 'package:scolvpet_api/api.dart';
```

All URIs are relative to *https://api.scolvpet.cn/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adjustBreedingBaseline**](DefaultApi.md#adjustbreedingbaseline) | **POST** /breeding-plans/{plan_id}/adjust-baseline | 修正配对基准时间
[**batchCreateHamsters**](DefaultApi.md#batchcreatehamsters) | **POST** /hamsters/batch | 批量创建仓鼠
[**batchCreateWeightRecords**](DefaultApi.md#batchcreateweightrecords) | **POST** /weight-records/batch | 批量创建体重记录
[**commitImportJob**](DefaultApi.md#commitimportjob) | **POST** /data-center/import-jobs/{job_id}/commit | 提交正式导入
[**completeBreedingPlan**](DefaultApi.md#completebreedingplan) | **POST** /breeding-plans/{plan_id}/complete | 完成繁育计划
[**completeMediaUpload**](DefaultApi.md#completemediaupload) | **POST** /media/uploads/{upload_id}/complete | 完成媒体上传
[**completeTask**](DefaultApi.md#completetask) | **POST** /tasks/{task_id}/complete | 完成任务或逐项完成任务成员
[**confirmBirth**](DefaultApi.md#confirmbirth) | **POST** /breeding-plans/{plan_id}/confirm-birth | 确认产仔并建立窝次
[**confirmBirth_0**](DefaultApi.md#confirmbirth_0) | **POST** /breeding-plans/{plan_id}/confirm-birth | 确认产仔并建立窝次
[**createBackupJob**](DefaultApi.md#createbackupjob) | **POST** /data-center/backup-jobs | 创建基础备份
[**createBreedingPlan**](DefaultApi.md#createbreedingplan) | **POST** /breeding-plans | 创建繁育计划草稿
[**createEnclosure**](DefaultApi.md#createenclosure) | **POST** /enclosures | 创建笼盒
[**createEnclosureCleaning**](DefaultApi.md#createenclosurecleaning) | **POST** /enclosures/{enclosure_id}/cleanings | 记录笼盒清洁或消毒
[**createEnclosureStay**](DefaultApi.md#createenclosurestay) | **POST** /enclosures/{enclosure_id}/stays | 创建入住或移笼事实
[**createExportJob**](DefaultApi.md#createexportjob) | **POST** /data-center/export-jobs | 创建数据导出
[**createHamster**](DefaultApi.md#createhamster) | **POST** /hamsters | 创建仓鼠档案
[**createHealthRecord**](DefaultApi.md#createhealthrecord) | **POST** /health-records | 创建健康记录
[**createImportJob**](DefaultApi.md#createimportjob) | **POST** /data-center/import-jobs | 创建 CSV 导入任务
[**createImportUpload**](DefaultApi.md#createimportupload) | **POST** /data-center/import-uploads | 创建 CSV 上传
[**createLitterCountEvent**](DefaultApi.md#createlittercountevent) | **POST** /litters/{litter_id}/count-events | 追加窝仔数量事件
[**createLitterParent**](DefaultApi.md#createlitterparent) | **POST** /litters/{litter_id}/parents | 新增或纠正窝次父母关系
[**createMediaEditRecipe**](DefaultApi.md#createmediaeditrecipe) | **POST** /media/{media_id}/edit-recipes | 创建图片编辑配方
[**createPedigreeParentage**](DefaultApi.md#createpedigreeparentage) | **POST** /pedigree-parentages | 新增父母关系断言
[**createSession**](DefaultApi.md#createsession) | **POST** /auth/sessions | 使用手机验证码登录
[**createShare**](DefaultApi.md#createshare) | **POST** /shares | 创建公开分享
[**createSpeciesRuleVersion**](DefaultApi.md#createspeciesruleversion) | **POST** /species-rule-versions | 创建规则版本
[**createTask**](DefaultApi.md#createtask) | **POST** /tasks | 创建手工任务
[**createWeightRecord**](DefaultApi.md#createweightrecord) | **POST** /weight-records | 创建体重记录
[**deleteCurrentSession**](DefaultApi.md#deletecurrentsession) | **DELETE** /auth/sessions/current | 退出当前会话
[**getAsyncJob**](DefaultApi.md#getasyncjob) | **GET** /jobs/{job_id} | 获取通用异步作业
[**getBackupDownload**](DefaultApi.md#getbackupdownload) | **GET** /data-center/backup-jobs/{job_id}/download | 获取备份下载链接
[**getBackupJob**](DefaultApi.md#getbackupjob) | **GET** /data-center/backup-jobs/{job_id} | 获取备份任务
[**getBreedingPlan**](DefaultApi.md#getbreedingplan) | **GET** /breeding-plans/{plan_id} | 获取繁育计划
[**getCurrentAccount**](DefaultApi.md#getcurrentaccount) | **GET** /me | 获取当前账号
[**getCurrentOrganization**](DefaultApi.md#getcurrentorganization) | **GET** /organizations/current | 获取当前熊舍
[**getCurrentUsage**](DefaultApi.md#getcurrentusage) | **GET** /usage/current | 获取当前用量
[**getDataCenterSummary**](DefaultApi.md#getdatacentersummary) | **GET** /data-center/summary | 获取数据中心摘要
[**getEnclosure**](DefaultApi.md#getenclosure) | **GET** /enclosures/{enclosure_id} | 获取笼盒详情
[**getEnclosureCleaning**](DefaultApi.md#getenclosurecleaning) | **GET** /enclosure-cleanings/{cleaning_id} | 获取清洁记录
[**getExportDownload**](DefaultApi.md#getexportdownload) | **GET** /data-center/export-jobs/{job_id}/download | 获取导出下载链接
[**getExportJob**](DefaultApi.md#getexportjob) | **GET** /data-center/export-jobs/{job_id} | 获取导出任务
[**getHamster**](DefaultApi.md#gethamster) | **GET** /hamsters/{hamster_id} | 获取仓鼠详情
[**getHamsterPedigree**](DefaultApi.md#gethamsterpedigree) | **GET** /hamsters/{hamster_id}/pedigree | 获取仓鼠家谱图
[**getHealthRecord**](DefaultApi.md#gethealthrecord) | **GET** /health-records/{health_record_id} | 获取健康记录
[**getImportErrorReport**](DefaultApi.md#getimporterrorreport) | **GET** /data-center/import-jobs/{job_id}/error-report | 下载 CSV 逐行错误报告
[**getImportJob**](DefaultApi.md#getimportjob) | **GET** /data-center/import-jobs/{job_id} | 获取导入任务
[**getImportTemplate**](DefaultApi.md#getimporttemplate) | **GET** /data-center/import-templates/{template_type} | 获取 CSV 导入模板
[**getLitter**](DefaultApi.md#getlitter) | **GET** /litters/{litter_id} | 获取窝次详情
[**getLitterIndividualizationEligibility**](DefaultApi.md#getlitterindividualizationeligibility) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set
[**getLitterIndividualizationEligibility_0**](DefaultApi.md#getlitterindividualizationeligibility_0) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set
[**getLitterIndividualizationEligibility_1**](DefaultApi.md#getlitterindividualizationeligibility_1) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set
[**getMediaAsset**](DefaultApi.md#getmediaasset) | **GET** /media/{media_id} | 获取媒体资产
[**getMediaTranscodeStatus**](DefaultApi.md#getmediatranscodestatus) | **GET** /media/{media_id}/transcode-status | 获取转码状态
[**getPairingAttempt**](DefaultApi.md#getpairingattempt) | **GET** /pairing-attempts/{attempt_id} | 获取配对尝试
[**getPublicShare**](DefaultApi.md#getpublicshare) | **GET** /public/shares/{token} | 无需认证读取公开分享
[**getPublicShareMedia**](DefaultApi.md#getpublicsharemedia) | **GET** /public/shares/{token}/media/{media_id} | 读取公开分享媒体
[**getReminder**](DefaultApi.md#getreminder) | **GET** /reminders/{reminder_id} | 获取提醒
[**getSpeciesRuleVersion**](DefaultApi.md#getspeciesruleversion) | **GET** /species-rule-versions/{rule_version_id} | 获取规则版本
[**getTask**](DefaultApi.md#gettask) | **GET** /tasks/{task_id} | 获取任务
[**individualizeLitter**](DefaultApi.md#individualizelitter) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化
[**individualizeLitter_0**](DefaultApi.md#individualizelitter_0) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化
[**individualizeLitter_1**](DefaultApi.md#individualizelitter_1) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化
[**listBackupJobs**](DefaultApi.md#listbackupjobs) | **GET** /data-center/backup-jobs | 列出备份任务
[**listBreedingPlans**](DefaultApi.md#listbreedingplans) | **GET** /breeding-plans | 列出繁育计划
[**listEnclosureCleanings**](DefaultApi.md#listenclosurecleanings) | **GET** /enclosures/{enclosure_id}/cleanings | 列出笼盒清洁历史
[**listEnclosureStays**](DefaultApi.md#listenclosurestays) | **GET** /enclosures/{enclosure_id}/stays | 列出笼盒入住历史
[**listEnclosures**](DefaultApi.md#listenclosures) | **GET** /enclosures | 列出笼盒
[**listExportJobs**](DefaultApi.md#listexportjobs) | **GET** /data-center/export-jobs | 列出导出任务
[**listHamsters**](DefaultApi.md#listhamsters) | **GET** /hamsters | 列出仓鼠
[**listHealthRecords**](DefaultApi.md#listhealthrecords) | **GET** /health-records | 列出健康记录
[**listImportJobs**](DefaultApi.md#listimportjobs) | **GET** /data-center/import-jobs | 列出导入任务
[**listImportRowResults**](DefaultApi.md#listimportrowresults) | **GET** /data-center/import-jobs/{job_id}/rows | 获取逐行导入结果
[**listLitterMembers**](DefaultApi.md#listlittermembers) | **GET** /litters/{litter_id}/members | 列出窝次成员
[**listLitterMembers_0**](DefaultApi.md#listlittermembers_0) | **GET** /litters/{litter_id}/members | 列出窝次成员
[**listLitterParents**](DefaultApi.md#listlitterparents) | **GET** /litters/{litter_id}/parents | 获取窝次父母关系
[**listLitters**](DefaultApi.md#listlitters) | **GET** /litters | 列出窝次
[**listPairingAttempts**](DefaultApi.md#listpairingattempts) | **GET** /breeding-plans/{plan_id}/pairing-attempts | 列出计划的配对尝试
[**listPedigreeParentages**](DefaultApi.md#listpedigreeparentages) | **GET** /pedigree-parentages | 列出家谱父母边
[**listPupIdentities**](DefaultApi.md#listpupidentities) | **GET** /litters/{litter_id}/pup-identities | 列出临时幼崽
[**listReminders**](DefaultApi.md#listreminders) | **GET** /reminders | 列出提醒
[**listShares**](DefaultApi.md#listshares) | **GET** /shares | 列出公开分享
[**listSpeciesRuleTemplates**](DefaultApi.md#listspeciesruletemplates) | **GET** /species-rule-templates | 列出系统物种规则模板
[**listSpeciesRuleVersions**](DefaultApi.md#listspeciesruleversions) | **GET** /species-rule-versions | 列出当前熊舍规则版本
[**listTasks**](DefaultApi.md#listtasks) | **GET** /tasks | 列出任务
[**listUsageSnapshots**](DefaultApi.md#listusagesnapshots) | **GET** /usage/snapshots | 列出用量快照
[**listWeightRecords**](DefaultApi.md#listweightrecords) | **GET** /weight-records | 列出体重记录
[**preflightImportJob**](DefaultApi.md#preflightimportjob) | **POST** /data-center/import-jobs/{job_id}/preflight | 全量预检 CSV
[**presignMediaUpload**](DefaultApi.md#presignmediaupload) | **POST** /media/uploads/presign | 创建媒体预签名上传
[**previewShare**](DefaultApi.md#previewshare) | **GET** /shares/{share_id}/preview | 预览公开分享
[**previewShareDraft**](DefaultApi.md#previewsharedraft) | **POST** /shares/preview | 创建前预览公开分享
[**publishBreedingPlan**](DefaultApi.md#publishbreedingplan) | **POST** /breeding-plans/{plan_id}/publish | 发布繁育计划
[**recordPairingObservation**](DefaultApi.md#recordpairingobservation) | **POST** /pairing-attempts/{attempt_id}/record-observation | 记录配对观察
[**refreshSession**](DefaultApi.md#refreshsession) | **POST** /auth/sessions/refresh | 刷新当前会话
[**retryBackupJob**](DefaultApi.md#retrybackupjob) | **POST** /data-center/backup-jobs/{job_id}/retry | 重试失败备份
[**retryExportJob**](DefaultApi.md#retryexportjob) | **POST** /data-center/export-jobs/{job_id}/retry | 重试失败导出
[**retryImportJob**](DefaultApi.md#retryimportjob) | **POST** /data-center/import-jobs/{job_id}/retry | 重试失败导入行
[**retryMediaProcessing**](DefaultApi.md#retrymediaprocessing) | **POST** /media/{media_id}/retry-processing | 重试失败的媒体处理
[**revokeShare**](DefaultApi.md#revokeshare) | **POST** /shares/{share_id}/revoke | 撤销公开分享
[**sendVerificationCode**](DefaultApi.md#sendverificationcode) | **POST** /auth/verification-codes | 发送手机验证码
[**separatePairing**](DefaultApi.md#separatepairing) | **POST** /pairing-attempts/{attempt_id}/separate | 结束配对并完成分笼
[**setImportMapping**](DefaultApi.md#setimportmapping) | **PUT** /data-center/import-jobs/{job_id}/mapping | 设置 CSV 字段映射
[**setMediaCover**](DefaultApi.md#setmediacover) | **PUT** /media/{media_id}/cover | 设置媒体封面
[**sexAndSeparateLitter**](DefaultApi.md#sexandseparatelitter) | **POST** /litters/{litter_id}/sex-and-separate | 分性并分笼
[**startGestationMonitoring**](DefaultApi.md#startgestationmonitoring) | **POST** /breeding-plans/{plan_id}/start-gestation | 从分笼后进入孕期观察
[**startPairing**](DefaultApi.md#startpairing) | **POST** /breeding-plans/{plan_id}/start-pairing | 开始配对
[**updateBreedingPlan**](DefaultApi.md#updatebreedingplan) | **PATCH** /breeding-plans/{plan_id} | 更新繁育计划资料
[**updateCurrentOrganization**](DefaultApi.md#updatecurrentorganization) | **PATCH** /organizations/current | 更新当前熊舍
[**updateEnclosure**](DefaultApi.md#updateenclosure) | **PATCH** /enclosures/{enclosure_id} | 更新笼盒资料
[**updateEnclosureStay**](DefaultApi.md#updateenclosurestay) | **PATCH** /enclosure-stays/{stay_id} | 结束或修正入住事实
[**updateHamster**](DefaultApi.md#updatehamster) | **PATCH** /hamsters/{hamster_id} | 更新仓鼠档案
[**updateHealthRecord**](DefaultApi.md#updatehealthrecord) | **PATCH** /health-records/{health_record_id} | 更新健康记录
[**updateSpeciesRuleVersion**](DefaultApi.md#updatespeciesruleversion) | **PATCH** /species-rule-versions/{rule_version_id} | 更新尚未冻结的规则版本
[**updateTask**](DefaultApi.md#updatetask) | **PATCH** /tasks/{task_id} | 更新任务非状态字段
[**weanLitter**](DefaultApi.md#weanlitter) | **POST** /litters/{litter_id}/wean | 完成断奶


# **adjustBreedingBaseline**
> AdjustBaselineResponse adjustBreedingBaseline(idempotencyKey, ifMatch, planId, adjustBaselineRequest)

修正配对基准时间

仅允许 gestation 或可恢复的 hold 状态。追加日期纠正事件，重算预产区间， 并将旧提醒标记为 superseded；客户端不得提交重算后的日期或提醒集合。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final AdjustBaselineRequest adjustBaselineRequest = {"new_baseline_at":"2026-07-18T12:12:00Z","reason":"以明确交配观察作为新基准","timezone":"Asia/Shanghai"}; // AdjustBaselineRequest |

try {
    final response = api.adjustBreedingBaseline(idempotencyKey, ifMatch, planId, adjustBaselineRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->adjustBreedingBaseline: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **planId** | **String**|  |
 **adjustBaselineRequest** | [**AdjustBaselineRequest**](AdjustBaselineRequest.md)|  |

### Return type

[**AdjustBaselineResponse**](AdjustBaselineResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **batchCreateHamsters**
> HamsterBatchCreateResponse batchCreateHamsters(idempotencyKey, hamsterBatchCreateRequest)

批量创建仓鼠

返回整体事务状态与逐项结果；每项使用 client_item_id 对齐客户端记录。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final HamsterBatchCreateRequest hamsterBatchCreateRequest = ; // HamsterBatchCreateRequest |

try {
    final response = api.batchCreateHamsters(idempotencyKey, hamsterBatchCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->batchCreateHamsters: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **hamsterBatchCreateRequest** | [**HamsterBatchCreateRequest**](HamsterBatchCreateRequest.md)|  |

### Return type

[**HamsterBatchCreateResponse**](HamsterBatchCreateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **batchCreateWeightRecords**
> WeightRecordBatchCreateResponse batchCreateWeightRecords(idempotencyKey, weightRecordBatchCreateRequest)

批量创建体重记录

返回逐项成功、失败与告警结果，适用于整窝逐只称重。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final WeightRecordBatchCreateRequest weightRecordBatchCreateRequest = ; // WeightRecordBatchCreateRequest |

try {
    final response = api.batchCreateWeightRecords(idempotencyKey, weightRecordBatchCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->batchCreateWeightRecords: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **weightRecordBatchCreateRequest** | [**WeightRecordBatchCreateRequest**](WeightRecordBatchCreateRequest.md)|  |

### Return type

[**WeightRecordBatchCreateResponse**](WeightRecordBatchCreateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **commitImportJob**
> ImportJobResponse commitImportJob(idempotencyKey, ifMatch, jobId, importCommitRequest)

提交正式导入

使用幂等批次号正式写入；提交前重新校验 preflight_version、全部阻塞问题和逐项 更新确认。历史窝次先按预检计划原子创建，再建立成员与父母关系；部分失败时保留 逐行结果，但不允许产生缺父母、错窝次或悬空谱系引用。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final ImportCommitRequest importCommitRequest = ; // ImportCommitRequest |

try {
    final response = api.commitImportJob(idempotencyKey, ifMatch, jobId, importCommitRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->commitImportJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **jobId** | **String**|  |
 **importCommitRequest** | [**ImportCommitRequest**](ImportCommitRequest.md)|  |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **completeBreedingPlan**
> CompleteBreedingPlanResponse completeBreedingPlan(idempotencyKey, ifMatch, planId, completeBreedingPlanRequest)

完成繁育计划

仅允许 individualizing。 服务端确认数量、性别、笼位、家谱和阻塞任务全部闭合后推进到 completed， 客户端不得提交目标状态或自行计算的对账数。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final CompleteBreedingPlanRequest completeBreedingPlanRequest = {"completed_at":"2026-09-05T03:00:00Z","timezone":"Asia/Shanghai","notes":"数量、分笼和谱系均已复核"}; // CompleteBreedingPlanRequest |

try {
    final response = api.completeBreedingPlan(idempotencyKey, ifMatch, planId, completeBreedingPlanRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->completeBreedingPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **planId** | **String**|  |
 **completeBreedingPlanRequest** | [**CompleteBreedingPlanRequest**](CompleteBreedingPlanRequest.md)|  |

### Return type

[**CompleteBreedingPlanResponse**](CompleteBreedingPlanResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **completeMediaUpload**
> MediaUploadCompleteResponse completeMediaUpload(idempotencyKey, ifMatch, uploadId, mediaUploadCompleteRequest)

完成媒体上传

校验对象元数据后创建 media_asset；视频转码异步执行。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String uploadId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final MediaUploadCompleteRequest mediaUploadCompleteRequest = ; // MediaUploadCompleteRequest |

try {
    final response = api.completeMediaUpload(idempotencyKey, ifMatch, uploadId, mediaUploadCompleteRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->completeMediaUpload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **uploadId** | **String**|  |
 **mediaUploadCompleteRequest** | [**MediaUploadCompleteRequest**](MediaUploadCompleteRequest.md)|  |

### Return type

[**MediaUploadCompleteResponse**](MediaUploadCompleteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **completeTask**
> CompleteTaskResponse completeTask(idempotencyKey, ifMatch, taskId, completeTaskRequest)

完成任务或逐项完成任务成员

支持整窝任务逐只完成；全部 subject 完成或登记例外后任务自动关闭。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String taskId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final CompleteTaskRequest completeTaskRequest = {"completed_at":"2026-08-10T02:00:00Z","subject_results":[{"subject_id":"018f47a2-73b3-762e-8498-07b13dc3b599","status":"completed","completion_record_id":"018f47a2-951e-7123-a5b3-1ade38a2b49e"},{"subject_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","status":"excepted","exception_reason":"当日医疗观察，延后称重"}],"notes":"本次完成 2 项"}; // CompleteTaskRequest |

try {
    final response = api.completeTask(idempotencyKey, ifMatch, taskId, completeTaskRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->completeTask: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **taskId** | **String**|  |
 **completeTaskRequest** | [**CompleteTaskRequest**](CompleteTaskRequest.md)|  |

### Return type

[**CompleteTaskResponse**](CompleteTaskResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmBirth**
> ConfirmBirthResponse confirmBirth(idempotencyKey, ifMatch, planId, confirmBirthRequest)

确认产仔并建立窝次

仅允许 gestation 状态；同一计划只允许一个未撤销的生产事实。 N>0 时幂等创建唯一有效 litter、初始数量流水及 N 条 pup_identity，并直接进入 litter_nursing。N=0 时只记录无活仔生产结果并进入 no_litter_outcome，不创建 litter、litter_count_event、pup_identity 或窝仔阶段任务。 报喜卡或媒体任务失败不回滚产仔事实。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final ConfirmBirthRequest confirmBirthRequest = {"born_at":"2026-08-04T02:30:00Z","enclosure_id":"018f47a2-6450-7f54-8851-050a3d63846f","initial_alive_count":4,"initial_other_count":1,"dam_condition":{"status":"stable","notes":"精神与进食正常"},"temporary_code_prefix":"L240804","timezone":"Asia/Shanghai","outcome_reason":"live_pups_observed","notes":"发现 4 只活仔，另有 1 只死产"}; // ConfirmBirthRequest |

try {
    final response = api.confirmBirth(idempotencyKey, ifMatch, planId, confirmBirthRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->confirmBirth: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **planId** | **String**|  |
 **confirmBirthRequest** | [**ConfirmBirthRequest**](ConfirmBirthRequest.md)|  |

### Return type

[**ConfirmBirthResponse**](ConfirmBirthResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmBirth_0**
> ConfirmBirthResponse confirmBirth_0(idempotencyKey, ifMatch, planId, confirmBirthRequest)

确认产仔并建立窝次

仅允许 gestation 状态；同一计划只允许一个未撤销的生产事实。 N>0 时幂等创建唯一有效 litter、初始数量流水及 N 条 pup_identity，并直接进入 litter_nursing。N=0 时只记录无活仔生产结果并进入 no_litter_outcome，不创建 litter、litter_count_event、pup_identity 或窝仔阶段任务。 报喜卡或媒体任务失败不回滚产仔事实。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final ConfirmBirthRequest confirmBirthRequest = {"born_at":"2026-08-04T02:30:00Z","enclosure_id":"018f47a2-6450-7f54-8851-050a3d63846f","initial_alive_count":4,"initial_other_count":1,"dam_condition":{"status":"stable","notes":"精神与进食正常"},"temporary_code_prefix":"L240804","timezone":"Asia/Shanghai","outcome_reason":"live_pups_observed","notes":"发现 4 只活仔，另有 1 只死产"}; // ConfirmBirthRequest |

try {
    final response = api.confirmBirth_0(idempotencyKey, ifMatch, planId, confirmBirthRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->confirmBirth_0: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **planId** | **String**|  |
 **confirmBirthRequest** | [**ConfirmBirthRequest**](ConfirmBirthRequest.md)|  |

### Return type

[**ConfirmBirthResponse**](ConfirmBirthResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createBackupJob**
> BackupJobResponse createBackupJob(idempotencyKey, backupJobCreateRequest)

创建基础备份

包含结构化数据、媒体清单和校验哈希。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final BackupJobCreateRequest backupJobCreateRequest = ; // BackupJobCreateRequest |

try {
    final response = api.createBackupJob(idempotencyKey, backupJobCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createBackupJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **backupJobCreateRequest** | [**BackupJobCreateRequest**](BackupJobCreateRequest.md)|  |

### Return type

[**BackupJobResponse**](BackupJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createBreedingPlan**
> BreedingPlanResponse createBreedingPlan(idempotencyKey, breedingPlanCreateRequest)

创建繁育计划草稿

新建计划固定为 draft；请求体不接受 state 或 owner_id。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final BreedingPlanCreateRequest breedingPlanCreateRequest = ; // BreedingPlanCreateRequest |

try {
    final response = api.createBreedingPlan(idempotencyKey, breedingPlanCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createBreedingPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **breedingPlanCreateRequest** | [**BreedingPlanCreateRequest**](BreedingPlanCreateRequest.md)|  |

### Return type

[**BreedingPlanResponse**](BreedingPlanResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createEnclosure**
> EnclosureResponse createEnclosure(idempotencyKey, enclosureCreateRequest)

创建笼盒

创建当前熊舍内唯一编号的笼盒。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final EnclosureCreateRequest enclosureCreateRequest = ; // EnclosureCreateRequest |

try {
    final response = api.createEnclosure(idempotencyKey, enclosureCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createEnclosure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **enclosureCreateRequest** | [**EnclosureCreateRequest**](EnclosureCreateRequest.md)|  |

### Return type

[**EnclosureResponse**](EnclosureResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createEnclosureCleaning**
> EnclosureCleaningResponse createEnclosureCleaning(idempotencyKey, ifMatch, enclosureId, enclosureCleaningCreateRequest)

记录笼盒清洁或消毒

追加清洁事实并更新笼盒清洁投影；纠错通过新记录引用原记录完成。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String enclosureId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final EnclosureCleaningCreateRequest enclosureCleaningCreateRequest = ; // EnclosureCleaningCreateRequest |

try {
    final response = api.createEnclosureCleaning(idempotencyKey, ifMatch, enclosureId, enclosureCleaningCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createEnclosureCleaning: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **enclosureId** | **String**|  |
 **enclosureCleaningCreateRequest** | [**EnclosureCleaningCreateRequest**](EnclosureCleaningCreateRequest.md)|  |

### Return type

[**EnclosureCleaningResponse**](EnclosureCleaningResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createEnclosureStay**
> EnclosureStayResponse createEnclosureStay(idempotencyKey, ifMatch, enclosureId, enclosureStayCreateRequest)

创建入住或移笼事实

校验目标笼盒容量、时段冲突和配对授权。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String enclosureId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final EnclosureStayCreateRequest enclosureStayCreateRequest = ; // EnclosureStayCreateRequest |

try {
    final response = api.createEnclosureStay(idempotencyKey, ifMatch, enclosureId, enclosureStayCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createEnclosureStay: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **enclosureId** | **String**|  |
 **enclosureStayCreateRequest** | [**EnclosureStayCreateRequest**](EnclosureStayCreateRequest.md)|  |

### Return type

[**EnclosureStayResponse**](EnclosureStayResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createExportJob**
> ExportJobResponse createExportJob(idempotencyKey, exportJobCreateRequest)

创建数据导出

支持仓鼠、笼舍、繁育、窝次、体重、健康和谱系的 CSV 或 JSON 导出。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final ExportJobCreateRequest exportJobCreateRequest = ; // ExportJobCreateRequest |

try {
    final response = api.createExportJob(idempotencyKey, exportJobCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createExportJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **exportJobCreateRequest** | [**ExportJobCreateRequest**](ExportJobCreateRequest.md)|  |

### Return type

[**ExportJobResponse**](ExportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createHamster**
> HamsterResponse createHamster(idempotencyKey, hamsterCreateRequest)

创建仓鼠档案

owner_id 从认证上下文解析；父母关系写入 pedigree_parentage。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final HamsterCreateRequest hamsterCreateRequest = {"internal_code":"SY-2026-001","name":"小云","species_rule_version_id":"018f47a2-3e3b-7e40-9665-12cd57082cf0","variety_code":"syrian","sex":"female","birth_date":"2026-05-20","source_type":"introduced","notes":"引入种母"}; // HamsterCreateRequest |

try {
    final response = api.createHamster(idempotencyKey, hamsterCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createHamster: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **hamsterCreateRequest** | [**HamsterCreateRequest**](HamsterCreateRequest.md)|  |

### Return type

[**HamsterResponse**](HamsterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createHealthRecord**
> HealthRecordResponse createHealthRecord(idempotencyKey, healthRecordCreateRequest)

创建健康记录

仓鼠或窝次至少关联一项；通知副作用不影响记录落库。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final HealthRecordCreateRequest healthRecordCreateRequest = ; // HealthRecordCreateRequest |

try {
    final response = api.createHealthRecord(idempotencyKey, healthRecordCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createHealthRecord: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **healthRecordCreateRequest** | [**HealthRecordCreateRequest**](HealthRecordCreateRequest.md)|  |

### Return type

[**HealthRecordResponse**](HealthRecordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createImportJob**
> ImportJobResponse createImportJob(idempotencyKey, importJobCreateRequest)

创建 CSV 导入任务

识别编码、表头和列；后续通过映射、预检和提交推进。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final ImportJobCreateRequest importJobCreateRequest = ; // ImportJobCreateRequest |

try {
    final response = api.createImportJob(idempotencyKey, importJobCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createImportJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **importJobCreateRequest** | [**ImportJobCreateRequest**](ImportJobCreateRequest.md)|  |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createImportUpload**
> ImportUploadResponse createImportUpload(idempotencyKey, importUploadCreateRequest)

创建 CSV 上传

返回预签名地址，上传完成后用 upload_id 创建导入任务。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final ImportUploadCreateRequest importUploadCreateRequest = ; // ImportUploadCreateRequest |

try {
    final response = api.createImportUpload(idempotencyKey, importUploadCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createImportUpload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **importUploadCreateRequest** | [**ImportUploadCreateRequest**](ImportUploadCreateRequest.md)|  |

### Return type

[**ImportUploadResponse**](ImportUploadResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createLitterCountEvent**
> AdjustLitterCountResponse createLitterCountEvent(idempotencyKey, ifMatch, litterId, adjustLitterCountRequest)

追加窝仔数量事件

追加数量流水；根据后补发现或关闭原因同步临时幼崽身份。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final AdjustLitterCountRequest adjustLitterCountRequest = {"event_type":"discovered","delta":1,"occurred_at":"2026-08-05T01:00:00Z","reason":"清点时后补发现一只","new_temporary_codes":["L240804-05"]}; // AdjustLitterCountRequest |

try {
    final response = api.createLitterCountEvent(idempotencyKey, ifMatch, litterId, adjustLitterCountRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createLitterCountEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **litterId** | **String**|  |
 **adjustLitterCountRequest** | [**AdjustLitterCountRequest**](AdjustLitterCountRequest.md)|  |

### Return type

[**AdjustLitterCountResponse**](AdjustLitterCountResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createLitterParent**
> LitterParentResponse createLitterParent(idempotencyKey, ifMatch, litterId, litterParentCreateRequest)

新增或纠正窝次父母关系

校验角色和祖先环，并保留关系断言来源。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final LitterParentCreateRequest litterParentCreateRequest = ; // LitterParentCreateRequest |

try {
    final response = api.createLitterParent(idempotencyKey, ifMatch, litterId, litterParentCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createLitterParent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **litterId** | **String**|  |
 **litterParentCreateRequest** | [**LitterParentCreateRequest**](LitterParentCreateRequest.md)|  |

### Return type

[**LitterParentResponse**](LitterParentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createMediaEditRecipe**
> MediaEditRecipeResponse createMediaEditRecipe(idempotencyKey, ifMatch, mediaId, mediaEditRecipeRequest)

创建图片编辑配方

保存裁剪、旋转、滤镜和标注配方，不覆盖原始文件。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String mediaId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final MediaEditRecipeRequest mediaEditRecipeRequest = ; // MediaEditRecipeRequest |

try {
    final response = api.createMediaEditRecipe(idempotencyKey, ifMatch, mediaId, mediaEditRecipeRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createMediaEditRecipe: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **mediaId** | **String**|  |
 **mediaEditRecipeRequest** | [**MediaEditRecipeRequest**](MediaEditRecipeRequest.md)|  |

### Return type

[**MediaEditRecipeResponse**](MediaEditRecipeResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPedigreeParentage**
> PedigreeParentageResponse createPedigreeParentage(idempotencyKey, pedigreeParentageCreateRequest)

新增父母关系断言

服务端校验角色、性别和祖先环；关系修正保留审计链。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final PedigreeParentageCreateRequest pedigreeParentageCreateRequest = ; // PedigreeParentageCreateRequest |

try {
    final response = api.createPedigreeParentage(idempotencyKey, pedigreeParentageCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createPedigreeParentage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **pedigreeParentageCreateRequest** | [**PedigreeParentageCreateRequest**](PedigreeParentageCreateRequest.md)|  |

### Return type

[**PedigreeParentageResponse**](PedigreeParentageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createSession**
> SessionResponse createSession(idempotencyKey, phoneCodeLoginRequest, xTimezone)

使用手机验证码登录

校验验证码并返回 Bearer 访问令牌、刷新令牌和当前个人熊舍。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final PhoneCodeLoginRequest phoneCodeLoginRequest = {"phone":"+8613800138000","verification_id":"018f47a2-2f7e-7f5d-a413-5bfe09a61f62","code":"482931","device":{"platform":"ios","device_name":"iPhone","app_version":"0.1.0"}}; // PhoneCodeLoginRequest |
final String xTimezone = Asia/Shanghai; // String | IANA 时区；缺省时使用当前熊舍 timezone。

try {
    final response = api.createSession(idempotencyKey, phoneCodeLoginRequest, xTimezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **phoneCodeLoginRequest** | [**PhoneCodeLoginRequest**](PhoneCodeLoginRequest.md)|  |
 **xTimezone** | **String**| IANA 时区；缺省时使用当前熊舍 timezone。 | [optional] [default to 'Asia/Shanghai']

### Return type

[**SessionResponse**](SessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createShare**
> SharePageResponse createShare(idempotencyKey, shareCreateRequest)

创建公开分享

为仓鼠或窝次生成随机公开令牌，只包含显式选择的字段和媒体。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final ShareCreateRequest shareCreateRequest = ; // ShareCreateRequest |

try {
    final response = api.createShare(idempotencyKey, shareCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createShare: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **shareCreateRequest** | [**ShareCreateRequest**](ShareCreateRequest.md)|  |

### Return type

[**SharePageResponse**](SharePageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createSpeciesRuleVersion**
> SpeciesRuleVersionResponse createSpeciesRuleVersion(idempotencyKey, speciesRuleVersionCreateRequest)

创建规则版本

可从系统模板复制并调整；历史繁育计划继续引用其原规则快照。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final SpeciesRuleVersionCreateRequest speciesRuleVersionCreateRequest = ; // SpeciesRuleVersionCreateRequest |

try {
    final response = api.createSpeciesRuleVersion(idempotencyKey, speciesRuleVersionCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createSpeciesRuleVersion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **speciesRuleVersionCreateRequest** | [**SpeciesRuleVersionCreateRequest**](SpeciesRuleVersionCreateRequest.md)|  |

### Return type

[**SpeciesRuleVersionResponse**](SpeciesRuleVersionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTask**
> CareTaskResponse createTask(idempotencyKey, careTaskCreateRequest)

创建手工任务

系统生成任务也使用同一资源模型；关闭系统通知不影响任务存在。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final CareTaskCreateRequest careTaskCreateRequest = ; // CareTaskCreateRequest |

try {
    final response = api.createTask(idempotencyKey, careTaskCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createTask: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **careTaskCreateRequest** | [**CareTaskCreateRequest**](CareTaskCreateRequest.md)|  |

### Return type

[**CareTaskResponse**](CareTaskResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createWeightRecord**
> WeightRecordResponse createWeightRecord(idempotencyKey, weightRecordCreateRequest)

创建体重记录

原始克值只追加；服务端保存出生和上次体重比较快照。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final WeightRecordCreateRequest weightRecordCreateRequest = ; // WeightRecordCreateRequest |

try {
    final response = api.createWeightRecord(idempotencyKey, weightRecordCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createWeightRecord: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **weightRecordCreateRequest** | [**WeightRecordCreateRequest**](WeightRecordCreateRequest.md)|  |

### Return type

[**WeightRecordResponse**](WeightRecordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteCurrentSession**
> deleteCurrentSession(idempotencyKey)

退出当前会话

使当前访问令牌与对应刷新令牌失效。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。

try {
    api.deleteCurrentSession(idempotencyKey);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->deleteCurrentSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAsyncJob**
> AsyncJobResponse getAsyncJob(jobId)

获取通用异步作业

查询导入、导出、备份、媒体派生、转码或报喜卡任务状态。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getAsyncJob(jobId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getAsyncJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  |

### Return type

[**AsyncJobResponse**](AsyncJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBackupDownload**
> DownloadLinkResponse getBackupDownload(jobId)

获取备份下载链接

返回短时有效下载地址、文件大小和 SHA-256。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getBackupDownload(jobId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getBackupDownload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  |

### Return type

[**DownloadLinkResponse**](DownloadLinkResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBackupJob**
> BackupJobResponse getBackupJob(jobId)

获取备份任务

返回进度、大小、哈希、失败原因和可恢复状态。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getBackupJob(jobId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getBackupJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  |

### Return type

[**BackupJobResponse**](BackupJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBreedingPlan**
> BreedingPlanResponse getBreedingPlan(planId)

获取繁育计划

返回计划、规则快照、亲缘检查和当前版本。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getBreedingPlan(planId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getBreedingPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planId** | **String**|  |

### Return type

[**BreedingPlanResponse**](BreedingPlanResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCurrentAccount**
> CurrentAccountResponse getCurrentAccount()

获取当前账号

返回认证账号、当前熊舍和会话能力。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();

try {
    final response = api.getCurrentAccount();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getCurrentAccount: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CurrentAccountResponse**](CurrentAccountResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCurrentOrganization**
> OrganizationResponse getCurrentOrganization()

获取当前熊舍

当前熊舍由认证上下文选择。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();

try {
    final response = api.getCurrentOrganization();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getCurrentOrganization: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**OrganizationResponse**](OrganizationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCurrentUsage**
> UsageResponse getCurrentUsage()

获取当前用量

返回活跃个体、窝次、笼盒、媒体、视频和备份用量及权益上限。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();

try {
    final response = api.getCurrentUsage();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getCurrentUsage: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UsageResponse**](UsageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDataCenterSummary**
> DataCenterSummaryResponse getDataCenterSummary()

获取数据中心摘要

返回最近导入、导出、备份和当前用量。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();

try {
    final response = api.getDataCenterSummary();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getDataCenterSummary: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DataCenterSummaryResponse**](DataCenterSummaryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEnclosure**
> EnclosureResponse getEnclosure(enclosureId)

获取笼盒详情

返回笼盒、当前占用和版本号。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String enclosureId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getEnclosure(enclosureId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getEnclosure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **enclosureId** | **String**|  |

### Return type

[**EnclosureResponse**](EnclosureResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEnclosureCleaning**
> EnclosureCleaningResponse getEnclosureCleaning(cleaningId)

获取清洁记录

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cleaningId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getEnclosureCleaning(cleaningId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getEnclosureCleaning: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cleaningId** | **String**|  |

### Return type

[**EnclosureCleaningResponse**](EnclosureCleaningResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getExportDownload**
> DownloadLinkResponse getExportDownload(jobId)

获取导出下载链接

仅成功且未过期的任务返回短时有效下载地址。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getExportDownload(jobId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getExportDownload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  |

### Return type

[**DownloadLinkResponse**](DownloadLinkResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getExportJob**
> ExportJobResponse getExportJob(jobId)

获取导出任务

返回进度、失败原因、过期时间和下载状态。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getExportJob(jobId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getExportJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  |

### Return type

[**ExportJobResponse**](ExportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHamster**
> HamsterResponse getHamster(hamsterId)

获取仓鼠详情

返回档案、当前笼位和版本号。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String hamsterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getHamster(hamsterId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getHamster: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **hamsterId** | **String**|  |

### Return type

[**HamsterResponse**](HamsterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHamsterPedigree**
> PedigreeGraphResponse getHamsterPedigree(hamsterId, generations)

获取仓鼠家谱图

返回 pedigree_parentage 边、窝次父母与窝次成员推导出的统一关系图。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String hamsterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final int generations = 56; // int |

try {
    final response = api.getHamsterPedigree(hamsterId, generations);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getHamsterPedigree: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **hamsterId** | **String**|  |
 **generations** | **int**|  | [optional] [default to 4]

### Return type

[**PedigreeGraphResponse**](PedigreeGraphResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHealthRecord**
> HealthRecordResponse getHealthRecord(healthRecordId)

获取健康记录

返回结构化检查、用药、媒体和版本。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String healthRecordId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getHealthRecord(healthRecordId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getHealthRecord: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **healthRecordId** | **String**|  |

### Return type

[**HealthRecordResponse**](HealthRecordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getImportErrorReport**
> DownloadLinkResponse getImportErrorReport(jobId)

下载 CSV 逐行错误报告

为完成预检或正式导入的任务生成短期签名下载地址。报告包含行号、列名、 错误码、严重级别、原值和修复建议；下载前再次校验认证 owner_id。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getImportErrorReport(jobId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getImportErrorReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  |

### Return type

[**DownloadLinkResponse**](DownloadLinkResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getImportJob**
> ImportJobResponse getImportJob(jobId)

获取导入任务

返回编码识别、映射、预检、提交进度和汇总。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getImportJob(jobId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getImportJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getImportTemplate**
> ImportTemplateResponse getImportTemplate(templateType)

获取 CSV 导入模板

首版提供 hamster、enclosure 和 weight 三类模板。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final ImportTemplateType templateType = ; // ImportTemplateType |

try {
    final response = api.getImportTemplate(templateType);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getImportTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **templateType** | [**ImportTemplateType**](.md)|  |

### Return type

[**ImportTemplateResponse**](ImportTemplateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLitter**
> LitterResponse getLitter(litterId)

获取窝次详情

返回数量对账、临时幼崽摘要和版本号。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getLitter(litterId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getLitter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **litterId** | **String**|  |

### Return type

[**LitterResponse**](LitterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLitterIndividualizationEligibility**
> IndividualizationEligibilityResponse getLitterIndividualizationEligibility(litterId)

获取服务端个体化 eligible set

服务端根据窝次状态、数量账、幼崽存活状态、断奶、性别复核和有效笼位， 计算本次必须完整转换的 pup_identity 集合。返回的 eligible_set_token 绑定 当前 litter version 与有序身份集合；任何相关事实变化都会使旧 token 失效。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getLitterIndividualizationEligibility(litterId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getLitterIndividualizationEligibility: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **litterId** | **String**|  |

### Return type

[**IndividualizationEligibilityResponse**](IndividualizationEligibilityResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLitterIndividualizationEligibility_0**
> IndividualizationEligibilityResponse getLitterIndividualizationEligibility_0(litterId)

获取服务端个体化 eligible set

服务端根据窝次状态、数量账、幼崽存活状态、断奶、性别复核和有效笼位， 计算本次必须完整转换的 pup_identity 集合。返回的 eligible_set_token 绑定 当前 litter version 与有序身份集合；任何相关事实变化都会使旧 token 失效。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getLitterIndividualizationEligibility_0(litterId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getLitterIndividualizationEligibility_0: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **litterId** | **String**|  |

### Return type

[**IndividualizationEligibilityResponse**](IndividualizationEligibilityResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLitterIndividualizationEligibility_1**
> IndividualizationEligibilityResponse getLitterIndividualizationEligibility_1(litterId)

获取服务端个体化 eligible set

服务端根据窝次状态、数量账、幼崽存活状态、断奶、性别复核和有效笼位， 计算本次必须完整转换的 pup_identity 集合。返回的 eligible_set_token 绑定 当前 litter version 与有序身份集合；任何相关事实变化都会使旧 token 失效。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getLitterIndividualizationEligibility_1(litterId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getLitterIndividualizationEligibility_1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **litterId** | **String**|  |

### Return type

[**IndividualizationEligibilityResponse**](IndividualizationEligibilityResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMediaAsset**
> MediaAssetResponse getMediaAsset(mediaId)

获取媒体资产

返回原始媒体、派生版本、转码状态与封面。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String mediaId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getMediaAsset(mediaId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getMediaAsset: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mediaId** | **String**|  |

### Return type

[**MediaAssetResponse**](MediaAssetResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMediaTranscodeStatus**
> AsyncJobResponse getMediaTranscodeStatus(mediaId)

获取转码状态

返回短视频转码、图片派生或编辑任务的异步状态。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String mediaId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getMediaTranscodeStatus(mediaId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getMediaTranscodeStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mediaId** | **String**|  |

### Return type

[**AsyncJobResponse**](AsyncJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPairingAttempt**
> PairingAttemptResponse getPairingAttempt(attemptId)

获取配对尝试

返回配对时间、结果、分笼截止时间和版本。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String attemptId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getPairingAttempt(attemptId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getPairingAttempt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **attemptId** | **String**|  |

### Return type

[**PairingAttemptResponse**](PairingAttemptResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPublicShare**
> PublicShareResponse getPublicShare(token)

无需认证读取公开分享

只返回舍主显式选择的字段和 share-scoped 媒体 URL；撤销或过期后返回 404。 MVP API 响应使用 no-store，确保撤销完成后不会由浏览器或 CDN 回放历史 JSON。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String token = token_example; // String |

try {
    final response = api.getPublicShare(token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getPublicShare: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  |

### Return type

[**PublicShareResponse**](PublicShareResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPublicShareMedia**
> Uint8List getPublicShareMedia(token, mediaId)

读取公开分享媒体

仅允许读取当前 token 显式选择的媒体；分享撤销或过期后返回 404。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String token = token_example; // String |
final String mediaId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getPublicShareMedia(token, mediaId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getPublicShareMedia: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  |
 **mediaId** | **String**|  |

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/octet-stream, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReminder**
> ReminderResponse getReminder(reminderId)

获取提醒

返回提醒规则、基准事件和多通道投递状态。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String reminderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getReminder(reminderId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getReminder: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reminderId** | **String**|  |

### Return type

[**ReminderResponse**](ReminderResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSpeciesRuleVersion**
> SpeciesRuleVersionResponse getSpeciesRuleVersion(ruleVersionId)

获取规则版本

返回单个规则版本及来源。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String ruleVersionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getSpeciesRuleVersion(ruleVersionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getSpeciesRuleVersion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ruleVersionId** | **String**|  |

### Return type

[**SpeciesRuleVersionResponse**](SpeciesRuleVersionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTask**
> CareTaskResponse getTask(taskId)

获取任务

返回阶段进度、关联对象和版本。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String taskId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getTask(taskId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getTask: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taskId** | **String**|  |

### Return type

[**CareTaskResponse**](CareTaskResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **individualizeLitter**
> IndividualizeLitterResponse individualizeLitter(idempotencyKey, ifMatch, litterId, individualizeLitterRequest)

将临时幼崽个体化

仅允许 individualizing。服务端重新计算完整 eligible set，并要求请求 token、 items 的身份集合与该集合完全一致；缺项、多项、重复项、失效 token 或任一阻塞项 均拒绝整批请求。通过后原子一对一转换为 hamster，建立 litter_member 与 pedigree_parentage，并返回服务端数量对账。客户端不提交目标状态或目标数量。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final IndividualizeLitterRequest individualizeLitterRequest = {"individualized_at":"2026-09-01T02:00:00Z","timezone":"Asia/Shanghai","eligible_set_token":"elig_v4_2c54b21e2fdb6ad3","items":[{"pup_identity_id":"018f47a2-73b3-762e-8498-07b13dc3b599","internal_code":"SY-2026-L01-01","name":"星一","variety_code":"syrian"},{"pup_identity_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","internal_code":"SY-2026-L01-02","name":"星二","variety_code":"syrian"}]}; // IndividualizeLitterRequest |

try {
    final response = api.individualizeLitter(idempotencyKey, ifMatch, litterId, individualizeLitterRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->individualizeLitter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **litterId** | **String**|  |
 **individualizeLitterRequest** | [**IndividualizeLitterRequest**](IndividualizeLitterRequest.md)|  |

### Return type

[**IndividualizeLitterResponse**](IndividualizeLitterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **individualizeLitter_0**
> IndividualizeLitterResponse individualizeLitter_0(idempotencyKey, ifMatch, litterId, individualizeLitterRequest)

将临时幼崽个体化

仅允许 individualizing。服务端重新计算完整 eligible set，并要求请求 token、 items 的身份集合与该集合完全一致；缺项、多项、重复项、失效 token 或任一阻塞项 均拒绝整批请求。通过后原子一对一转换为 hamster，建立 litter_member 与 pedigree_parentage，并返回服务端数量对账。客户端不提交目标状态或目标数量。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final IndividualizeLitterRequest individualizeLitterRequest = {"individualized_at":"2026-09-01T02:00:00Z","timezone":"Asia/Shanghai","eligible_set_token":"elig_v4_2c54b21e2fdb6ad3","items":[{"pup_identity_id":"018f47a2-73b3-762e-8498-07b13dc3b599","internal_code":"SY-2026-L01-01","name":"星一","variety_code":"syrian"},{"pup_identity_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","internal_code":"SY-2026-L01-02","name":"星二","variety_code":"syrian"}]}; // IndividualizeLitterRequest |

try {
    final response = api.individualizeLitter_0(idempotencyKey, ifMatch, litterId, individualizeLitterRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->individualizeLitter_0: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **litterId** | **String**|  |
 **individualizeLitterRequest** | [**IndividualizeLitterRequest**](IndividualizeLitterRequest.md)|  |

### Return type

[**IndividualizeLitterResponse**](IndividualizeLitterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **individualizeLitter_1**
> IndividualizeLitterResponse individualizeLitter_1(idempotencyKey, ifMatch, litterId, individualizeLitterRequest)

将临时幼崽个体化

仅允许 individualizing。服务端重新计算完整 eligible set，并要求请求 token、 items 的身份集合与该集合完全一致；缺项、多项、重复项、失效 token 或任一阻塞项 均拒绝整批请求。通过后原子一对一转换为 hamster，建立 litter_member 与 pedigree_parentage，并返回服务端数量对账。客户端不提交目标状态或目标数量。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final IndividualizeLitterRequest individualizeLitterRequest = {"individualized_at":"2026-09-01T02:00:00Z","timezone":"Asia/Shanghai","eligible_set_token":"elig_v4_2c54b21e2fdb6ad3","items":[{"pup_identity_id":"018f47a2-73b3-762e-8498-07b13dc3b599","internal_code":"SY-2026-L01-01","name":"星一","variety_code":"syrian"},{"pup_identity_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","internal_code":"SY-2026-L01-02","name":"星二","variety_code":"syrian"}]}; // IndividualizeLitterRequest |

try {
    final response = api.individualizeLitter_1(idempotencyKey, ifMatch, litterId, individualizeLitterRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->individualizeLitter_1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **litterId** | **String**|  |
 **individualizeLitterRequest** | [**IndividualizeLitterRequest**](IndividualizeLitterRequest.md)|  |

### Return type

[**IndividualizeLitterResponse**](IndividualizeLitterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBackupJobs**
> BackupJobListResponse listBackupJobs(cursor, limit)

列出备份任务

使用 cursor 分页返回备份、校验与可恢复状态。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。

try {
    final response = api.listBackupJobs(cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listBackupJobs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]

### Return type

[**BackupJobListResponse**](BackupJobListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBreedingPlans**
> BreedingPlanListResponse listBreedingPlans(cursor, limit, state, sireId, damId)

列出繁育计划

使用 cursor 分页并按状态、父本、母本或日期筛选。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final BreedingPlanState state = ; // BreedingPlanState |
final String sireId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String damId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.listBreedingPlans(cursor, limit, state, sireId, damId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listBreedingPlans: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **state** | [**BreedingPlanState**](.md)|  | [optional]
 **sireId** | **String**|  | [optional]
 **damId** | **String**|  | [optional]

### Return type

[**BreedingPlanListResponse**](BreedingPlanListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEnclosureCleanings**
> EnclosureCleaningListResponse listEnclosureCleanings(enclosureId, cursor, limit)

列出笼盒清洁历史

返回清洁、消毒及纠错记录；历史记录只追加，不原地覆盖。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String enclosureId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。

try {
    final response = api.listEnclosureCleanings(enclosureId, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listEnclosureCleanings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **enclosureId** | **String**|  |
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]

### Return type

[**EnclosureCleaningListResponse**](EnclosureCleaningListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEnclosureStays**
> EnclosureStayListResponse listEnclosureStays(enclosureId, cursor, limit, active)

列出笼盒入住历史

返回指定笼盒的入住、移笼和离开历史。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String enclosureId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final bool active = true; // bool |

try {
    final response = api.listEnclosureStays(enclosureId, cursor, limit, active);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listEnclosureStays: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **enclosureId** | **String**|  |
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **active** | **bool**|  | [optional]

### Return type

[**EnclosureStayListResponse**](EnclosureStayListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEnclosures**
> EnclosureListResponse listEnclosures(cursor, limit, state, rackCode, cleanlinessState)

列出笼盒

使用 cursor 分页并支持状态、笼架和清洁状态筛选。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final EnclosureState state = ; // EnclosureState |
final String rackCode = rackCode_example; // String |
final CleanlinessState cleanlinessState = ; // CleanlinessState |

try {
    final response = api.listEnclosures(cursor, limit, state, rackCode, cleanlinessState);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listEnclosures: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **state** | [**EnclosureState**](.md)|  | [optional]
 **rackCode** | **String**|  | [optional]
 **cleanlinessState** | [**CleanlinessState**](.md)|  | [optional]

### Return type

[**EnclosureListResponse**](EnclosureListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listExportJobs**
> ExportJobListResponse listExportJobs(cursor, limit)

列出导出任务

使用 cursor 分页返回导出状态。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。

try {
    final response = api.listExportJobs(cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listExportJobs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]

### Return type

[**ExportJobListResponse**](ExportJobListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listHamsters**
> HamsterListResponse listHamsters(cursor, limit, lifecycleStatus, sex, enclosureId, q)

列出仓鼠

使用 cursor 分页；支持按状态、性别、笼盒和关键词筛选。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final HamsterLifecycleStatus lifecycleStatus = ; // HamsterLifecycleStatus |
final Sex sex = ; // Sex |
final String enclosureId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String q = q_example; // String | 编号或昵称关键词

try {
    final response = api.listHamsters(cursor, limit, lifecycleStatus, sex, enclosureId, q);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listHamsters: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **lifecycleStatus** | [**HamsterLifecycleStatus**](.md)|  | [optional]
 **sex** | [**Sex**](.md)|  | [optional]
 **enclosureId** | **String**|  | [optional]
 **q** | **String**| 编号或昵称关键词 | [optional]

### Return type

[**HamsterListResponse**](HamsterListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listHealthRecords**
> HealthRecordListResponse listHealthRecords(cursor, limit, hamsterId, litterId, type)

列出健康记录

按仓鼠、窝次、类型和发生时间筛选。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final String hamsterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final HealthRecordType type = ; // HealthRecordType |

try {
    final response = api.listHealthRecords(cursor, limit, hamsterId, litterId, type);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listHealthRecords: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **hamsterId** | **String**|  | [optional]
 **litterId** | **String**|  | [optional]
 **type** | [**HealthRecordType**](.md)|  | [optional]

### Return type

[**HealthRecordListResponse**](HealthRecordListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listImportJobs**
> ImportJobListResponse listImportJobs(cursor, limit, status)

列出导入任务

使用 cursor 分页返回任务状态。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final JobStatus status = ; // JobStatus |

try {
    final response = api.listImportJobs(cursor, limit, status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listImportJobs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **status** | [**JobStatus**](.md)|  | [optional]

### Return type

[**ImportJobListResponse**](ImportJobListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listImportRowResults**
> ImportRowResultListResponse listImportRowResults(jobId, cursor, limit, status)

获取逐行导入结果

使用 cursor 分页返回每行映射值、状态、资源 ID 和错误。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final ImportRowStatus status = ; // ImportRowStatus |

try {
    final response = api.listImportRowResults(jobId, cursor, limit, status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listImportRowResults: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  |
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **status** | [**ImportRowStatus**](.md)|  | [optional]

### Return type

[**ImportRowResultListResponse**](ImportRowResultListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLitterMembers**
> LitterMemberListResponse listLitterMembers(litterId, cursor, limit)

列出窝次成员

返回 litter_member，对临时幼崽或正式 hamster 二选一关联。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。

try {
    final response = api.listLitterMembers(litterId, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listLitterMembers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **litterId** | **String**|  |
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]

### Return type

[**LitterMemberListResponse**](LitterMemberListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLitterMembers_0**
> LitterMemberListResponse listLitterMembers_0(litterId, cursor, limit)

列出窝次成员

返回 litter_member，对临时幼崽或正式 hamster 二选一关联。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。

try {
    final response = api.listLitterMembers_0(litterId, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listLitterMembers_0: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **litterId** | **String**|  |
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]

### Return type

[**LitterMemberListResponse**](LitterMemberListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLitterParents**
> LitterParentListResponse listLitterParents(litterId)

获取窝次父母关系

返回 litter_parent 关系。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.listLitterParents(litterId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listLitterParents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **litterId** | **String**|  |

### Return type

[**LitterParentListResponse**](LitterParentListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLitters**
> LitterListResponse listLitters(cursor, limit, state, bornFrom, bornTo)

列出窝次

使用 cursor 分页并支持状态、父母和出生日期筛选。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final LitterState state = ; // LitterState |
final DateTime bornFrom = 2013-10-20; // DateTime |
final DateTime bornTo = 2013-10-20; // DateTime |

try {
    final response = api.listLitters(cursor, limit, state, bornFrom, bornTo);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listLitters: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **state** | [**LitterState**](.md)|  | [optional]
 **bornFrom** | **DateTime**|  | [optional]
 **bornTo** | **DateTime**|  | [optional]

### Return type

[**LitterListResponse**](LitterListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPairingAttempts**
> PairingAttemptListResponse listPairingAttempts(planId, cursor, limit)

列出计划的配对尝试

返回多次配对尝试及当前版本。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。

try {
    final response = api.listPairingAttempts(planId, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listPairingAttempts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planId** | **String**|  |
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]

### Return type

[**PairingAttemptListResponse**](PairingAttemptListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPedigreeParentages**
> PedigreeParentageListResponse listPedigreeParentages(cursor, limit, childHamsterId, parentHamsterId)

列出家谱父母边

按子代、父母或有效期筛选 pedigree_parentage。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final String childHamsterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String parentHamsterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.listPedigreeParentages(cursor, limit, childHamsterId, parentHamsterId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listPedigreeParentages: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **childHamsterId** | **String**|  | [optional]
 **parentHamsterId** | **String**|  | [optional]

### Return type

[**PedigreeParentageListResponse**](PedigreeParentageListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPupIdentities**
> PupIdentityListResponse listPupIdentities(litterId, cursor, limit, outcomeStatus, profileStatus)

列出临时幼崽

返回未个体化及已映射幼崽身份。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final PupOutcomeStatus outcomeStatus = ; // PupOutcomeStatus |
final PupProfileStatus profileStatus = ; // PupProfileStatus |

try {
    final response = api.listPupIdentities(litterId, cursor, limit, outcomeStatus, profileStatus);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listPupIdentities: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **litterId** | **String**|  |
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **outcomeStatus** | [**PupOutcomeStatus**](.md)|  | [optional]
 **profileStatus** | [**PupProfileStatus**](.md)|  | [optional]

### Return type

[**PupIdentityListResponse**](PupIdentityListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listReminders**
> ReminderListResponse listReminders(cursor, limit, state, ruleCode)

列出提醒

返回站内提醒及各通知通道投递状态。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final ReminderState state = ; // ReminderState |
final String ruleCode = ruleCode_example; // String |

try {
    final response = api.listReminders(cursor, limit, state, ruleCode);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listReminders: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **state** | [**ReminderState**](.md)|  | [optional]
 **ruleCode** | **String**|  | [optional]

### Return type

[**ReminderListResponse**](ReminderListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listShares**
> SharePageListResponse listShares(cursor, limit, status)

列出公开分享

使用 cursor 分页返回当前熊舍创建的分享。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final ShareStatus status = ; // ShareStatus |

try {
    final response = api.listShares(cursor, limit, status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listShares: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **status** | [**ShareStatus**](.md)|  | [optional]

### Return type

[**SharePageListResponse**](SharePageListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSpeciesRuleTemplates**
> SpeciesRuleVersionListResponse listSpeciesRuleTemplates(cursor, limit)

列出系统物种规则模板

返回系统维护的只读模板，可复制为当前熊舍规则版本。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。

try {
    final response = api.listSpeciesRuleTemplates(cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listSpeciesRuleTemplates: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]

### Return type

[**SpeciesRuleVersionListResponse**](SpeciesRuleVersionListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSpeciesRuleVersions**
> SpeciesRuleVersionListResponse listSpeciesRuleVersions(cursor, limit, speciesCode)

列出当前熊舍规则版本

按 cursor 分页返回当前熊舍复制或创建的历史规则版本。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final String speciesCode = speciesCode_example; // String | 按物种编码筛选

try {
    final response = api.listSpeciesRuleVersions(cursor, limit, speciesCode);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listSpeciesRuleVersions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **speciesCode** | **String**| 按物种编码筛选 | [optional]

### Return type

[**SpeciesRuleVersionListResponse**](SpeciesRuleVersionListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTasks**
> CareTaskListResponse listTasks(cursor, limit, state, priority, targetType, dueBefore)

列出任务

使用 cursor 分页，支持状态、优先级、目标和时间范围筛选。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final TaskState state = ; // TaskState |
final TaskPriority priority = ; // TaskPriority |
final String targetType = targetType_example; // String |
final DateTime dueBefore = 2013-10-20T19:20:30+01:00; // DateTime |

try {
    final response = api.listTasks(cursor, limit, state, priority, targetType, dueBefore);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listTasks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **state** | [**TaskState**](.md)|  | [optional]
 **priority** | [**TaskPriority**](.md)|  | [optional]
 **targetType** | **String**|  | [optional]
 **dueBefore** | **DateTime**|  | [optional]

### Return type

[**CareTaskListResponse**](CareTaskListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listUsageSnapshots**
> UsageSnapshotListResponse listUsageSnapshots(cursor, limit, from, to)

列出用量快照

使用 cursor 分页返回历史计量快照。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final DateTime from = 2013-10-20; // DateTime |
final DateTime to = 2013-10-20; // DateTime |

try {
    final response = api.listUsageSnapshots(cursor, limit, from, to);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listUsageSnapshots: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **from** | **DateTime**|  | [optional]
 **to** | **DateTime**|  | [optional]

### Return type

[**UsageSnapshotListResponse**](UsageSnapshotListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listWeightRecords**
> WeightRecordListResponse listWeightRecords(cursor, limit, hamsterId, pupIdentityId, litterId, recordedFrom, recordedTo)

列出体重记录

按仓鼠、临时幼崽、窝次和时间范围筛选，使用 cursor 分页。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String cursor = cursor_example; // String | 上一页响应返回的不透明 next_cursor。
final int limit = 56; // int | 每页数量。
final String hamsterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String pupIdentityId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final DateTime recordedFrom = 2013-10-20T19:20:30+01:00; // DateTime |
final DateTime recordedTo = 2013-10-20T19:20:30+01:00; // DateTime |

try {
    final response = api.listWeightRecords(cursor, limit, hamsterId, pupIdentityId, litterId, recordedFrom, recordedTo);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listWeightRecords: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| 上一页响应返回的不透明 next_cursor。 | [optional]
 **limit** | **int**| 每页数量。 | [optional] [default to 50]
 **hamsterId** | **String**|  | [optional]
 **pupIdentityId** | **String**|  | [optional]
 **litterId** | **String**|  | [optional]
 **recordedFrom** | **DateTime**|  | [optional]
 **recordedTo** | **DateTime**|  | [optional]

### Return type

[**WeightRecordListResponse**](WeightRecordListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **preflightImportJob**
> ImportJobResponse preflightImportJob(idempotencyKey, ifMatch, jobId, importPreflightRequest)

全量预检 CSV

全量检查缺列、重复编号、父母缺失、父母与既有窝次不一致、谱系环、笼位冲突 和非法体重。仓鼠模板可按窝次编号自动规划历史窝次，但只有同一窝次的出生时间、 双亲和物种规则全部一致时才允许创建；任何冲突均作为阻塞问题返回，不静默合并。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final ImportPreflightRequest importPreflightRequest = ; // ImportPreflightRequest |

try {
    final response = api.preflightImportJob(idempotencyKey, ifMatch, jobId, importPreflightRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->preflightImportJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **jobId** | **String**|  |
 **importPreflightRequest** | [**ImportPreflightRequest**](ImportPreflightRequest.md)|  |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **presignMediaUpload**
> MediaUploadPresignResponse presignMediaUpload(idempotencyKey, mediaUploadPresignRequest)

创建媒体预签名上传

生成对象存储上传地址；支持图片与短视频。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final MediaUploadPresignRequest mediaUploadPresignRequest = ; // MediaUploadPresignRequest |

try {
    final response = api.presignMediaUpload(idempotencyKey, mediaUploadPresignRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->presignMediaUpload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **mediaUploadPresignRequest** | [**MediaUploadPresignRequest**](MediaUploadPresignRequest.md)|  |

### Return type

[**MediaUploadPresignResponse**](MediaUploadPresignResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **previewShare**
> PublicShareResponse previewShare(shareId)

预览公开分享

认证态预览最终公开字段和媒体，不增加公开访问计数。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String shareId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.previewShare(shareId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->previewShare: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **shareId** | **String**|  |

### Return type

[**PublicShareResponse**](PublicShareResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **previewShareDraft**
> PublicShareResponse previewShareDraft(idempotencyKey, shareCreateRequest)

创建前预览公开分享

不持久化分享，不生成公开令牌；按当前 owner 校验主体、字段和媒体后返回 匿名访客将看到的精确投影。禁止输出健康备注、联系方式、任务和审计字段。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final ShareCreateRequest shareCreateRequest = ; // ShareCreateRequest |

try {
    final response = api.previewShareDraft(idempotencyKey, shareCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->previewShareDraft: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **shareCreateRequest** | [**ShareCreateRequest**](ShareCreateRequest.md)|  |

### Return type

[**PublicShareResponse**](PublicShareResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishBreedingPlan**
> PublishBreedingPlanResponse publishBreedingPlan(idempotencyKey, ifMatch, planId, publishBreedingPlanRequest)

发布繁育计划

校验父母资格、并行计划、规则版本与亲缘风险后，将 draft 推进到 pair_ready。 仅允许当前状态为 draft；客户端不提交目标 state。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final PublishBreedingPlanRequest publishBreedingPlanRequest = {"planned_pairing_at":"2026-07-18T12:00:00Z","pairing_enclosure_id":"018f47a2-4b10-77eb-a297-ad0e32886a35","timezone":"Asia/Shanghai","kinship_override_reason":null}; // PublishBreedingPlanRequest |

try {
    final response = api.publishBreedingPlan(idempotencyKey, ifMatch, planId, publishBreedingPlanRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->publishBreedingPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **planId** | **String**|  |
 **publishBreedingPlanRequest** | [**PublishBreedingPlanRequest**](PublishBreedingPlanRequest.md)|  |

### Return type

[**PublishBreedingPlanResponse**](PublishBreedingPlanResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recordPairingObservation**
> RecordObservationResponse recordPairingObservation(idempotencyKey, ifMatch, attemptId, recordObservationRequest)

记录配对观察

在有效配对时间段内追加观察，不覆盖已有观察。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String attemptId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final RecordObservationRequest recordObservationRequest = {"observed_at":"2026-07-18T12:12:00Z","type":"mating","duration_seconds":14,"severity":"info","confidence":0.9,"media_ids":["018f47a2-5e60-7fc7-b29c-1f2d435f49cd"],"notes":"观察到一次明确交配"}; // RecordObservationRequest |

try {
    final response = api.recordPairingObservation(idempotencyKey, ifMatch, attemptId, recordObservationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->recordPairingObservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **attemptId** | **String**|  |
 **recordObservationRequest** | [**RecordObservationRequest**](RecordObservationRequest.md)|  |

### Return type

[**RecordObservationResponse**](RecordObservationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshSession**
> SessionResponse refreshSession(idempotencyKey, refreshSessionRequest, xTimezone)

刷新当前会话

使用刷新令牌轮换访问令牌和刷新令牌，供客户端恢复认证 owner 上下文。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final RefreshSessionRequest refreshSessionRequest = ; // RefreshSessionRequest |
final String xTimezone = Asia/Shanghai; // String | IANA 时区；缺省时使用当前熊舍 timezone。

try {
    final response = api.refreshSession(idempotencyKey, refreshSessionRequest, xTimezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->refreshSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **refreshSessionRequest** | [**RefreshSessionRequest**](RefreshSessionRequest.md)|  |
 **xTimezone** | **String**| IANA 时区；缺省时使用当前熊舍 timezone。 | [optional] [default to 'Asia/Shanghai']

### Return type

[**SessionResponse**](SessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **retryBackupJob**
> BackupJobResponse retryBackupJob(idempotencyKey, ifMatch, jobId, retryJobRequest)

重试失败备份

保留原失败记录并创建新的执行尝试。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final RetryJobRequest retryJobRequest = ; // RetryJobRequest |

try {
    final response = api.retryBackupJob(idempotencyKey, ifMatch, jobId, retryJobRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->retryBackupJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **jobId** | **String**|  |
 **retryJobRequest** | [**RetryJobRequest**](RetryJobRequest.md)|  |

### Return type

[**BackupJobResponse**](BackupJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **retryExportJob**
> ExportJobResponse retryExportJob(idempotencyKey, ifMatch, jobId, retryJobRequest)

重试失败导出

从相同导出快照创建新执行尝试。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final RetryJobRequest retryJobRequest = ; // RetryJobRequest |

try {
    final response = api.retryExportJob(idempotencyKey, ifMatch, jobId, retryJobRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->retryExportJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **jobId** | **String**|  |
 **retryJobRequest** | [**RetryJobRequest**](RetryJobRequest.md)|  |

### Return type

[**ExportJobResponse**](ExportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **retryImportJob**
> ImportJobResponse retryImportJob(idempotencyKey, ifMatch, jobId, retryImportRequest)

重试失败导入行

可重试全部失败行或指定行号，已成功行不会重复写入。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final RetryImportRequest retryImportRequest = ; // RetryImportRequest |

try {
    final response = api.retryImportJob(idempotencyKey, ifMatch, jobId, retryImportRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->retryImportJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **jobId** | **String**|  |
 **retryImportRequest** | [**RetryImportRequest**](RetryImportRequest.md)|  |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **retryMediaProcessing**
> MediaProcessingRetryResponse retryMediaProcessing(idempotencyKey, ifMatch, mediaId, mediaProcessingRetryRequest)

重试失败的媒体处理

仅允许原始媒体已完成校验且目标派生处于 failed。保留原失败作业， 幂等创建新的图片派生或短视频转码作业；业务记录和原始媒体事实不回滚。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String mediaId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final MediaProcessingRetryRequest mediaProcessingRetryRequest = ; // MediaProcessingRetryRequest |

try {
    final response = api.retryMediaProcessing(idempotencyKey, ifMatch, mediaId, mediaProcessingRetryRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->retryMediaProcessing: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **mediaId** | **String**|  |
 **mediaProcessingRetryRequest** | [**MediaProcessingRetryRequest**](MediaProcessingRetryRequest.md)|  |

### Return type

[**MediaProcessingRetryResponse**](MediaProcessingRetryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revokeShare**
> ShareRevocationResponse revokeShare(idempotencyKey, ifMatch, shareId, revokeShareRequest)

撤销公开分享

同一事务内标记令牌已撤销并写入 CDN purge Outbox，事务提交后立即返回 200； 公开 API 的下一次请求立即失效，HTML/JSON 使用 no-store。share-scoped 公开媒体 的边缘 TTL 不超过 60 秒，最迟 60 秒不再返回；内部资源和原始私有媒体不受影响。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String shareId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final RevokeShareRequest revokeShareRequest = ; // RevokeShareRequest |

try {
    final response = api.revokeShare(idempotencyKey, ifMatch, shareId, revokeShareRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->revokeShare: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **shareId** | **String**|  |
 **revokeShareRequest** | [**RevokeShareRequest**](RevokeShareRequest.md)|  |

### Return type

[**ShareRevocationResponse**](ShareRevocationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendVerificationCode**
> VerificationCodeChallengeResponse sendVerificationCode(idempotencyKey, sendVerificationCodeRequest, xTimezone)

发送手机验证码

为登录目的发送验证码；相同手机号和用途受冷却时间与频率限制。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final SendVerificationCodeRequest sendVerificationCodeRequest = {"phone":"+8613800138000","purpose":"login"}; // SendVerificationCodeRequest |
final String xTimezone = Asia/Shanghai; // String | IANA 时区；缺省时使用当前熊舍 timezone。

try {
    final response = api.sendVerificationCode(idempotencyKey, sendVerificationCodeRequest, xTimezone);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->sendVerificationCode: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **sendVerificationCodeRequest** | [**SendVerificationCodeRequest**](SendVerificationCodeRequest.md)|  |
 **xTimezone** | **String**| IANA 时区；缺省时使用当前熊舍 timezone。 | [optional] [default to 'Asia/Shanghai']

### Return type

[**VerificationCodeChallengeResponse**](VerificationCodeChallengeResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **separatePairing**
> SeparatePairingResponse separatePairing(idempotencyKey, ifMatch, attemptId, separatePairingRequest)

结束配对并完成分笼

仅允许 active 或 safety_hold 的配对尝试。 原子关闭临时配对占用、登记双方去向并创建新入住事实。 若笼盒冲突或只登记一方，整体失败且不释放配对笼。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String attemptId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final SeparatePairingRequest separatePairingRequest = {"ended_at":"2026-07-18T12:25:00Z","separated_at":"2026-07-18T12:26:00Z","result":"effective","sire_destination_enclosure_id":"018f47a2-6338-7952-9753-052621e1858e","dam_destination_enclosure_id":"018f47a2-6450-7f54-8851-050a3d63846f","safety_stop":false,"timezone":"Asia/Shanghai","notes":"双方状态正常"}; // SeparatePairingRequest |

try {
    final response = api.separatePairing(idempotencyKey, ifMatch, attemptId, separatePairingRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->separatePairing: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **attemptId** | **String**|  |
 **separatePairingRequest** | [**SeparatePairingRequest**](SeparatePairingRequest.md)|  |

### Return type

[**SeparatePairingResponse**](SeparatePairingResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setImportMapping**
> ImportJobResponse setImportMapping(idempotencyKey, ifMatch, jobId, importMappingRequest)

设置 CSV 字段映射

保存源列到目标字段的映射、空值策略和时区。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final ImportMappingRequest importMappingRequest = ; // ImportMappingRequest |

try {
    final response = api.setImportMapping(idempotencyKey, ifMatch, jobId, importMappingRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->setImportMapping: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **jobId** | **String**|  |
 **importMappingRequest** | [**ImportMappingRequest**](ImportMappingRequest.md)|  |

### Return type

[**ImportJobResponse**](ImportJobResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setMediaCover**
> MediaAssetResponse setMediaCover(idempotencyKey, ifMatch, mediaId, mediaCoverRequest)

设置媒体封面

视频可选择时间点或已有媒体作为封面。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String mediaId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final MediaCoverRequest mediaCoverRequest = ; // MediaCoverRequest |

try {
    final response = api.setMediaCover(idempotencyKey, ifMatch, mediaId, mediaCoverRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->setMediaCover: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **mediaId** | **String**|  |
 **mediaCoverRequest** | [**MediaCoverRequest**](MediaCoverRequest.md)|  |

### Return type

[**MediaAssetResponse**](MediaAssetResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sexAndSeparateLitter**
> SexAndSeparateResponse sexAndSeparateLitter(idempotencyKey, ifMatch, litterId, sexAndSeparateRequest)

分性并分笼

仅允许 sexing_due；逐项提交性别、置信度和目标笼盒。服务端验证完整在管集合、 异性混笼、容量和待复核安排，客户端不得提交目标状态。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final SexAndSeparateRequest sexAndSeparateRequest = {"separated_at":"2026-08-27T02:00:00Z","timezone":"Asia/Shanghai","items":[{"pup_identity_id":"018f47a2-73b3-762e-8498-07b13dc3b599","sex":"male","sex_confidence":0.98,"destination_enclosure_id":"018f47a2-8620-73ef-823e-03f187be47a2","requires_recheck":false},{"pup_identity_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","sex":"unknown","sex_confidence":0.45,"destination_enclosure_id":"018f47a2-8712-7863-ab76-9a6614ef3e2b","requires_recheck":true}]}; // SexAndSeparateRequest |

try {
    final response = api.sexAndSeparateLitter(idempotencyKey, ifMatch, litterId, sexAndSeparateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->sexAndSeparateLitter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **litterId** | **String**|  |
 **sexAndSeparateRequest** | [**SexAndSeparateRequest**](SexAndSeparateRequest.md)|  |

### Return type

[**SexAndSeparateResponse**](SexAndSeparateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startGestationMonitoring**
> StartGestationResponse startGestationMonitoring(idempotencyKey, ifMatch, planId, startGestationRequest)

从分笼后进入孕期观察

仅允许 post_pair。服务端校验至少一次 pairing_attempt 已闭环、结果为有效或待定、 配对笼已释放，再计算预产区间、创建提醒并推进到 gestation。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final StartGestationRequest startGestationRequest = ; // StartGestationRequest |

try {
    final response = api.startGestationMonitoring(idempotencyKey, ifMatch, planId, startGestationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->startGestationMonitoring: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **planId** | **String**|  |
 **startGestationRequest** | [**StartGestationRequest**](StartGestationRequest.md)|  |

### Return type

[**StartGestationResponse**](StartGestationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startPairing**
> StartPairingResponse startPairing(idempotencyKey, ifMatch, planId, startPairingRequest)

开始配对

仅允许当前状态为 pair_ready。原子创建 pairing_attempt、占用临时配对笼 并推进到 pairing；任一父母资格或笼位守卫失败时不产生部分事实。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final StartPairingRequest startPairingRequest = {"enclosure_id":"018f47a2-4b10-77eb-a297-ad0e32886a35","started_at":"2026-07-18T12:03:00Z","timezone":"Asia/Shanghai","notes":"现场扫码开始"}; // StartPairingRequest |

try {
    final response = api.startPairing(idempotencyKey, ifMatch, planId, startPairingRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->startPairing: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **planId** | **String**|  |
 **startPairingRequest** | [**StartPairingRequest**](StartPairingRequest.md)|  |

### Return type

[**StartPairingResponse**](StartPairingResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateBreedingPlan**
> BreedingPlanResponse updateBreedingPlan(idempotencyKey, ifMatch, planId, breedingPlanUpdateRequest)

更新繁育计划资料

只更新非状态字段；客户端不得直接 PATCH state。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final BreedingPlanUpdateRequest breedingPlanUpdateRequest = ; // BreedingPlanUpdateRequest |

try {
    final response = api.updateBreedingPlan(idempotencyKey, ifMatch, planId, breedingPlanUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->updateBreedingPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **planId** | **String**|  |
 **breedingPlanUpdateRequest** | [**BreedingPlanUpdateRequest**](BreedingPlanUpdateRequest.md)|  |

### Return type

[**BreedingPlanResponse**](BreedingPlanResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/merge-patch+json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateCurrentOrganization**
> OrganizationResponse updateCurrentOrganization(idempotencyKey, ifMatch, organizationUpdateRequest)

更新当前熊舍

仅更新熊舍资料；owner_id 由认证上下文解析且不在请求体中出现。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final OrganizationUpdateRequest organizationUpdateRequest = {"name":"星河熊舍二号馆","timezone":"Asia/Shanghai"}; // OrganizationUpdateRequest |

try {
    final response = api.updateCurrentOrganization(idempotencyKey, ifMatch, organizationUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->updateCurrentOrganization: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **organizationUpdateRequest** | [**OrganizationUpdateRequest**](OrganizationUpdateRequest.md)|  |

### Return type

[**OrganizationResponse**](OrganizationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/merge-patch+json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateEnclosure**
> EnclosureResponse updateEnclosure(idempotencyKey, ifMatch, enclosureId, enclosureUpdateRequest)

更新笼盒资料

修改编号、位置、笼内设施（跑轮、饮水器、食盆、躲避屋、垫材等）和清洁资料；占用事实通过入住资源维护。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String enclosureId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final EnclosureUpdateRequest enclosureUpdateRequest = ; // EnclosureUpdateRequest |

try {
    final response = api.updateEnclosure(idempotencyKey, ifMatch, enclosureId, enclosureUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->updateEnclosure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **enclosureId** | **String**|  |
 **enclosureUpdateRequest** | [**EnclosureUpdateRequest**](EnclosureUpdateRequest.md)|  |

### Return type

[**EnclosureResponse**](EnclosureResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/merge-patch+json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateEnclosureStay**
> EnclosureStayResponse updateEnclosureStay(idempotencyKey, ifMatch, stayId, enclosureStayUpdateRequest)

结束或修正入住事实

可填写结束时间与修正原因；历史修正保留审计信息。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String stayId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final EnclosureStayUpdateRequest enclosureStayUpdateRequest = ; // EnclosureStayUpdateRequest |

try {
    final response = api.updateEnclosureStay(idempotencyKey, ifMatch, stayId, enclosureStayUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->updateEnclosureStay: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **stayId** | **String**|  |
 **enclosureStayUpdateRequest** | [**EnclosureStayUpdateRequest**](EnclosureStayUpdateRequest.md)|  |

### Return type

[**EnclosureStayResponse**](EnclosureStayResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/merge-patch+json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateHamster**
> HamsterResponse updateHamster(idempotencyKey, ifMatch, hamsterId, hamsterUpdateRequest)

更新仓鼠档案

请求体不接受 owner_id、state 或父母快捷字段；父母变更走家谱关系接口。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String hamsterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final HamsterUpdateRequest hamsterUpdateRequest = ; // HamsterUpdateRequest |

try {
    final response = api.updateHamster(idempotencyKey, ifMatch, hamsterId, hamsterUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->updateHamster: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **hamsterId** | **String**|  |
 **hamsterUpdateRequest** | [**HamsterUpdateRequest**](HamsterUpdateRequest.md)|  |

### Return type

[**HamsterResponse**](HamsterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/merge-patch+json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateHealthRecord**
> HealthRecordResponse updateHealthRecord(idempotencyKey, ifMatch, healthRecordId, healthRecordUpdateRequest)

更新健康记录

通过 If-Match 修正备注、结构化检查、媒体或复查时间。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String healthRecordId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final HealthRecordUpdateRequest healthRecordUpdateRequest = ; // HealthRecordUpdateRequest |

try {
    final response = api.updateHealthRecord(idempotencyKey, ifMatch, healthRecordId, healthRecordUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->updateHealthRecord: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **healthRecordId** | **String**|  |
 **healthRecordUpdateRequest** | [**HealthRecordUpdateRequest**](HealthRecordUpdateRequest.md)|  |

### Return type

[**HealthRecordResponse**](HealthRecordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/merge-patch+json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSpeciesRuleVersion**
> SpeciesRuleVersionResponse updateSpeciesRuleVersion(idempotencyKey, ifMatch, ruleVersionId, speciesRuleVersionUpdateRequest)

更新尚未冻结的规则版本

已被繁育计划引用的规则版本保持只读，应创建新版本。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String ruleVersionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final SpeciesRuleVersionUpdateRequest speciesRuleVersionUpdateRequest = ; // SpeciesRuleVersionUpdateRequest |

try {
    final response = api.updateSpeciesRuleVersion(idempotencyKey, ifMatch, ruleVersionId, speciesRuleVersionUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->updateSpeciesRuleVersion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **ruleVersionId** | **String**|  |
 **speciesRuleVersionUpdateRequest** | [**SpeciesRuleVersionUpdateRequest**](SpeciesRuleVersionUpdateRequest.md)|  |

### Return type

[**SpeciesRuleVersionResponse**](SpeciesRuleVersionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/merge-patch+json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTask**
> CareTaskResponse updateTask(idempotencyKey, ifMatch, taskId, careTaskUpdateRequest)

更新任务非状态字段

可修改计划时间、优先级、标题和备注；完成状态走 complete 动作。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String taskId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final CareTaskUpdateRequest careTaskUpdateRequest = ; // CareTaskUpdateRequest |

try {
    final response = api.updateTask(idempotencyKey, ifMatch, taskId, careTaskUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->updateTask: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **taskId** | **String**|  |
 **careTaskUpdateRequest** | [**CareTaskUpdateRequest**](CareTaskUpdateRequest.md)|  |

### Return type

[**CareTaskResponse**](CareTaskResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/merge-patch+json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **weanLitter**
> WeanLitterResponse weanLitter(idempotencyKey, ifMatch, litterId, weanLitterRequest)

完成断奶

仅允许 weaning_due；对服务端计算的当前在管幼崽逐项提交生存/离舍结果并校验去向。 断奶动作不接受或修改 profile_status，个体化进度仅由 individualize 动作推进。 缺少当前在管身份、包含已关闭身份或笼位冲突时整体不推进状态。

### Example
```dart
import 'package:scolvpet_api/api.dart';

final api = ScolvpetApi().getDefaultApi();
final String idempotencyKey = 018f47a2-281b-79e2-b861-bf785ab6fba7; // String | 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。
final String ifMatch = "7"; // String | 当前资源版本对应的 ETag，例如双引号包裹的整数版本。
final String litterId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final WeanLitterRequest weanLitterRequest = {"weaned_at":"2026-08-25T02:00:00Z","timezone":"Asia/Shanghai","items":[{"pup_identity_id":"018f47a2-73b3-762e-8498-07b13dc3b599","outcome_status":"alive","destination_enclosure_id":"018f47a2-81bf-72b2-8990-79310bde2638"},{"pup_identity_id":"018f47a2-748c-7d2d-a19f-ab53e616d7d8","outcome_status":"alive","destination_enclosure_id":"018f47a2-81bf-72b2-8990-79310bde2638"}]}; // WeanLitterRequest |

try {
    final response = api.weanLitter(idempotencyKey, ifMatch, litterId, weanLitterRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->weanLitter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| 写请求唯一键。唯一域为 owner_id + action_code + resource_id + key；相同规范化 载荷返回首次结果，不同载荷返回 409 IDEMPOTENCY_PAYLOAD_MISMATCH。结果至少保留 24 小时；confirm-birth、individualize 与分享撤销保留至对应业务记录归档。  |
 **ifMatch** | **String**| 当前资源版本对应的 ETag，例如双引号包裹的整数版本。 |
 **litterId** | **String**|  |
 **weanLitterRequest** | [**WeanLitterRequest**](WeanLitterRequest.md)|  |

### Return type

[**WeanLitterResponse**](WeanLitterResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

