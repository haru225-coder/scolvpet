-- Composite FKs declared ON DELETE SET NULL without a column list null out
-- EVERY referencing column on delete — including NOT NULL owner_id — so any
-- hard delete of the referenced row fails with 23502 (docs/31 §5.5, audit
-- docs/29 P1-3.5). Rebuild all of them with an explicit column list so only
-- the nullable reference column is cleared. Requires PostgreSQL 15+.
BEGIN;

ALTER TABLE crm_handover
  DROP CONSTRAINT IF EXISTS fk_crm_handover_reservation,
  ADD CONSTRAINT fk_crm_handover_reservation
    FOREIGN KEY (owner_id, reservation_id)
    REFERENCES crm_reservation(owner_id, id) ON DELETE SET NULL (reservation_id);

ALTER TABLE doc_document
  DROP CONSTRAINT IF EXISTS fk_doc_document_contact,
  ADD CONSTRAINT fk_doc_document_contact
    FOREIGN KEY (owner_id, contact_id)
    REFERENCES crm_contact(owner_id, id) ON DELETE SET NULL (contact_id),
  DROP CONSTRAINT IF EXISTS fk_doc_document_handover,
  ADD CONSTRAINT fk_doc_document_handover
    FOREIGN KEY (owner_id, handover_id)
    REFERENCES crm_handover(owner_id, id) ON DELETE SET NULL (handover_id),
  DROP CONSTRAINT IF EXISTS fk_doc_document_reservation,
  ADD CONSTRAINT fk_doc_document_reservation
    FOREIGN KEY (owner_id, reservation_id)
    REFERENCES crm_reservation(owner_id, id) ON DELETE SET NULL (reservation_id);

ALTER TABLE accounting_record
  DROP CONSTRAINT IF EXISTS fk_accounting_record_category,
  ADD CONSTRAINT fk_accounting_record_category
    FOREIGN KEY (owner_id, category_id)
    REFERENCES accounting_category(owner_id, id) ON DELETE SET NULL (category_id),
  DROP CONSTRAINT IF EXISTS fk_accounting_record_contact,
  ADD CONSTRAINT fk_accounting_record_contact
    FOREIGN KEY (owner_id, contact_id)
    REFERENCES crm_contact(owner_id, id) ON DELETE SET NULL (contact_id);

ALTER TABLE push_message
  DROP CONSTRAINT IF EXISTS fk_push_message_device,
  ADD CONSTRAINT fk_push_message_device
    FOREIGN KEY (owner_id, target_device_id)
    REFERENCES push_device(owner_id, id) ON DELETE SET NULL (target_device_id);

ALTER TABLE public_consultation
  DROP CONSTRAINT IF EXISTS fk_public_consultation_campaign,
  ADD CONSTRAINT fk_public_consultation_campaign
    FOREIGN KEY (owner_id, campaign_id)
    REFERENCES growth_campaign(owner_id, id) ON DELETE SET NULL (campaign_id),
  DROP CONSTRAINT IF EXISTS fk_public_consultation_hamster,
  ADD CONSTRAINT fk_public_consultation_hamster
    FOREIGN KEY (owner_id, interested_hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE SET NULL (interested_hamster_id);

ALTER TABLE crm_contact_attribution
  DROP CONSTRAINT IF EXISTS fk_crm_contact_attribution_campaign,
  ADD CONSTRAINT fk_crm_contact_attribution_campaign
    FOREIGN KEY (owner_id, campaign_id)
    REFERENCES growth_campaign(owner_id, id) ON DELETE SET NULL (campaign_id),
  DROP CONSTRAINT IF EXISTS fk_crm_contact_attribution_consultation,
  ADD CONSTRAINT fk_crm_contact_attribution_consultation
    FOREIGN KEY (owner_id, consultation_id)
    REFERENCES public_consultation(owner_id, id) ON DELETE SET NULL (consultation_id),
  DROP CONSTRAINT IF EXISTS fk_crm_contact_attribution_hamster,
  ADD CONSTRAINT fk_crm_contact_attribution_hamster
    FOREIGN KEY (owner_id, interest_hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE SET NULL (interest_hamster_id);

ALTER TABLE hamster
  DROP CONSTRAINT IF EXISTS fk_hamster_cover_media,
  ADD CONSTRAINT fk_hamster_cover_media
    FOREIGN KEY (owner_id, cover_media_id)
    REFERENCES media_asset(owner_id, id) ON DELETE SET NULL (cover_media_id);

COMMIT;
