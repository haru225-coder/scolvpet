-- T-P1-06 genetic phenotype profiles (minimal).
BEGIN;

CREATE TYPE genetic_confidence AS ENUM ('observed', 'inferred', 'unknown');

CREATE TABLE genetic_profile (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  hamster_id uuid,
  name varchar(120) NOT NULL,
  phenotype jsonb NOT NULL DEFAULT '{}'::jsonb,
  genotype jsonb NOT NULL DEFAULT '{}'::jsonb,
  confidence genetic_confidence NOT NULL DEFAULT 'unknown',
  notes text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_genetic_profile_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_genetic_profile_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE INDEX ix_genetic_profile_owner_updated
  ON genetic_profile (owner_id, updated_at DESC);

CREATE INDEX ix_genetic_profile_owner_hamster
  ON genetic_profile (owner_id, hamster_id)
  WHERE hamster_id IS NOT NULL;

COMMIT;
