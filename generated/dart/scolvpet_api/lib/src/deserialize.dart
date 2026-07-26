import 'package:scolvpet_api/src/model/account.dart';
import 'package:scolvpet_api/src/model/accounting_category.dart';
import 'package:scolvpet_api/src/model/accounting_category_list_response.dart';
import 'package:scolvpet_api/src/model/accounting_category_response.dart';
import 'package:scolvpet_api/src/model/accounting_category_summary.dart';
import 'package:scolvpet_api/src/model/accounting_record.dart';
import 'package:scolvpet_api/src/model/accounting_record_list_response.dart';
import 'package:scolvpet_api/src/model/accounting_record_response.dart';
import 'package:scolvpet_api/src/model/accounting_summary.dart';
import 'package:scolvpet_api/src/model/accounting_summary_response.dart';
import 'package:scolvpet_api/src/model/action_item_result.dart';
import 'package:scolvpet_api/src/model/adjust_baseline_request.dart';
import 'package:scolvpet_api/src/model/adjust_baseline_response.dart';
import 'package:scolvpet_api/src/model/adjust_baseline_response_data.dart';
import 'package:scolvpet_api/src/model/adjust_litter_count_request.dart';
import 'package:scolvpet_api/src/model/adjust_litter_count_response.dart';
import 'package:scolvpet_api/src/model/adjust_litter_count_response_data.dart';
import 'package:scolvpet_api/src/model/assistant_action_cancel_response.dart';
import 'package:scolvpet_api/src/model/assistant_action_cancel_result.dart';
import 'package:scolvpet_api/src/model/assistant_action_confirm_response.dart';
import 'package:scolvpet_api/src/model/assistant_action_confirm_result.dart';
import 'package:scolvpet_api/src/model/assistant_answer.dart';
import 'package:scolvpet_api/src/model/assistant_answer_response.dart';
import 'package:scolvpet_api/src/model/assistant_ask_request.dart';
import 'package:scolvpet_api/src/model/assistant_capabilities.dart';
import 'package:scolvpet_api/src/model/assistant_capabilities_response.dart';
import 'package:scolvpet_api/src/model/assistant_chat_action.dart';
import 'package:scolvpet_api/src/model/assistant_chat_request.dart';
import 'package:scolvpet_api/src/model/assistant_chat_response.dart';
import 'package:scolvpet_api/src/model/assistant_chat_result.dart';
import 'package:scolvpet_api/src/model/assistant_fact.dart';
import 'package:scolvpet_api/src/model/assistant_message.dart';
import 'package:scolvpet_api/src/model/assistant_message_list_response.dart';
import 'package:scolvpet_api/src/model/assistant_session.dart';
import 'package:scolvpet_api/src/model/assistant_session_create_request.dart';
import 'package:scolvpet_api/src/model/assistant_session_list_response.dart';
import 'package:scolvpet_api/src/model/assistant_session_response.dart';
import 'package:scolvpet_api/src/model/async_job.dart';
import 'package:scolvpet_api/src/model/async_job_response.dart';
import 'package:scolvpet_api/src/model/audit_miniprogram_release_request.dart';
import 'package:scolvpet_api/src/model/backup_job.dart';
import 'package:scolvpet_api/src/model/backup_job_create_request.dart';
import 'package:scolvpet_api/src/model/backup_job_list_response.dart';
import 'package:scolvpet_api/src/model/backup_job_response.dart';
import 'package:scolvpet_api/src/model/breeding_plan.dart';
import 'package:scolvpet_api/src/model/breeding_plan_create_request.dart';
import 'package:scolvpet_api/src/model/breeding_plan_list_response.dart';
import 'package:scolvpet_api/src/model/breeding_plan_response.dart';
import 'package:scolvpet_api/src/model/breeding_plan_update_request.dart';
import 'package:scolvpet_api/src/model/care_task.dart';
import 'package:scolvpet_api/src/model/care_task_create_request.dart';
import 'package:scolvpet_api/src/model/care_task_list_response.dart';
import 'package:scolvpet_api/src/model/care_task_response.dart';
import 'package:scolvpet_api/src/model/care_task_update_request.dart';
import 'package:scolvpet_api/src/model/complete_breeding_plan_request.dart';
import 'package:scolvpet_api/src/model/complete_breeding_plan_response.dart';
import 'package:scolvpet_api/src/model/complete_breeding_plan_response_data.dart';
import 'package:scolvpet_api/src/model/complete_task_request.dart';
import 'package:scolvpet_api/src/model/complete_task_request_subject_results_inner.dart';
import 'package:scolvpet_api/src/model/complete_task_response.dart';
import 'package:scolvpet_api/src/model/complete_task_response_data.dart';
import 'package:scolvpet_api/src/model/complete_task_response_data_item_results_inner.dart';
import 'package:scolvpet_api/src/model/confirm_birth_live_litter_data.dart';
import 'package:scolvpet_api/src/model/confirm_birth_no_litter_data.dart';
import 'package:scolvpet_api/src/model/confirm_birth_request.dart';
import 'package:scolvpet_api/src/model/confirm_birth_response.dart';
import 'package:scolvpet_api/src/model/confirm_birth_response_data.dart';
import 'package:scolvpet_api/src/model/create_accounting_category_request.dart';
import 'package:scolvpet_api/src/model/create_accounting_record_request.dart';
import 'package:scolvpet_api/src/model/create_contract_request.dart';
import 'package:scolvpet_api/src/model/create_crm_contact_request.dart';
import 'package:scolvpet_api/src/model/create_crm_handover_request.dart';
import 'package:scolvpet_api/src/model/create_crm_reservation_request.dart';
import 'package:scolvpet_api/src/model/create_customer_session_request.dart';
import 'package:scolvpet_api/src/model/create_document_template_request.dart';
import 'package:scolvpet_api/src/model/create_genetic_profile_request.dart';
import 'package:scolvpet_api/src/model/create_miniprogram_release_request.dart';
import 'package:scolvpet_api/src/model/create_push_message_request.dart';
import 'package:scolvpet_api/src/model/create_receipt_request.dart';
import 'package:scolvpet_api/src/model/create_stud_deal_request.dart';
import 'package:scolvpet_api/src/model/create_stud_listing_request.dart';
import 'package:scolvpet_api/src/model/crm_contact.dart';
import 'package:scolvpet_api/src/model/crm_contact_list_response.dart';
import 'package:scolvpet_api/src/model/crm_contact_response.dart';
import 'package:scolvpet_api/src/model/crm_handover.dart';
import 'package:scolvpet_api/src/model/crm_handover_list_response.dart';
import 'package:scolvpet_api/src/model/crm_handover_response.dart';
import 'package:scolvpet_api/src/model/crm_reservation.dart';
import 'package:scolvpet_api/src/model/crm_reservation_list_response.dart';
import 'package:scolvpet_api/src/model/crm_reservation_response.dart';
import 'package:scolvpet_api/src/model/current_account_response.dart';
import 'package:scolvpet_api/src/model/current_account_response_data.dart';
import 'package:scolvpet_api/src/model/customer_reservation.dart';
import 'package:scolvpet_api/src/model/customer_reservation_documents_inner.dart';
import 'package:scolvpet_api/src/model/customer_reservation_hamster.dart';
import 'package:scolvpet_api/src/model/customer_reservation_list_response.dart';
import 'package:scolvpet_api/src/model/customer_reservation_response.dart';
import 'package:scolvpet_api/src/model/customer_session_response.dart';
import 'package:scolvpet_api/src/model/customer_session_response_data.dart';
import 'package:scolvpet_api/src/model/customer_verification_code_response.dart';
import 'package:scolvpet_api/src/model/customer_verification_code_response_data.dart';
import 'package:scolvpet_api/src/model/dam_condition.dart';
import 'package:scolvpet_api/src/model/data_center_summary_response.dart';
import 'package:scolvpet_api/src/model/data_center_summary_response_data.dart';
import 'package:scolvpet_api/src/model/device_info.dart';
import 'package:scolvpet_api/src/model/document.dart';
import 'package:scolvpet_api/src/model/document_list_response.dart';
import 'package:scolvpet_api/src/model/document_response.dart';
import 'package:scolvpet_api/src/model/document_template.dart';
import 'package:scolvpet_api/src/model/document_template_list_response.dart';
import 'package:scolvpet_api/src/model/document_template_response.dart';
import 'package:scolvpet_api/src/model/download_link_response.dart';
import 'package:scolvpet_api/src/model/download_link_response_data.dart';
import 'package:scolvpet_api/src/model/enclosure.dart';
import 'package:scolvpet_api/src/model/enclosure_cleaning.dart';
import 'package:scolvpet_api/src/model/enclosure_cleaning_create_request.dart';
import 'package:scolvpet_api/src/model/enclosure_cleaning_list_response.dart';
import 'package:scolvpet_api/src/model/enclosure_cleaning_response.dart';
import 'package:scolvpet_api/src/model/enclosure_create_request.dart';
import 'package:scolvpet_api/src/model/enclosure_dimensions.dart';
import 'package:scolvpet_api/src/model/enclosure_list_response.dart';
import 'package:scolvpet_api/src/model/enclosure_response.dart';
import 'package:scolvpet_api/src/model/enclosure_stay.dart';
import 'package:scolvpet_api/src/model/enclosure_stay_create_request.dart';
import 'package:scolvpet_api/src/model/enclosure_stay_list_response.dart';
import 'package:scolvpet_api/src/model/enclosure_stay_response.dart';
import 'package:scolvpet_api/src/model/enclosure_stay_update_request.dart';
import 'package:scolvpet_api/src/model/enclosure_update_request.dart';
import 'package:scolvpet_api/src/model/entitlement_catalog_response.dart';
import 'package:scolvpet_api/src/model/entitlement_check_request.dart';
import 'package:scolvpet_api/src/model/entitlement_check_response.dart';
import 'package:scolvpet_api/src/model/entitlement_check_result.dart';
import 'package:scolvpet_api/src/model/entitlement_feature.dart';
import 'package:scolvpet_api/src/model/entitlement_limit.dart';
import 'package:scolvpet_api/src/model/entitlement_snapshot.dart';
import 'package:scolvpet_api/src/model/entitlement_snapshot_response.dart';
import 'package:scolvpet_api/src/model/error_object.dart';
import 'package:scolvpet_api/src/model/error_response.dart';
import 'package:scolvpet_api/src/model/export_job.dart';
import 'package:scolvpet_api/src/model/export_job_create_request.dart';
import 'package:scolvpet_api/src/model/export_job_list_response.dart';
import 'package:scolvpet_api/src/model/export_job_response.dart';
import 'package:scolvpet_api/src/model/field_error.dart';
import 'package:scolvpet_api/src/model/genetic_locus.dart';
import 'package:scolvpet_api/src/model/genetic_locus_list_response.dart';
import 'package:scolvpet_api/src/model/genetic_outcome.dart';
import 'package:scolvpet_api/src/model/genetic_profile.dart';
import 'package:scolvpet_api/src/model/genetic_profile_list_response.dart';
import 'package:scolvpet_api/src/model/genetic_profile_response.dart';
import 'package:scolvpet_api/src/model/genetic_simulation_request.dart';
import 'package:scolvpet_api/src/model/genetic_simulation_response.dart';
import 'package:scolvpet_api/src/model/genetic_simulation_result.dart';
import 'package:scolvpet_api/src/model/growth_campaign.dart';
import 'package:scolvpet_api/src/model/growth_campaign_generate_request.dart';
import 'package:scolvpet_api/src/model/growth_campaign_list_response.dart';
import 'package:scolvpet_api/src/model/growth_campaign_response.dart';
import 'package:scolvpet_api/src/model/growth_lead.dart';
import 'package:scolvpet_api/src/model/growth_lead_list_response.dart';
import 'package:scolvpet_api/src/model/growth_opportunity.dart';
import 'package:scolvpet_api/src/model/growth_opportunity_list_response.dart';
import 'package:scolvpet_api/src/model/growth_public_fact.dart';
import 'package:scolvpet_api/src/model/growth_public_hamster.dart';
import 'package:scolvpet_api/src/model/growth_public_hamster_list_response.dart';
import 'package:scolvpet_api/src/model/growth_public_hamster_request.dart';
import 'package:scolvpet_api/src/model/growth_public_hamster_response.dart';
import 'package:scolvpet_api/src/model/growth_public_media.dart';
import 'package:scolvpet_api/src/model/growth_script.dart';
import 'package:scolvpet_api/src/model/growth_script_section.dart';
import 'package:scolvpet_api/src/model/hamster.dart';
import 'package:scolvpet_api/src/model/hamster_batch_create_request.dart';
import 'package:scolvpet_api/src/model/hamster_batch_create_request_items_inner.dart';
import 'package:scolvpet_api/src/model/hamster_batch_create_response.dart';
import 'package:scolvpet_api/src/model/hamster_batch_create_response_data.dart';
import 'package:scolvpet_api/src/model/hamster_batch_create_response_data_items_inner.dart';
import 'package:scolvpet_api/src/model/hamster_create_request.dart';
import 'package:scolvpet_api/src/model/hamster_list_response.dart';
import 'package:scolvpet_api/src/model/hamster_response.dart';
import 'package:scolvpet_api/src/model/hamster_update_request.dart';
import 'package:scolvpet_api/src/model/health_record.dart';
import 'package:scolvpet_api/src/model/health_record_create_request.dart';
import 'package:scolvpet_api/src/model/health_record_list_response.dart';
import 'package:scolvpet_api/src/model/health_record_response.dart';
import 'package:scolvpet_api/src/model/health_record_update_request.dart';
import 'package:scolvpet_api/src/model/import_commit_request.dart';
import 'package:scolvpet_api/src/model/import_commit_request_approved_updates_inner.dart';
import 'package:scolvpet_api/src/model/import_issue.dart';
import 'package:scolvpet_api/src/model/import_job.dart';
import 'package:scolvpet_api/src/model/import_job_create_request.dart';
import 'package:scolvpet_api/src/model/import_job_list_response.dart';
import 'package:scolvpet_api/src/model/import_job_response.dart';
import 'package:scolvpet_api/src/model/import_mapping_request.dart';
import 'package:scolvpet_api/src/model/import_mapping_request_mappings_inner.dart';
import 'package:scolvpet_api/src/model/import_preflight_request.dart';
import 'package:scolvpet_api/src/model/import_row_result.dart';
import 'package:scolvpet_api/src/model/import_row_result_list_response.dart';
import 'package:scolvpet_api/src/model/import_template_response.dart';
import 'package:scolvpet_api/src/model/import_template_response_data.dart';
import 'package:scolvpet_api/src/model/import_template_response_data_columns_inner.dart';
import 'package:scolvpet_api/src/model/import_template_response_data_columns_inner_example.dart';
import 'package:scolvpet_api/src/model/import_upload_create_request.dart';
import 'package:scolvpet_api/src/model/import_upload_response.dart';
import 'package:scolvpet_api/src/model/individualization_eligibility.dart';
import 'package:scolvpet_api/src/model/individualization_eligibility_blocker.dart';
import 'package:scolvpet_api/src/model/individualization_eligibility_response.dart';
import 'package:scolvpet_api/src/model/individualize_litter_request.dart';
import 'package:scolvpet_api/src/model/individualize_litter_request_items_inner.dart';
import 'package:scolvpet_api/src/model/individualize_litter_response.dart';
import 'package:scolvpet_api/src/model/individualize_litter_response_data.dart';
import 'package:scolvpet_api/src/model/individualize_mapping.dart';
import 'package:scolvpet_api/src/model/invite_organization_member_request.dart';
import 'package:scolvpet_api/src/model/kinship_check.dart';
import 'package:scolvpet_api/src/model/litter.dart';
import 'package:scolvpet_api/src/model/litter_count_event.dart';
import 'package:scolvpet_api/src/model/litter_list_response.dart';
import 'package:scolvpet_api/src/model/litter_member.dart';
import 'package:scolvpet_api/src/model/litter_member_list_response.dart';
import 'package:scolvpet_api/src/model/litter_member_one_of.dart';
import 'package:scolvpet_api/src/model/litter_member_one_of1.dart';
import 'package:scolvpet_api/src/model/litter_parent.dart';
import 'package:scolvpet_api/src/model/litter_parent_create_request.dart';
import 'package:scolvpet_api/src/model/litter_parent_list_response.dart';
import 'package:scolvpet_api/src/model/litter_parent_response.dart';
import 'package:scolvpet_api/src/model/litter_response.dart';
import 'package:scolvpet_api/src/model/litter_response_data.dart';
import 'package:scolvpet_api/src/model/mating_observation.dart';
import 'package:scolvpet_api/src/model/media_asset.dart';
import 'package:scolvpet_api/src/model/media_asset_response.dart';
import 'package:scolvpet_api/src/model/media_cover_request.dart';
import 'package:scolvpet_api/src/model/media_edit_recipe_request.dart';
import 'package:scolvpet_api/src/model/media_edit_recipe_request_operations_inner.dart';
import 'package:scolvpet_api/src/model/media_edit_recipe_response.dart';
import 'package:scolvpet_api/src/model/media_edit_recipe_response_data.dart';
import 'package:scolvpet_api/src/model/media_processing_retry_request.dart';
import 'package:scolvpet_api/src/model/media_processing_retry_response.dart';
import 'package:scolvpet_api/src/model/media_processing_retry_response_data.dart';
import 'package:scolvpet_api/src/model/media_upload_complete_request.dart';
import 'package:scolvpet_api/src/model/media_upload_complete_response.dart';
import 'package:scolvpet_api/src/model/media_upload_complete_response_data.dart';
import 'package:scolvpet_api/src/model/media_upload_presign_request.dart';
import 'package:scolvpet_api/src/model/media_upload_presign_response.dart';
import 'package:scolvpet_api/src/model/media_variant.dart';
import 'package:scolvpet_api/src/model/miniprogram_config.dart';
import 'package:scolvpet_api/src/model/miniprogram_config_response.dart';
import 'package:scolvpet_api/src/model/miniprogram_release.dart';
import 'package:scolvpet_api/src/model/miniprogram_release_list_response.dart';
import 'package:scolvpet_api/src/model/miniprogram_release_response.dart';
import 'package:scolvpet_api/src/model/organization.dart';
import 'package:scolvpet_api/src/model/organization_member.dart';
import 'package:scolvpet_api/src/model/organization_member_list_response.dart';
import 'package:scolvpet_api/src/model/organization_member_response.dart';
import 'package:scolvpet_api/src/model/organization_response.dart';
import 'package:scolvpet_api/src/model/organization_update_request.dart';
import 'package:scolvpet_api/src/model/page_info.dart';
import 'package:scolvpet_api/src/model/pairing_attempt.dart';
import 'package:scolvpet_api/src/model/pairing_attempt_list_response.dart';
import 'package:scolvpet_api/src/model/pairing_attempt_response.dart';
import 'package:scolvpet_api/src/model/pedigree_graph_response.dart';
import 'package:scolvpet_api/src/model/pedigree_graph_response_data.dart';
import 'package:scolvpet_api/src/model/pedigree_graph_response_data_common_ancestors_inner.dart';
import 'package:scolvpet_api/src/model/pedigree_parentage.dart';
import 'package:scolvpet_api/src/model/pedigree_parentage_create_request.dart';
import 'package:scolvpet_api/src/model/pedigree_parentage_end_request.dart';
import 'package:scolvpet_api/src/model/pedigree_parentage_list_response.dart';
import 'package:scolvpet_api/src/model/pedigree_parentage_response.dart';
import 'package:scolvpet_api/src/model/phenotype_table_outcome.dart';
import 'package:scolvpet_api/src/model/phone_code_login_request.dart';
import 'package:scolvpet_api/src/model/plan_catalog_entry.dart';
import 'package:scolvpet_api/src/model/post_public_site_simulate_request.dart';
import 'package:scolvpet_api/src/model/public_document_response.dart';
import 'package:scolvpet_api/src/model/public_document_response_data.dart';
import 'package:scolvpet_api/src/model/public_growth_catalog.dart';
import 'package:scolvpet_api/src/model/public_growth_catalog_response.dart';
import 'package:scolvpet_api/src/model/public_growth_consult_request.dart';
import 'package:scolvpet_api/src/model/public_growth_consult_response.dart';
import 'package:scolvpet_api/src/model/public_growth_consult_response_data.dart';
import 'package:scolvpet_api/src/model/public_growth_lead_request.dart';
import 'package:scolvpet_api/src/model/public_growth_lead_response.dart';
import 'package:scolvpet_api/src/model/public_growth_reservation_request.dart';
import 'package:scolvpet_api/src/model/public_growth_reservation_response.dart';
import 'package:scolvpet_api/src/model/public_growth_reservation_response_data.dart';
import 'package:scolvpet_api/src/model/public_share_response.dart';
import 'package:scolvpet_api/src/model/public_share_response_data.dart';
import 'package:scolvpet_api/src/model/public_site.dart';
import 'package:scolvpet_api/src/model/public_site_response.dart';
import 'package:scolvpet_api/src/model/public_site_view.dart';
import 'package:scolvpet_api/src/model/public_site_view_response.dart';
import 'package:scolvpet_api/src/model/publish_breeding_plan_request.dart';
import 'package:scolvpet_api/src/model/publish_breeding_plan_response.dart';
import 'package:scolvpet_api/src/model/publish_breeding_plan_response_data.dart';
import 'package:scolvpet_api/src/model/pup_identity.dart';
import 'package:scolvpet_api/src/model/pup_identity_list_response.dart';
import 'package:scolvpet_api/src/model/push_device.dart';
import 'package:scolvpet_api/src/model/push_device_list_response.dart';
import 'package:scolvpet_api/src/model/push_device_response.dart';
import 'package:scolvpet_api/src/model/push_message.dart';
import 'package:scolvpet_api/src/model/push_message_list_response.dart';
import 'package:scolvpet_api/src/model/push_message_response.dart';
import 'package:scolvpet_api/src/model/reconciliation.dart';
import 'package:scolvpet_api/src/model/record_observation_request.dart';
import 'package:scolvpet_api/src/model/record_observation_response.dart';
import 'package:scolvpet_api/src/model/record_observation_response_data.dart';
import 'package:scolvpet_api/src/model/recovery_action.dart';
import 'package:scolvpet_api/src/model/refresh_session_request.dart';
import 'package:scolvpet_api/src/model/reminder.dart';
import 'package:scolvpet_api/src/model/reminder_delivery.dart';
import 'package:scolvpet_api/src/model/reminder_list_response.dart';
import 'package:scolvpet_api/src/model/reminder_response.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:scolvpet_api/src/model/retry_import_request.dart';
import 'package:scolvpet_api/src/model/retry_job_request.dart';
import 'package:scolvpet_api/src/model/revoke_share_request.dart';
import 'package:scolvpet_api/src/model/sandbox_activate_plan_request.dart';
import 'package:scolvpet_api/src/model/send_customer_verification_code_request.dart';
import 'package:scolvpet_api/src/model/send_verification_code_request.dart';
import 'package:scolvpet_api/src/model/separate_pairing_request.dart';
import 'package:scolvpet_api/src/model/separate_pairing_response.dart';
import 'package:scolvpet_api/src/model/separate_pairing_response_data.dart';
import 'package:scolvpet_api/src/model/session_response.dart';
import 'package:scolvpet_api/src/model/session_response_data.dart';
import 'package:scolvpet_api/src/model/sex_and_separate_request.dart';
import 'package:scolvpet_api/src/model/sex_and_separate_request_items_inner.dart';
import 'package:scolvpet_api/src/model/sex_and_separate_response.dart';
import 'package:scolvpet_api/src/model/sex_and_separate_response_data.dart';
import 'package:scolvpet_api/src/model/share_create_request.dart';
import 'package:scolvpet_api/src/model/share_page.dart';
import 'package:scolvpet_api/src/model/share_page_list_response.dart';
import 'package:scolvpet_api/src/model/share_page_response.dart';
import 'package:scolvpet_api/src/model/share_revocation_response.dart';
import 'package:scolvpet_api/src/model/share_revocation_response_data.dart';
import 'package:scolvpet_api/src/model/share_revocation_response_data_cache_invalidation.dart';
import 'package:scolvpet_api/src/model/species_rule_version.dart';
import 'package:scolvpet_api/src/model/species_rule_version_create_request.dart';
import 'package:scolvpet_api/src/model/species_rule_version_list_response.dart';
import 'package:scolvpet_api/src/model/species_rule_version_response.dart';
import 'package:scolvpet_api/src/model/species_rule_version_update_request.dart';
import 'package:scolvpet_api/src/model/start_gestation_request.dart';
import 'package:scolvpet_api/src/model/start_gestation_response.dart';
import 'package:scolvpet_api/src/model/start_gestation_response_data.dart';
import 'package:scolvpet_api/src/model/start_pairing_request.dart';
import 'package:scolvpet_api/src/model/start_pairing_response.dart';
import 'package:scolvpet_api/src/model/start_pairing_response_data.dart';
import 'package:scolvpet_api/src/model/stud_deal.dart';
import 'package:scolvpet_api/src/model/stud_deal_list_response.dart';
import 'package:scolvpet_api/src/model/stud_deal_response.dart';
import 'package:scolvpet_api/src/model/stud_listing.dart';
import 'package:scolvpet_api/src/model/stud_listing_list_response.dart';
import 'package:scolvpet_api/src/model/stud_listing_response.dart';
import 'package:scolvpet_api/src/model/task_correction_request.dart';
import 'package:scolvpet_api/src/model/update_organization_member_request.dart';
import 'package:scolvpet_api/src/model/upload_session.dart';
import 'package:scolvpet_api/src/model/upsert_miniprogram_config_request.dart';
import 'package:scolvpet_api/src/model/upsert_public_site_request.dart';
import 'package:scolvpet_api/src/model/upsert_push_device_request.dart';
import 'package:scolvpet_api/src/model/usage_metric.dart';
import 'package:scolvpet_api/src/model/usage_response.dart';
import 'package:scolvpet_api/src/model/usage_response_data.dart';
import 'package:scolvpet_api/src/model/usage_response_data_entitlement.dart';
import 'package:scolvpet_api/src/model/usage_snapshot.dart';
import 'package:scolvpet_api/src/model/usage_snapshot_list_response.dart';
import 'package:scolvpet_api/src/model/verification_code_challenge_response.dart';
import 'package:scolvpet_api/src/model/verification_code_challenge_response_data.dart';
import 'package:scolvpet_api/src/model/wean_litter_request.dart';
import 'package:scolvpet_api/src/model/wean_litter_request_items_inner.dart';
import 'package:scolvpet_api/src/model/wean_litter_response.dart';
import 'package:scolvpet_api/src/model/wean_litter_response_data.dart';
import 'package:scolvpet_api/src/model/weight_record.dart';
import 'package:scolvpet_api/src/model/weight_record_batch_create_request.dart';
import 'package:scolvpet_api/src/model/weight_record_batch_create_request_items_inner.dart';
import 'package:scolvpet_api/src/model/weight_record_batch_create_response.dart';
import 'package:scolvpet_api/src/model/weight_record_batch_create_response_data.dart';
import 'package:scolvpet_api/src/model/weight_record_batch_create_response_data_items_inner.dart';
import 'package:scolvpet_api/src/model/weight_record_create_request.dart';
import 'package:scolvpet_api/src/model/weight_record_list_response.dart';
import 'package:scolvpet_api/src/model/weight_record_one_of.dart';
import 'package:scolvpet_api/src/model/weight_record_one_of1.dart';
import 'package:scolvpet_api/src/model/weight_record_one_of2.dart';
import 'package:scolvpet_api/src/model/weight_record_response.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'Account':
          return Account.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountingCategory':
          return AccountingCategory.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountingCategoryListResponse':
          return AccountingCategoryListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountingCategoryResponse':
          return AccountingCategoryResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountingCategorySummary':
          return AccountingCategorySummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountingRecord':
          return AccountingRecord.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountingRecordListResponse':
          return AccountingRecordListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountingRecordResponse':
          return AccountingRecordResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountingSummary':
          return AccountingSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountingSummaryResponse':
          return AccountingSummaryResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActionItemResult':
          return ActionItemResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdjustBaselineRequest':
          return AdjustBaselineRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdjustBaselineResponse':
          return AdjustBaselineResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdjustBaselineResponseData':
          return AdjustBaselineResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdjustLitterCountRequest':
          return AdjustLitterCountRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdjustLitterCountResponse':
          return AdjustLitterCountResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdjustLitterCountResponseData':
          return AdjustLitterCountResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantActionCancelResponse':
          return AssistantActionCancelResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantActionCancelResult':
          return AssistantActionCancelResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantActionConfirmResponse':
          return AssistantActionConfirmResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantActionConfirmResult':
          return AssistantActionConfirmResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantAnswer':
          return AssistantAnswer.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantAnswerResponse':
          return AssistantAnswerResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantAskRequest':
          return AssistantAskRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantCapabilities':
          return AssistantCapabilities.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantCapabilitiesResponse':
          return AssistantCapabilitiesResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantChatAction':
          return AssistantChatAction.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantChatRequest':
          return AssistantChatRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantChatResponse':
          return AssistantChatResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantChatResult':
          return AssistantChatResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantFact':
          return AssistantFact.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantMessage':
          return AssistantMessage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantMessageListResponse':
          return AssistantMessageListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantSession':
          return AssistantSession.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantSessionCreateRequest':
          return AssistantSessionCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantSessionListResponse':
          return AssistantSessionListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantSessionResponse':
          return AssistantSessionResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AsyncJob':
          return AsyncJob.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AsyncJobResponse':
          return AsyncJobResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AuditMiniprogramReleaseRequest':
          return AuditMiniprogramReleaseRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BackupJob':
          return BackupJob.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BackupJobCreateRequest':
          return BackupJobCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BackupJobListResponse':
          return BackupJobListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BackupJobResponse':
          return BackupJobResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BatchItemStatus':


        case 'BatchTransactionStatus':


        case 'BreedingPlan':
          return BreedingPlan.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BreedingPlanCreateRequest':
          return BreedingPlanCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BreedingPlanListResponse':
          return BreedingPlanListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BreedingPlanResponse':
          return BreedingPlanResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BreedingPlanState':


        case 'BreedingPlanUpdateRequest':
          return BreedingPlanUpdateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CareTask':
          return CareTask.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CareTaskCreateRequest':
          return CareTaskCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CareTaskListResponse':
          return CareTaskListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CareTaskResponse':
          return CareTaskResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CareTaskUpdateRequest':
          return CareTaskUpdateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CleanlinessState':


        case 'CompleteBreedingPlanRequest':
          return CompleteBreedingPlanRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CompleteBreedingPlanResponse':
          return CompleteBreedingPlanResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CompleteBreedingPlanResponseData':
          return CompleteBreedingPlanResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CompleteTaskRequest':
          return CompleteTaskRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CompleteTaskRequestSubjectResultsInner':
          return CompleteTaskRequestSubjectResultsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CompleteTaskResponse':
          return CompleteTaskResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CompleteTaskResponseData':
          return CompleteTaskResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CompleteTaskResponseDataItemResultsInner':
          return CompleteTaskResponseDataItemResultsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConfirmBirthLiveLitterData':
          return ConfirmBirthLiveLitterData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConfirmBirthNoLitterData':
          return ConfirmBirthNoLitterData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConfirmBirthRequest':
          return ConfirmBirthRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConfirmBirthResponse':
          return ConfirmBirthResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConfirmBirthResponseData':
          return ConfirmBirthResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateAccountingCategoryRequest':
          return CreateAccountingCategoryRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateAccountingRecordRequest':
          return CreateAccountingRecordRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateContractRequest':
          return CreateContractRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateCrmContactRequest':
          return CreateCrmContactRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateCrmHandoverRequest':
          return CreateCrmHandoverRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateCrmReservationRequest':
          return CreateCrmReservationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateCustomerSessionRequest':
          return CreateCustomerSessionRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateDocumentTemplateRequest':
          return CreateDocumentTemplateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateGeneticProfileRequest':
          return CreateGeneticProfileRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateMiniprogramReleaseRequest':
          return CreateMiniprogramReleaseRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreatePushMessageRequest':
          return CreatePushMessageRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateReceiptRequest':
          return CreateReceiptRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateStudDealRequest':
          return CreateStudDealRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateStudListingRequest':
          return CreateStudListingRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CrmContact':
          return CrmContact.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CrmContactListResponse':
          return CrmContactListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CrmContactResponse':
          return CrmContactResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CrmHandover':
          return CrmHandover.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CrmHandoverListResponse':
          return CrmHandoverListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CrmHandoverResponse':
          return CrmHandoverResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CrmReservation':
          return CrmReservation.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CrmReservationListResponse':
          return CrmReservationListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CrmReservationResponse':
          return CrmReservationResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CurrentAccountResponse':
          return CurrentAccountResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CurrentAccountResponseData':
          return CurrentAccountResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerReservation':
          return CustomerReservation.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerReservationDocumentsInner':
          return CustomerReservationDocumentsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerReservationHamster':
          return CustomerReservationHamster.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerReservationListResponse':
          return CustomerReservationListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerReservationResponse':
          return CustomerReservationResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerSessionResponse':
          return CustomerSessionResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerSessionResponseData':
          return CustomerSessionResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerVerificationCodeResponse':
          return CustomerVerificationCodeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerVerificationCodeResponseData':
          return CustomerVerificationCodeResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DamCondition':
          return DamCondition.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DataCenterSummaryResponse':
          return DataCenterSummaryResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DataCenterSummaryResponseData':
          return DataCenterSummaryResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeviceInfo':
          return DeviceInfo.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Document':
          return Document.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentListResponse':
          return DocumentListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentResponse':
          return DocumentResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentTemplate':
          return DocumentTemplate.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentTemplateListResponse':
          return DocumentTemplateListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentTemplateResponse':
          return DocumentTemplateResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DownloadLinkResponse':
          return DownloadLinkResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DownloadLinkResponseData':
          return DownloadLinkResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Enclosure':
          return Enclosure.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureCleaning':
          return EnclosureCleaning.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureCleaningCreateRequest':
          return EnclosureCleaningCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureCleaningListResponse':
          return EnclosureCleaningListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureCleaningResponse':
          return EnclosureCleaningResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureCleaningType':


        case 'EnclosureCreateRequest':
          return EnclosureCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureDimensions':
          return EnclosureDimensions.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureListResponse':
          return EnclosureListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureResponse':
          return EnclosureResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureState':


        case 'EnclosureStay':
          return EnclosureStay.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureStayCreateRequest':
          return EnclosureStayCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureStayListResponse':
          return EnclosureStayListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureStayResponse':
          return EnclosureStayResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureStayUpdateRequest':
          return EnclosureStayUpdateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnclosureUpdateRequest':
          return EnclosureUpdateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EntitlementCatalogResponse':
          return EntitlementCatalogResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EntitlementCheckRequest':
          return EntitlementCheckRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EntitlementCheckResponse':
          return EntitlementCheckResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EntitlementCheckResult':
          return EntitlementCheckResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EntitlementFeature':
          return EntitlementFeature.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EntitlementLimit':
          return EntitlementLimit.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EntitlementSnapshot':
          return EntitlementSnapshot.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EntitlementSnapshotResponse':
          return EntitlementSnapshotResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ErrorObject':
          return ErrorObject.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ErrorResponse':
          return ErrorResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ExportJob':
          return ExportJob.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ExportJobCreateRequest':
          return ExportJobCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ExportJobListResponse':
          return ExportJobListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ExportJobResponse':
          return ExportJobResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FieldError':
          return FieldError.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GeneticLocus':
          return GeneticLocus.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GeneticLocusListResponse':
          return GeneticLocusListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GeneticOutcome':
          return GeneticOutcome.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GeneticProfile':
          return GeneticProfile.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GeneticProfileListResponse':
          return GeneticProfileListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GeneticProfileResponse':
          return GeneticProfileResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GeneticSimulationRequest':
          return GeneticSimulationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GeneticSimulationResponse':
          return GeneticSimulationResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GeneticSimulationResult':
          return GeneticSimulationResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthCampaign':
          return GrowthCampaign.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthCampaignGenerateRequest':
          return GrowthCampaignGenerateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthCampaignListResponse':
          return GrowthCampaignListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthCampaignResponse':
          return GrowthCampaignResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthLead':
          return GrowthLead.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthLeadListResponse':
          return GrowthLeadListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthOpportunity':
          return GrowthOpportunity.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthOpportunityListResponse':
          return GrowthOpportunityListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthPublicFact':
          return GrowthPublicFact.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthPublicHamster':
          return GrowthPublicHamster.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthPublicHamsterListResponse':
          return GrowthPublicHamsterListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthPublicHamsterRequest':
          return GrowthPublicHamsterRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthPublicHamsterResponse':
          return GrowthPublicHamsterResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthPublicMedia':
          return GrowthPublicMedia.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthScript':
          return GrowthScript.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrowthScriptSection':
          return GrowthScriptSection.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Hamster':
          return Hamster.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HamsterBatchCreateRequest':
          return HamsterBatchCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HamsterBatchCreateRequestItemsInner':
          return HamsterBatchCreateRequestItemsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HamsterBatchCreateResponse':
          return HamsterBatchCreateResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HamsterBatchCreateResponseData':
          return HamsterBatchCreateResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HamsterBatchCreateResponseDataItemsInner':
          return HamsterBatchCreateResponseDataItemsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HamsterBreedingStatus':


        case 'HamsterCreateRequest':
          return HamsterCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HamsterLifecycleStatus':


        case 'HamsterListResponse':
          return HamsterListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HamsterResponse':
          return HamsterResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HamsterSourceType':


        case 'HamsterUpdateRequest':
          return HamsterUpdateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthRecord':
          return HealthRecord.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthRecordCreateRequest':
          return HealthRecordCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthRecordListResponse':
          return HealthRecordListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthRecordResponse':
          return HealthRecordResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthRecordType':


        case 'HealthRecordUpdateRequest':
          return HealthRecordUpdateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportCommitRequest':
          return ImportCommitRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportCommitRequestApprovedUpdatesInner':
          return ImportCommitRequestApprovedUpdatesInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportIssue':
          return ImportIssue.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportJob':
          return ImportJob.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportJobCreateRequest':
          return ImportJobCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportJobListResponse':
          return ImportJobListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportJobResponse':
          return ImportJobResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportMappingRequest':
          return ImportMappingRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportMappingRequestMappingsInner':
          return ImportMappingRequestMappingsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportPreflightRequest':
          return ImportPreflightRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportRowResult':
          return ImportRowResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportRowResultListResponse':
          return ImportRowResultListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportRowStatus':


        case 'ImportTemplateResponse':
          return ImportTemplateResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportTemplateResponseData':
          return ImportTemplateResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportTemplateResponseDataColumnsInner':
          return ImportTemplateResponseDataColumnsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportTemplateResponseDataColumnsInnerExample':
          return ImportTemplateResponseDataColumnsInnerExample.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportTemplateType':


        case 'ImportUploadCreateRequest':
          return ImportUploadCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImportUploadResponse':
          return ImportUploadResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IndividualizationEligibility':
          return IndividualizationEligibility.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IndividualizationEligibilityBlocker':
          return IndividualizationEligibilityBlocker.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IndividualizationEligibilityResponse':
          return IndividualizationEligibilityResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IndividualizeLitterRequest':
          return IndividualizeLitterRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IndividualizeLitterRequestItemsInner':
          return IndividualizeLitterRequestItemsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IndividualizeLitterResponse':
          return IndividualizeLitterResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IndividualizeLitterResponseData':
          return IndividualizeLitterResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IndividualizeMapping':
          return IndividualizeMapping.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InviteOrganizationMemberRequest':
          return InviteOrganizationMemberRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'JobStatus':


        case 'KinshipCheck':
          return KinshipCheck.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Litter':
          return Litter.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterCountEvent':
          return LitterCountEvent.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterListResponse':
          return LitterListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterMember':
          return LitterMember.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterMemberListResponse':
          return LitterMemberListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterMemberOneOf':
          return LitterMemberOneOf.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterMemberOneOf1':
          return LitterMemberOneOf1.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterParent':
          return LitterParent.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterParentCreateRequest':
          return LitterParentCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterParentListResponse':
          return LitterParentListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterParentResponse':
          return LitterParentResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterResponse':
          return LitterResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterResponseData':
          return LitterResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LitterState':


        case 'MatingObservation':
          return MatingObservation.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaAsset':
          return MediaAsset.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaAssetResponse':
          return MediaAssetResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaCoverRequest':
          return MediaCoverRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaEditRecipeRequest':
          return MediaEditRecipeRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaEditRecipeRequestOperationsInner':
          return MediaEditRecipeRequestOperationsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaEditRecipeResponse':
          return MediaEditRecipeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaEditRecipeResponseData':
          return MediaEditRecipeResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaProcessingRetryRequest':
          return MediaProcessingRetryRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaProcessingRetryResponse':
          return MediaProcessingRetryResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaProcessingRetryResponseData':
          return MediaProcessingRetryResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaUploadCompleteRequest':
          return MediaUploadCompleteRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaUploadCompleteResponse':
          return MediaUploadCompleteResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaUploadCompleteResponseData':
          return MediaUploadCompleteResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaUploadPresignRequest':
          return MediaUploadPresignRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaUploadPresignResponse':
          return MediaUploadPresignResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MediaVariant':
          return MediaVariant.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MiniprogramConfig':
          return MiniprogramConfig.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MiniprogramConfigResponse':
          return MiniprogramConfigResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MiniprogramRelease':
          return MiniprogramRelease.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MiniprogramReleaseListResponse':
          return MiniprogramReleaseListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MiniprogramReleaseResponse':
          return MiniprogramReleaseResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ObservationType':


        case 'Organization':
          return Organization.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrganizationMember':
          return OrganizationMember.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrganizationMemberListResponse':
          return OrganizationMemberListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrganizationMemberResponse':
          return OrganizationMemberResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrganizationResponse':
          return OrganizationResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrganizationUpdateRequest':
          return OrganizationUpdateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PageInfo':
          return PageInfo.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PairingAttempt':
          return PairingAttempt.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PairingAttemptListResponse':
          return PairingAttemptListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PairingAttemptResponse':
          return PairingAttemptResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PairingAttemptStatus':


        case 'PairingResult':


        case 'PedigreeGraphResponse':
          return PedigreeGraphResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PedigreeGraphResponseData':
          return PedigreeGraphResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PedigreeGraphResponseDataCommonAncestorsInner':
          return PedigreeGraphResponseDataCommonAncestorsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PedigreeParentage':
          return PedigreeParentage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PedigreeParentageCreateRequest':
          return PedigreeParentageCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PedigreeParentageEndRequest':
          return PedigreeParentageEndRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PedigreeParentageListResponse':
          return PedigreeParentageListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PedigreeParentageResponse':
          return PedigreeParentageResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PhenotypeTableOutcome':
          return PhenotypeTableOutcome.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PhoneCodeLoginRequest':
          return PhoneCodeLoginRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlanCatalogEntry':
          return PlanCatalogEntry.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PostPublicSiteSimulateRequest':
          return PostPublicSiteSimulateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicDocumentResponse':
          return PublicDocumentResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicDocumentResponseData':
          return PublicDocumentResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicGrowthCatalog':
          return PublicGrowthCatalog.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicGrowthCatalogResponse':
          return PublicGrowthCatalogResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicGrowthConsultRequest':
          return PublicGrowthConsultRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicGrowthConsultResponse':
          return PublicGrowthConsultResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicGrowthConsultResponseData':
          return PublicGrowthConsultResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicGrowthLeadRequest':
          return PublicGrowthLeadRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicGrowthLeadResponse':
          return PublicGrowthLeadResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicGrowthReservationRequest':
          return PublicGrowthReservationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicGrowthReservationResponse':
          return PublicGrowthReservationResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicGrowthReservationResponseData':
          return PublicGrowthReservationResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicShareResponse':
          return PublicShareResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicShareResponseData':
          return PublicShareResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicSite':
          return PublicSite.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicSiteResponse':
          return PublicSiteResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicSiteView':
          return PublicSiteView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicSiteViewResponse':
          return PublicSiteViewResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublishBreedingPlanRequest':
          return PublishBreedingPlanRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublishBreedingPlanResponse':
          return PublishBreedingPlanResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublishBreedingPlanResponseData':
          return PublishBreedingPlanResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PupIdentity':
          return PupIdentity.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PupIdentityListResponse':
          return PupIdentityListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PupOutcomeStatus':


        case 'PupProfileStatus':


        case 'PushDevice':
          return PushDevice.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushDeviceListResponse':
          return PushDeviceListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushDeviceResponse':
          return PushDeviceResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushMessage':
          return PushMessage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushMessageListResponse':
          return PushMessageListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushMessageResponse':
          return PushMessageResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Reconciliation':
          return Reconciliation.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RecordObservationRequest':
          return RecordObservationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RecordObservationResponse':
          return RecordObservationResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RecordObservationResponseData':
          return RecordObservationResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RecoveryAction':
          return RecoveryAction.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RefreshSessionRequest':
          return RefreshSessionRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Reminder':
          return Reminder.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReminderDelivery':
          return ReminderDelivery.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReminderListResponse':
          return ReminderListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReminderResponse':
          return ReminderResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReminderState':


        case 'ResponseMeta':
          return ResponseMeta.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RetryImportRequest':
          return RetryImportRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RetryJobRequest':
          return RetryJobRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RevokeShareRequest':
          return RevokeShareRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SandboxActivatePlanRequest':
          return SandboxActivatePlanRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SendCustomerVerificationCodeRequest':
          return SendCustomerVerificationCodeRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SendVerificationCodeRequest':
          return SendVerificationCodeRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SeparatePairingRequest':
          return SeparatePairingRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SeparatePairingResponse':
          return SeparatePairingResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SeparatePairingResponseData':
          return SeparatePairingResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SessionResponse':
          return SessionResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SessionResponseData':
          return SessionResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Severity':


        case 'Sex':


        case 'SexAndSeparateRequest':
          return SexAndSeparateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SexAndSeparateRequestItemsInner':
          return SexAndSeparateRequestItemsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SexAndSeparateResponse':
          return SexAndSeparateResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SexAndSeparateResponseData':
          return SexAndSeparateResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShareCreateRequest':
          return ShareCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SharePage':
          return SharePage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SharePageListResponse':
          return SharePageListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SharePageResponse':
          return SharePageResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SharePublicField':


        case 'ShareRevocationResponse':
          return ShareRevocationResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShareRevocationResponseData':
          return ShareRevocationResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShareRevocationResponseDataCacheInvalidation':
          return ShareRevocationResponseDataCacheInvalidation.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShareStatus':


        case 'SpeciesRuleVersion':
          return SpeciesRuleVersion.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SpeciesRuleVersionCreateRequest':
          return SpeciesRuleVersionCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SpeciesRuleVersionListResponse':
          return SpeciesRuleVersionListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SpeciesRuleVersionResponse':
          return SpeciesRuleVersionResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SpeciesRuleVersionUpdateRequest':
          return SpeciesRuleVersionUpdateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StartGestationRequest':
          return StartGestationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StartGestationResponse':
          return StartGestationResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StartGestationResponseData':
          return StartGestationResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StartPairingRequest':
          return StartPairingRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StartPairingResponse':
          return StartPairingResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StartPairingResponseData':
          return StartPairingResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StudDeal':
          return StudDeal.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StudDealListResponse':
          return StudDealListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StudDealResponse':
          return StudDealResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StudListing':
          return StudListing.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StudListingListResponse':
          return StudListingListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StudListingResponse':
          return StudListingResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TaskCorrectionRequest':
          return TaskCorrectionRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TaskPriority':


        case 'TaskState':


        case 'UpdateOrganizationMemberRequest':
          return UpdateOrganizationMemberRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UploadSession':
          return UploadSession.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpsertMiniprogramConfigRequest':
          return UpsertMiniprogramConfigRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpsertPublicSiteRequest':
          return UpsertPublicSiteRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpsertPushDeviceRequest':
          return UpsertPushDeviceRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UsageMetric':
          return UsageMetric.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UsageResponse':
          return UsageResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UsageResponseData':
          return UsageResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UsageResponseDataEntitlement':
          return UsageResponseDataEntitlement.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UsageSnapshot':
          return UsageSnapshot.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UsageSnapshotListResponse':
          return UsageSnapshotListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VerificationCodeChallengeResponse':
          return VerificationCodeChallengeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VerificationCodeChallengeResponseData':
          return VerificationCodeChallengeResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeanLitterRequest':
          return WeanLitterRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeanLitterRequestItemsInner':
          return WeanLitterRequestItemsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeanLitterResponse':
          return WeanLitterResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeanLitterResponseData':
          return WeanLitterResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecord':
          return WeightRecord.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecordBatchCreateRequest':
          return WeightRecordBatchCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecordBatchCreateRequestItemsInner':
          return WeightRecordBatchCreateRequestItemsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecordBatchCreateResponse':
          return WeightRecordBatchCreateResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecordBatchCreateResponseData':
          return WeightRecordBatchCreateResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecordBatchCreateResponseDataItemsInner':
          return WeightRecordBatchCreateResponseDataItemsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecordCreateRequest':
          return WeightRecordCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecordListResponse':
          return WeightRecordListResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecordOneOf':
          return WeightRecordOneOf.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecordOneOf1':
          return WeightRecordOneOf1.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecordOneOf2':
          return WeightRecordOneOf2.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeightRecordResponse':
          return WeightRecordResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }