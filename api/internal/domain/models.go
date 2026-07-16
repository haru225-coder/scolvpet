package domain

import "time"

type Account struct {
	ID          string  `json:"id"`
	PhoneMasked string  `json:"phone_masked"`
	DisplayName *string `json:"display_name"`
}

type Organization struct {
	ID         string    `json:"id"`
	OwnerID    string    `json:"owner_id"`
	Name       string    `json:"name"`
	Mode       string    `json:"mode"`
	Timezone   string    `json:"timezone"`
	WeightUnit string    `json:"weight_unit"`
	Version    int       `json:"version"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type SpeciesRuleVersion struct {
	ID                          string         `json:"id"`
	OwnerID                     *string        `json:"owner_id"`
	Scope                       string         `json:"scope"`
	SourceTemplateID            *string        `json:"source_template_id"`
	SpeciesCode                 string         `json:"species_code"`
	VarietyScope                []string       `json:"variety_scope"`
	DisplayName                 string         `json:"-"`
	GestationMinDays            int            `json:"gestation_min_days"`
	GestationMaxDays            int            `json:"gestation_max_days"`
	PairingMaxMinutes           *int           `json:"pairing_max_minutes"`
	WeaningTargetDays           int            `json:"weaning_target_days"`
	SexingTargetDays            int            `json:"sexing_target_days"`
	SeparationTargetDays        int            `json:"separation_target_days"`
	PostBreedingRestDays        int            `json:"post_breeding_rest_days"`
	ProfileCreationDeadlineDays int            `json:"profile_creation_deadline_days"`
	WeightReference             map[string]any `json:"weight_reference"`
	SourceNote                  string         `json:"source_note"`
	Version                     int            `json:"version"`
	EffectiveAt                 time.Time      `json:"effective_at"`
	Frozen                      bool           `json:"frozen"`
}
