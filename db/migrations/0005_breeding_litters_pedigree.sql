-- Generated from specs/database/schema.sql; do not edit this migration by hand.
BEGIN;

CREATE TABLE breeding_plan (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  name varchar(160),
  sire_id uuid NOT NULL,
  dam_id uuid NOT NULL,
  species_rule_version_id uuid NOT NULL REFERENCES species_rule_version(id) ON DELETE RESTRICT,
  state breeding_plan_state NOT NULL DEFAULT 'draft',
  planned_pairing_at timestamptz,
  mating_baseline_at timestamptz,
  expected_birth_start date,
  expected_birth_end date,
  actual_birth_at timestamptz,
  birth_result_alive_count integer CHECK (birth_result_alive_count >= 0),
  birth_result_other_count integer CHECK (birth_result_other_count >= 0),
  birth_result_reason text,
  birth_dam_condition jsonb NOT NULL DEFAULT '{}'::jsonb,
  objective_traits jsonb NOT NULL DEFAULT '{}'::jsonb,
  kinship_check jsonb NOT NULL DEFAULT '{}'::jsonb,
  eligibility_override_reason text,
  date_correction_note text,
  notes text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_breeding_plan_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_breeding_plan_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_breeding_plan_sire
    FOREIGN KEY (owner_id, sire_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_breeding_plan_dam
    FOREIGN KEY (owner_id, dam_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_breeding_plan_parents CHECK (sire_id <> dam_id),
  CONSTRAINT ck_breeding_plan_birth_window CHECK (
    expected_birth_start IS NULL OR expected_birth_end IS NULL
    OR expected_birth_start <= expected_birth_end
  ),
  CONSTRAINT ck_breeding_plan_no_litter_outcome CHECK (
    state <> 'no_litter_outcome'
    OR (
      actual_birth_at IS NOT NULL
      AND birth_result_alive_count = 0
      AND birth_result_other_count IS NOT NULL
      AND NULLIF(btrim(birth_result_reason), '') IS NOT NULL
    )
  )
);

CREATE INDEX ix_breeding_plan_state_time
  ON breeding_plan (owner_id, state, planned_pairing_at)
  WHERE deleted_at IS NULL;

CREATE TABLE pairing_attempt (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  breeding_plan_id uuid NOT NULL,
  attempt_no integer NOT NULL CHECK (attempt_no > 0),
  sire_id uuid NOT NULL,
  dam_id uuid NOT NULL,
  pairing_enclosure_id uuid NOT NULL,
  status pairing_attempt_status NOT NULL DEFAULT 'active',
  started_at timestamptz NOT NULL,
  separation_deadline timestamptz NOT NULL,
  ended_at timestamptz,
  separated_at timestamptz,
  result pairing_result,
  conflict_level severity_level,
  sire_destination_enclosure_id uuid,
  dam_destination_enclosure_id uuid,
  evidence_note text,
  notes text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_pairing_attempt_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_pairing_attempt_plan
    FOREIGN KEY (owner_id, breeding_plan_id)
    REFERENCES breeding_plan(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pairing_attempt_sire
    FOREIGN KEY (owner_id, sire_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pairing_attempt_dam
    FOREIGN KEY (owner_id, dam_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pairing_attempt_enclosure
    FOREIGN KEY (owner_id, pairing_enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pairing_attempt_sire_destination
    FOREIGN KEY (owner_id, sire_destination_enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pairing_attempt_dam_destination
    FOREIGN KEY (owner_id, dam_destination_enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_pairing_attempt_sequence UNIQUE (owner_id, breeding_plan_id, attempt_no),
  CONSTRAINT ck_pairing_attempt_parents CHECK (sire_id <> dam_id),
  CONSTRAINT ck_pairing_attempt_deadline CHECK (separation_deadline > started_at),
  CONSTRAINT ck_pairing_attempt_end CHECK (ended_at IS NULL OR ended_at >= started_at),
  CONSTRAINT ck_pairing_attempt_separated_at CHECK (
    separated_at IS NULL OR separated_at >= started_at
  ),
  CONSTRAINT ck_pairing_attempt_closed CHECK (
    status <> 'separated'
    OR (
      ended_at IS NOT NULL AND separated_at IS NOT NULL AND result IS NOT NULL
      AND sire_destination_enclosure_id IS NOT NULL
      AND dam_destination_enclosure_id IS NOT NULL
    )
  ),
  CONSTRAINT ck_pairing_attempt_destinations CHECK (
    sire_destination_enclosure_id IS NULL OR dam_destination_enclosure_id IS NULL
    OR sire_destination_enclosure_id <> dam_destination_enclosure_id
  )
);

CREATE UNIQUE INDEX ux_pairing_attempt_active_plan
  ON pairing_attempt (owner_id, breeding_plan_id)
  WHERE status IN ('active', 'safety_hold') AND deleted_at IS NULL;

CREATE INDEX ix_pairing_attempt_participants
  ON pairing_attempt (owner_id, sire_id, dam_id, status)
  WHERE deleted_at IS NULL;

CREATE TABLE enclosure_stay (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  enclosure_id uuid NOT NULL,
  hamster_id uuid NOT NULL,
  pairing_attempt_id uuid,
  purpose enclosure_stay_purpose NOT NULL,
  started_at timestamptz NOT NULL,
  ended_at timestamptz,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  reason text,
  correction_note text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_enclosure_stay_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_enclosure_stay_enclosure
    FOREIGN KEY (owner_id, enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_enclosure_stay_hamster
    FOREIGN KEY (owner_id, hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_enclosure_stay_pairing
    FOREIGN KEY (owner_id, pairing_attempt_id)
    REFERENCES pairing_attempt(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_enclosure_stay_time CHECK (ended_at IS NULL OR ended_at > started_at),
  CONSTRAINT ck_enclosure_stay_pairing_reference CHECK (
    (purpose = 'pairing_temp' AND pairing_attempt_id IS NOT NULL)
    OR (purpose <> 'pairing_temp' AND pairing_attempt_id IS NULL)
  )
);

CREATE INDEX ix_enclosure_stay_enclosure_period
  ON enclosure_stay USING gist (
    owner_id, enclosure_id, tstzrange(started_at, ended_at, '[)')
  ) WHERE deleted_at IS NULL;

CREATE INDEX ix_enclosure_stay_hamster_period
  ON enclosure_stay USING gist (
    owner_id, hamster_id, tstzrange(started_at, ended_at, '[)')
  ) WHERE deleted_at IS NULL;

CREATE TABLE enclosure_cleaning_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  enclosure_id uuid NOT NULL,
  cleaning_type enclosure_cleaning_type NOT NULL,
  performed_at timestamptz NOT NULL,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  source_event_id uuid,
  supplies jsonb NOT NULL DEFAULT '{}'::jsonb,
  notes text,
  corrects_cleaning_record_id uuid,
  correction_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_enclosure_cleaning_record_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_enclosure_cleaning_record_enclosure
    FOREIGN KEY (owner_id, enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_enclosure_cleaning_record_event
    FOREIGN KEY (owner_id, source_event_id)
    REFERENCES domain_event(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_enclosure_cleaning_record_correction
    FOREIGN KEY (owner_id, corrects_cleaning_record_id)
    REFERENCES enclosure_cleaning_record(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_enclosure_cleaning_record_correction CHECK (
    corrects_cleaning_record_id IS NULL OR correction_reason IS NOT NULL
  )
);

CREATE INDEX ix_enclosure_cleaning_time
  ON enclosure_cleaning_record (owner_id, enclosure_id, performed_at DESC);

CREATE TABLE mating_observation (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  pairing_attempt_id uuid NOT NULL,
  observed_at timestamptz NOT NULL,
  observation_type mating_observation_type NOT NULL,
  duration_seconds integer CHECK (duration_seconds >= 0),
  severity severity_level,
  confidence numeric(5,4),
  note text,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_mating_observation_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_mating_observation_pairing
    FOREIGN KEY (owner_id, pairing_attempt_id)
    REFERENCES pairing_attempt(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_mating_observation_confidence CHECK (
    confidence IS NULL OR confidence BETWEEN 0 AND 1
  )
);

CREATE INDEX ix_mating_observation_attempt_time
  ON mating_observation (owner_id, pairing_attempt_id, observed_at DESC)
  WHERE deleted_at IS NULL;

CREATE TABLE litter (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  breeding_plan_id uuid,
  origin litter_origin NOT NULL DEFAULT 'breeding',
  code varchar(80) NOT NULL,
  state litter_state NOT NULL DEFAULT 'newborn',
  born_at timestamptz,
  enclosure_id uuid,
  dam_condition jsonb NOT NULL DEFAULT '{}'::jsonb,
  initial_alive_count integer NOT NULL DEFAULT 0,
  initial_other_count integer NOT NULL DEFAULT 0,
  discovered_count integer NOT NULL DEFAULT 0,
  deceased_count integer NOT NULL DEFAULT 0,
  transferred_out_count integer NOT NULL DEFAULT 0,
  correction_delta integer NOT NULL DEFAULT 0,
  current_managed_count integer NOT NULL DEFAULT 0,
  unindividualized_alive_count integer NOT NULL DEFAULT 0,
  individualized_alive_count integer NOT NULL DEFAULT 0,
  weaning_completed_at timestamptz,
  sex_separation_completed_at timestamptz,
  reconciled_at timestamptz,
  notes text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_litter_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_litter_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_plan
    FOREIGN KEY (owner_id, breeding_plan_id)
    REFERENCES breeding_plan(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_enclosure
    FOREIGN KEY (owner_id, enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_litter_counts_nonnegative CHECK (
    initial_alive_count >= 0 AND initial_other_count >= 0
    AND discovered_count >= 0 AND deceased_count >= 0
    AND transferred_out_count >= 0 AND current_managed_count >= 0
    AND unindividualized_alive_count >= 0 AND individualized_alive_count >= 0
  ),
  CONSTRAINT ck_litter_origin CHECK (
    (origin = 'breeding' AND breeding_plan_id IS NOT NULL
      AND born_at IS NOT NULL AND enclosure_id IS NOT NULL)
    OR
    (origin = 'import' AND breeding_plan_id IS NULL
      AND state = 'closed' AND enclosure_id IS NULL)
  )
);

CREATE UNIQUE INDEX ux_litter_owner_code_active
  ON litter (owner_id, code)
  WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX ux_litter_one_effective_per_plan
  ON litter (owner_id, breeding_plan_id)
  WHERE breeding_plan_id IS NOT NULL AND state <> 'voided' AND deleted_at IS NULL;

CREATE INDEX ix_litter_state_born_at
  ON litter (owner_id, state, born_at DESC)
  WHERE deleted_at IS NULL;

CREATE TABLE pup_identity (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  litter_id uuid NOT NULL,
  temporary_code varchar(80) NOT NULL,
  sex sex_code NOT NULL DEFAULT 'unknown',
  sex_confidence numeric(5,4),
  profile_status pup_profile_status NOT NULL DEFAULT 'unindividualized',
  outcome_status pup_outcome_status NOT NULL DEFAULT 'alive',
  weaned_at timestamptz,
  current_enclosure_id uuid,
  individualized_hamster_id uuid,
  phenotype_summary jsonb NOT NULL DEFAULT '{}'::jsonb,
  destination_code varchar(80),
  status_reason text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_pup_identity_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_pup_identity_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pup_identity_enclosure
    FOREIGN KEY (owner_id, current_enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pup_identity_hamster
    FOREIGN KEY (owner_id, individualized_hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_pup_identity_sex_confidence CHECK (
    sex_confidence IS NULL OR sex_confidence BETWEEN 0 AND 1
  ),
  CONSTRAINT ck_pup_identity_individualization CHECK (
    (profile_status = 'individualized' AND individualized_hamster_id IS NOT NULL)
    OR (profile_status <> 'individualized' AND individualized_hamster_id IS NULL)
  )
);

CREATE UNIQUE INDEX ux_pup_identity_temp_code_active
  ON pup_identity (owner_id, litter_id, temporary_code)
  WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX ux_pup_identity_hamster_one_to_one
  ON pup_identity (owner_id, individualized_hamster_id)
  WHERE individualized_hamster_id IS NOT NULL AND deleted_at IS NULL;

CREATE INDEX ix_pup_identity_litter_status
  ON pup_identity (owner_id, litter_id, profile_status, outcome_status)
  WHERE deleted_at IS NULL;

CREATE TABLE relationship_assertion (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  assertion_kind relationship_assertion_kind NOT NULL,
  subject_type relationship_subject_type NOT NULL,
  subject_id uuid,
  related_type relationship_subject_type NOT NULL,
  related_id uuid,
  relationship_role varchar(80),
  raw_reference jsonb NOT NULL DEFAULT '{}'::jsonb,
  evidence_type relationship_evidence_type NOT NULL,
  evidence_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  confidence numeric(5,4),
  status relationship_status NOT NULL DEFAULT 'pending',
  valid_from timestamptz NOT NULL DEFAULT now(),
  valid_to timestamptz,
  corrects_assertion_id uuid,
  review_note text,
  reviewed_by uuid REFERENCES account(id) ON DELETE SET NULL,
  reviewed_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_relationship_assertion_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_relationship_assertion_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_relationship_assertion_correction
    FOREIGN KEY (owner_id, corrects_assertion_id)
    REFERENCES relationship_assertion(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_relationship_assertion_confidence CHECK (
    confidence IS NULL OR confidence BETWEEN 0 AND 1
  ),
  CONSTRAINT ck_relationship_assertion_validity CHECK (
    valid_to IS NULL OR valid_to > valid_from
  ),
  CONSTRAINT ck_relationship_assertion_reference CHECK (
    ((subject_type = 'external_reference' AND subject_id IS NULL)
      OR (subject_type <> 'external_reference' AND subject_id IS NOT NULL))
    AND
    ((related_type = 'external_reference' AND related_id IS NULL)
      OR (related_type <> 'external_reference' AND related_id IS NOT NULL))
  )
);

CREATE INDEX ix_relationship_assertion_review
  ON relationship_assertion (owner_id, status, assertion_kind, created_at)
  WHERE status = 'pending';

CREATE TABLE pedigree_parentage (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  parent_id uuid NOT NULL,
  child_id uuid NOT NULL,
  role parent_role NOT NULL,
  evidence_type relationship_evidence_type NOT NULL,
  evidence_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  confidence numeric(5,4) NOT NULL DEFAULT 1,
  status relationship_status NOT NULL DEFAULT 'accepted',
  valid_from timestamptz NOT NULL DEFAULT now(),
  valid_to timestamptz,
  relationship_assertion_id uuid,
  corrects_parentage_id uuid,
  correction_note text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_pedigree_parentage_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_pedigree_parentage_parent
    FOREIGN KEY (owner_id, parent_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pedigree_parentage_child
    FOREIGN KEY (owner_id, child_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pedigree_parentage_assertion
    FOREIGN KEY (owner_id, relationship_assertion_id)
    REFERENCES relationship_assertion(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pedigree_parentage_correction
    FOREIGN KEY (owner_id, corrects_parentage_id)
    REFERENCES pedigree_parentage(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_pedigree_parentage_distinct CHECK (parent_id <> child_id),
  CONSTRAINT ck_pedigree_parentage_confidence CHECK (confidence BETWEEN 0 AND 1),
  CONSTRAINT ck_pedigree_parentage_validity CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE UNIQUE INDEX ux_pedigree_parentage_active_role
  ON pedigree_parentage (owner_id, child_id, role)
  WHERE status = 'accepted' AND valid_to IS NULL;

CREATE INDEX ix_pedigree_parentage_parent_active
  ON pedigree_parentage (owner_id, parent_id, child_id)
  WHERE status = 'accepted' AND valid_to IS NULL;

CREATE TABLE litter_parent (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  litter_id uuid NOT NULL,
  parent_id uuid NOT NULL,
  role parent_role NOT NULL,
  evidence_type relationship_evidence_type NOT NULL DEFAULT 'litter_inferred',
  evidence_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  confidence numeric(5,4) NOT NULL DEFAULT 1,
  status relationship_status NOT NULL DEFAULT 'accepted',
  valid_from timestamptz NOT NULL DEFAULT now(),
  valid_to timestamptz,
  relationship_assertion_id uuid,
  corrects_litter_parent_id uuid,
  correction_note text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_litter_parent_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_litter_parent_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_parent_hamster
    FOREIGN KEY (owner_id, parent_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_parent_assertion
    FOREIGN KEY (owner_id, relationship_assertion_id)
    REFERENCES relationship_assertion(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_parent_correction
    FOREIGN KEY (owner_id, corrects_litter_parent_id)
    REFERENCES litter_parent(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_litter_parent_confidence CHECK (confidence BETWEEN 0 AND 1),
  CONSTRAINT ck_litter_parent_validity CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE UNIQUE INDEX ux_litter_parent_active_role
  ON litter_parent (owner_id, litter_id, role)
  WHERE status = 'accepted' AND valid_to IS NULL;

CREATE TABLE litter_member (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  litter_id uuid NOT NULL,
  member_type litter_member_type NOT NULL,
  pup_identity_id uuid,
  hamster_id uuid,
  origin_pup_identity_id uuid,
  evidence_type relationship_evidence_type NOT NULL DEFAULT 'litter_inferred',
  evidence_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  confidence numeric(5,4) NOT NULL DEFAULT 1,
  status relationship_status NOT NULL DEFAULT 'accepted',
  valid_from timestamptz NOT NULL DEFAULT now(),
  valid_to timestamptz,
  relationship_assertion_id uuid,
  corrects_litter_member_id uuid,
  correction_note text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_litter_member_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_litter_member_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_member_pup
    FOREIGN KEY (owner_id, pup_identity_id)
    REFERENCES pup_identity(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_member_hamster
    FOREIGN KEY (owner_id, hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_member_origin_pup
    FOREIGN KEY (owner_id, origin_pup_identity_id)
    REFERENCES pup_identity(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_member_assertion
    FOREIGN KEY (owner_id, relationship_assertion_id)
    REFERENCES relationship_assertion(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_member_correction
    FOREIGN KEY (owner_id, corrects_litter_member_id)
    REFERENCES litter_member(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_litter_member_target CHECK (
    (member_type = 'pup_identity' AND pup_identity_id IS NOT NULL
      AND hamster_id IS NULL AND origin_pup_identity_id IS NULL)
    OR
    (member_type = 'hamster' AND hamster_id IS NOT NULL AND pup_identity_id IS NULL)
  ),
  CONSTRAINT ck_litter_member_confidence CHECK (confidence BETWEEN 0 AND 1),
  CONSTRAINT ck_litter_member_validity CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE UNIQUE INDEX ux_litter_member_active_pup
  ON litter_member (owner_id, pup_identity_id)
  WHERE pup_identity_id IS NOT NULL AND status = 'accepted' AND valid_to IS NULL;

CREATE UNIQUE INDEX ux_litter_member_active_hamster
  ON litter_member (owner_id, hamster_id)
  WHERE hamster_id IS NOT NULL AND status = 'accepted' AND valid_to IS NULL;

CREATE UNIQUE INDEX ux_litter_member_origin_pup
  ON litter_member (owner_id, origin_pup_identity_id)
  WHERE origin_pup_identity_id IS NOT NULL AND status = 'accepted' AND valid_to IS NULL;

COMMIT;
