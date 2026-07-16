-- Generated from specs/database/schema.sql; do not edit this migration by hand.
BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TYPE dictionary_scope AS ENUM ('system', 'owner');
CREATE TYPE account_status AS ENUM ('active', 'suspended', 'closed');
CREATE TYPE organization_mode AS ENUM ('personal', 'professional');
CREATE TYPE species_rule_status AS ENUM ('draft', 'published', 'retired');
CREATE TYPE sex_code AS ENUM ('male', 'female', 'unknown');
CREATE TYPE hamster_source_type AS ENUM ('born_here', 'introduced', 'customer', 'imported');
CREATE TYPE hamster_lifecycle_status AS ENUM ('active', 'transferred', 'retired', 'deceased');
CREATE TYPE hamster_breeding_status AS ENUM ('candidate', 'active', 'resting', 'retired');
CREATE TYPE enclosure_state AS ENUM (
  'vacant', 'occupied_single', 'pairing_temp', 'gestation',
  'dam_with_litter', 'isolation', 'cleaning_due', 'disabled'
);
CREATE TYPE cleanliness_state AS ENUM ('clean', 'partial_due', 'full_due');
CREATE TYPE enclosure_stay_purpose AS ENUM (
  'single', 'pairing_temp', 'gestation', 'isolation', 'dam_with_litter'
);
CREATE TYPE enclosure_cleaning_type AS ENUM ('partial', 'full', 'disinfection');
CREATE TYPE breeding_plan_state AS ENUM (
  'draft', 'pair_ready', 'pairing', 'post_pair', 'gestation',
  'litter_nursing', 'weaning_due',
  'sex_separation_due', 'individualizing', 'completed',
  'no_litter_outcome', 'hold', 'unsuccessful', 'cancelled'
);
CREATE TYPE pairing_attempt_status AS ENUM ('active', 'separated', 'safety_hold', 'cancelled');
CREATE TYPE pairing_result AS ENUM ('effective', 'uncertain', 'ineffective', 'safety_stop');
CREATE TYPE mating_observation_type AS ENUM (
  'contact', 'chase', 'conflict', 'mating', 'separated', 'other'
);
CREATE TYPE severity_level AS ENUM ('info', 'low', 'medium', 'high', 'critical');
CREATE TYPE litter_state AS ENUM (
  'newborn', 'nursing', 'weaning_due', 'sexing_due',
  'individualizing', 'closed', 'voided'
);
CREATE TYPE litter_origin AS ENUM ('breeding', 'import');
CREATE TYPE litter_count_event_type AS ENUM (
  'initial_alive', 'discovered', 'death', 'transferred_out', 'correction'
);
CREATE TYPE pup_profile_status AS ENUM ('unindividualized', 'individualized', 'voided');
CREATE TYPE pup_outcome_status AS ENUM ('alive', 'deceased', 'transferred_out');
CREATE TYPE relationship_evidence_type AS ENUM (
  'system', 'litter_inferred', 'manual', 'imported', 'document', 'dna'
);
CREATE TYPE relationship_status AS ENUM ('pending', 'accepted', 'rejected', 'superseded');
CREATE TYPE parent_role AS ENUM ('sire', 'dam');
CREATE TYPE relationship_assertion_kind AS ENUM (
  'parentage', 'litter_parent', 'litter_member', 'sibling'
);
CREATE TYPE relationship_subject_type AS ENUM (
  'hamster', 'litter', 'pup_identity', 'external_reference'
);
CREATE TYPE litter_member_type AS ENUM ('pup_identity', 'hamster');
CREATE TYPE measurement_source AS ENUM ('manual', 'bluetooth_scale', 'import');
CREATE TYPE weight_subject_type AS ENUM ('hamster', 'pup_identity', 'litter');
CREATE TYPE weight_measurement_kind AS ENUM ('individual', 'litter_total', 'litter_average');
CREATE TYPE health_subject_type AS ENUM ('hamster', 'pup_identity', 'litter', 'enclosure');
CREATE TYPE health_record_type AS ENUM (
  'daily_check', 'anomaly', 'medication', 'follow_up', 'isolation', 'death'
);
CREATE TYPE care_task_type AS ENUM (
  'pair_prep', 'pairing_timeout', 'separate_now',
  'gestation_window_open', 'gestation_window_close', 'no_birth_review',
  'litter_observation', 'pup_weight_check', 'pup_weight_drop',
  'weaning_due', 'sex_separation_due', 'sex_recheck',
  'profile_creation_due', 'cleaning', 'medication', 'follow_up', 'custom'
);
CREATE TYPE care_task_target_type AS ENUM (
  'organization', 'hamster', 'litter', 'enclosure',
  'breeding_plan', 'pairing_attempt', 'pup_identity'
);
CREATE TYPE care_task_subject_type AS ENUM ('hamster', 'pup_identity');
CREATE TYPE task_priority AS ENUM ('low', 'normal', 'high', 'urgent', 'critical');
CREATE TYPE task_status AS ENUM (
  'pending', 'in_progress', 'completed', 'snoozed', 'cancelled', 'superseded'
);
CREATE TYPE delivery_channel AS ENUM ('in_app', 'local_notification', 'app_push', 'service_account');
CREATE TYPE delivery_status AS ENUM ('queued', 'sending', 'succeeded', 'failed', 'read', 'cancelled');
CREATE TYPE outbox_status AS ENUM ('pending', 'processing', 'published', 'failed', 'dead_letter');
CREATE TYPE async_job_type AS ENUM (
  'import', 'export', 'backup', 'media_transform', 'usage_snapshot', 'share_render'
);
CREATE TYPE async_job_status AS ENUM ('queued', 'running', 'succeeded', 'failed', 'cancelled');
CREATE TYPE media_kind AS ENUM ('image', 'video', 'document');
CREATE TYPE media_upload_status AS ENUM (
  'pending_upload', 'uploaded', 'processing', 'ready', 'failed', 'quarantined'
);
CREATE TYPE media_variant_kind AS ENUM (
  'thumbnail', 'preview', 'image_edit', 'video_transcode', 'video_cover', 'share_render'
);
CREATE TYPE media_variant_status AS ENUM ('queued', 'processing', 'ready', 'failed');
CREATE TYPE media_target_type AS ENUM (
  'hamster', 'litter', 'health_record', 'mating_observation',
  'pairing_attempt', 'breeding_plan', 'enclosure', 'domain_event', 'share_page'
);
CREATE TYPE media_link_role AS ENUM ('cover', 'gallery', 'attachment', 'timeline', 'share');
CREATE TYPE share_target_type AS ENUM ('hamster', 'litter');
CREATE TYPE import_template_type AS ENUM ('hamster', 'enclosure', 'weight');
CREATE TYPE import_job_status AS ENUM (
  'uploaded', 'mapping', 'prechecking', 'ready', 'applying',
  'succeeded', 'partially_succeeded', 'failed', 'cancelled'
);
CREATE TYPE import_row_status AS ENUM ('pending', 'valid', 'invalid', 'imported', 'skipped', 'failed');
CREATE TYPE import_issue_severity AS ENUM ('warning', 'error');
CREATE TYPE export_format AS ENUM ('csv', 'json', 'pdf', 'zip');
CREATE TYPE export_scope AS ENUM (
  'hamsters', 'enclosures', 'breeding', 'litters',
  'weights', 'health', 'pedigree', 'full'
);
CREATE TYPE backup_kind AS ENUM ('full', 'incremental');
CREATE TYPE entitlement_value_type AS ENUM ('boolean', 'integer', 'decimal', 'json');
CREATE TYPE usage_metric AS ENUM (
  'active_hamsters', 'active_litters', 'enclosures',
  'media_bytes', 'video_minutes', 'backup_bytes'
);
CREATE TYPE idempotency_status AS ENUM ('processing', 'completed', 'failed');

COMMIT;
