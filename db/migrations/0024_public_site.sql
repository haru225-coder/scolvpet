-- T-P2-01 lightweight public cattery homepage (not a visual editor).
BEGIN;

CREATE TABLE public_site (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  slug varchar(64) NOT NULL,
  title varchar(120) NOT NULL,
  tagline varchar(240),
  about text,
  contact_wechat varchar(64),
  contact_phone varchar(32),
  theme_color varchar(16) NOT NULL DEFAULT '#c77852',
  show_stats boolean NOT NULL DEFAULT true,
  show_contact boolean NOT NULL DEFAULT true,
  published boolean NOT NULL DEFAULT false,
  published_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_public_site_owner UNIQUE (owner_id),
  CONSTRAINT uq_public_site_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT uq_public_site_slug UNIQUE (slug),
  CONSTRAINT fk_public_site_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_public_site_slug CHECK (
    slug ~ '^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$'
  ),
  CONSTRAINT ck_public_site_theme CHECK (theme_color ~ '^#[0-9A-Fa-f]{6}$'),
  CONSTRAINT ck_public_site_published CHECK (
    (published = false AND published_at IS NULL)
    OR (published = true AND published_at IS NOT NULL)
  )
);

CREATE INDEX ix_public_site_published_slug
  ON public_site (slug)
  WHERE published = true;

COMMIT;
