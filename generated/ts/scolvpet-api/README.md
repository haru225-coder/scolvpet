# @scolvpet/scolvpet-api@1.0.0

A TypeScript SDK client for the api.scolvpet.cn API.

## Usage

First, install the SDK from npm.

```bash
npm install @scolvpet/scolvpet-api --save
```

Next, try it out.


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


## Documentation

### API Endpoints

All URIs are relative to *https://api.scolvpet.cn/v1*

| Class | Method | HTTP request | Description
| ----- | ------ | ------------ | -------------
*DefaultApi* | [**adjustBreedingBaseline**](docs/DefaultApi.md#adjustbreedingbaseline) | **POST** /breeding-plans/{plan_id}/adjust-baseline | 修正配对基准时间
*DefaultApi* | [**batchCreateHamsters**](docs/DefaultApi.md#batchcreatehamsters) | **POST** /hamsters/batch | 批量创建仓鼠
*DefaultApi* | [**batchCreateWeightRecords**](docs/DefaultApi.md#batchcreateweightrecords) | **POST** /weight-records/batch | 批量创建体重记录
*DefaultApi* | [**cancelTask**](docs/DefaultApi.md#canceltask) | **POST** /tasks/{task_id}/cancel | 取消任务
*DefaultApi* | [**commitImportJob**](docs/DefaultApi.md#commitimportjob) | **POST** /data-center/import-jobs/{job_id}/commit | 提交正式导入
*DefaultApi* | [**completeBreedingPlan**](docs/DefaultApi.md#completebreedingplanoperation) | **POST** /breeding-plans/{plan_id}/complete | 完成繁育计划
*DefaultApi* | [**completeMediaUpload**](docs/DefaultApi.md#completemediaupload) | **POST** /media/uploads/{upload_id}/complete | 完成媒体上传
*DefaultApi* | [**completeTask**](docs/DefaultApi.md#completetaskoperation) | **POST** /tasks/{task_id}/complete | 完成任务或逐项完成任务成员
*DefaultApi* | [**confirmBirth**](docs/DefaultApi.md#confirmbirthoperation) | **POST** /breeding-plans/{plan_id}/confirm-birth | 确认产仔并建立窝次
*DefaultApi* | [**confirmBirth_0**](docs/DefaultApi.md#confirmbirth_0) | **POST** /breeding-plans/{plan_id}/confirm-birth | 确认产仔并建立窝次
*DefaultApi* | [**createBackupJob**](docs/DefaultApi.md#createbackupjob) | **POST** /data-center/backup-jobs | 创建基础备份
*DefaultApi* | [**createBreedingPlan**](docs/DefaultApi.md#createbreedingplan) | **POST** /breeding-plans | 创建繁育计划草稿
*DefaultApi* | [**createEnclosure**](docs/DefaultApi.md#createenclosure) | **POST** /enclosures | 创建笼盒
*DefaultApi* | [**createEnclosureCleaning**](docs/DefaultApi.md#createenclosurecleaning) | **POST** /enclosures/{enclosure_id}/cleanings | 记录笼盒清洁或消毒
*DefaultApi* | [**createEnclosureStay**](docs/DefaultApi.md#createenclosurestay) | **POST** /enclosures/{enclosure_id}/stays | 创建入住或移笼事实
*DefaultApi* | [**createExportJob**](docs/DefaultApi.md#createexportjob) | **POST** /data-center/export-jobs | 创建数据导出
*DefaultApi* | [**createHamster**](docs/DefaultApi.md#createhamster) | **POST** /hamsters | 创建仓鼠档案
*DefaultApi* | [**createHealthRecord**](docs/DefaultApi.md#createhealthrecord) | **POST** /health-records | 创建健康记录
*DefaultApi* | [**createImportJob**](docs/DefaultApi.md#createimportjob) | **POST** /data-center/import-jobs | 创建 CSV 导入任务
*DefaultApi* | [**createImportUpload**](docs/DefaultApi.md#createimportupload) | **POST** /data-center/import-uploads | 创建 CSV 上传
*DefaultApi* | [**createLitterCountEvent**](docs/DefaultApi.md#createlittercountevent) | **POST** /litters/{litter_id}/count-events | 追加窝仔数量事件
*DefaultApi* | [**createLitterParent**](docs/DefaultApi.md#createlitterparent) | **POST** /litters/{litter_id}/parents | 新增或纠正窝次父母关系
*DefaultApi* | [**createMediaEditRecipe**](docs/DefaultApi.md#createmediaeditrecipe) | **POST** /media/{media_id}/edit-recipes | 创建图片编辑配方
*DefaultApi* | [**createPedigreeParentage**](docs/DefaultApi.md#createpedigreeparentage) | **POST** /pedigree-parentages | 新增父母关系断言
*DefaultApi* | [**createSession**](docs/DefaultApi.md#createsession) | **POST** /auth/sessions | 使用手机验证码登录
*DefaultApi* | [**createShare**](docs/DefaultApi.md#createshare) | **POST** /shares | 创建公开分享
*DefaultApi* | [**createSpeciesRuleVersion**](docs/DefaultApi.md#createspeciesruleversion) | **POST** /species-rule-versions | 创建规则版本
*DefaultApi* | [**createTask**](docs/DefaultApi.md#createtask) | **POST** /tasks | 创建手工任务
*DefaultApi* | [**createWeightRecord**](docs/DefaultApi.md#createweightrecord) | **POST** /weight-records | 创建体重记录
*DefaultApi* | [**deleteCurrentSession**](docs/DefaultApi.md#deletecurrentsession) | **DELETE** /auth/sessions/current | 退出当前会话
*DefaultApi* | [**endPedigreeParentage**](docs/DefaultApi.md#endpedigreeparentage) | **POST** /pedigree-parentages/end | 解除当前有效父母关系
*DefaultApi* | [**getAsyncJob**](docs/DefaultApi.md#getasyncjob) | **GET** /jobs/{job_id} | 获取通用异步作业
*DefaultApi* | [**getBackupDownload**](docs/DefaultApi.md#getbackupdownload) | **GET** /data-center/backup-jobs/{job_id}/download | 获取备份下载链接
*DefaultApi* | [**getBackupJob**](docs/DefaultApi.md#getbackupjob) | **GET** /data-center/backup-jobs/{job_id} | 获取备份任务
*DefaultApi* | [**getBreedingPlan**](docs/DefaultApi.md#getbreedingplan) | **GET** /breeding-plans/{plan_id} | 获取繁育计划
*DefaultApi* | [**getCurrentAccount**](docs/DefaultApi.md#getcurrentaccount) | **GET** /me | 获取当前账号
*DefaultApi* | [**getCurrentOrganization**](docs/DefaultApi.md#getcurrentorganization) | **GET** /organizations/current | 获取当前熊舍
*DefaultApi* | [**getCurrentUsage**](docs/DefaultApi.md#getcurrentusage) | **GET** /usage/current | 获取当前用量
*DefaultApi* | [**getDataCenterSummary**](docs/DefaultApi.md#getdatacentersummary) | **GET** /data-center/summary | 获取数据中心摘要
*DefaultApi* | [**getEnclosure**](docs/DefaultApi.md#getenclosure) | **GET** /enclosures/{enclosure_id} | 获取笼盒详情
*DefaultApi* | [**getEnclosureCleaning**](docs/DefaultApi.md#getenclosurecleaning) | **GET** /enclosure-cleanings/{cleaning_id} | 获取清洁记录
*DefaultApi* | [**getExportDownload**](docs/DefaultApi.md#getexportdownload) | **GET** /data-center/export-jobs/{job_id}/download | 获取导出下载链接
*DefaultApi* | [**getExportJob**](docs/DefaultApi.md#getexportjob) | **GET** /data-center/export-jobs/{job_id} | 获取导出任务
*DefaultApi* | [**getHamster**](docs/DefaultApi.md#gethamster) | **GET** /hamsters/{hamster_id} | 获取仓鼠详情
*DefaultApi* | [**getHamsterPedigree**](docs/DefaultApi.md#gethamsterpedigree) | **GET** /hamsters/{hamster_id}/pedigree | 获取仓鼠家谱图
*DefaultApi* | [**getHealthRecord**](docs/DefaultApi.md#gethealthrecord) | **GET** /health-records/{health_record_id} | 获取健康记录
*DefaultApi* | [**getImportErrorReport**](docs/DefaultApi.md#getimporterrorreport) | **GET** /data-center/import-jobs/{job_id}/error-report | 下载 CSV 逐行错误报告
*DefaultApi* | [**getImportJob**](docs/DefaultApi.md#getimportjob) | **GET** /data-center/import-jobs/{job_id} | 获取导入任务
*DefaultApi* | [**getImportTemplate**](docs/DefaultApi.md#getimporttemplate) | **GET** /data-center/import-templates/{template_type} | 获取 CSV 导入模板
*DefaultApi* | [**getLitter**](docs/DefaultApi.md#getlitter) | **GET** /litters/{litter_id} | 获取窝次详情
*DefaultApi* | [**getLitterIndividualizationEligibility**](docs/DefaultApi.md#getlitterindividualizationeligibility) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set
*DefaultApi* | [**getLitterIndividualizationEligibility_0**](docs/DefaultApi.md#getlitterindividualizationeligibility_0) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set
*DefaultApi* | [**getLitterIndividualizationEligibility_1**](docs/DefaultApi.md#getlitterindividualizationeligibility_1) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set
*DefaultApi* | [**getMediaAsset**](docs/DefaultApi.md#getmediaasset) | **GET** /media/{media_id} | 获取媒体资产
*DefaultApi* | [**getMediaTranscodeStatus**](docs/DefaultApi.md#getmediatranscodestatus) | **GET** /media/{media_id}/transcode-status | 获取转码状态
*DefaultApi* | [**getPairingAttempt**](docs/DefaultApi.md#getpairingattempt) | **GET** /pairing-attempts/{attempt_id} | 获取配对尝试
*DefaultApi* | [**getPublicShare**](docs/DefaultApi.md#getpublicshare) | **GET** /public/shares/{token} | 无需认证读取公开分享
*DefaultApi* | [**getPublicShareMedia**](docs/DefaultApi.md#getpublicsharemedia) | **GET** /public/shares/{token}/media/{media_id} | 读取公开分享媒体
*DefaultApi* | [**getReminder**](docs/DefaultApi.md#getreminder) | **GET** /reminders/{reminder_id} | 获取提醒
*DefaultApi* | [**getSpeciesRuleVersion**](docs/DefaultApi.md#getspeciesruleversion) | **GET** /species-rule-versions/{rule_version_id} | 获取规则版本
*DefaultApi* | [**getTask**](docs/DefaultApi.md#gettask) | **GET** /tasks/{task_id} | 获取任务
*DefaultApi* | [**individualizeLitter**](docs/DefaultApi.md#individualizelitteroperation) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化
*DefaultApi* | [**individualizeLitter_0**](docs/DefaultApi.md#individualizelitter_0) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化
*DefaultApi* | [**individualizeLitter_1**](docs/DefaultApi.md#individualizelitter_1) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化
*DefaultApi* | [**listBackupJobs**](docs/DefaultApi.md#listbackupjobs) | **GET** /data-center/backup-jobs | 列出备份任务
*DefaultApi* | [**listBreedingPlans**](docs/DefaultApi.md#listbreedingplans) | **GET** /breeding-plans | 列出繁育计划
*DefaultApi* | [**listEnclosureCleanings**](docs/DefaultApi.md#listenclosurecleanings) | **GET** /enclosures/{enclosure_id}/cleanings | 列出笼盒清洁历史
*DefaultApi* | [**listEnclosureStays**](docs/DefaultApi.md#listenclosurestays) | **GET** /enclosures/{enclosure_id}/stays | 列出笼盒入住历史
*DefaultApi* | [**listEnclosures**](docs/DefaultApi.md#listenclosures) | **GET** /enclosures | 列出笼盒
*DefaultApi* | [**listExportJobs**](docs/DefaultApi.md#listexportjobs) | **GET** /data-center/export-jobs | 列出导出任务
*DefaultApi* | [**listHamsters**](docs/DefaultApi.md#listhamsters) | **GET** /hamsters | 列出仓鼠
*DefaultApi* | [**listHealthRecords**](docs/DefaultApi.md#listhealthrecords) | **GET** /health-records | 列出健康记录
*DefaultApi* | [**listImportJobs**](docs/DefaultApi.md#listimportjobs) | **GET** /data-center/import-jobs | 列出导入任务
*DefaultApi* | [**listImportRowResults**](docs/DefaultApi.md#listimportrowresults) | **GET** /data-center/import-jobs/{job_id}/rows | 获取逐行导入结果
*DefaultApi* | [**listLitterMembers**](docs/DefaultApi.md#listlittermembers) | **GET** /litters/{litter_id}/members | 列出窝次成员
*DefaultApi* | [**listLitterMembers_0**](docs/DefaultApi.md#listlittermembers_0) | **GET** /litters/{litter_id}/members | 列出窝次成员
*DefaultApi* | [**listLitterParents**](docs/DefaultApi.md#listlitterparents) | **GET** /litters/{litter_id}/parents | 获取窝次父母关系
*DefaultApi* | [**listLitters**](docs/DefaultApi.md#listlitters) | **GET** /litters | 列出窝次
*DefaultApi* | [**listPairingAttempts**](docs/DefaultApi.md#listpairingattempts) | **GET** /breeding-plans/{plan_id}/pairing-attempts | 列出计划的配对尝试
*DefaultApi* | [**listPedigreeParentages**](docs/DefaultApi.md#listpedigreeparentages) | **GET** /pedigree-parentages | 列出家谱父母边
*DefaultApi* | [**listPupIdentities**](docs/DefaultApi.md#listpupidentities) | **GET** /litters/{litter_id}/pup-identities | 列出临时幼崽
*DefaultApi* | [**listReminders**](docs/DefaultApi.md#listreminders) | **GET** /reminders | 列出提醒
*DefaultApi* | [**listShares**](docs/DefaultApi.md#listshares) | **GET** /shares | 列出公开分享
*DefaultApi* | [**listSpeciesRuleTemplates**](docs/DefaultApi.md#listspeciesruletemplates) | **GET** /species-rule-templates | 列出系统物种规则模板
*DefaultApi* | [**listSpeciesRuleVersions**](docs/DefaultApi.md#listspeciesruleversions) | **GET** /species-rule-versions | 列出当前熊舍规则版本
*DefaultApi* | [**listTasks**](docs/DefaultApi.md#listtasks) | **GET** /tasks | 列出任务
*DefaultApi* | [**listUsageSnapshots**](docs/DefaultApi.md#listusagesnapshots) | **GET** /usage/snapshots | 列出用量快照
*DefaultApi* | [**listWeightRecords**](docs/DefaultApi.md#listweightrecords) | **GET** /weight-records | 列出体重记录
*DefaultApi* | [**preflightImportJob**](docs/DefaultApi.md#preflightimportjob) | **POST** /data-center/import-jobs/{job_id}/preflight | 全量预检 CSV
*DefaultApi* | [**presignMediaUpload**](docs/DefaultApi.md#presignmediaupload) | **POST** /media/uploads/presign | 创建媒体预签名上传
*DefaultApi* | [**previewShare**](docs/DefaultApi.md#previewshare) | **GET** /shares/{share_id}/preview | 预览公开分享
*DefaultApi* | [**previewShareDraft**](docs/DefaultApi.md#previewsharedraft) | **POST** /shares/preview | 创建前预览公开分享
*DefaultApi* | [**publishBreedingPlan**](docs/DefaultApi.md#publishbreedingplanoperation) | **POST** /breeding-plans/{plan_id}/publish | 发布繁育计划
*DefaultApi* | [**recordPairingObservation**](docs/DefaultApi.md#recordpairingobservation) | **POST** /pairing-attempts/{attempt_id}/record-observation | 记录配对观察
*DefaultApi* | [**refreshSession**](docs/DefaultApi.md#refreshsessionoperation) | **POST** /auth/sessions/refresh | 刷新当前会话
*DefaultApi* | [**reopenTask**](docs/DefaultApi.md#reopentask) | **POST** /tasks/{task_id}/reopen | 撤销任务的完成或取消
*DefaultApi* | [**retryBackupJob**](docs/DefaultApi.md#retrybackupjob) | **POST** /data-center/backup-jobs/{job_id}/retry | 重试失败备份
*DefaultApi* | [**retryExportJob**](docs/DefaultApi.md#retryexportjob) | **POST** /data-center/export-jobs/{job_id}/retry | 重试失败导出
*DefaultApi* | [**retryImportJob**](docs/DefaultApi.md#retryimportjob) | **POST** /data-center/import-jobs/{job_id}/retry | 重试失败导入行
*DefaultApi* | [**retryMediaProcessing**](docs/DefaultApi.md#retrymediaprocessing) | **POST** /media/{media_id}/retry-processing | 重试失败的媒体处理
*DefaultApi* | [**revokeShare**](docs/DefaultApi.md#revokeshareoperation) | **POST** /shares/{share_id}/revoke | 撤销公开分享
*DefaultApi* | [**sendVerificationCode**](docs/DefaultApi.md#sendverificationcodeoperation) | **POST** /auth/verification-codes | 发送手机验证码
*DefaultApi* | [**separatePairing**](docs/DefaultApi.md#separatepairingoperation) | **POST** /pairing-attempts/{attempt_id}/separate | 结束配对并完成分笼
*DefaultApi* | [**setImportMapping**](docs/DefaultApi.md#setimportmapping) | **PUT** /data-center/import-jobs/{job_id}/mapping | 设置 CSV 字段映射
*DefaultApi* | [**setMediaCover**](docs/DefaultApi.md#setmediacover) | **PUT** /media/{media_id}/cover | 设置媒体封面
*DefaultApi* | [**sexAndSeparateLitter**](docs/DefaultApi.md#sexandseparatelitter) | **POST** /litters/{litter_id}/sex-and-separate | 分性并分笼
*DefaultApi* | [**startGestationMonitoring**](docs/DefaultApi.md#startgestationmonitoring) | **POST** /breeding-plans/{plan_id}/start-gestation | 从分笼后进入孕期观察
*DefaultApi* | [**startPairing**](docs/DefaultApi.md#startpairingoperation) | **POST** /breeding-plans/{plan_id}/start-pairing | 开始配对
*DefaultApi* | [**updateBreedingPlan**](docs/DefaultApi.md#updatebreedingplan) | **PATCH** /breeding-plans/{plan_id} | 更新繁育计划资料
*DefaultApi* | [**updateCurrentOrganization**](docs/DefaultApi.md#updatecurrentorganization) | **PATCH** /organizations/current | 更新当前熊舍
*DefaultApi* | [**updateEnclosure**](docs/DefaultApi.md#updateenclosure) | **PATCH** /enclosures/{enclosure_id} | 更新笼盒资料
*DefaultApi* | [**updateEnclosureStay**](docs/DefaultApi.md#updateenclosurestay) | **PATCH** /enclosure-stays/{stay_id} | 结束或修正入住事实
*DefaultApi* | [**updateHamster**](docs/DefaultApi.md#updatehamster) | **PATCH** /hamsters/{hamster_id} | 更新仓鼠档案
*DefaultApi* | [**updateHealthRecord**](docs/DefaultApi.md#updatehealthrecord) | **PATCH** /health-records/{health_record_id} | 更新健康记录
*DefaultApi* | [**updateSpeciesRuleVersion**](docs/DefaultApi.md#updatespeciesruleversion) | **PATCH** /species-rule-versions/{rule_version_id} | 更新尚未冻结的规则版本
*DefaultApi* | [**updateTask**](docs/DefaultApi.md#updatetask) | **PATCH** /tasks/{task_id} | 更新任务非状态字段
*DefaultApi* | [**weanLitter**](docs/DefaultApi.md#weanlitteroperation) | **POST** /litters/{litter_id}/wean | 完成断奶
*CustomerApi* | [**cancelCustomerReservation**](docs/CustomerApi.md#cancelcustomerreservation) | **POST** /v1/customer/reservations/{reservation_id}/cancel | 客户取消 held 预订
*CustomerApi* | [**createCustomerSession**](docs/CustomerApi.md#createcustomersessionoperation) | **POST** /v1/public/customer/sessions | 客户验证码登录
*CustomerApi* | [**createCustomerWechatBinding**](docs/CustomerApi.md#createcustomerwechatbindingoperation) | **POST** /v1/public/customer/wechat-bindings | 短信验证并绑定微信身份
*CustomerApi* | [**createCustomerWechatSession**](docs/CustomerApi.md#createcustomerwechatsessionoperation) | **POST** /v1/public/customer/wechat-sessions | 微信 wx.login 静默登录
*CustomerApi* | [**deleteCustomerSession**](docs/CustomerApi.md#deletecustomersession) | **DELETE** /v1/customer/sessions/current | 客户退出当前会话
*CustomerApi* | [**deleteCustomerWechatBinding**](docs/CustomerApi.md#deletecustomerwechatbinding) | **DELETE** /v1/customer/wechat-bindings/current | 解绑当前客户的微信身份
*CustomerApi* | [**getCustomerReservation**](docs/CustomerApi.md#getcustomerreservation) | **GET** /v1/customer/reservations/{reservation_id} | 获取客户预订详情
*CustomerApi* | [**listCustomerReservations**](docs/CustomerApi.md#listcustomerreservations) | **GET** /v1/customer/reservations | 列出当前客户预订
*CustomerApi* | [**sendCustomerVerificationCode**](docs/CustomerApi.md#sendcustomerverificationcodeoperation) | **POST** /v1/public/customer/verification-codes | 客户侧发送登录验证码
*GeneticApi* | [**compareGeneticActual**](docs/GeneticApi.md#comparegeneticactual) | **POST** /v1/genetic/compare-actual | Compare actual litter phenotype counts to core table expectation
*GeneticApi* | [**listGeneticFeedbackSummary**](docs/GeneticApi.md#listgeneticfeedbacksummary) | **GET** /v1/genetic/feedback-summary | Summarize historical phenotype prediction feedback
*GeneticApi* | [**listGeneticPhenotypeCatalog**](docs/GeneticApi.md#listgeneticphenotypecatalog) | **GET** /v1/genetic/phenotype-catalog | List phenotype series catalog from authority table
*GeneticApi* | [**listGeneticTargetCrosses**](docs/GeneticApi.md#listgenetictargetcrosses) | **GET** /v1/genetic/target-crosses | Rank parent pairs that can produce a target phenotype
*GrowthApi* | [**archiveGrowthCampaign**](docs/GrowthApi.md#archivegrowthcampaign) | **POST** /v1/growth/campaigns/{campaign_id}/archive | 归档获客活动
*GrowthApi* | [**generateGrowthCampaign**](docs/GrowthApi.md#generategrowthcampaign) | **POST** /v1/growth/campaigns/generate | 生成并保存视频或直播脚本
*GrowthApi* | [**getGrowthCampaign**](docs/GrowthApi.md#getgrowthcampaign) | **GET** /v1/growth/campaigns/{campaign_id} | 查看获客活动详情
*GrowthApi* | [**listGrowthCampaigns**](docs/GrowthApi.md#listgrowthcampaigns) | **GET** /v1/growth/campaigns | 查看获客活动
*GrowthApi* | [**listGrowthLeads**](docs/GrowthApi.md#listgrowthleads) | **GET** /v1/growth/leads | 查看获客线索及来源归因
*GrowthApi* | [**listGrowthOpportunities**](docs/GrowthApi.md#listgrowthopportunities) | **GET** /v1/growth/opportunities | 查看 AI 内容机会
*GrowthApi* | [**listGrowthPublicHamsters**](docs/GrowthApi.md#listgrowthpublichamsters) | **GET** /v1/growth/public-hamsters | 查看本舍仓鼠公开资料
*GrowthApi* | [**publishGrowthCampaign**](docs/GrowthApi.md#publishgrowthcampaign) | **POST** /v1/growth/campaigns/{campaign_id}/publish | 发布获客活动
*GrowthApi* | [**upsertGrowthPublicHamster**](docs/GrowthApi.md#upsertgrowthpublichamster) | **PUT** /v1/growth/public-hamsters/{hamster_id} | 保存仓鼠公开资料
*P1Api* | [**checkEntitlement**](docs/P1Api.md#checkentitlement) | **POST** /v1/entitlements/check | 检查功能或指标权益
*P1Api* | [**createAccountingCategory**](docs/P1Api.md#createaccountingcategoryoperation) | **POST** /v1/accounting/categories | 创建记账分类
*P1Api* | [**createAccountingRecord**](docs/P1Api.md#createaccountingrecordoperation) | **POST** /v1/accounting/records | 创建记账流水
*P1Api* | [**createContract**](docs/P1Api.md#createcontractoperation) | **POST** /v1/contracts | 创建合同单据
*P1Api* | [**createContractTemplate**](docs/P1Api.md#createcontracttemplate) | **POST** /v1/contracts/templates | 创建合同模板
*P1Api* | [**createGeneticProfile**](docs/P1Api.md#creategeneticprofileoperation) | **POST** /v1/genetic/profiles | 创建遗传档案
*P1Api* | [**createPushMessage**](docs/P1Api.md#createpushmessageoperation) | **POST** /v1/push/messages | 创建推送消息
*P1Api* | [**createReceipt**](docs/P1Api.md#createreceiptoperation) | **POST** /v1/receipts | 创建回执单据
*P1Api* | [**createReceiptTemplate**](docs/P1Api.md#createreceipttemplate) | **POST** /v1/receipts/templates | 创建回执模板
*P1Api* | [**disablePushDevice**](docs/P1Api.md#disablepushdevice) | **DELETE** /v1/push/devices/{device_id} | 停用推送设备
*P1Api* | [**getAccountingSummary**](docs/P1Api.md#getaccountingsummary) | **GET** /v1/accounting/summary | 读取记账汇总
*P1Api* | [**getCurrentEntitlement**](docs/P1Api.md#getcurrententitlement) | **GET** /v1/entitlements/current | 读取当前权益快照
*P1Api* | [**getEntitlementCatalog**](docs/P1Api.md#getentitlementcatalog) | **GET** /v1/entitlements/catalog | 读取权益套餐目录
*P1Api* | [**inviteOrganizationMember**](docs/P1Api.md#inviteorganizationmemberoperation) | **POST** /v1/organization-members | 邀请熊舍成员
*P1Api* | [**issueContract**](docs/P1Api.md#issuecontract) | **POST** /v1/contracts/{document_id}/issue | 签发合同
*P1Api* | [**issueReceipt**](docs/P1Api.md#issuereceipt) | **POST** /v1/receipts/{document_id}/issue | 签发回执
*P1Api* | [**listAccountingCategories**](docs/P1Api.md#listaccountingcategories) | **GET** /v1/accounting/categories | 列出记账分类
*P1Api* | [**listAccountingRecords**](docs/P1Api.md#listaccountingrecords) | **GET** /v1/accounting/records | 列出记账流水
*P1Api* | [**listContractTemplates**](docs/P1Api.md#listcontracttemplates) | **GET** /v1/contracts/templates | 列出合同模板
*P1Api* | [**listContracts**](docs/P1Api.md#listcontracts) | **GET** /v1/contracts | 列出合同单据
*P1Api* | [**listGeneticLoci**](docs/P1Api.md#listgeneticloci) | **GET** /v1/genetic/loci | 列出遗传位点
*P1Api* | [**listGeneticProfiles**](docs/P1Api.md#listgeneticprofiles) | **GET** /v1/genetic/profiles | 列出遗传档案
*P1Api* | [**listOrganizationMembers**](docs/P1Api.md#listorganizationmembers) | **GET** /v1/organization-members | 列出熊舍成员
*P1Api* | [**listPushDevices**](docs/P1Api.md#listpushdevices) | **GET** /v1/push/devices | 列出推送设备
*P1Api* | [**listPushMessages**](docs/P1Api.md#listpushmessages) | **GET** /v1/push/messages | 列出推送消息
*P1Api* | [**listReceiptTemplates**](docs/P1Api.md#listreceipttemplates) | **GET** /v1/receipts/templates | 列出回执模板
*P1Api* | [**listReceipts**](docs/P1Api.md#listreceipts) | **GET** /v1/receipts | 列出回执单据
*P1Api* | [**revokeContract**](docs/P1Api.md#revokecontract) | **POST** /v1/contracts/{document_id}/revoke | 撤销合同
*P1Api* | [**revokeOrganizationMember**](docs/P1Api.md#revokeorganizationmember) | **POST** /v1/organization-members/{member_id}/revoke | 撤销熊舍成员
*P1Api* | [**revokeReceipt**](docs/P1Api.md#revokereceipt) | **POST** /v1/receipts/{document_id}/revoke | 撤销回执
*P1Api* | [**sandboxActivatePlan**](docs/P1Api.md#sandboxactivateplanoperation) | **POST** /v1/entitlements/sandbox/activate | 沙箱激活权益套餐
*P1Api* | [**simulateGeneticBreeding**](docs/P1Api.md#simulategeneticbreeding) | **POST** /v1/genetic/simulate | 模拟遗传配对
*P1Api* | [**updateOrganizationMember**](docs/P1Api.md#updateorganizationmemberoperation) | **PATCH** /v1/organization-members/{member_id} | 更新熊舍成员
*P1Api* | [**upsertPushDevice**](docs/P1Api.md#upsertpushdeviceoperation) | **PUT** /v1/push/devices | 登记推送设备
*P1CRMApi* | [**cancelCrmReservation**](docs/P1CRMApi.md#cancelcrmreservation) | **POST** /v1/crm/reservations/{reservation_id}/cancel | 取消客户预订
*P1CRMApi* | [**completeCrmHandover**](docs/P1CRMApi.md#completecrmhandover) | **POST** /v1/crm/handovers/{handover_id}/complete | 完成客户交付
*P1CRMApi* | [**confirmCrmReservation**](docs/P1CRMApi.md#confirmcrmreservation) | **POST** /v1/crm/reservations/{reservation_id}/confirm | 确认客户预订
*P1CRMApi* | [**createCrmContact**](docs/P1CRMApi.md#createcrmcontactoperation) | **POST** /v1/crm/contacts | 创建 CRM 客户
*P1CRMApi* | [**createCrmHandover**](docs/P1CRMApi.md#createcrmhandoveroperation) | **POST** /v1/crm/handovers | 创建交付记录
*P1CRMApi* | [**createCrmReservation**](docs/P1CRMApi.md#createcrmreservationoperation) | **POST** /v1/crm/reservations | 创建客户预订
*P1CRMApi* | [**listCrmContacts**](docs/P1CRMApi.md#listcrmcontacts) | **GET** /v1/crm/contacts | 列出 CRM 客户
*P1CRMApi* | [**listCrmHandovers**](docs/P1CRMApi.md#listcrmhandovers) | **GET** /v1/crm/handovers | 列出交付记录
*P1CRMApi* | [**listCrmReservations**](docs/P1CRMApi.md#listcrmreservations) | **GET** /v1/crm/reservations | 列出客户预订
*P2Api* | [**askAssistant**](docs/P2Api.md#askassistant) | **POST** /v1/assistant/ask | 向只读助手提问
*P2Api* | [**assistantCapabilities**](docs/P2Api.md#assistantcapabilities) | **GET** /v1/assistant/capabilities | 读取助手能力
*P2Api* | [**auditMiniprogramRelease**](docs/P2Api.md#auditminiprogramreleaseoperation) | **POST** /v1/miniprogram/releases/{release_id}/audit | 审核小程序版本
*P2Api* | [**cancelAssistantAction**](docs/P2Api.md#cancelassistantaction) | **POST** /v1/assistant/actions/{action_id}/cancel | 取消助手动作
*P2Api* | [**cancelStudDeal**](docs/P2Api.md#cancelstuddeal) | **POST** /v1/stud/deals/{deal_id}/cancel | 取消跨舍借配单
*P2Api* | [**chatAssistant**](docs/P2Api.md#chatassistant) | **POST** /v1/assistant/chat | 通用多轮对话
*P2Api* | [**completeStudDeal**](docs/P2Api.md#completestuddeal) | **POST** /v1/stud/deals/{deal_id}/complete | 完成跨舍借配单
*P2Api* | [**confirmAssistantAction**](docs/P2Api.md#confirmassistantaction) | **POST** /v1/assistant/actions/{action_id}/confirm | 确认并执行助手动作
*P2Api* | [**confirmStudDeal**](docs/P2Api.md#confirmstuddeal) | **POST** /v1/stud/deals/{deal_id}/confirm | 确认跨舍借配单
*P2Api* | [**createAssistantSession**](docs/P2Api.md#createassistantsession) | **POST** /v1/assistant/sessions | 创建会话
*P2Api* | [**createMiniprogramRelease**](docs/P2Api.md#createminiprogramreleaseoperation) | **POST** /v1/miniprogram/releases | 创建小程序版本
*P2Api* | [**createStudDeal**](docs/P2Api.md#createstuddealoperation) | **POST** /v1/stud/deals | 创建跨舍借配单
*P2Api* | [**createStudListing**](docs/P2Api.md#createstudlistingoperation) | **POST** /v1/stud/listings | 创建种公借配挂牌
*P2Api* | [**getMiniprogramConfig**](docs/P2Api.md#getminiprogramconfig) | **GET** /v1/miniprogram/config | 读取小程序配置
*P2Api* | [**getOwnerPublicSite**](docs/P2Api.md#getownerpublicsite) | **GET** /v1/public-site | 读取熊舍公开主页草稿
*P2Api* | [**getPublicSiteBySlug**](docs/P2Api.md#getpublicsitebyslug) | **GET** /v1/public/sites/{slug} | 读取公开主页投影
*P2Api* | [**listAssistantMessages**](docs/P2Api.md#listassistantmessages) | **GET** /v1/assistant/sessions/{session_id}/messages | 列出会话消息
*P2Api* | [**listAssistantSessions**](docs/P2Api.md#listassistantsessions) | **GET** /v1/assistant/sessions | 列出会话
*P2Api* | [**listMiniprogramReleases**](docs/P2Api.md#listminiprogramreleases) | **GET** /v1/miniprogram/releases | 列出小程序版本
*P2Api* | [**listStudDeals**](docs/P2Api.md#liststuddeals) | **GET** /v1/stud/deals | 列出跨舍借配单
*P2Api* | [**listStudListings**](docs/P2Api.md#liststudlistings) | **GET** /v1/stud/listings | 列出种公借配挂牌
*P2Api* | [**publishMiniprogramRelease**](docs/P2Api.md#publishminiprogramrelease) | **POST** /v1/miniprogram/releases/{release_id}/publish | 发布小程序版本
*P2Api* | [**publishOwnerPublicSite**](docs/P2Api.md#publishownerpublicsite) | **POST** /v1/public-site/publish | 发布熊舍公开主页
*P2Api* | [**rollbackMiniprogramRelease**](docs/P2Api.md#rollbackminiprogramrelease) | **POST** /v1/miniprogram/releases/{release_id}/rollback | 回滚小程序版本
*P2Api* | [**startStudDeal**](docs/P2Api.md#startstuddeal) | **POST** /v1/stud/deals/{deal_id}/start | 开始跨舍借配单
*P2Api* | [**submitMiniprogramRelease**](docs/P2Api.md#submitminiprogramrelease) | **POST** /v1/miniprogram/releases/{release_id}/submit | 提交小程序审核
*P2Api* | [**unpublishOwnerPublicSite**](docs/P2Api.md#unpublishownerpublicsite) | **POST** /v1/public-site/unpublish | 撤下熊舍公开主页
*P2Api* | [**unpublishStudListing**](docs/P2Api.md#unpublishstudlisting) | **POST** /v1/stud/listings/{listing_id}/unpublish | 撤下种公挂牌
*P2Api* | [**upsertMiniprogramConfig**](docs/P2Api.md#upsertminiprogramconfigoperation) | **PUT** /v1/miniprogram/config | 保存小程序配置
*P2Api* | [**upsertOwnerPublicSite**](docs/P2Api.md#upsertownerpublicsite) | **PUT** /v1/public-site | 保存熊舍公开主页
*PublicDocumentsApi* | [**getPublicDocument**](docs/PublicDocumentsApi.md#getpublicdocument) | **GET** /v1/public/documents/{token} | 客户只读查看已签发合同/回执
*PublicGrowthApi* | [**consultPublicGrowthAdvisor**](docs/PublicGrowthApi.md#consultpublicgrowthadvisor) | **POST** /v1/public/sites/{slug}/consult | 向公开 AI 顾问咨询
*PublicGrowthApi* | [**createPublicGrowthLead**](docs/PublicGrowthApi.md#createpublicgrowthlead) | **POST** /v1/public/sites/{slug}/leads | 提交公开咨询线索
*PublicGrowthApi* | [**createPublicGrowthReservation**](docs/PublicGrowthApi.md#createpublicgrowthreservation) | **POST** /v1/public/sites/{slug}/reservations | 客户提交公开仓鼠预订
*PublicGrowthApi* | [**getPublicGrowthCatalog**](docs/PublicGrowthApi.md#getpublicgrowthcatalog) | **GET** /v1/public/sites/{slug}/catalog | 查看公开熊舍获客目录
*PublicGrowthApi* | [**getPublicGrowthMedia**](docs/PublicGrowthApi.md#getpublicgrowthmedia) | **GET** /v1/public/sites/{slug}/media/{media_id} | 读取公开仓鼠封面图片
*PublicGrowthApi* | [**getPublicSiteHamsterPedigree**](docs/PublicGrowthApi.md#getpublicsitehamsterpedigree) | **GET** /v1/public/sites/{slug}/hamsters/{hamster_id}/pedigree | 公开仓鼠血统（仅已发布档案名称）
*PublicGrowthApi* | [**postPublicSiteSimulate**](docs/PublicGrowthApi.md#postpublicsitesimulateoperation) | **POST** /v1/public/sites/{slug}/simulate | 公开繁育模拟（权威表型表）


### Models

- [Account](docs/Account.md)
- [AccountingCategory](docs/AccountingCategory.md)
- [AccountingCategoryListResponse](docs/AccountingCategoryListResponse.md)
- [AccountingCategoryResponse](docs/AccountingCategoryResponse.md)
- [AccountingCategorySummary](docs/AccountingCategorySummary.md)
- [AccountingRecord](docs/AccountingRecord.md)
- [AccountingRecordListResponse](docs/AccountingRecordListResponse.md)
- [AccountingRecordResponse](docs/AccountingRecordResponse.md)
- [AccountingSummary](docs/AccountingSummary.md)
- [AccountingSummaryResponse](docs/AccountingSummaryResponse.md)
- [ActionItemResult](docs/ActionItemResult.md)
- [AdjustBaselineRequest](docs/AdjustBaselineRequest.md)
- [AdjustBaselineResponse](docs/AdjustBaselineResponse.md)
- [AdjustBaselineResponseData](docs/AdjustBaselineResponseData.md)
- [AdjustLitterCountRequest](docs/AdjustLitterCountRequest.md)
- [AdjustLitterCountResponse](docs/AdjustLitterCountResponse.md)
- [AdjustLitterCountResponseData](docs/AdjustLitterCountResponseData.md)
- [AssistantActionCancelResponse](docs/AssistantActionCancelResponse.md)
- [AssistantActionCancelResult](docs/AssistantActionCancelResult.md)
- [AssistantActionConfirmResponse](docs/AssistantActionConfirmResponse.md)
- [AssistantActionConfirmResult](docs/AssistantActionConfirmResult.md)
- [AssistantAnswer](docs/AssistantAnswer.md)
- [AssistantAnswerResponse](docs/AssistantAnswerResponse.md)
- [AssistantAskRequest](docs/AssistantAskRequest.md)
- [AssistantCapabilities](docs/AssistantCapabilities.md)
- [AssistantCapabilitiesResponse](docs/AssistantCapabilitiesResponse.md)
- [AssistantChatAction](docs/AssistantChatAction.md)
- [AssistantChatRequest](docs/AssistantChatRequest.md)
- [AssistantChatResponse](docs/AssistantChatResponse.md)
- [AssistantChatResult](docs/AssistantChatResult.md)
- [AssistantFact](docs/AssistantFact.md)
- [AssistantMessage](docs/AssistantMessage.md)
- [AssistantMessageListResponse](docs/AssistantMessageListResponse.md)
- [AssistantSession](docs/AssistantSession.md)
- [AssistantSessionCreateRequest](docs/AssistantSessionCreateRequest.md)
- [AssistantSessionListResponse](docs/AssistantSessionListResponse.md)
- [AssistantSessionResponse](docs/AssistantSessionResponse.md)
- [AsyncJob](docs/AsyncJob.md)
- [AsyncJobResponse](docs/AsyncJobResponse.md)
- [AuditMiniprogramReleaseRequest](docs/AuditMiniprogramReleaseRequest.md)
- [BackupJob](docs/BackupJob.md)
- [BackupJobCreateRequest](docs/BackupJobCreateRequest.md)
- [BackupJobListResponse](docs/BackupJobListResponse.md)
- [BackupJobResponse](docs/BackupJobResponse.md)
- [BatchItemStatus](docs/BatchItemStatus.md)
- [BatchTransactionStatus](docs/BatchTransactionStatus.md)
- [BreedingPlan](docs/BreedingPlan.md)
- [BreedingPlanCreateRequest](docs/BreedingPlanCreateRequest.md)
- [BreedingPlanListResponse](docs/BreedingPlanListResponse.md)
- [BreedingPlanResponse](docs/BreedingPlanResponse.md)
- [BreedingPlanState](docs/BreedingPlanState.md)
- [BreedingPlanUpdateRequest](docs/BreedingPlanUpdateRequest.md)
- [CareTask](docs/CareTask.md)
- [CareTaskCreateRequest](docs/CareTaskCreateRequest.md)
- [CareTaskListResponse](docs/CareTaskListResponse.md)
- [CareTaskResponse](docs/CareTaskResponse.md)
- [CareTaskUpdateRequest](docs/CareTaskUpdateRequest.md)
- [CleanlinessState](docs/CleanlinessState.md)
- [CompleteBreedingPlanRequest](docs/CompleteBreedingPlanRequest.md)
- [CompleteBreedingPlanResponse](docs/CompleteBreedingPlanResponse.md)
- [CompleteBreedingPlanResponseData](docs/CompleteBreedingPlanResponseData.md)
- [CompleteTaskRequest](docs/CompleteTaskRequest.md)
- [CompleteTaskRequestSubjectResultsInner](docs/CompleteTaskRequestSubjectResultsInner.md)
- [CompleteTaskResponse](docs/CompleteTaskResponse.md)
- [CompleteTaskResponseData](docs/CompleteTaskResponseData.md)
- [CompleteTaskResponseDataItemResultsInner](docs/CompleteTaskResponseDataItemResultsInner.md)
- [ConfirmBirthLiveLitterData](docs/ConfirmBirthLiveLitterData.md)
- [ConfirmBirthNoLitterData](docs/ConfirmBirthNoLitterData.md)
- [ConfirmBirthRequest](docs/ConfirmBirthRequest.md)
- [ConfirmBirthResponse](docs/ConfirmBirthResponse.md)
- [ConfirmBirthResponseData](docs/ConfirmBirthResponseData.md)
- [CreateAccountingCategoryRequest](docs/CreateAccountingCategoryRequest.md)
- [CreateAccountingRecordRequest](docs/CreateAccountingRecordRequest.md)
- [CreateContractRequest](docs/CreateContractRequest.md)
- [CreateCrmContactRequest](docs/CreateCrmContactRequest.md)
- [CreateCrmHandoverRequest](docs/CreateCrmHandoverRequest.md)
- [CreateCrmReservationRequest](docs/CreateCrmReservationRequest.md)
- [CreateCustomerSessionRequest](docs/CreateCustomerSessionRequest.md)
- [CreateCustomerWechatBindingRequest](docs/CreateCustomerWechatBindingRequest.md)
- [CreateCustomerWechatSessionRequest](docs/CreateCustomerWechatSessionRequest.md)
- [CreateDocumentTemplateRequest](docs/CreateDocumentTemplateRequest.md)
- [CreateGeneticProfileRequest](docs/CreateGeneticProfileRequest.md)
- [CreateMiniprogramReleaseRequest](docs/CreateMiniprogramReleaseRequest.md)
- [CreatePushMessageRequest](docs/CreatePushMessageRequest.md)
- [CreateReceiptRequest](docs/CreateReceiptRequest.md)
- [CreateStudDealRequest](docs/CreateStudDealRequest.md)
- [CreateStudListingRequest](docs/CreateStudListingRequest.md)
- [CrmContact](docs/CrmContact.md)
- [CrmContactListResponse](docs/CrmContactListResponse.md)
- [CrmContactResponse](docs/CrmContactResponse.md)
- [CrmHandover](docs/CrmHandover.md)
- [CrmHandoverListResponse](docs/CrmHandoverListResponse.md)
- [CrmHandoverResponse](docs/CrmHandoverResponse.md)
- [CrmReservation](docs/CrmReservation.md)
- [CrmReservationListResponse](docs/CrmReservationListResponse.md)
- [CrmReservationResponse](docs/CrmReservationResponse.md)
- [CurrentAccountResponse](docs/CurrentAccountResponse.md)
- [CurrentAccountResponseData](docs/CurrentAccountResponseData.md)
- [CustomerReservation](docs/CustomerReservation.md)
- [CustomerReservationDocumentsInner](docs/CustomerReservationDocumentsInner.md)
- [CustomerReservationHamster](docs/CustomerReservationHamster.md)
- [CustomerReservationListResponse](docs/CustomerReservationListResponse.md)
- [CustomerReservationResponse](docs/CustomerReservationResponse.md)
- [CustomerSessionResponse](docs/CustomerSessionResponse.md)
- [CustomerSessionResponseData](docs/CustomerSessionResponseData.md)
- [CustomerVerificationCodeResponse](docs/CustomerVerificationCodeResponse.md)
- [CustomerVerificationCodeResponseData](docs/CustomerVerificationCodeResponseData.md)
- [CustomerWechatBindTicketResponse](docs/CustomerWechatBindTicketResponse.md)
- [CustomerWechatBindTicketResponseData](docs/CustomerWechatBindTicketResponseData.md)
- [DamCondition](docs/DamCondition.md)
- [DataCenterSummaryResponse](docs/DataCenterSummaryResponse.md)
- [DataCenterSummaryResponseData](docs/DataCenterSummaryResponseData.md)
- [DeviceInfo](docs/DeviceInfo.md)
- [Document](docs/Document.md)
- [DocumentListResponse](docs/DocumentListResponse.md)
- [DocumentResponse](docs/DocumentResponse.md)
- [DocumentTemplate](docs/DocumentTemplate.md)
- [DocumentTemplateListResponse](docs/DocumentTemplateListResponse.md)
- [DocumentTemplateResponse](docs/DocumentTemplateResponse.md)
- [DownloadLinkResponse](docs/DownloadLinkResponse.md)
- [DownloadLinkResponseData](docs/DownloadLinkResponseData.md)
- [Enclosure](docs/Enclosure.md)
- [EnclosureCleaning](docs/EnclosureCleaning.md)
- [EnclosureCleaningCreateRequest](docs/EnclosureCleaningCreateRequest.md)
- [EnclosureCleaningListResponse](docs/EnclosureCleaningListResponse.md)
- [EnclosureCleaningResponse](docs/EnclosureCleaningResponse.md)
- [EnclosureCleaningType](docs/EnclosureCleaningType.md)
- [EnclosureCreateRequest](docs/EnclosureCreateRequest.md)
- [EnclosureDimensions](docs/EnclosureDimensions.md)
- [EnclosureListResponse](docs/EnclosureListResponse.md)
- [EnclosureResponse](docs/EnclosureResponse.md)
- [EnclosureState](docs/EnclosureState.md)
- [EnclosureStay](docs/EnclosureStay.md)
- [EnclosureStayCreateRequest](docs/EnclosureStayCreateRequest.md)
- [EnclosureStayListResponse](docs/EnclosureStayListResponse.md)
- [EnclosureStayResponse](docs/EnclosureStayResponse.md)
- [EnclosureStayUpdateRequest](docs/EnclosureStayUpdateRequest.md)
- [EnclosureUpdateRequest](docs/EnclosureUpdateRequest.md)
- [EntitlementCatalogResponse](docs/EntitlementCatalogResponse.md)
- [EntitlementCheckRequest](docs/EntitlementCheckRequest.md)
- [EntitlementCheckResponse](docs/EntitlementCheckResponse.md)
- [EntitlementCheckResult](docs/EntitlementCheckResult.md)
- [EntitlementFeature](docs/EntitlementFeature.md)
- [EntitlementLimit](docs/EntitlementLimit.md)
- [EntitlementSnapshot](docs/EntitlementSnapshot.md)
- [EntitlementSnapshotResponse](docs/EntitlementSnapshotResponse.md)
- [ErrorObject](docs/ErrorObject.md)
- [ErrorResponse](docs/ErrorResponse.md)
- [ExportJob](docs/ExportJob.md)
- [ExportJobCreateRequest](docs/ExportJobCreateRequest.md)
- [ExportJobListResponse](docs/ExportJobListResponse.md)
- [ExportJobResponse](docs/ExportJobResponse.md)
- [FieldError](docs/FieldError.md)
- [GeneticLocus](docs/GeneticLocus.md)
- [GeneticLocusListResponse](docs/GeneticLocusListResponse.md)
- [GeneticOutcome](docs/GeneticOutcome.md)
- [GeneticProfile](docs/GeneticProfile.md)
- [GeneticProfileListResponse](docs/GeneticProfileListResponse.md)
- [GeneticProfileResponse](docs/GeneticProfileResponse.md)
- [GeneticSimulationRequest](docs/GeneticSimulationRequest.md)
- [GeneticSimulationResponse](docs/GeneticSimulationResponse.md)
- [GeneticSimulationResult](docs/GeneticSimulationResult.md)
- [GrowthCampaign](docs/GrowthCampaign.md)
- [GrowthCampaignGenerateRequest](docs/GrowthCampaignGenerateRequest.md)
- [GrowthCampaignListResponse](docs/GrowthCampaignListResponse.md)
- [GrowthCampaignResponse](docs/GrowthCampaignResponse.md)
- [GrowthLead](docs/GrowthLead.md)
- [GrowthLeadListResponse](docs/GrowthLeadListResponse.md)
- [GrowthOpportunity](docs/GrowthOpportunity.md)
- [GrowthOpportunityListResponse](docs/GrowthOpportunityListResponse.md)
- [GrowthPublicFact](docs/GrowthPublicFact.md)
- [GrowthPublicHamster](docs/GrowthPublicHamster.md)
- [GrowthPublicHamsterListResponse](docs/GrowthPublicHamsterListResponse.md)
- [GrowthPublicHamsterRequest](docs/GrowthPublicHamsterRequest.md)
- [GrowthPublicHamsterResponse](docs/GrowthPublicHamsterResponse.md)
- [GrowthPublicMedia](docs/GrowthPublicMedia.md)
- [GrowthScript](docs/GrowthScript.md)
- [GrowthScriptSection](docs/GrowthScriptSection.md)
- [Hamster](docs/Hamster.md)
- [HamsterBatchCreateRequest](docs/HamsterBatchCreateRequest.md)
- [HamsterBatchCreateRequestItemsInner](docs/HamsterBatchCreateRequestItemsInner.md)
- [HamsterBatchCreateResponse](docs/HamsterBatchCreateResponse.md)
- [HamsterBatchCreateResponseData](docs/HamsterBatchCreateResponseData.md)
- [HamsterBatchCreateResponseDataItemsInner](docs/HamsterBatchCreateResponseDataItemsInner.md)
- [HamsterBreedingStatus](docs/HamsterBreedingStatus.md)
- [HamsterCreateRequest](docs/HamsterCreateRequest.md)
- [HamsterLifecycleStatus](docs/HamsterLifecycleStatus.md)
- [HamsterListResponse](docs/HamsterListResponse.md)
- [HamsterResponse](docs/HamsterResponse.md)
- [HamsterSourceType](docs/HamsterSourceType.md)
- [HamsterUpdateRequest](docs/HamsterUpdateRequest.md)
- [HealthRecord](docs/HealthRecord.md)
- [HealthRecordCreateRequest](docs/HealthRecordCreateRequest.md)
- [HealthRecordListResponse](docs/HealthRecordListResponse.md)
- [HealthRecordResponse](docs/HealthRecordResponse.md)
- [HealthRecordType](docs/HealthRecordType.md)
- [HealthRecordUpdateRequest](docs/HealthRecordUpdateRequest.md)
- [ImportCommitRequest](docs/ImportCommitRequest.md)
- [ImportCommitRequestApprovedUpdatesInner](docs/ImportCommitRequestApprovedUpdatesInner.md)
- [ImportIssue](docs/ImportIssue.md)
- [ImportJob](docs/ImportJob.md)
- [ImportJobCreateRequest](docs/ImportJobCreateRequest.md)
- [ImportJobListResponse](docs/ImportJobListResponse.md)
- [ImportJobResponse](docs/ImportJobResponse.md)
- [ImportMappingRequest](docs/ImportMappingRequest.md)
- [ImportMappingRequestMappingsInner](docs/ImportMappingRequestMappingsInner.md)
- [ImportPreflightRequest](docs/ImportPreflightRequest.md)
- [ImportRowResult](docs/ImportRowResult.md)
- [ImportRowResultListResponse](docs/ImportRowResultListResponse.md)
- [ImportRowStatus](docs/ImportRowStatus.md)
- [ImportTemplateResponse](docs/ImportTemplateResponse.md)
- [ImportTemplateResponseData](docs/ImportTemplateResponseData.md)
- [ImportTemplateResponseDataColumnsInner](docs/ImportTemplateResponseDataColumnsInner.md)
- [ImportTemplateResponseDataColumnsInnerExample](docs/ImportTemplateResponseDataColumnsInnerExample.md)
- [ImportTemplateType](docs/ImportTemplateType.md)
- [ImportUploadCreateRequest](docs/ImportUploadCreateRequest.md)
- [ImportUploadResponse](docs/ImportUploadResponse.md)
- [IndividualizationEligibility](docs/IndividualizationEligibility.md)
- [IndividualizationEligibilityBlocker](docs/IndividualizationEligibilityBlocker.md)
- [IndividualizationEligibilityResponse](docs/IndividualizationEligibilityResponse.md)
- [IndividualizeLitterRequest](docs/IndividualizeLitterRequest.md)
- [IndividualizeLitterRequestItemsInner](docs/IndividualizeLitterRequestItemsInner.md)
- [IndividualizeLitterResponse](docs/IndividualizeLitterResponse.md)
- [IndividualizeLitterResponseData](docs/IndividualizeLitterResponseData.md)
- [IndividualizeMapping](docs/IndividualizeMapping.md)
- [InviteOrganizationMemberRequest](docs/InviteOrganizationMemberRequest.md)
- [JobStatus](docs/JobStatus.md)
- [KinshipCheck](docs/KinshipCheck.md)
- [Litter](docs/Litter.md)
- [LitterCountEvent](docs/LitterCountEvent.md)
- [LitterListResponse](docs/LitterListResponse.md)
- [LitterMember](docs/LitterMember.md)
- [LitterMemberListResponse](docs/LitterMemberListResponse.md)
- [LitterMemberOneOf](docs/LitterMemberOneOf.md)
- [LitterMemberOneOf1](docs/LitterMemberOneOf1.md)
- [LitterParent](docs/LitterParent.md)
- [LitterParentCreateRequest](docs/LitterParentCreateRequest.md)
- [LitterParentListResponse](docs/LitterParentListResponse.md)
- [LitterParentResponse](docs/LitterParentResponse.md)
- [LitterResponse](docs/LitterResponse.md)
- [LitterResponseData](docs/LitterResponseData.md)
- [LitterState](docs/LitterState.md)
- [MatingObservation](docs/MatingObservation.md)
- [MediaAsset](docs/MediaAsset.md)
- [MediaAssetResponse](docs/MediaAssetResponse.md)
- [MediaCoverRequest](docs/MediaCoverRequest.md)
- [MediaEditRecipeRequest](docs/MediaEditRecipeRequest.md)
- [MediaEditRecipeRequestOperationsInner](docs/MediaEditRecipeRequestOperationsInner.md)
- [MediaEditRecipeResponse](docs/MediaEditRecipeResponse.md)
- [MediaEditRecipeResponseData](docs/MediaEditRecipeResponseData.md)
- [MediaProcessingRetryRequest](docs/MediaProcessingRetryRequest.md)
- [MediaProcessingRetryResponse](docs/MediaProcessingRetryResponse.md)
- [MediaProcessingRetryResponseData](docs/MediaProcessingRetryResponseData.md)
- [MediaUploadCompleteRequest](docs/MediaUploadCompleteRequest.md)
- [MediaUploadCompleteResponse](docs/MediaUploadCompleteResponse.md)
- [MediaUploadCompleteResponseData](docs/MediaUploadCompleteResponseData.md)
- [MediaUploadPresignRequest](docs/MediaUploadPresignRequest.md)
- [MediaUploadPresignResponse](docs/MediaUploadPresignResponse.md)
- [MediaVariant](docs/MediaVariant.md)
- [MiniprogramConfig](docs/MiniprogramConfig.md)
- [MiniprogramConfigResponse](docs/MiniprogramConfigResponse.md)
- [MiniprogramRelease](docs/MiniprogramRelease.md)
- [MiniprogramReleaseListResponse](docs/MiniprogramReleaseListResponse.md)
- [MiniprogramReleaseResponse](docs/MiniprogramReleaseResponse.md)
- [ObservationType](docs/ObservationType.md)
- [Organization](docs/Organization.md)
- [OrganizationMember](docs/OrganizationMember.md)
- [OrganizationMemberListResponse](docs/OrganizationMemberListResponse.md)
- [OrganizationMemberResponse](docs/OrganizationMemberResponse.md)
- [OrganizationResponse](docs/OrganizationResponse.md)
- [OrganizationUpdateRequest](docs/OrganizationUpdateRequest.md)
- [PageInfo](docs/PageInfo.md)
- [PairingAttempt](docs/PairingAttempt.md)
- [PairingAttemptListResponse](docs/PairingAttemptListResponse.md)
- [PairingAttemptResponse](docs/PairingAttemptResponse.md)
- [PairingAttemptStatus](docs/PairingAttemptStatus.md)
- [PairingResult](docs/PairingResult.md)
- [PedigreeGraphResponse](docs/PedigreeGraphResponse.md)
- [PedigreeGraphResponseData](docs/PedigreeGraphResponseData.md)
- [PedigreeGraphResponseDataCommonAncestorsInner](docs/PedigreeGraphResponseDataCommonAncestorsInner.md)
- [PedigreeParentage](docs/PedigreeParentage.md)
- [PedigreeParentageCreateRequest](docs/PedigreeParentageCreateRequest.md)
- [PedigreeParentageEndRequest](docs/PedigreeParentageEndRequest.md)
- [PedigreeParentageListResponse](docs/PedigreeParentageListResponse.md)
- [PedigreeParentageResponse](docs/PedigreeParentageResponse.md)
- [PhenotypeTableOutcome](docs/PhenotypeTableOutcome.md)
- [PhoneCodeLoginRequest](docs/PhoneCodeLoginRequest.md)
- [PlanCatalogEntry](docs/PlanCatalogEntry.md)
- [PostPublicSiteSimulateRequest](docs/PostPublicSiteSimulateRequest.md)
- [PublicDocumentResponse](docs/PublicDocumentResponse.md)
- [PublicDocumentResponseData](docs/PublicDocumentResponseData.md)
- [PublicGrowthCatalog](docs/PublicGrowthCatalog.md)
- [PublicGrowthCatalogResponse](docs/PublicGrowthCatalogResponse.md)
- [PublicGrowthConsultRequest](docs/PublicGrowthConsultRequest.md)
- [PublicGrowthConsultResponse](docs/PublicGrowthConsultResponse.md)
- [PublicGrowthConsultResponseData](docs/PublicGrowthConsultResponseData.md)
- [PublicGrowthLeadRequest](docs/PublicGrowthLeadRequest.md)
- [PublicGrowthLeadResponse](docs/PublicGrowthLeadResponse.md)
- [PublicGrowthReservationRequest](docs/PublicGrowthReservationRequest.md)
- [PublicGrowthReservationResponse](docs/PublicGrowthReservationResponse.md)
- [PublicGrowthReservationResponseData](docs/PublicGrowthReservationResponseData.md)
- [PublicShareResponse](docs/PublicShareResponse.md)
- [PublicShareResponseData](docs/PublicShareResponseData.md)
- [PublicSite](docs/PublicSite.md)
- [PublicSiteResponse](docs/PublicSiteResponse.md)
- [PublicSiteView](docs/PublicSiteView.md)
- [PublicSiteViewResponse](docs/PublicSiteViewResponse.md)
- [PublishBreedingPlanRequest](docs/PublishBreedingPlanRequest.md)
- [PublishBreedingPlanResponse](docs/PublishBreedingPlanResponse.md)
- [PublishBreedingPlanResponseData](docs/PublishBreedingPlanResponseData.md)
- [PupIdentity](docs/PupIdentity.md)
- [PupIdentityListResponse](docs/PupIdentityListResponse.md)
- [PupOutcomeStatus](docs/PupOutcomeStatus.md)
- [PupProfileStatus](docs/PupProfileStatus.md)
- [PushDevice](docs/PushDevice.md)
- [PushDeviceListResponse](docs/PushDeviceListResponse.md)
- [PushDeviceResponse](docs/PushDeviceResponse.md)
- [PushMessage](docs/PushMessage.md)
- [PushMessageListResponse](docs/PushMessageListResponse.md)
- [PushMessageResponse](docs/PushMessageResponse.md)
- [Reconciliation](docs/Reconciliation.md)
- [RecordObservationRequest](docs/RecordObservationRequest.md)
- [RecordObservationResponse](docs/RecordObservationResponse.md)
- [RecordObservationResponseData](docs/RecordObservationResponseData.md)
- [RecoveryAction](docs/RecoveryAction.md)
- [RefreshSessionRequest](docs/RefreshSessionRequest.md)
- [Reminder](docs/Reminder.md)
- [ReminderDelivery](docs/ReminderDelivery.md)
- [ReminderListResponse](docs/ReminderListResponse.md)
- [ReminderResponse](docs/ReminderResponse.md)
- [ReminderState](docs/ReminderState.md)
- [ResponseMeta](docs/ResponseMeta.md)
- [RetryImportRequest](docs/RetryImportRequest.md)
- [RetryJobRequest](docs/RetryJobRequest.md)
- [RevokeShareRequest](docs/RevokeShareRequest.md)
- [SandboxActivatePlanRequest](docs/SandboxActivatePlanRequest.md)
- [SendCustomerVerificationCodeRequest](docs/SendCustomerVerificationCodeRequest.md)
- [SendVerificationCodeRequest](docs/SendVerificationCodeRequest.md)
- [SeparatePairingRequest](docs/SeparatePairingRequest.md)
- [SeparatePairingResponse](docs/SeparatePairingResponse.md)
- [SeparatePairingResponseData](docs/SeparatePairingResponseData.md)
- [SessionResponse](docs/SessionResponse.md)
- [SessionResponseData](docs/SessionResponseData.md)
- [Severity](docs/Severity.md)
- [Sex](docs/Sex.md)
- [SexAndSeparateRequest](docs/SexAndSeparateRequest.md)
- [SexAndSeparateRequestItemsInner](docs/SexAndSeparateRequestItemsInner.md)
- [SexAndSeparateResponse](docs/SexAndSeparateResponse.md)
- [SexAndSeparateResponseData](docs/SexAndSeparateResponseData.md)
- [ShareCreateRequest](docs/ShareCreateRequest.md)
- [SharePage](docs/SharePage.md)
- [SharePageListResponse](docs/SharePageListResponse.md)
- [SharePageResponse](docs/SharePageResponse.md)
- [SharePublicField](docs/SharePublicField.md)
- [ShareRevocationResponse](docs/ShareRevocationResponse.md)
- [ShareRevocationResponseData](docs/ShareRevocationResponseData.md)
- [ShareRevocationResponseDataCacheInvalidation](docs/ShareRevocationResponseDataCacheInvalidation.md)
- [ShareStatus](docs/ShareStatus.md)
- [SpeciesRuleVersion](docs/SpeciesRuleVersion.md)
- [SpeciesRuleVersionCreateRequest](docs/SpeciesRuleVersionCreateRequest.md)
- [SpeciesRuleVersionListResponse](docs/SpeciesRuleVersionListResponse.md)
- [SpeciesRuleVersionResponse](docs/SpeciesRuleVersionResponse.md)
- [SpeciesRuleVersionUpdateRequest](docs/SpeciesRuleVersionUpdateRequest.md)
- [StartGestationRequest](docs/StartGestationRequest.md)
- [StartGestationResponse](docs/StartGestationResponse.md)
- [StartGestationResponseData](docs/StartGestationResponseData.md)
- [StartPairingRequest](docs/StartPairingRequest.md)
- [StartPairingResponse](docs/StartPairingResponse.md)
- [StartPairingResponseData](docs/StartPairingResponseData.md)
- [StudDeal](docs/StudDeal.md)
- [StudDealListResponse](docs/StudDealListResponse.md)
- [StudDealResponse](docs/StudDealResponse.md)
- [StudListing](docs/StudListing.md)
- [StudListingListResponse](docs/StudListingListResponse.md)
- [StudListingResponse](docs/StudListingResponse.md)
- [TaskCorrectionRequest](docs/TaskCorrectionRequest.md)
- [TaskPriority](docs/TaskPriority.md)
- [TaskState](docs/TaskState.md)
- [UpdateOrganizationMemberRequest](docs/UpdateOrganizationMemberRequest.md)
- [UploadSession](docs/UploadSession.md)
- [UpsertMiniprogramConfigRequest](docs/UpsertMiniprogramConfigRequest.md)
- [UpsertPublicSiteRequest](docs/UpsertPublicSiteRequest.md)
- [UpsertPushDeviceRequest](docs/UpsertPushDeviceRequest.md)
- [UsageMetric](docs/UsageMetric.md)
- [UsageResponse](docs/UsageResponse.md)
- [UsageResponseData](docs/UsageResponseData.md)
- [UsageResponseDataEntitlement](docs/UsageResponseDataEntitlement.md)
- [UsageSnapshot](docs/UsageSnapshot.md)
- [UsageSnapshotListResponse](docs/UsageSnapshotListResponse.md)
- [VerificationCodeChallengeResponse](docs/VerificationCodeChallengeResponse.md)
- [VerificationCodeChallengeResponseData](docs/VerificationCodeChallengeResponseData.md)
- [WeanLitterRequest](docs/WeanLitterRequest.md)
- [WeanLitterRequestItemsInner](docs/WeanLitterRequestItemsInner.md)
- [WeanLitterResponse](docs/WeanLitterResponse.md)
- [WeanLitterResponseData](docs/WeanLitterResponseData.md)
- [WeightRecord](docs/WeightRecord.md)
- [WeightRecordBatchCreateRequest](docs/WeightRecordBatchCreateRequest.md)
- [WeightRecordBatchCreateRequestItemsInner](docs/WeightRecordBatchCreateRequestItemsInner.md)
- [WeightRecordBatchCreateResponse](docs/WeightRecordBatchCreateResponse.md)
- [WeightRecordBatchCreateResponseData](docs/WeightRecordBatchCreateResponseData.md)
- [WeightRecordBatchCreateResponseDataItemsInner](docs/WeightRecordBatchCreateResponseDataItemsInner.md)
- [WeightRecordCreateRequest](docs/WeightRecordCreateRequest.md)
- [WeightRecordListResponse](docs/WeightRecordListResponse.md)
- [WeightRecordOneOf](docs/WeightRecordOneOf.md)
- [WeightRecordOneOf1](docs/WeightRecordOneOf1.md)
- [WeightRecordOneOf2](docs/WeightRecordOneOf2.md)
- [WeightRecordResponse](docs/WeightRecordResponse.md)

### Authorization


Authentication schemes defined for the API:
<a id="bearerAuth"></a>
#### bearerAuth


- **Type**: HTTP Bearer Token authentication (JWT)
<a id="customerBearerAuth"></a>
#### customerBearerAuth


- **Type**: HTTP Bearer Token authentication (opaque)

## About

This TypeScript SDK client supports the [Fetch API](https://fetch.spec.whatwg.org/)
and is automatically generated by the
[OpenAPI Generator](https://openapi-generator.tech) project:

- API version: `1.0.1`
- Package version: `1.0.0`
- Generator version: `7.23.0`
- Build package: `org.openapitools.codegen.languages.TypeScriptFetchClientCodegen`

The generated npm module supports the following:

- Environments
  * Node.js
  * Webpack
  * Browserify
- Language levels
  * ES5 - you must have a Promises/A+ library installed
  * ES6
- Module systems
  * CommonJS
  * ES6 module system


## Development

### Building

To build the TypeScript source code, you need to have Node.js and npm installed.
After cloning the repository, navigate to the project directory and run:

```bash
npm install
npm run build
```

### Publishing

Once you've built the package, you can publish it to npm:

```bash
npm publish
```

## License

[Proprietary]()
