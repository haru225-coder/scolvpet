-- Generated from specs/database/schema.sql; do not edit this migration by hand.
BEGIN;

CREATE TABLE litter_count_event (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  litter_id uuid NOT NULL,
  pup_identity_id uuid,
  event_type litter_count_event_type NOT NULL,
  delta integer NOT NULL,
  occurred_at timestamptz NOT NULL,
  reason text,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  source_event_id uuid,
  corrects_count_event_id uuid,
  idempotency_key varchar(160) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_litter_count_event_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_litter_count_event_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_count_event_pup
    FOREIGN KEY (owner_id, pup_identity_id)
    REFERENCES pup_identity(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_count_event_domain_event
    FOREIGN KEY (owner_id, source_event_id)
    REFERENCES domain_event(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_count_event_correction
    FOREIGN KEY (owner_id, corrects_count_event_id)
    REFERENCES litter_count_event(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_litter_count_event_idempotency UNIQUE (owner_id, idempotency_key),
  CONSTRAINT ck_litter_count_event_delta CHECK (
    (event_type = 'initial_alive' AND delta > 0)
    OR (event_type = 'discovered' AND delta > 0)
    OR (event_type IN ('death', 'transferred_out') AND delta < 0)
    OR (event_type = 'correction' AND delta <> 0)
  ),
  CONSTRAINT ck_litter_count_event_reason CHECK (
    event_type = 'initial_alive' OR reason IS NOT NULL
  )
);

CREATE UNIQUE INDEX ux_litter_count_initial
  ON litter_count_event (owner_id, litter_id)
  WHERE event_type = 'initial_alive';

CREATE INDEX ix_litter_count_event_time
  ON litter_count_event (owner_id, litter_id, occurred_at, created_at);

CREATE TABLE weight_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  subject_type weight_subject_type NOT NULL,
  hamster_id uuid,
  pup_identity_id uuid,
  litter_id uuid,
  measurement_kind weight_measurement_kind NOT NULL,
  subject_count integer,
  weight_g numeric(10,2) NOT NULL CHECK (weight_g > 0),
  recorded_at timestamptz NOT NULL,
  source measurement_source NOT NULL,
  acquisition_key varchar(160),
  species_rule_version_id uuid REFERENCES species_rule_version(id) ON DELETE RESTRICT,
  birth_weight_g numeric(10,2) CHECK (birth_weight_g > 0),
  previous_weight_g numeric(10,2) CHECK (previous_weight_g > 0),
  change_from_birth_g numeric(10,2),
  change_from_previous_g numeric(10,2),
  alert_flags jsonb NOT NULL DEFAULT '[]'::jsonb,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  corrects_weight_record_id uuid,
  correction_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_weight_record_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_weight_record_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_weight_record_hamster
    FOREIGN KEY (owner_id, hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_weight_record_pup
    FOREIGN KEY (owner_id, pup_identity_id)
    REFERENCES pup_identity(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_weight_record_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_weight_record_correction
    FOREIGN KEY (owner_id, corrects_weight_record_id)
    REFERENCES weight_record(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_weight_record_subject CHECK (
    (subject_type = 'hamster' AND hamster_id IS NOT NULL
      AND pup_identity_id IS NULL AND litter_id IS NULL
      AND measurement_kind = 'individual' AND subject_count IS NULL)
    OR
    (subject_type = 'pup_identity' AND pup_identity_id IS NOT NULL
      AND hamster_id IS NULL AND litter_id IS NULL
      AND measurement_kind = 'individual' AND subject_count IS NULL)
    OR
    (subject_type = 'litter' AND litter_id IS NOT NULL
      AND hamster_id IS NULL AND pup_identity_id IS NULL
      AND measurement_kind IN ('litter_total', 'litter_average')
      AND subject_count IS NOT NULL AND subject_count > 0)
  ),
  CONSTRAINT ck_weight_record_correction CHECK (
    corrects_weight_record_id IS NULL OR correction_reason IS NOT NULL
  )
);

CREATE UNIQUE INDEX ux_weight_record_acquisition
  ON weight_record (owner_id, acquisition_key)
  WHERE acquisition_key IS NOT NULL;

CREATE INDEX ix_weight_record_hamster_time
  ON weight_record (owner_id, hamster_id, recorded_at DESC)
  WHERE hamster_id IS NOT NULL;

CREATE INDEX ix_weight_record_pup_time
  ON weight_record (owner_id, pup_identity_id, recorded_at DESC)
  WHERE pup_identity_id IS NOT NULL;

CREATE INDEX ix_weight_record_litter_time
  ON weight_record (owner_id, litter_id, recorded_at DESC)
  WHERE litter_id IS NOT NULL;

CREATE TABLE health_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  subject_type health_subject_type NOT NULL,
  hamster_id uuid,
  pup_identity_id uuid,
  litter_id uuid,
  enclosure_id uuid,
  record_type health_record_type NOT NULL,
  observed_at timestamptz NOT NULL,
  structured_checks jsonb NOT NULL DEFAULT '{}'::jsonb,
  severity severity_level,
  medication jsonb NOT NULL DEFAULT '{}'::jsonb,
  follow_up_at timestamptz,
  notes text,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  corrects_health_record_id uuid,
  correction_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_health_record_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_health_record_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_health_record_hamster
    FOREIGN KEY (owner_id, hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_health_record_pup
    FOREIGN KEY (owner_id, pup_identity_id)
    REFERENCES pup_identity(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_health_record_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_health_record_enclosure
    FOREIGN KEY (owner_id, enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_health_record_correction
    FOREIGN KEY (owner_id, corrects_health_record_id)
    REFERENCES health_record(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_health_record_subject CHECK (
    (subject_type = 'hamster' AND hamster_id IS NOT NULL
      AND pup_identity_id IS NULL AND litter_id IS NULL AND enclosure_id IS NULL)
    OR
    (subject_type = 'pup_identity' AND pup_identity_id IS NOT NULL
      AND hamster_id IS NULL AND litter_id IS NULL AND enclosure_id IS NULL)
    OR
    (subject_type = 'litter' AND litter_id IS NOT NULL
      AND hamster_id IS NULL AND pup_identity_id IS NULL AND enclosure_id IS NULL)
    OR
    (subject_type = 'enclosure' AND enclosure_id IS NOT NULL
      AND hamster_id IS NULL AND pup_identity_id IS NULL AND litter_id IS NULL)
  ),
  CONSTRAINT ck_health_record_follow_up CHECK (
    follow_up_at IS NULL OR follow_up_at >= observed_at
  ),
  CONSTRAINT ck_health_record_correction CHECK (
    corrects_health_record_id IS NULL OR correction_reason IS NOT NULL
  )
);

CREATE INDEX ix_health_record_hamster_time
  ON health_record (owner_id, hamster_id, observed_at DESC)
  WHERE hamster_id IS NOT NULL;

CREATE INDEX ix_health_record_pup_time
  ON health_record (owner_id, pup_identity_id, observed_at DESC)
  WHERE pup_identity_id IS NOT NULL;

CREATE INDEX ix_health_record_litter_time
  ON health_record (owner_id, litter_id, observed_at DESC)
  WHERE litter_id IS NOT NULL;

COMMIT;
