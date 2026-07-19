-- AI 获客闭环 P0：公开仓鼠资料、内容活动、公开咨询与 CRM 来源归因。
BEGIN;

CREATE TABLE hamster_public_profile (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  hamster_id uuid NOT NULL,
  public_name varchar(160),
  summary text,
  traits jsonb NOT NULL DEFAULT '[]'::jsonb,
  filming_status varchar(24) NOT NULL DEFAULT 'rest',
  published boolean NOT NULL DEFAULT false,
  consultable boolean NOT NULL DEFAULT false,
  cta_text varchar(160),
  price_label varchar(120),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_hamster_public_profile_owner_hamster UNIQUE (owner_id, hamster_id),
  CONSTRAINT uq_hamster_public_profile_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_hamster_public_profile_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_hamster_public_profile_hamster
    FOREIGN KEY (owner_id, hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_hamster_public_profile_filming_status
    CHECK (filming_status IN ('ready', 'rest', 'restricted')),
  CONSTRAINT ck_hamster_public_profile_consultable
    CHECK (consultable = false OR published = true),
  CONSTRAINT ck_hamster_public_profile_traits
    CHECK (jsonb_typeof(traits) = 'array')
);

CREATE INDEX ix_hamster_public_profile_owner_visibility
  ON hamster_public_profile (owner_id, published, consultable, updated_at DESC);

CREATE TABLE growth_campaign (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  campaign_code varchar(24) NOT NULL,
  campaign_type varchar(16) NOT NULL,
  platform varchar(32) NOT NULL,
  status varchar(16) NOT NULL DEFAULT 'draft',
  subject_type varchar(16) NOT NULL DEFAULT 'hamster',
  subject_id uuid NOT NULL,
  title varchar(200) NOT NULL,
  goal text NOT NULL,
  duration_seconds integer,
  tone varchar(80) NOT NULL,
  cta text NOT NULL,
  facts_snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
  script_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  model_name varchar(120) NOT NULL DEFAULT 'template-v1',
  prompt_version varchar(40) NOT NULL DEFAULT 'growth-p0-v1',
  published_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_growth_campaign_code UNIQUE (campaign_code),
  CONSTRAINT uq_growth_campaign_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_growth_campaign_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_growth_campaign_type CHECK (campaign_type IN ('video', 'live')),
  CONSTRAINT ck_growth_campaign_status CHECK (status IN ('draft', 'ready', 'published', 'archived')),
  CONSTRAINT ck_growth_campaign_subject_type CHECK (subject_type IN ('hamster', 'litter')),
  CONSTRAINT ck_growth_campaign_duration CHECK (duration_seconds IS NULL OR duration_seconds BETWEEN 1 AND 7200),
  CONSTRAINT ck_growth_campaign_published_at CHECK (
    (status <> 'published' AND published_at IS NULL)
    OR (status = 'published' AND published_at IS NOT NULL)
  )
);

CREATE INDEX ix_growth_campaign_owner_created
  ON growth_campaign (owner_id, created_at DESC);

CREATE TABLE public_consultation (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  public_token_hash varchar(64) NOT NULL,
  token_prefix varchar(12) NOT NULL,
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  public_site_id uuid NOT NULL,
  campaign_id uuid,
  interested_hamster_id uuid,
  status varchar(16) NOT NULL DEFAULT 'open',
  turn_count integer NOT NULL DEFAULT 0 CHECK (turn_count >= 0),
  started_at timestamptz NOT NULL DEFAULT now(),
  last_message_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_public_consultation_token UNIQUE (public_token_hash),
  CONSTRAINT uq_public_consultation_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_public_consultation_site
    FOREIGN KEY (owner_id, public_site_id)
    REFERENCES public_site(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_public_consultation_campaign
    FOREIGN KEY (owner_id, campaign_id)
    REFERENCES growth_campaign(owner_id, id) ON DELETE SET NULL,
  CONSTRAINT fk_public_consultation_hamster
    FOREIGN KEY (owner_id, interested_hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE SET NULL,
  CONSTRAINT ck_public_consultation_status
    CHECK (status IN ('open', 'lead_created', 'closed'))
);

CREATE INDEX ix_public_consultation_owner_recent
  ON public_consultation (owner_id, last_message_at DESC);

CREATE TABLE public_consultation_message (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  consultation_id uuid NOT NULL,
  role varchar(16) NOT NULL,
  content text NOT NULL,
  facts_snapshot jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_public_consultation_message_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_public_consultation_message_consultation
    FOREIGN KEY (owner_id, consultation_id)
    REFERENCES public_consultation(owner_id, id) ON DELETE CASCADE,
  CONSTRAINT ck_public_consultation_message_role CHECK (role IN ('user', 'assistant')),
  CONSTRAINT ck_public_consultation_message_content CHECK (char_length(content) BETWEEN 1 AND 4000),
  CONSTRAINT ck_public_consultation_message_facts CHECK (jsonb_typeof(facts_snapshot) IN ('array', 'object'))
);

CREATE INDEX ix_public_consultation_message_conversation
  ON public_consultation_message (owner_id, consultation_id, created_at);

CREATE TABLE crm_contact_attribution (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  contact_id uuid NOT NULL,
  campaign_id uuid,
  consultation_id uuid,
  source_channel varchar(32) NOT NULL DEFAULT 'public_page',
  landing_path text,
  interest_hamster_id uuid,
  intent_summary text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_crm_contact_attribution_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_crm_contact_attribution_contact
    FOREIGN KEY (owner_id, contact_id)
    REFERENCES crm_contact(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_crm_contact_attribution_campaign
    FOREIGN KEY (owner_id, campaign_id)
    REFERENCES growth_campaign(owner_id, id) ON DELETE SET NULL,
  CONSTRAINT fk_crm_contact_attribution_consultation
    FOREIGN KEY (owner_id, consultation_id)
    REFERENCES public_consultation(owner_id, id) ON DELETE SET NULL,
  CONSTRAINT fk_crm_contact_attribution_hamster
    FOREIGN KEY (owner_id, interest_hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE SET NULL
);

CREATE UNIQUE INDEX ux_crm_contact_attribution_consultation
  ON crm_contact_attribution (owner_id, consultation_id)
  WHERE consultation_id IS NOT NULL;

CREATE INDEX ix_crm_contact_attribution_owner_recent
  ON crm_contact_attribution (owner_id, created_at DESC);

COMMIT;
