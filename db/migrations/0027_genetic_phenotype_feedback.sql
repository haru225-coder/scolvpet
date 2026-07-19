-- T-P1-06 phenotype feedback: actual litter counts vs core-table prediction.
BEGIN;

CREATE TABLE genetic_phenotype_feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  breeding_plan_id uuid,
  litter_id uuid,
  series varchar(40) NOT NULL,
  sire_phenotype varchar(120) NOT NULL,
  dam_phenotype varchar(120) NOT NULL,
  total_actual integer NOT NULL CHECK (total_actual > 0),
  actual_counts jsonb NOT NULL DEFAULT '{}'::jsonb,
  mean_abs_error double precision NOT NULL DEFAULT 0,
  total_variation double precision NOT NULL DEFAULT 0,
  compare_rows jsonb NOT NULL DEFAULT '[]'::jsonb,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_genetic_phenotype_feedback_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE INDEX ix_genetic_phenotype_feedback_owner_created
  ON genetic_phenotype_feedback (owner_id, created_at DESC);

CREATE INDEX ix_genetic_phenotype_feedback_owner_pair
  ON genetic_phenotype_feedback (owner_id, series, sire_phenotype, dam_phenotype);

COMMIT;
