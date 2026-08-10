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


## Documentation

### API Endpoints

All URIs are relative to *https://api.scolvpet.cn/v1*

| Class | Method | HTTP request | Description
| ----- | ------ | ------------ | -------------
*DefaultApi* | [**batchCreateHamsters**](docs/DefaultApi.md#batchcreatehamsters) | **POST** /hamsters/batch | 批量创建仓鼠
*DefaultApi* | [**cancelTask**](docs/DefaultApi.md#canceltask) | **POST** /tasks/{task_id}/cancel | 取消任务
*DefaultApi* | [**commitImportJob**](docs/DefaultApi.md#commitimportjob) | **POST** /data-center/import-jobs/{job_id}/commit | 提交正式导入
*DefaultApi* | [**completeMediaUpload**](docs/DefaultApi.md#completemediaupload) | **POST** /media/uploads/{upload_id}/complete | 完成媒体上传
*DefaultApi* | [**completeTask**](docs/DefaultApi.md#completetaskoperation) | **POST** /tasks/{task_id}/complete | 完成任务或逐项完成任务成员
*DefaultApi* | [**createBackupJob**](docs/DefaultApi.md#createbackupjob) | **POST** /data-center/backup-jobs | 创建基础备份
*DefaultApi* | [**createBreederWechatBinding**](docs/DefaultApi.md#createbreederwechatbindingoperation) | **POST** /auth/wechat-bindings | 短信验证并绑定 B 端微信身份
*DefaultApi* | [**createBreederWechatSession**](docs/DefaultApi.md#createbreederwechatsessionoperation) | **POST** /auth/wechat-sessions | B 端微信 wx.login 登录
*DefaultApi* | [**createExportJob**](docs/DefaultApi.md#createexportjob) | **POST** /data-center/export-jobs | 创建数据导出
*DefaultApi* | [**createHamster**](docs/DefaultApi.md#createhamster) | **POST** /hamsters | 创建仓鼠档案
*DefaultApi* | [**createHealthRecord**](docs/DefaultApi.md#createhealthrecord) | **POST** /health-records | 创建健康记录
*DefaultApi* | [**createImportJob**](docs/DefaultApi.md#createimportjob) | **POST** /data-center/import-jobs | 创建 CSV 导入任务
*DefaultApi* | [**createImportUpload**](docs/DefaultApi.md#createimportupload) | **POST** /data-center/import-uploads | 创建 CSV 上传
*DefaultApi* | [**createLitterCountEvent**](docs/DefaultApi.md#createlittercountevent) | **POST** /litters/{litter_id}/count-events | 追加窝仔数量事件
*DefaultApi* | [**createSession**](docs/DefaultApi.md#createsession) | **POST** /auth/sessions | 使用手机验证码登录
*DefaultApi* | [**createTask**](docs/DefaultApi.md#createtask) | **POST** /tasks | 创建手工任务
*DefaultApi* | [**createWeightRecord**](docs/DefaultApi.md#createweightrecord) | **POST** /weight-records | 创建体重记录
*DefaultApi* | [**getBackupDownload**](docs/DefaultApi.md#getbackupdownload) | **GET** /data-center/backup-jobs/{job_id}/download | 获取备份下载链接
*DefaultApi* | [**getDataCenterSummary**](docs/DefaultApi.md#getdatacentersummary) | **GET** /data-center/summary | 获取数据中心摘要
*DefaultApi* | [**getExportDownload**](docs/DefaultApi.md#getexportdownload) | **GET** /data-center/export-jobs/{job_id}/download | 获取导出下载链接
*DefaultApi* | [**getHamster**](docs/DefaultApi.md#gethamster) | **GET** /hamsters/{hamster_id} | 获取仓鼠详情
*DefaultApi* | [**getHamsterPedigree**](docs/DefaultApi.md#gethamsterpedigree) | **GET** /hamsters/{hamster_id}/pedigree | 获取仓鼠家谱图
*DefaultApi* | [**getImportErrorReport**](docs/DefaultApi.md#getimporterrorreport) | **GET** /data-center/import-jobs/{job_id}/error-report | 下载 CSV 逐行错误报告
*DefaultApi* | [**getImportJob**](docs/DefaultApi.md#getimportjob) | **GET** /data-center/import-jobs/{job_id} | 获取导入任务
*DefaultApi* | [**getLitter**](docs/DefaultApi.md#getlitter) | **GET** /litters/{litter_id} | 获取窝次详情
*DefaultApi* | [**getLitterIndividualizationEligibility**](docs/DefaultApi.md#getlitterindividualizationeligibility) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set
*DefaultApi* | [**getLitterIndividualizationEligibility_0**](docs/DefaultApi.md#getlitterindividualizationeligibility_0) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set
*DefaultApi* | [**getLitterIndividualizationEligibility_1**](docs/DefaultApi.md#getlitterindividualizationeligibility_1) | **GET** /litters/{litter_id}/individualization-eligibility | 获取服务端个体化 eligible set
*DefaultApi* | [**getMediaAsset**](docs/DefaultApi.md#getmediaasset) | **GET** /media/{media_id} | 获取媒体资产
*DefaultApi* | [**individualizeLitter**](docs/DefaultApi.md#individualizelitteroperation) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化
*DefaultApi* | [**individualizeLitter_0**](docs/DefaultApi.md#individualizelitter_0) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化
*DefaultApi* | [**individualizeLitter_1**](docs/DefaultApi.md#individualizelitter_1) | **POST** /litters/{litter_id}/individualize | 将临时幼崽个体化
*DefaultApi* | [**listBackupJobs**](docs/DefaultApi.md#listbackupjobs) | **GET** /data-center/backup-jobs | 列出备份任务
*DefaultApi* | [**listEnclosures**](docs/DefaultApi.md#listenclosures) | **GET** /enclosures | 列出笼盒
*DefaultApi* | [**listExportJobs**](docs/DefaultApi.md#listexportjobs) | **GET** /data-center/export-jobs | 列出导出任务
*DefaultApi* | [**listHamsters**](docs/DefaultApi.md#listhamsters) | **GET** /hamsters | 列出仓鼠
*DefaultApi* | [**listHealthRecords**](docs/DefaultApi.md#listhealthrecords) | **GET** /health-records | 列出健康记录
*DefaultApi* | [**listImportRowResults**](docs/DefaultApi.md#listimportrowresults) | **GET** /data-center/import-jobs/{job_id}/rows | 获取逐行导入结果
*DefaultApi* | [**listLitterMembers**](docs/DefaultApi.md#listlittermembers) | **GET** /litters/{litter_id}/members | 列出窝次成员
*DefaultApi* | [**listLitterMembers_0**](docs/DefaultApi.md#listlittermembers_0) | **GET** /litters/{litter_id}/members | 列出窝次成员
*DefaultApi* | [**listLitters**](docs/DefaultApi.md#listlitters) | **GET** /litters | 列出窝次
*DefaultApi* | [**listReminders**](docs/DefaultApi.md#listreminders) | **GET** /reminders | 列出提醒
*DefaultApi* | [**listSpeciesRuleVersions**](docs/DefaultApi.md#listspeciesruleversions) | **GET** /species-rule-versions | 列出当前熊舍规则版本
*DefaultApi* | [**listTasks**](docs/DefaultApi.md#listtasks) | **GET** /tasks | 列出任务
*DefaultApi* | [**listWechatSubscriptions**](docs/DefaultApi.md#listwechatsubscriptions) | **GET** /wechat/subscriptions | 查看当前 B 端微信订阅授权
*DefaultApi* | [**listWeightRecords**](docs/DefaultApi.md#listweightrecords) | **GET** /weight-records | 列出体重记录
*DefaultApi* | [**preflightImportJob**](docs/DefaultApi.md#preflightimportjob) | **POST** /data-center/import-jobs/{job_id}/preflight | 全量预检 CSV
*DefaultApi* | [**presignMediaUpload**](docs/DefaultApi.md#presignmediaupload) | **POST** /media/uploads/presign | 创建媒体预签名上传
*DefaultApi* | [**refreshSession**](docs/DefaultApi.md#refreshsessionoperation) | **POST** /auth/sessions/refresh | 刷新当前会话
*DefaultApi* | [**reopenTask**](docs/DefaultApi.md#reopentask) | **POST** /tasks/{task_id}/reopen | 撤销任务的完成或取消
*DefaultApi* | [**retryBackupJob**](docs/DefaultApi.md#retrybackupjob) | **POST** /data-center/backup-jobs/{job_id}/retry | 重试失败备份
*DefaultApi* | [**retryExportJob**](docs/DefaultApi.md#retryexportjob) | **POST** /data-center/export-jobs/{job_id}/retry | 重试失败导出
*DefaultApi* | [**retryImportJob**](docs/DefaultApi.md#retryimportjob) | **POST** /data-center/import-jobs/{job_id}/retry | 重试失败导入行
*DefaultApi* | [**sendVerificationCode**](docs/DefaultApi.md#sendverificationcodeoperation) | **POST** /auth/verification-codes | 发送手机验证码
*DefaultApi* | [**setImportMapping**](docs/DefaultApi.md#setimportmapping) | **PUT** /data-center/import-jobs/{job_id}/mapping | 设置 CSV 字段映射
*DefaultApi* | [**sexAndSeparateLitter**](docs/DefaultApi.md#sexandseparatelitter) | **POST** /litters/{litter_id}/sex-and-separate | 分性并分笼
*DefaultApi* | [**updateHamster**](docs/DefaultApi.md#updatehamster) | **PATCH** /hamsters/{hamster_id} | 更新仓鼠档案
*DefaultApi* | [**upsertWechatSubscriptions**](docs/DefaultApi.md#upsertwechatsubscriptionsoperation) | **PUT** /wechat/subscriptions | 保存当前 B 端微信订阅授权
*DefaultApi* | [**weanLitter**](docs/DefaultApi.md#weanlitteroperation) | **POST** /litters/{litter_id}/wean | 完成断奶
*CustomerApi* | [**createCustomerWechatPhoneBinding**](docs/CustomerApi.md#createcustomerwechatphonebindingoperation) | **POST** /v1/public/customer/wechat-phone-bindings | 微信授权手机号并创建客户会话
*GeneticApi* | [**compareGeneticActual**](docs/GeneticApi.md#comparegeneticactual) | **POST** /v1/genetic/compare-actual | Compare actual litter phenotype counts to core table expectation
*GeneticApi* | [**inferGeneticParents**](docs/GeneticApi.md#infergeneticparents) | **POST** /v1/genetic/infer-parents | Infer parent genotypes from litter phenotype counts
*GeneticApi* | [**listGeneticFeedbackSummary**](docs/GeneticApi.md#listgeneticfeedbacksummary) | **GET** /v1/genetic/feedback-summary | Summarize historical phenotype prediction feedback
*GeneticApi* | [**listGeneticPhenotypeCatalog**](docs/GeneticApi.md#listgeneticphenotypecatalog) | **GET** /v1/genetic/phenotype-catalog | List phenotype series catalog from authority table
*GeneticApi* | [**listGeneticTargetCrosses**](docs/GeneticApi.md#listgenetictargetcrosses) | **GET** /v1/genetic/target-crosses | Rank parent pairs that can produce a target phenotype
*P1Api* | [**createAccountingCategory**](docs/P1Api.md#createaccountingcategoryoperation) | **POST** /v1/accounting/categories | 创建记账分类
*P1Api* | [**createAccountingRecord**](docs/P1Api.md#createaccountingrecordoperation) | **POST** /v1/accounting/records | 创建记账流水
*P1Api* | [**createContract**](docs/P1Api.md#createcontractoperation) | **POST** /v1/contracts | 创建合同单据
*P1Api* | [**createContractTemplate**](docs/P1Api.md#createcontracttemplate) | **POST** /v1/contracts/templates | 创建合同模板
*P1Api* | [**createGeneticProfile**](docs/P1Api.md#creategeneticprofileoperation) | **POST** /v1/genetic/profiles | 创建遗传档案
*P1Api* | [**createReceipt**](docs/P1Api.md#createreceiptoperation) | **POST** /v1/receipts | 创建回执单据
*P1Api* | [**createReceiptTemplate**](docs/P1Api.md#createreceipttemplate) | **POST** /v1/receipts/templates | 创建回执模板
*P1Api* | [**deleteGeneticProfile**](docs/P1Api.md#deletegeneticprofile) | **DELETE** /v1/genetic/profiles/{profile_id} | 删除遗传档案
*P1Api* | [**getAccountingSummary**](docs/P1Api.md#getaccountingsummary) | **GET** /v1/accounting/summary | 读取记账汇总
*P1Api* | [**getContract**](docs/P1Api.md#getcontract) | **GET** /v1/contracts/{document_id} | 获取合同单据详情
*P1Api* | [**getReceipt**](docs/P1Api.md#getreceipt) | **GET** /v1/receipts/{document_id} | 获取回执单据详情
*P1Api* | [**issueContract**](docs/P1Api.md#issuecontract) | **POST** /v1/contracts/{document_id}/issue | 签发合同
*P1Api* | [**issueReceipt**](docs/P1Api.md#issuereceipt) | **POST** /v1/receipts/{document_id}/issue | 签发回执
*P1Api* | [**listAccountingCategories**](docs/P1Api.md#listaccountingcategories) | **GET** /v1/accounting/categories | 列出记账分类
*P1Api* | [**listAccountingRecords**](docs/P1Api.md#listaccountingrecords) | **GET** /v1/accounting/records | 列出记账流水
*P1Api* | [**listContractTemplates**](docs/P1Api.md#listcontracttemplates) | **GET** /v1/contracts/templates | 列出合同模板
*P1Api* | [**listContracts**](docs/P1Api.md#listcontracts) | **GET** /v1/contracts | 列出合同单据
*P1Api* | [**listGeneticLoci**](docs/P1Api.md#listgeneticloci) | **GET** /v1/genetic/loci | 列出遗传位点
*P1Api* | [**listGeneticProfiles**](docs/P1Api.md#listgeneticprofiles) | **GET** /v1/genetic/profiles | 列出遗传档案
*P1Api* | [**listReceiptTemplates**](docs/P1Api.md#listreceipttemplates) | **GET** /v1/receipts/templates | 列出回执模板
*P1Api* | [**listReceipts**](docs/P1Api.md#listreceipts) | **GET** /v1/receipts | 列出回执单据
*P1Api* | [**revokeContract**](docs/P1Api.md#revokecontract) | **POST** /v1/contracts/{document_id}/revoke | 撤销合同
*P1Api* | [**revokeReceipt**](docs/P1Api.md#revokereceipt) | **POST** /v1/receipts/{document_id}/revoke | 撤销回执
*P1Api* | [**simulateGeneticBreeding**](docs/P1Api.md#simulategeneticbreeding) | **POST** /v1/genetic/simulate | 模拟遗传配对
*P1Api* | [**updateGeneticProfile**](docs/P1Api.md#updategeneticprofileoperation) | **PATCH** /v1/genetic/profiles/{profile_id} | 更新遗传档案
*P1CRMApi* | [**cancelCrmReservation**](docs/P1CRMApi.md#cancelcrmreservation) | **POST** /v1/crm/reservations/{reservation_id}/cancel | 取消客户预订
*P1CRMApi* | [**completeCrmHandover**](docs/P1CRMApi.md#completecrmhandover) | **POST** /v1/crm/handovers/{handover_id}/complete | 完成客户交付
*P1CRMApi* | [**confirmCrmReservation**](docs/P1CRMApi.md#confirmcrmreservation) | **POST** /v1/crm/reservations/{reservation_id}/confirm | 确认客户预订
*P1CRMApi* | [**createCrmContact**](docs/P1CRMApi.md#createcrmcontactoperation) | **POST** /v1/crm/contacts | 创建 CRM 客户
*P1CRMApi* | [**createCrmHandover**](docs/P1CRMApi.md#createcrmhandoveroperation) | **POST** /v1/crm/handovers | 创建交付记录
*P1CRMApi* | [**createCrmReservation**](docs/P1CRMApi.md#createcrmreservationoperation) | **POST** /v1/crm/reservations | 创建客户预订
*P1CRMApi* | [**getCrmContact**](docs/P1CRMApi.md#getcrmcontact) | **GET** /v1/crm/contacts/{contact_id} | 获取 CRM 客户详情
*P1CRMApi* | [**getCrmHandover**](docs/P1CRMApi.md#getcrmhandover) | **GET** /v1/crm/handovers/{handover_id} | 获取客户交付详情
*P1CRMApi* | [**getCrmReservation**](docs/P1CRMApi.md#getcrmreservation) | **GET** /v1/crm/reservations/{reservation_id} | 获取客户预订详情
*P1CRMApi* | [**listCrmContacts**](docs/P1CRMApi.md#listcrmcontacts) | **GET** /v1/crm/contacts | 列出 CRM 客户
*P1CRMApi* | [**listCrmHandovers**](docs/P1CRMApi.md#listcrmhandovers) | **GET** /v1/crm/handovers | 列出交付记录
*P1CRMApi* | [**listCrmReservations**](docs/P1CRMApi.md#listcrmreservations) | **GET** /v1/crm/reservations | 列出客户预订
*P2Api* | [**assistantCapabilities**](docs/P2Api.md#assistantcapabilities) | **GET** /v1/assistant/capabilities | 读取助手能力
*P2Api* | [**cancelAssistantAction**](docs/P2Api.md#cancelassistantaction) | **POST** /v1/assistant/actions/{action_id}/cancel | 取消助手动作
*P2Api* | [**chatAssistant**](docs/P2Api.md#chatassistant) | **POST** /v1/assistant/chat | 通用多轮对话
*P2Api* | [**confirmAssistantAction**](docs/P2Api.md#confirmassistantaction) | **POST** /v1/assistant/actions/{action_id}/confirm | 确认并执行助手动作


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
- [AdjustLitterCountRequest](docs/AdjustLitterCountRequest.md)
- [AdjustLitterCountResponse](docs/AdjustLitterCountResponse.md)
- [AdjustLitterCountResponseData](docs/AdjustLitterCountResponseData.md)
- [AssistantActionCancelResponse](docs/AssistantActionCancelResponse.md)
- [AssistantActionCancelResult](docs/AssistantActionCancelResult.md)
- [AssistantActionConfirmResponse](docs/AssistantActionConfirmResponse.md)
- [AssistantActionConfirmResult](docs/AssistantActionConfirmResult.md)
- [AssistantCapabilities](docs/AssistantCapabilities.md)
- [AssistantCapabilitiesResponse](docs/AssistantCapabilitiesResponse.md)
- [AssistantChatAction](docs/AssistantChatAction.md)
- [AssistantChatRequest](docs/AssistantChatRequest.md)
- [AssistantChatResponse](docs/AssistantChatResponse.md)
- [AssistantChatResult](docs/AssistantChatResult.md)
- [AssistantFact](docs/AssistantFact.md)
- [AsyncJob](docs/AsyncJob.md)
- [BackupJob](docs/BackupJob.md)
- [BackupJobCreateRequest](docs/BackupJobCreateRequest.md)
- [BackupJobListResponse](docs/BackupJobListResponse.md)
- [BackupJobResponse](docs/BackupJobResponse.md)
- [BatchItemStatus](docs/BatchItemStatus.md)
- [BatchTransactionStatus](docs/BatchTransactionStatus.md)
- [BreederWechatSessionResponse](docs/BreederWechatSessionResponse.md)
- [BreederWechatSessionResponseData](docs/BreederWechatSessionResponseData.md)
- [CareTask](docs/CareTask.md)
- [CareTaskCreateRequest](docs/CareTaskCreateRequest.md)
- [CareTaskListResponse](docs/CareTaskListResponse.md)
- [CareTaskResponse](docs/CareTaskResponse.md)
- [CleanlinessState](docs/CleanlinessState.md)
- [CompleteTaskRequest](docs/CompleteTaskRequest.md)
- [CompleteTaskRequestSubjectResultsInner](docs/CompleteTaskRequestSubjectResultsInner.md)
- [CompleteTaskResponse](docs/CompleteTaskResponse.md)
- [CompleteTaskResponseData](docs/CompleteTaskResponseData.md)
- [CompleteTaskResponseDataItemResultsInner](docs/CompleteTaskResponseDataItemResultsInner.md)
- [CreateAccountingCategoryRequest](docs/CreateAccountingCategoryRequest.md)
- [CreateAccountingRecordRequest](docs/CreateAccountingRecordRequest.md)
- [CreateBreederWechatBindingRequest](docs/CreateBreederWechatBindingRequest.md)
- [CreateBreederWechatSessionRequest](docs/CreateBreederWechatSessionRequest.md)
- [CreateContractRequest](docs/CreateContractRequest.md)
- [CreateCrmContactRequest](docs/CreateCrmContactRequest.md)
- [CreateCrmHandoverRequest](docs/CreateCrmHandoverRequest.md)
- [CreateCrmReservationRequest](docs/CreateCrmReservationRequest.md)
- [CreateCustomerWechatPhoneBindingRequest](docs/CreateCustomerWechatPhoneBindingRequest.md)
- [CreateDocumentTemplateRequest](docs/CreateDocumentTemplateRequest.md)
- [CreateGeneticProfileRequest](docs/CreateGeneticProfileRequest.md)
- [CreateReceiptRequest](docs/CreateReceiptRequest.md)
- [CrmContact](docs/CrmContact.md)
- [CrmContactListResponse](docs/CrmContactListResponse.md)
- [CrmContactResponse](docs/CrmContactResponse.md)
- [CrmHandover](docs/CrmHandover.md)
- [CrmHandoverListResponse](docs/CrmHandoverListResponse.md)
- [CrmHandoverResponse](docs/CrmHandoverResponse.md)
- [CrmReservation](docs/CrmReservation.md)
- [CrmReservationListResponse](docs/CrmReservationListResponse.md)
- [CrmReservationResponse](docs/CrmReservationResponse.md)
- [CustomerSessionResponse](docs/CustomerSessionResponse.md)
- [CustomerSessionResponseData](docs/CustomerSessionResponseData.md)
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
- [EnclosureDimensions](docs/EnclosureDimensions.md)
- [EnclosureListResponse](docs/EnclosureListResponse.md)
- [EnclosureState](docs/EnclosureState.md)
- [EnclosureStay](docs/EnclosureStay.md)
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
- [ImportCommitRequest](docs/ImportCommitRequest.md)
- [ImportCommitRequestApprovedUpdatesInner](docs/ImportCommitRequestApprovedUpdatesInner.md)
- [ImportIssue](docs/ImportIssue.md)
- [ImportJob](docs/ImportJob.md)
- [ImportJobCreateRequest](docs/ImportJobCreateRequest.md)
- [ImportJobResponse](docs/ImportJobResponse.md)
- [ImportMappingRequest](docs/ImportMappingRequest.md)
- [ImportMappingRequestMappingsInner](docs/ImportMappingRequestMappingsInner.md)
- [ImportMappingRequestMappingsInnerDefaultValue](docs/ImportMappingRequestMappingsInnerDefaultValue.md)
- [ImportPreflightRequest](docs/ImportPreflightRequest.md)
- [ImportRowResult](docs/ImportRowResult.md)
- [ImportRowResultListResponse](docs/ImportRowResultListResponse.md)
- [ImportRowStatus](docs/ImportRowStatus.md)
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
- [JobStatus](docs/JobStatus.md)
- [Litter](docs/Litter.md)
- [LitterCountEvent](docs/LitterCountEvent.md)
- [LitterListResponse](docs/LitterListResponse.md)
- [LitterMember](docs/LitterMember.md)
- [LitterMemberListResponse](docs/LitterMemberListResponse.md)
- [LitterMemberOneOf](docs/LitterMemberOneOf.md)
- [LitterMemberOneOf1](docs/LitterMemberOneOf1.md)
- [LitterParent](docs/LitterParent.md)
- [LitterResponse](docs/LitterResponse.md)
- [LitterResponseData](docs/LitterResponseData.md)
- [LitterState](docs/LitterState.md)
- [MediaAsset](docs/MediaAsset.md)
- [MediaAssetResponse](docs/MediaAssetResponse.md)
- [MediaUploadCompleteRequest](docs/MediaUploadCompleteRequest.md)
- [MediaUploadCompleteResponse](docs/MediaUploadCompleteResponse.md)
- [MediaUploadCompleteResponseData](docs/MediaUploadCompleteResponseData.md)
- [MediaUploadPresignRequest](docs/MediaUploadPresignRequest.md)
- [MediaUploadPresignResponse](docs/MediaUploadPresignResponse.md)
- [MediaVariant](docs/MediaVariant.md)
- [Organization](docs/Organization.md)
- [PageInfo](docs/PageInfo.md)
- [PedigreeGraphResponse](docs/PedigreeGraphResponse.md)
- [PedigreeGraphResponseData](docs/PedigreeGraphResponseData.md)
- [PedigreeGraphResponseDataCommonAncestorsInner](docs/PedigreeGraphResponseDataCommonAncestorsInner.md)
- [PedigreeParentage](docs/PedigreeParentage.md)
- [PhenotypeTableOutcome](docs/PhenotypeTableOutcome.md)
- [PhoneCodeLoginRequest](docs/PhoneCodeLoginRequest.md)
- [PupIdentity](docs/PupIdentity.md)
- [PupOutcomeStatus](docs/PupOutcomeStatus.md)
- [PupProfileStatus](docs/PupProfileStatus.md)
- [Reconciliation](docs/Reconciliation.md)
- [RecoveryAction](docs/RecoveryAction.md)
- [RefreshSessionRequest](docs/RefreshSessionRequest.md)
- [Reminder](docs/Reminder.md)
- [ReminderDelivery](docs/ReminderDelivery.md)
- [ReminderListResponse](docs/ReminderListResponse.md)
- [ReminderState](docs/ReminderState.md)
- [ResponseMeta](docs/ResponseMeta.md)
- [RetryImportRequest](docs/RetryImportRequest.md)
- [RetryJobRequest](docs/RetryJobRequest.md)
- [SendVerificationCodeRequest](docs/SendVerificationCodeRequest.md)
- [SessionResponse](docs/SessionResponse.md)
- [SessionResponseData](docs/SessionResponseData.md)
- [Severity](docs/Severity.md)
- [Sex](docs/Sex.md)
- [SexAndSeparateRequest](docs/SexAndSeparateRequest.md)
- [SexAndSeparateRequestItemsInner](docs/SexAndSeparateRequestItemsInner.md)
- [SexAndSeparateResponse](docs/SexAndSeparateResponse.md)
- [SexAndSeparateResponseData](docs/SexAndSeparateResponseData.md)
- [SpeciesRuleVersion](docs/SpeciesRuleVersion.md)
- [SpeciesRuleVersionListResponse](docs/SpeciesRuleVersionListResponse.md)
- [TaskCorrectionRequest](docs/TaskCorrectionRequest.md)
- [TaskPriority](docs/TaskPriority.md)
- [TaskState](docs/TaskState.md)
- [UpdateGeneticProfileRequest](docs/UpdateGeneticProfileRequest.md)
- [UploadSession](docs/UploadSession.md)
- [UpsertWechatSubscriptionsRequest](docs/UpsertWechatSubscriptionsRequest.md)
- [UsageMetric](docs/UsageMetric.md)
- [VerificationCodeChallengeResponse](docs/VerificationCodeChallengeResponse.md)
- [VerificationCodeChallengeResponseData](docs/VerificationCodeChallengeResponseData.md)
- [WeanLitterRequest](docs/WeanLitterRequest.md)
- [WeanLitterRequestItemsInner](docs/WeanLitterRequestItemsInner.md)
- [WeanLitterResponse](docs/WeanLitterResponse.md)
- [WeanLitterResponseData](docs/WeanLitterResponseData.md)
- [WechatSubscription](docs/WechatSubscription.md)
- [WechatSubscriptionListResponse](docs/WechatSubscriptionListResponse.md)
- [WeightRecord](docs/WeightRecord.md)
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
