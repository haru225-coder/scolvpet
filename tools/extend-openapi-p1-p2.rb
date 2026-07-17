#!/usr/bin/env ruby
# frozen_string_literal: true

# Extend the hand-maintained OpenAPI contract with the implemented P1/P2 routes.
# The script intentionally appends only the generated blocks, preserving the
# existing I1-I6 contract formatting and examples.

require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
SPEC = File.join(ROOT, "specs/api/openapi.yaml")

def ref(name)
  { "$ref" => "#/components/schemas/#{name}" }
end

def param_ref(name)
  { "$ref" => "#/components/parameters/#{name}" }
end

def obj(properties, required = [], description = nil, additional = false)
  out = { "type" => "object", "properties" => properties }
  out["required"] = required unless required.empty?
  out["description"] = description if description
  out["additionalProperties"] = additional
  out
end

def uuid_schema(nullable = false)
  return { "type" => ["string", "null"], "format" => "uuid" } if nullable

  { "type" => "string", "format" => "uuid" }
end

def string_schema(nullable = false, max = nil)
  out = { "type" => nullable ? ["string", "null"] : "string" }
  out["maxLength"] = max if max
  out
end

def time_schema(nullable = false)
  nullable ? { "type" => ["string", "null"], "format" => "date-time" } : { "type" => "string", "format" => "date-time" }
end

def map_schema(value = nil)
  out = { "type" => "object" }
  out["additionalProperties"] = value || true
  out
end

def envelope(name, data)
  { name => obj({ "data" => data, "meta" => ref("ResponseMeta") }, %w[data meta]) }
end

def list_envelope(name, item)
  envelope(name, { "type" => "array", "items" => ref(item) })
end

def json_content(schema_name)
  { "content" => { "application/json" => { "schema" => ref(schema_name) } } }
end

def response(code, description, schema_name = nil)
  out = { "description" => description }
  out.merge!(json_content(schema_name)) if schema_name
  out
end

def errors(include_not_found: false, include_conflict: false, include_validation: true)
  out = { "401" => { "$ref" => "#/components/responses/Unauthorized" } }
  out["404"] = { "$ref" => "#/components/responses/NotFound" } if include_not_found
  out["409"] = { "$ref" => "#/components/responses/ConflictError" } if include_conflict
  out["422"] = { "$ref" => "#/components/responses/ValidationError" } if include_validation
  out
end

def private_description(permission)
  "需要 Bearer 令牌；#{permission}。所有资源按当前 owner_id 隔离，跨舍或不存在资源统一返回 404。"
end

def operation(tags:, id:, summary:, permission:, method: nil, parameters: [], request: nil, response_schema:, status: "200", include_not_found: false, include_conflict: false, description: nil, security: nil)
  out = {
    "tags" => tags,
    "operationId" => id,
    "summary" => summary,
    "description" => description || private_description(permission),
    "parameters" => parameters,
    "responses" => { status => response(status, "#{summary}成功", response_schema) }
  }
  out["requestBody"] = { "required" => true, "content" => { "application/json" => { "schema" => ref(request) } } } if request
  errors(include_not_found: include_not_found, include_conflict: include_conflict).each { |code, value| out["responses"][code] = value }
  out["security"] = security if security
  out["parameters"] = out["parameters"].reject { |p| p.nil? }
  out
end

def action_parameter(name, description)
  { "name" => name, "in" => "path", "required" => true, "description" => description, "schema" => uuid_schema }
end

def query_parameter(name, schema, description)
  { "name" => name, "in" => "query", "required" => false, "description" => description, "schema" => schema }
end

schemas = {}

schemas["OrganizationMember"] = obj({
  "id" => uuid_schema, "organization_id" => uuid_schema, "account_id" => uuid_schema(true),
  "phone" => string_schema(false, 20), "display_name" => string_schema(true, 120),
  "role" => { "type" => "string", "enum" => %w[owner breeder caretaker staff viewer] },
  "status" => { "type" => "string", "enum" => %w[invited active revoked] },
  "invited_at" => time_schema, "accepted_at" => time_schema(true), "revoked_at" => time_schema(true),
  "version" => { "type" => "integer", "minimum" => 1 }
}, %w[id organization_id phone role status invited_at version])
schemas["InviteOrganizationMemberRequest"] = obj({
  "phone" => { "type" => "string", "minLength" => 6, "maxLength" => 20 },
  "role" => { "type" => "string", "enum" => %w[breeder caretaker staff viewer] },
  "display_name" => string_schema(true, 120)
}, %w[phone role])
schemas["UpdateOrganizationMemberRequest"] = obj({ "role" => { "type" => ["string", "null"], "enum" => [nil, "breeder", "caretaker", "staff", "viewer"] }, "display_name" => string_schema(true, 120) })
schemas.merge!(envelope("OrganizationMemberResponse", ref("OrganizationMember")))
schemas.merge!(list_envelope("OrganizationMemberListResponse", "OrganizationMember"))

schemas["CrmContact"] = obj({
  "id" => uuid_schema, "name" => { "type" => "string" }, "phone" => string_schema(true, 64),
  "wechat" => string_schema(true, 128), "notes" => string_schema(true, 4000),
  "status" => { "type" => "string", "enum" => %w[lead active archived] }, "version" => { "type" => "integer", "minimum" => 1 }
}, %w[id name status version])
schemas["CreateCrmContactRequest"] = obj({
  "name" => { "type" => "string", "minLength" => 1, "maxLength" => 160 }, "phone" => string_schema(true, 64),
  "wechat" => string_schema(true, 128), "notes" => string_schema(true, 4000),
  "status" => { "type" => "string", "enum" => %w[lead active archived], "default" => "lead" }
}, %w[name])
schemas["CrmReservation"] = obj({
  "id" => uuid_schema, "contact_id" => uuid_schema, "hamster_id" => uuid_schema(true),
  "title" => { "type" => "string" }, "status" => { "type" => "string", "enum" => %w[held confirmed handed_over cancelled] },
  "reserved_at" => time_schema, "notes" => string_schema(true, 4000), "version" => { "type" => "integer", "minimum" => 1 },
  "contact_name" => { "type" => "string" }
}, %w[id contact_id title status reserved_at version])
schemas["CreateCrmReservationRequest"] = obj({
  "contact_id" => uuid_schema, "hamster_id" => uuid_schema(true), "title" => string_schema(false, 200), "notes" => string_schema(true, 4000)
}, %w[contact_id])
schemas["CrmHandover"] = obj({
  "id" => uuid_schema, "contact_id" => uuid_schema, "reservation_id" => uuid_schema(true), "hamster_id" => uuid_schema(true),
  "status" => { "type" => "string", "enum" => %w[scheduled completed cancelled] }, "scheduled_at" => time_schema,
  "completed_at" => time_schema(true), "notes" => string_schema(true, 4000), "version" => { "type" => "integer", "minimum" => 1 },
  "contact_name" => { "type" => "string" }
}, %w[id contact_id status scheduled_at version])
schemas["CreateCrmHandoverRequest"] = obj({
  "contact_id" => uuid_schema, "reservation_id" => uuid_schema(true), "hamster_id" => uuid_schema(true),
  "notes" => string_schema(true, 4000), "scheduled_at" => time_schema(true)
}, %w[contact_id])
schemas.merge!(envelope("CrmContactResponse", ref("CrmContact")))
schemas.merge!(list_envelope("CrmContactListResponse", "CrmContact"))
schemas.merge!(envelope("CrmReservationResponse", ref("CrmReservation")))
schemas.merge!(list_envelope("CrmReservationListResponse", "CrmReservation"))
schemas.merge!(envelope("CrmHandoverResponse", ref("CrmHandover")))
schemas.merge!(list_envelope("CrmHandoverListResponse", "CrmHandover"))

schemas["DocumentTemplate"] = obj({
  "id" => uuid_schema, "kind" => { "type" => "string", "enum" => %w[contract receipt] }, "name" => { "type" => "string" },
  "body_text" => { "type" => "string" }, "version" => { "type" => "integer", "minimum" => 1 }
}, %w[id kind name body_text version])
schemas["CreateDocumentTemplateRequest"] = obj({ "name" => { "type" => "string", "minLength" => 1, "maxLength" => 160 }, "body_text" => string_schema(false, 20_000) }, %w[name])
schemas["Document"] = obj({
  "id" => uuid_schema, "template_id" => uuid_schema, "kind" => { "type" => "string", "enum" => %w[contract receipt] },
  "contact_id" => uuid_schema(true), "handover_id" => uuid_schema(true), "title" => { "type" => "string" },
  "body_filled" => { "type" => "string" }, "amount_cents" => { "type" => ["integer", "null"], "format" => "int64", "minimum" => 0 },
  "currency" => { "type" => "string", "minLength" => 3, "maxLength" => 3 },
  "status" => { "type" => "string", "enum" => %w[draft issued archived] }, "issued_at" => time_schema(true),
  "notes" => string_schema(true, 4000), "version" => { "type" => "integer", "minimum" => 1 }, "contact_name" => { "type" => "string" }
}, %w[id template_id kind title body_filled currency status version])
schemas["CreateContractRequest"] = obj({
  "template_id" => uuid_schema, "contact_id" => uuid_schema(true), "handover_id" => uuid_schema(true),
  "title" => string_schema(false, 200), "notes" => string_schema(true, 4000), "contact_name" => string_schema(true, 160), "hamster_name" => string_schema(true, 160)
}, %w[template_id])
schemas["CreateReceiptRequest"] = obj({
  "template_id" => uuid_schema, "contact_id" => uuid_schema(true), "title" => string_schema(false, 200),
  "amount_cents" => { "type" => "integer", "format" => "int64", "minimum" => 0 }, "currency" => { "type" => "string", "default" => "CNY", "minLength" => 3, "maxLength" => 3 },
  "notes" => string_schema(true, 4000), "contact_name" => string_schema(true, 160)
}, %w[template_id amount_cents])
schemas.merge!(list_envelope("DocumentTemplateListResponse", "DocumentTemplate"))
schemas.merge!(envelope("DocumentTemplateResponse", ref("DocumentTemplate")))
schemas.merge!(list_envelope("DocumentListResponse", "Document"))
schemas.merge!(envelope("DocumentResponse", ref("Document")))

schemas["AccountingCategory"] = obj({
  "id" => uuid_schema, "entry_type" => { "type" => "string", "enum" => %w[income expense] }, "name" => { "type" => "string" },
  "sort_order" => { "type" => "integer" }, "version" => { "type" => "integer", "minimum" => 1 }
}, %w[id entry_type name sort_order version])
schemas["CreateAccountingCategoryRequest"] = obj({ "entry_type" => { "type" => "string", "enum" => %w[income expense] }, "name" => { "type" => "string", "minLength" => 1, "maxLength" => 120 }, "sort_order" => { "type" => ["integer", "null"] } }, %w[entry_type name])
schemas["AccountingRecord"] = obj({
  "id" => uuid_schema, "category_id" => uuid_schema(true), "entry_type" => { "type" => "string", "enum" => %w[income expense] },
  "amount_cents" => { "type" => "integer", "format" => "int64", "minimum" => 1 }, "currency" => { "type" => "string" }, "title" => { "type" => "string" },
  "notes" => string_schema(true, 4000), "contact_id" => uuid_schema(true), "occurred_at" => time_schema,
  "version" => { "type" => "integer", "minimum" => 1 }, "category_name" => { "type" => "string" }, "contact_name" => { "type" => "string" }
}, %w[id entry_type amount_cents currency title occurred_at version])
schemas["CreateAccountingRecordRequest"] = obj({
  "category_id" => uuid_schema(true), "entry_type" => { "type" => "string", "enum" => %w[income expense] }, "amount_cents" => { "type" => "integer", "format" => "int64", "minimum" => 1 },
  "currency" => { "type" => "string", "default" => "CNY" }, "title" => { "type" => "string", "minLength" => 1, "maxLength" => 200 },
  "notes" => string_schema(true, 4000), "contact_id" => uuid_schema(true), "occurred_at" => time_schema(true)
}, %w[entry_type amount_cents title])
schemas["AccountingCategorySummary"] = obj({ "category_id" => uuid_schema(true), "category_name" => { "type" => "string" }, "entry_type" => { "type" => "string", "enum" => %w[income expense] }, "amount_cents" => { "type" => "integer", "format" => "int64" }, "count" => { "type" => "integer", "minimum" => 0 } }, %w[category_name entry_type amount_cents count])
schemas["AccountingSummary"] = obj({
  "from" => time_schema, "to" => time_schema, "income_cents" => { "type" => "integer", "format" => "int64" }, "expense_cents" => { "type" => "integer", "format" => "int64" },
  "net_cents" => { "type" => "integer", "format" => "int64" }, "currency" => { "type" => "string" }, "record_count" => { "type" => "integer", "minimum" => 0 },
  "by_category" => { "type" => "array", "items" => ref("AccountingCategorySummary") }
}, %w[from to income_cents expense_cents net_cents currency record_count by_category])
schemas.merge!(list_envelope("AccountingCategoryListResponse", "AccountingCategory"))
schemas.merge!(envelope("AccountingCategoryResponse", ref("AccountingCategory")))
schemas.merge!(list_envelope("AccountingRecordListResponse", "AccountingRecord"))
schemas.merge!(envelope("AccountingRecordResponse", ref("AccountingRecord")))
schemas.merge!(envelope("AccountingSummaryResponse", ref("AccountingSummary")))

schemas["GeneticLocus"] = obj({
  "code" => { "type" => "string" }, "name" => { "type" => "string" }, "dominant_allele" => { "type" => "string" }, "recessive_allele" => { "type" => "string" },
  "dominant_label" => { "type" => "string" }, "recessive_label" => { "type" => "string" }, "description" => string_schema(true, 1000)
}, %w[code name dominant_allele recessive_allele dominant_label recessive_label])
schemas["GeneticProfile"] = obj({
  "id" => uuid_schema, "hamster_id" => uuid_schema(true), "name" => { "type" => "string" }, "phenotype" => map_schema,
  "genotype" => map_schema({ "type" => "string" }), "confidence" => { "type" => "string", "enum" => %w[observed inferred unknown] },
  "notes" => string_schema(true, 4000), "version" => { "type" => "integer", "minimum" => 1 }, "updated_at" => time_schema
}, %w[id name phenotype genotype confidence version updated_at])
schemas["CreateGeneticProfileRequest"] = obj({
  "hamster_id" => uuid_schema(true), "name" => { "type" => "string", "minLength" => 1, "maxLength" => 160 }, "phenotype" => map_schema,
  "genotype" => map_schema({ "type" => "string" }), "confidence" => { "type" => "string", "enum" => %w[observed inferred unknown], "default" => "unknown" }, "notes" => string_schema(true, 4000)
}, %w[name])
schemas["GeneticSimulationRequest"] = obj({ "sire" => map_schema({ "type" => "string" }), "dam" => map_schema({ "type" => "string" }) }, %w[sire dam])
schemas["GeneticOutcome"] = obj({
  "genotype_key" => { "type" => "string" }, "genotype" => map_schema({ "type" => "string" }), "phenotype_label" => { "type" => "string" },
  "phenotype" => map_schema({ "type" => "string" }), "probability" => { "type" => "number", "format" => "double", "minimum" => 0, "maximum" => 1 }, "count_weight" => { "type" => "integer", "minimum" => 1 }
}, %w[genotype_key genotype phenotype_label phenotype probability count_weight])
schemas["GeneticSimulationResult"] = obj({
  "sire" => map_schema({ "type" => "string" }), "dam" => map_schema({ "type" => "string" }), "outcomes" => { "type" => "array", "items" => ref("GeneticOutcome") }, "notes" => { "type" => "string" }
}, %w[sire dam outcomes notes])
schemas.merge!(envelope("GeneticLocusListResponse", { "type" => "array", "items" => ref("GeneticLocus") }))
schemas.merge!(list_envelope("GeneticProfileListResponse", "GeneticProfile"))
schemas.merge!(envelope("GeneticProfileResponse", ref("GeneticProfile")))
schemas.merge!(envelope("GeneticSimulationResponse", ref("GeneticSimulationResult")))

schemas["PushDevice"] = obj({
  "id" => uuid_schema, "platform" => { "type" => "string", "enum" => %w[ios android web unknown] }, "provider" => { "type" => "string", "enum" => %w[apns fcm log] },
  "token" => { "type" => "string" }, "device_name" => string_schema(true, 160), "app_version" => string_schema(true, 64), "enabled" => { "type" => "boolean" }, "last_seen_at" => time_schema, "version" => { "type" => "integer", "minimum" => 1 }
}, %w[id platform provider token enabled last_seen_at version])
schemas["UpsertPushDeviceRequest"] = obj({
  "platform" => { "type" => "string", "enum" => %w[ios android web unknown] }, "provider" => { "type" => "string", "enum" => %w[apns fcm log] },
  "token" => { "type" => "string", "minLength" => 1, "maxLength" => 512 }, "device_name" => string_schema(true, 160), "app_version" => string_schema(true, 64)
}, %w[token])
schemas["PushMessage"] = obj({
  "id" => uuid_schema, "title" => { "type" => "string" }, "body" => { "type" => "string" }, "data" => map_schema,
  "status" => { "type" => "string", "enum" => %w[queued sending sent failed] }, "target_device_id" => uuid_schema(true), "provider" => { "type" => "string" },
  "provider_message_id" => string_schema(true, 256), "attempt_count" => { "type" => "integer", "minimum" => 0 }, "last_error" => string_schema(true, 2000), "sent_at" => time_schema(true), "version" => { "type" => "integer", "minimum" => 1 }, "created_at" => time_schema
}, %w[id title body data status provider attempt_count version created_at])
schemas["CreatePushMessageRequest"] = obj({ "title" => { "type" => "string", "minLength" => 1, "maxLength" => 160 }, "body" => { "type" => "string", "minLength" => 1, "maxLength" => 4000 }, "data" => map_schema, "target_device_id" => uuid_schema(true) }, %w[title body])
schemas.merge!(list_envelope("PushDeviceListResponse", "PushDevice"))
schemas.merge!(envelope("PushDeviceResponse", ref("PushDevice")))
schemas.merge!(list_envelope("PushMessageListResponse", "PushMessage"))
schemas.merge!(envelope("PushMessageResponse", ref("PushMessage")))

schemas["EntitlementFeature"] = obj({ "code" => { "type" => "string" }, "title" => { "type" => "string" }, "description" => { "type" => "string" }, "allowed" => { "type" => "boolean" } }, %w[code title description allowed])
schemas["EntitlementLimit"] = obj({ "code" => { "type" => "string" }, "metric" => { "type" => "string" }, "title" => { "type" => "string" }, "limit" => { "type" => ["number", "null"] }, "used" => { "type" => "number" }, "remaining" => { "type" => ["number", "null"] }, "over" => { "type" => "boolean" }, "unit" => { "type" => "string" } }, %w[code metric title used over unit])
schemas["PlanCatalogEntry"] = obj({ "code" => { "type" => "string", "enum" => %w[free pro] }, "title" => { "type" => "string" }, "description" => { "type" => "string" }, "price_hint" => { "type" => "string" }, "features" => map_schema({ "type" => "boolean" }), "limits" => map_schema({ "type" => "number" }), "enforcement" => { "type" => "string", "enum" => %w[none soft hard] }, "highlight" => { "type" => "boolean" } }, %w[code title description price_hint features limits enforcement])
schemas["EntitlementSnapshot"] = obj({ "plan_code" => { "type" => "string" }, "plan_title" => { "type" => "string" }, "enforcement" => { "type" => "string", "enum" => %w[none soft hard] }, "source" => { "type" => "string" }, "effective_at" => time_schema, "expires_at" => time_schema(true), "features" => { "type" => "array", "items" => ref("EntitlementFeature") }, "limits" => { "type" => "array", "items" => ref("EntitlementLimit") }, "over_limit" => { "type" => "boolean" }, "paywall_hint" => string_schema(true, 1000) }, %w[plan_code plan_title enforcement source effective_at features limits over_limit])
schemas["EntitlementCheckRequest"] = obj({ "feature" => string_schema(false, 160), "metric" => string_schema(false, 160) })
schemas["EntitlementCheckResult"] = obj({ "allowed" => { "type" => "boolean" }, "enforcement" => { "type" => "string" }, "plan_code" => { "type" => "string" }, "reason" => string_schema(true, 1000), "feature" => string_schema(true, 160), "metric" => string_schema(true, 160), "used" => { "type" => ["number", "null"] }, "limit" => { "type" => ["number", "null"] } }, %w[allowed enforcement plan_code])
schemas["SandboxActivatePlanRequest"] = obj({ "plan_code" => { "type" => "string", "enum" => %w[free pro], "default" => "pro" } })
schemas.merge!(envelope("EntitlementCatalogResponse", { "type" => "array", "items" => ref("PlanCatalogEntry") }))
schemas.merge!(envelope("EntitlementSnapshotResponse", ref("EntitlementSnapshot")))
schemas.merge!(envelope("EntitlementCheckResponse", ref("EntitlementCheckResult")))

schemas["PublicSite"] = obj({
  "id" => uuid_schema, "slug" => { "type" => "string", "pattern" => "^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$" }, "title" => { "type" => "string" },
  "tagline" => string_schema(true, 400), "about" => string_schema(true, 4000), "contact_wechat" => string_schema(true, 128), "contact_phone" => string_schema(true, 64),
  "theme_color" => { "type" => "string", "pattern" => "^#[0-9A-Fa-f]{6}$" }, "show_stats" => { "type" => "boolean" }, "show_contact" => { "type" => "boolean" },
  "published" => { "type" => "boolean" }, "published_at" => time_schema(true), "version" => { "type" => "integer", "minimum" => 1 }, "updated_at" => time_schema, "public_url_path" => { "type" => "string" }
}, %w[slug title theme_color show_stats show_contact published])
schemas["PublicSiteView"] = obj({ "slug" => { "type" => "string" }, "title" => { "type" => "string" }, "tagline" => string_schema(true, 400), "about" => string_schema(true, 4000), "theme_color" => { "type" => "string" }, "contact_wechat" => string_schema(true, 128), "contact_phone" => string_schema(true, 64), "stats" => map_schema, "organization_name" => string_schema(true, 160), "published_at" => time_schema(true) }, %w[slug title theme_color])
schemas["UpsertPublicSiteRequest"] = obj({ "slug" => { "type" => "string", "minLength" => 2, "maxLength" => 64, "pattern" => "^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$" }, "title" => { "type" => "string", "minLength" => 1, "maxLength" => 120 }, "tagline" => string_schema(true, 400), "about" => string_schema(true, 4000), "contact_wechat" => string_schema(true, 128), "contact_phone" => string_schema(true, 64), "theme_color" => { "type" => "string", "pattern" => "^#[0-9A-Fa-f]{6}$", "default" => "#c77852" }, "show_stats" => { "type" => ["boolean", "null"], "default" => true }, "show_contact" => { "type" => ["boolean", "null"], "default" => true } }, %w[slug title])
schemas.merge!(envelope("PublicSiteResponse", ref("PublicSite")))
schemas.merge!(envelope("PublicSiteViewResponse", ref("PublicSiteView")))

schemas["MiniprogramConfig"] = obj({ "id" => uuid_schema, "display_name" => { "type" => "string" }, "app_id" => string_schema(true, 128), "bound_public_slug" => string_schema(true, 64), "enabled" => { "type" => "boolean" }, "version" => { "type" => "integer", "minimum" => 1 }, "updated_at" => time_schema, "pipeline_note" => { "type" => "string" } }, %w[display_name enabled pipeline_note])
schemas["UpsertMiniprogramConfigRequest"] = obj({ "display_name" => string_schema(false, 80), "app_id" => string_schema(true, 128), "bound_public_slug" => string_schema(true, 64), "enabled" => { "type" => ["boolean", "null"] } })
schemas["MiniprogramRelease"] = obj({ "id" => uuid_schema, "version_label" => { "type" => "string" }, "status" => { "type" => "string", "enum" => %w[draft submitted auditing approved rejected published rolled_back] }, "title" => { "type" => "string" }, "summary" => string_schema(true, 2000), "public_slug" => string_schema(true, 64), "audit_note" => string_schema(true, 2000), "submitted_at" => time_schema(true), "audited_at" => time_schema(true), "published_at" => time_schema(true), "rolled_back_at" => time_schema(true), "version" => { "type" => "integer", "minimum" => 1 }, "created_at" => time_schema, "updated_at" => time_schema }, %w[id version_label status title version created_at updated_at])
schemas["CreateMiniprogramReleaseRequest"] = obj({ "version_label" => string_schema(false, 32), "title" => string_schema(false, 160), "summary" => string_schema(true, 2000), "public_slug" => string_schema(true, 64) })
schemas["AuditMiniprogramReleaseRequest"] = obj({ "decision" => { "type" => "string", "enum" => %w[approve reject] }, "note" => string_schema(true, 2000) }, %w[decision])
schemas.merge!(envelope("MiniprogramConfigResponse", ref("MiniprogramConfig")))
schemas.merge!(list_envelope("MiniprogramReleaseListResponse", "MiniprogramRelease"))
schemas.merge!(envelope("MiniprogramReleaseResponse", ref("MiniprogramRelease")))

schemas["AssistantFact"] = obj({ "key" => { "type" => "string" }, "label" => { "type" => "string" }, "value" => { "type" => "string" }, "source" => { "type" => "string" } }, %w[key label value source])
schemas["AssistantAnswer"] = obj({ "answer" => { "type" => "string" }, "intent" => { "type" => "string" }, "mode" => { "type" => "string", "enum" => %w[rules llm] }, "facts" => { "type" => "array", "items" => ref("AssistantFact") }, "disclaimer" => { "type" => "string" } }, %w[answer intent mode facts disclaimer])
schemas["AssistantCapabilities"] = obj({ "intents" => { "type" => "array", "items" => { "type" => "string" } }, "mode_default" => { "type" => "string", "const" => "rules" }, "llm_available" => { "type" => "boolean" }, "disclaimer" => { "type" => "string" } }, %w[intents mode_default llm_available disclaimer])
schemas["AssistantAskRequest"] = obj({ "question" => { "type" => "string", "minLength" => 1, "maxLength" => 500 }, "prefer_llm" => { "type" => "boolean", "default" => false } }, %w[question])
schemas.merge!(envelope("AssistantAnswerResponse", ref("AssistantAnswer")))
schemas.merge!(envelope("AssistantCapabilitiesResponse", ref("AssistantCapabilities")))

schemas["StudListing"] = obj({ "id" => uuid_schema, "owner_id" => uuid_schema, "sire_label" => { "type" => "string" }, "title" => { "type" => "string" }, "fee_cents" => { "type" => "integer", "format" => "int64", "minimum" => 0 }, "currency" => { "type" => "string" }, "notes" => string_schema(true, 4000), "published" => { "type" => "boolean" }, "version" => { "type" => "integer", "minimum" => 1 }, "updated_at" => time_schema, "cattery_name" => { "type" => "string" }, "is_mine" => { "type" => "boolean" } }, %w[id owner_id sire_label title fee_cents currency published version updated_at is_mine])
schemas["CreateStudListingRequest"] = obj({ "sire_label" => { "type" => "string", "minLength" => 1, "maxLength" => 160 }, "title" => string_schema(false, 200), "fee_cents" => { "type" => "integer", "format" => "int64", "minimum" => 0 }, "currency" => { "type" => "string", "default" => "CNY" }, "notes" => string_schema(true, 4000), "published" => { "type" => ["boolean", "null"], "default" => true } }, %w[sire_label])
schemas["StudDeal"] = obj({ "id" => uuid_schema, "listing_id" => uuid_schema(true), "side" => { "type" => "string", "enum" => %w[provider requester] }, "status" => { "type" => "string", "enum" => %w[draft requested confirmed in_progress completed cancelled] }, "my_hamster_label" => string_schema(true, 160), "partner_cattery_name" => { "type" => "string" }, "partner_contact" => string_schema(true, 160), "partner_animal_label" => string_schema(true, 160), "fee_cents" => { "type" => "integer", "format" => "int64", "minimum" => 0 }, "currency" => { "type" => "string" }, "notes" => string_schema(true, 4000), "confirmed_at" => time_schema(true), "started_at" => time_schema(true), "completed_at" => time_schema(true), "cancelled_at" => time_schema(true), "version" => { "type" => "integer", "minimum" => 1 }, "updated_at" => time_schema }, %w[id side status partner_cattery_name fee_cents currency version updated_at])
schemas["CreateStudDealRequest"] = obj({ "listing_id" => uuid_schema(true), "side" => { "type" => "string", "enum" => %w[provider requester] }, "my_hamster_label" => string_schema(true, 160), "partner_cattery_name" => { "type" => "string", "minLength" => 1, "maxLength" => 160 }, "partner_contact" => string_schema(true, 160), "partner_animal_label" => string_schema(true, 160), "fee_cents" => { "type" => ["integer", "null"], "format" => "int64", "minimum" => 0 }, "currency" => { "type" => "string", "default" => "CNY" }, "notes" => string_schema(true, 4000) }, %w[side partner_cattery_name])
schemas.merge!(list_envelope("StudListingListResponse", "StudListing"))
schemas.merge!(envelope("StudListingResponse", ref("StudListing")))
schemas.merge!(list_envelope("StudDealListResponse", "StudDeal"))
schemas.merge!(envelope("StudDealResponse", ref("StudDeal")))

private_key = param_ref("P1P2IdempotencyKey")
if_match_optional = param_ref("IfMatchOptional")

paths = {}
paths["/v1/organization-members"] = {
  "get" => operation(tags: ["P1 成员"], id: "listOrganizationMembers", summary: "列出熊舍成员", permission: "仅舍主和具备成员管理权限的成员可读", response_schema: "OrganizationMemberListResponse"),
  "post" => operation(tags: ["P1 成员"], id: "inviteOrganizationMember", summary: "邀请熊舍成员", permission: "仅舍主可邀请成员", method: "POST", parameters: [private_key], request: "InviteOrganizationMemberRequest", response_schema: "OrganizationMemberResponse", status: "201", include_conflict: true)
}
paths["/v1/organization-members/{member_id}"] = {
  "patch" => operation(tags: ["P1 成员"], id: "updateOrganizationMember", summary: "更新熊舍成员", permission: "仅舍主可修改成员角色或显示名", parameters: [action_parameter("member_id", "成员 ID") , if_match_optional, private_key], request: "UpdateOrganizationMemberRequest", response_schema: "OrganizationMemberResponse", include_not_found: true, include_conflict: true)
}
paths["/v1/organization-members/{member_id}/revoke"] = {
  "post" => operation(tags: ["P1 成员"], id: "revokeOrganizationMember", summary: "撤销熊舍成员", permission: "仅舍主可撤销成员", parameters: [action_parameter("member_id", "成员 ID"), private_key], response_schema: "OrganizationMemberResponse", include_not_found: true, include_conflict: true)
}

paths["/v1/crm/contacts"] = {
  "get" => operation(tags: ["P1 CRM"], id: "listCrmContacts", summary: "列出 CRM 客户", permission: "当前熊舍成员可读客户档案", response_schema: "CrmContactListResponse"),
  "post" => operation(tags: ["P1 CRM"], id: "createCrmContact", summary: "创建 CRM 客户", permission: "当前熊舍成员可创建客户档案", parameters: [private_key], request: "CreateCrmContactRequest", response_schema: "CrmContactResponse", status: "201")
}
paths["/v1/crm/reservations"] = {
  "get" => operation(tags: ["P1 CRM"], id: "listCrmReservations", summary: "列出客户预订", permission: "当前熊舍成员可读预订记录", response_schema: "CrmReservationListResponse"),
  "post" => operation(tags: ["P1 CRM"], id: "createCrmReservation", summary: "创建客户预订", permission: "当前熊舍成员可创建预订记录", parameters: [private_key], request: "CreateCrmReservationRequest", response_schema: "CrmReservationResponse", status: "201", include_not_found: true)
}
paths["/v1/crm/reservations/{reservation_id}/confirm"] = { "post" => operation(tags: ["P1 CRM"], id: "confirmCrmReservation", summary: "确认客户预订", permission: "当前熊舍成员可推进预订状态", parameters: [action_parameter("reservation_id", "预订 ID"), private_key], response_schema: "CrmReservationResponse", include_not_found: true, include_conflict: true) }
paths["/v1/crm/reservations/{reservation_id}/cancel"] = { "post" => operation(tags: ["P1 CRM"], id: "cancelCrmReservation", summary: "取消客户预订", permission: "当前熊舍成员可取消预订", parameters: [action_parameter("reservation_id", "预订 ID"), private_key], response_schema: "CrmReservationResponse", include_not_found: true, include_conflict: true) }
paths["/v1/crm/handovers"] = {
  "get" => operation(tags: ["P1 CRM"], id: "listCrmHandovers", summary: "列出交付记录", permission: "当前熊舍成员可读交付记录", response_schema: "CrmHandoverListResponse"),
  "post" => operation(tags: ["P1 CRM"], id: "createCrmHandover", summary: "创建交付记录", permission: "当前熊舍成员可创建交付记录", parameters: [private_key], request: "CreateCrmHandoverRequest", response_schema: "CrmHandoverResponse", status: "201", include_not_found: true)
}
paths["/v1/crm/handovers/{handover_id}/complete"] = { "post" => operation(tags: ["P1 CRM"], id: "completeCrmHandover", summary: "完成客户交付", permission: "当前熊舍成员可完成交付并闭合关联预订", parameters: [action_parameter("handover_id", "交付 ID"), private_key], response_schema: "CrmHandoverResponse", include_not_found: true, include_conflict: true) }

paths["/v1/contracts/templates"] = {
  "get" => operation(tags: ["P1 合同与回执"], id: "listContractTemplates", summary: "列出合同模板", permission: "当前熊舍成员可读合同模板", response_schema: "DocumentTemplateListResponse"),
  "post" => operation(tags: ["P1 合同与回执"], id: "createContractTemplate", summary: "创建合同模板", permission: "当前熊舍成员可创建合同模板", parameters: [private_key], request: "CreateDocumentTemplateRequest", response_schema: "DocumentTemplateResponse", status: "201")
}
paths["/v1/contracts"] = {
  "get" => operation(tags: ["P1 合同与回执"], id: "listContracts", summary: "列出合同单据", permission: "当前熊舍成员可读合同单据", response_schema: "DocumentListResponse"),
  "post" => operation(tags: ["P1 合同与回执"], id: "createContract", summary: "创建合同单据", permission: "当前熊舍成员可创建合同草稿", parameters: [private_key], request: "CreateContractRequest", response_schema: "DocumentResponse", status: "201", include_not_found: true)
}
paths["/v1/contracts/{document_id}/issue"] = { "post" => operation(tags: ["P1 合同与回执"], id: "issueContract", summary: "签发合同", permission: "当前熊舍成员可签发合同草稿", parameters: [action_parameter("document_id", "合同单据 ID"), if_match_optional, private_key], response_schema: "DocumentResponse", include_not_found: true, include_conflict: true) }
paths["/v1/receipts/templates"] = {
  "get" => operation(tags: ["P1 合同与回执"], id: "listReceiptTemplates", summary: "列出回执模板", permission: "当前熊舍成员可读回执模板", response_schema: "DocumentTemplateListResponse"),
  "post" => operation(tags: ["P1 合同与回执"], id: "createReceiptTemplate", summary: "创建回执模板", permission: "当前熊舍成员可创建回执模板", parameters: [private_key], request: "CreateDocumentTemplateRequest", response_schema: "DocumentTemplateResponse", status: "201")
}
paths["/v1/receipts"] = {
  "get" => operation(tags: ["P1 合同与回执"], id: "listReceipts", summary: "列出回执单据", permission: "当前熊舍成员可读回执单据", response_schema: "DocumentListResponse"),
  "post" => operation(tags: ["P1 合同与回执"], id: "createReceipt", summary: "创建回执单据", permission: "当前熊舍成员可创建回执草稿", parameters: [private_key], request: "CreateReceiptRequest", response_schema: "DocumentResponse", status: "201", include_not_found: true)
}
paths["/v1/receipts/{document_id}/issue"] = { "post" => operation(tags: ["P1 合同与回执"], id: "issueReceipt", summary: "签发回执", permission: "当前熊舍成员可签发回执草稿", parameters: [action_parameter("document_id", "回执单据 ID"), if_match_optional, private_key], response_schema: "DocumentResponse", include_not_found: true, include_conflict: true) }

paths["/v1/accounting/categories"] = {
  "get" => operation(tags: ["P1 记账"], id: "listAccountingCategories", summary: "列出记账分类", permission: "当前熊舍成员可读记账分类", parameters: [query_parameter("entry_type", { "type" => "string", "enum" => %w[income expense] }, "按收入或支出筛选")], response_schema: "AccountingCategoryListResponse"),
  "post" => operation(tags: ["P1 记账"], id: "createAccountingCategory", summary: "创建记账分类", permission: "当前熊舍成员可创建记账分类", parameters: [private_key], request: "CreateAccountingCategoryRequest", response_schema: "AccountingCategoryResponse", status: "201", include_conflict: true)
}
accounting_filters = [query_parameter("entry_type", { "type" => "string", "enum" => %w[income expense] }, "按收支类型筛选"), query_parameter("from", { "type" => "string", "format" => "date-time" }, "起始时间"), query_parameter("to", { "type" => "string", "format" => "date-time" }, "结束时间")]
paths["/v1/accounting/records"] = {
  "get" => operation(tags: ["P1 记账"], id: "listAccountingRecords", summary: "列出记账流水", permission: "当前熊舍成员可读记账流水", parameters: accounting_filters, response_schema: "AccountingRecordListResponse"),
  "post" => operation(tags: ["P1 记账"], id: "createAccountingRecord", summary: "创建记账流水", permission: "当前熊舍成员可创建记账流水", parameters: [private_key], request: "CreateAccountingRecordRequest", response_schema: "AccountingRecordResponse", status: "201", include_not_found: true)
}
paths["/v1/accounting/summary"] = { "get" => operation(tags: ["P1 记账"], id: "getAccountingSummary", summary: "读取记账汇总", permission: "当前熊舍成员可读收支汇总", parameters: accounting_filters, response_schema: "AccountingSummaryResponse") }

paths["/v1/genetic/loci"] = { "get" => operation(tags: ["P1 遗传"], id: "listGeneticLoci", summary: "列出遗传位点", permission: "当前熊舍成员可读系统遗传位点目录", response_schema: "GeneticLocusListResponse") }
paths["/v1/genetic/profiles"] = {
  "get" => operation(tags: ["P1 遗传"], id: "listGeneticProfiles", summary: "列出遗传档案", permission: "当前熊舍成员可读遗传档案", response_schema: "GeneticProfileListResponse"),
  "post" => operation(tags: ["P1 遗传"], id: "createGeneticProfile", summary: "创建遗传档案", permission: "当前熊舍成员可创建遗传档案", parameters: [private_key], request: "CreateGeneticProfileRequest", response_schema: "GeneticProfileResponse", status: "201", include_not_found: true)
}
paths["/v1/genetic/simulate"] = { "post" => operation(tags: ["P1 遗传"], id: "simulateGeneticBreeding", summary: "模拟遗传配对", permission: "当前熊舍成员可运行只读遗传模拟", parameters: [private_key], request: "GeneticSimulationRequest", response_schema: "GeneticSimulationResponse") }

paths["/v1/push/devices"] = {
  "get" => operation(tags: ["P1 推送"], id: "listPushDevices", summary: "列出推送设备", permission: "当前熊舍成员可读自己的推送设备", response_schema: "PushDeviceListResponse"),
  "put" => operation(tags: ["P1 推送"], id: "upsertPushDevice", summary: "登记推送设备", permission: "当前熊舍成员可登记或恢复推送设备", parameters: [private_key], request: "UpsertPushDeviceRequest", response_schema: "PushDeviceResponse")
}
paths["/v1/push/devices/{device_id}"] = { "delete" => operation(tags: ["P1 推送"], id: "disablePushDevice", summary: "停用推送设备", permission: "当前熊舍成员可停用自己的推送设备", parameters: [action_parameter("device_id", "设备 ID"), private_key], response_schema: "PushDeviceResponse", include_not_found: true) }
paths["/v1/push/messages"] = {
  "get" => operation(tags: ["P1 推送"], id: "listPushMessages", summary: "列出推送消息", permission: "当前熊舍成员可读推送审计记录", response_schema: "PushMessageListResponse"),
  "post" => operation(tags: ["P1 推送"], id: "createPushMessage", summary: "创建推送消息", permission: "当前熊舍成员可发送测试或业务推送", parameters: [private_key], request: "CreatePushMessageRequest", response_schema: "PushMessageResponse", status: "201", include_not_found: true)
}

paths["/v1/entitlements/catalog"] = { "get" => operation(tags: ["P1 权益"], id: "getEntitlementCatalog", summary: "读取权益套餐目录", permission: "当前熊舍成员可读公开套餐与功能目录", response_schema: "EntitlementCatalogResponse") }
paths["/v1/entitlements/current"] = { "get" => operation(tags: ["P1 权益"], id: "getCurrentEntitlement", summary: "读取当前权益快照", permission: "当前熊舍成员可读本舍权益与用量门限", response_schema: "EntitlementSnapshotResponse") }
paths["/v1/entitlements/check"] = { "post" => operation(tags: ["P1 权益"], id: "checkEntitlement", summary: "检查功能或指标权益", permission: "当前熊舍成员可检查本舍功能与指标门限", parameters: [private_key], request: "EntitlementCheckRequest", response_schema: "EntitlementCheckResponse") }
paths["/v1/entitlements/sandbox/activate"] = { "post" => operation(tags: ["P1 权益"], id: "sandboxActivatePlan", summary: "沙箱激活权益套餐", permission: "仅本地或预发布沙箱使用；当前成员可切换模拟套餐", parameters: [private_key], request: "SandboxActivatePlanRequest", response_schema: "EntitlementSnapshotResponse", description: "需要 Bearer 令牌；仅写入 sandbox 来源的权益记录，不代表正式支付或生产订阅。") }

paths["/v1/public-site"] = {
  "get" => operation(tags: ["P2 官网"], id: "getOwnerPublicSite", summary: "读取熊舍公开主页草稿", permission: "当前熊舍成员可读本舍公开主页配置", response_schema: "PublicSiteResponse"),
  "put" => operation(tags: ["P2 官网"], id: "upsertOwnerPublicSite", summary: "保存熊舍公开主页", permission: "当前熊舍成员可保存本舍公开主页配置", parameters: [private_key], request: "UpsertPublicSiteRequest", response_schema: "PublicSiteResponse", include_conflict: true)
}
paths["/v1/public-site/publish"] = { "post" => operation(tags: ["P2 官网"], id: "publishOwnerPublicSite", summary: "发布熊舍公开主页", permission: "当前熊舍成员可发布本舍公开主页", parameters: [private_key], response_schema: "PublicSiteResponse", include_not_found: true, include_conflict: true) }
paths["/v1/public-site/unpublish"] = { "post" => operation(tags: ["P2 官网"], id: "unpublishOwnerPublicSite", summary: "撤下熊舍公开主页", permission: "当前熊舍成员可撤下本舍公开主页", parameters: [private_key], response_schema: "PublicSiteResponse", include_not_found: true, include_conflict: true) }
paths["/v1/public/sites/{slug}"] = { "get" => operation(tags: ["P2 官网"], id: "getPublicSiteBySlug", summary: "读取公开主页投影", permission: "只返回已发布且匹配 slug 的公开主页，不要求登录", parameters: [{ "name" => "slug", "in" => "path", "required" => true, "schema" => { "type" => "string", "minLength" => 2, "maxLength" => 64, "pattern" => "^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$" } }], response_schema: "PublicSiteViewResponse", include_not_found: true, description: "匿名公开读取；仅返回 published=true 的主页投影，未发布或不存在统一返回 404。", security: []) }

paths["/v1/miniprogram/config"] = {
  "get" => operation(tags: ["P2 小程序"], id: "getMiniprogramConfig", summary: "读取小程序配置", permission: "当前熊舍成员可读小程序配置", response_schema: "MiniprogramConfigResponse"),
  "put" => operation(tags: ["P2 小程序"], id: "upsertMiniprogramConfig", summary: "保存小程序配置", permission: "当前熊舍成员可保存小程序配置", parameters: [private_key], request: "UpsertMiniprogramConfigRequest", response_schema: "MiniprogramConfigResponse")
}
paths["/v1/miniprogram/releases"] = {
  "get" => operation(tags: ["P2 小程序"], id: "listMiniprogramReleases", summary: "列出小程序版本", permission: "当前熊舍成员可读小程序发布流水", response_schema: "MiniprogramReleaseListResponse"),
  "post" => operation(tags: ["P2 小程序"], id: "createMiniprogramRelease", summary: "创建小程序版本", permission: "当前熊舍成员可创建小程序草稿版本", parameters: [private_key], request: "CreateMiniprogramReleaseRequest", response_schema: "MiniprogramReleaseResponse", status: "201", include_conflict: true)
}
paths["/v1/miniprogram/releases/{release_id}/submit"] = { "post" => operation(tags: ["P2 小程序"], id: "submitMiniprogramRelease", summary: "提交小程序审核", permission: "当前熊舍成员可提交草稿或驳回版本", parameters: [action_parameter("release_id", "版本 ID"), private_key], response_schema: "MiniprogramReleaseResponse", include_not_found: true, include_conflict: true) }
paths["/v1/miniprogram/releases/{release_id}/audit"] = { "post" => operation(tags: ["P2 小程序"], id: "auditMiniprogramRelease", summary: "审核小程序版本", permission: "当前熊舍成员可在沙箱审核流水中通过或驳回版本", parameters: [action_parameter("release_id", "版本 ID"), private_key], request: "AuditMiniprogramReleaseRequest", response_schema: "MiniprogramReleaseResponse", include_not_found: true, include_conflict: true) }
paths["/v1/miniprogram/releases/{release_id}/publish"] = { "post" => operation(tags: ["P2 小程序"], id: "publishMiniprogramRelease", summary: "发布小程序版本", permission: "当前熊舍成员可发布已审核通过版本", parameters: [action_parameter("release_id", "版本 ID"), private_key], response_schema: "MiniprogramReleaseResponse", include_not_found: true, include_conflict: true) }
paths["/v1/miniprogram/releases/{release_id}/rollback"] = { "post" => operation(tags: ["P2 小程序"], id: "rollbackMiniprogramRelease", summary: "回滚小程序版本", permission: "当前熊舍成员可回滚线上版本", parameters: [action_parameter("release_id", "版本 ID"), private_key], response_schema: "MiniprogramReleaseResponse", include_not_found: true, include_conflict: true) }

paths["/v1/assistant/ask"] = { "post" => operation(tags: ["P2 助手"], id: "askAssistant", summary: "向只读助手提问", permission: "当前熊舍成员可查询本舍结构化数据；助手不修改业务数据", parameters: [private_key], request: "AssistantAskRequest", response_schema: "AssistantAnswerResponse") }
paths["/v1/assistant/capabilities"] = { "get" => operation(tags: ["P2 助手"], id: "assistantCapabilities", summary: "读取助手能力", permission: "当前熊舍成员可读取只读助手能力与可用模式", response_schema: "AssistantCapabilitiesResponse") }

paths["/v1/stud/listings"] = {
  "get" => operation(tags: ["P2 借配"], id: "listStudListings", summary: "列出种公借配挂牌", permission: "当前成员可读公开挂牌及自己的未公开挂牌", parameters: [query_parameter("mine", { "type" => "string", "enum" => ["0", "1"] }, "仅查看自己的挂牌时传 1")], response_schema: "StudListingListResponse"),
  "post" => operation(tags: ["P2 借配"], id: "createStudListing", summary: "创建种公借配挂牌", permission: "当前熊舍成员可创建本舍种公挂牌", parameters: [private_key], request: "CreateStudListingRequest", response_schema: "StudListingResponse", status: "201")
}
paths["/v1/stud/listings/{listing_id}/unpublish"] = { "post" => operation(tags: ["P2 借配"], id: "unpublishStudListing", summary: "撤下种公挂牌", permission: "当前熊舍成员可撤下自己的种公挂牌", parameters: [action_parameter("listing_id", "挂牌 ID"), private_key], response_schema: "StudListingResponse", include_not_found: true, include_conflict: true) }
paths["/v1/stud/deals"] = {
  "get" => operation(tags: ["P2 借配"], id: "listStudDeals", summary: "列出跨舍借配单", permission: "当前熊舍成员可读本舍借配履约记录", response_schema: "StudDealListResponse"),
  "post" => operation(tags: ["P2 借配"], id: "createStudDeal", summary: "创建跨舍借配单", permission: "当前熊舍成员可创建借配履约记录", parameters: [private_key], request: "CreateStudDealRequest", response_schema: "StudDealResponse", status: "201", include_not_found: true)
}
%w[confirm start complete cancel].each do |action|
  next_status = { "confirm" => "确认", "start" => "开始", "complete" => "完成", "cancel" => "取消" }[action]
  paths["/v1/stud/deals/{deal_id}/#{action}"] = { "post" => operation(tags: ["P2 借配"], id: "#{action}StudDeal", summary: "#{next_status}跨舍借配单", permission: "当前熊舍成员可推进本舍借配履约状态", parameters: [action_parameter("deal_id", "借配单 ID"), private_key], response_schema: "StudDealResponse", include_not_found: true, include_conflict: true) }
end

parameters = {
  "P1P2IdempotencyKey" => {
    "name" => "Idempotency-Key", "in" => "header", "required" => false,
    "description" => "P1/P2 写请求建议使用的幂等键；服务端以 owner、方法、路径和规范化载荷记录审计上下文。",
    "schema" => { "type" => "string", "minLength" => 8, "maxLength" => 128 }
  },
  "IfMatchOptional" => {
    "name" => "If-Match", "in" => "header", "required" => false,
    "description" => "可选的当前资源版本 ETag；传入时用于乐观并发控制。",
    "schema" => { "type" => "string", "pattern" => '^W?/"[0-9]+"$' }
  }
}

text = File.read(SPEC)
abort "P1/P2 paths already present" if text.include?("/v1/organization-members")

path_yaml = YAML.dump(paths).sub(/\A---\n/, "").lines.map { |line| "  #{line}" }.join
text = text.sub(/^components:\n/, "#{path_yaml}\ncomponents:\n")

tag_yaml = <<~TAGS
  - name: P1 成员
    description: 熊舍成员邀请、角色和撤销
  - name: P1 CRM
    description: 客户、预订和交付
  - name: P1 合同与回执
    description: 合同与回执模板、单据和签发
  - name: P1 记账
    description: 分类、流水与汇总
  - name: P1 遗传
    description: 遗传位点、档案和配对模拟
  - name: P1 推送
    description: 设备令牌与推送审计
  - name: P1 权益
    description: 套餐、用量门限和沙箱激活
  - name: P2 官网
    description: 公开主页配置、发布和匿名投影
  - name: P2 小程序
    description: 小程序配置与沙箱审核流水
  - name: P2 助手
    description: 只读数据助手
  - name: P2 借配
    description: 种公挂牌与跨舍借配履约
TAGS
tag_yaml = tag_yaml.lines.map { |line| line.strip.empty? ? line : "  #{line}" }.join
text = text.sub(/^security:\n/, "#{tag_yaml}security:\n")

schema_yaml = YAML.dump(schemas).sub(/\A---\n/, "").lines.map { |line| "    #{line}" }.join
text = text.rstrip + "\n" + schema_yaml

component_param_yaml = YAML.dump(parameters).sub(/\A---\n/, "").lines.map { |line| "    #{line}" }.join
component_start = text.index("components:\n")
marker = text.index("  parameters:\n", component_start)
abort "components.parameters anchor not found" unless marker
insert_at = marker + "  parameters:\n".length
text = text[0...insert_at] + component_param_yaml + text[insert_at..]

File.write(SPEC, text)
puts "added #{paths.length} P1/P2 paths and #{schemas.length} schemas"
