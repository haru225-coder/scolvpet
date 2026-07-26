package httpapi

import (
	"encoding/json"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i2core"
)

type i2PageRequest struct {
	Limit  int
	Offset int
}

type i2PageInfo struct {
	NextCursor *string `json:"next_cursor"`
	HasMore    bool    `json:"has_more"`
	Count      int     `json:"count"`
}

type i2EnclosureDimensionsRequest struct {
	Length int    `json:"length"`
	Width  int    `json:"width"`
	Height int    `json:"height"`
	Unit   string `json:"unit,omitempty"`
}

type i2HamsterCreateRequest struct {
	InternalCode         string         `json:"internal_code"`
	Name                 *string        `json:"name"`
	SpeciesRuleVersionID uuid.UUID      `json:"species_rule_version_id"`
	VarietyCode          *string        `json:"variety_code"`
	Sex                  string         `json:"sex"`
	SexConfidence        *float64       `json:"sex_confidence"`
	BirthDate            *string        `json:"birth_date"`
	SourceType           string         `json:"source_type"`
	CoverMediaID         *uuid.UUID     `json:"cover_media_id"`
	Notes                *string        `json:"notes"`
	SireID               *uuid.UUID     `json:"sire_id"`
	DamID                *uuid.UUID     `json:"dam_id"`
	LitterID             *uuid.UUID     `json:"litter_id"`
	Phenotype            map[string]any `json:"phenotype"`
}

type i2HamsterBatchItemRequest struct {
	ClientItemID string                 `json:"client_item_id"`
	Hamster      i2HamsterCreateRequest `json:"hamster"`
}

type i2HamsterBatchRequest struct {
	Atomic *bool                       `json:"atomic"`
	Items  []i2HamsterBatchItemRequest `json:"items"`
}

type i2PedigreeParentageCreateRequest struct {
	ChildHamsterID   uuid.UUID `json:"child_hamster_id"`
	ParentHamsterID  uuid.UUID `json:"parent_hamster_id"`
	Role             string    `json:"role"`
	EvidenceType     string    `json:"evidence_type"`
	Confidence       float64   `json:"confidence"`
	ValidFrom        string    `json:"valid_from"`
	Notes            *string   `json:"notes"`
	CorrectionReason *string   `json:"correction_reason"`
}

type i2PedigreeParentageEndRequest struct {
	ChildHamsterID   uuid.UUID `json:"child_hamster_id"`
	Role             string    `json:"role"`
	CorrectionReason string    `json:"correction_reason"`
}

type i2EnclosureCreateRequest struct {
	Code       string                        `json:"code"`
	RackCode   *string                       `json:"rack_code"`
	LevelCode  *string                       `json:"level_code"`
	Dimensions *i2EnclosureDimensionsRequest `json:"dimensions"`
	Capacity   int                           `json:"capacity"`
	Equipment  []string                      `json:"equipment"`
}

type i2EnclosureStayCreateRequest struct {
	HamsterID        uuid.UUID  `json:"hamster_id"`
	Purpose          string     `json:"purpose"`
	PairingAttemptID *uuid.UUID `json:"pairing_attempt_id"`
	StartedAt        string     `json:"started_at"`
	PreviousStayID   *uuid.UUID `json:"previous_stay_id"`
	Reason           *string    `json:"reason"`
}

type i2EnclosureCleaningCreateRequest struct {
	CleaningType             string         `json:"cleaning_type"`
	PerformedAt              string         `json:"performed_at"`
	Supplies                 map[string]any `json:"supplies"`
	Notes                    *string        `json:"notes"`
	CorrectsCleaningRecordID *uuid.UUID     `json:"corrects_cleaning_record_id"`
	CorrectionReason         *string        `json:"correction_reason"`
}

type i2LitterParentCreateRequest struct {
	HamsterID        uuid.UUID      `json:"hamster_id"`
	Role             string         `json:"role"`
	EvidenceType     string         `json:"evidence_type"`
	EvidencePayload  map[string]any `json:"-"`
	Confidence       float64        `json:"confidence"`
	CorrectionReason *string        `json:"correction_reason"`
}

type i2WeightCreateRequest struct {
	HamsterID       *uuid.UUID `json:"hamster_id"`
	PupIdentityID   *uuid.UUID `json:"pup_identity_id"`
	LitterID        *uuid.UUID `json:"litter_id"`
	MeasurementKind string     `json:"measurement_kind"`
	SubjectCount    *int       `json:"subject_count"`
	WeightG         float64    `json:"weight_g"`
	RecordedAt      string     `json:"recorded_at"`
	Source          string     `json:"source"`
	DeviceReadingID *string    `json:"device_reading_id"`
	Notes           *string    `json:"notes"`
	// Correction chain: a new record supersedes an earlier one without deleting it.
	CorrectsWeightRecordID *uuid.UUID `json:"corrects_weight_record_id"`
	CorrectionReason       *string    `json:"correction_reason"`
}

type i2WeightBatchItemRequest struct {
	ClientItemID string                `json:"client_item_id"`
	Record       i2WeightCreateRequest `json:"record"`
}

type i2WeightBatchRequest struct {
	TaskID json.RawMessage            `json:"task_id"`
	Items  []i2WeightBatchItemRequest `json:"items"`
}

func (request i2HamsterCreateRequest) coreInput() (i2core.CreateHamsterInput, error) {
	request.InternalCode = strings.TrimSpace(request.InternalCode)
	if request.InternalCode == "" || len(request.InternalCode) > 64 || request.SpeciesRuleVersionID == uuid.Nil ||
		!i2OneOf(request.Sex, "male", "female", "unknown") || !i2OneOf(request.SourceType, "born_here", "introduced", "customer", "imported") {
		return i2core.CreateHamsterInput{}, validationError("hamster", "仓鼠必填字段或枚举值不正确")
	}
	if request.Name != nil && len(*request.Name) > 100 || request.VarietyCode != nil && len(*request.VarietyCode) > 80 ||
		request.Notes != nil && len(*request.Notes) > 4000 || request.SexConfidence != nil && (*request.SexConfidence < 0 || *request.SexConfidence > 1) {
		return i2core.CreateHamsterInput{}, validationError("hamster", "仓鼠字段长度或范围不正确")
	}
	var birthDate *time.Time
	if request.BirthDate != nil {
		parsed, err := parseI2Date(*request.BirthDate)
		if err != nil {
			return i2core.CreateHamsterInput{}, validationError("birth_date", "出生日期格式不正确")
		}
		birthDate = &parsed
	}
	return i2core.CreateHamsterInput{
		InternalCode: request.InternalCode, Name: request.Name, SpeciesRuleVersionID: request.SpeciesRuleVersionID,
		VarietyCode: request.VarietyCode, Sex: request.Sex, SexConfidence: request.SexConfidence,
		BirthDate: birthDate, SourceType: request.SourceType, Notes: request.Notes,
		Phenotype: request.Phenotype,
	}, nil
}

func (request i2EnclosureCreateRequest) coreInput() (i2core.CreateEnclosureInput, error) {
	request.Code = strings.TrimSpace(request.Code)
	if request.Code == "" || len(request.Code) > 64 || request.RackCode != nil && len(*request.RackCode) > 64 ||
		request.LevelCode != nil && len(*request.LevelCode) > 64 || request.Capacity < 0 {
		return i2core.CreateEnclosureInput{}, validationError("enclosure", "笼盒字段格式不正确")
	}
	if request.Dimensions != nil && !request.Dimensions.valid() {
		return i2core.CreateEnclosureInput{}, validationError("dimensions", "笼盒尺寸格式不正确")
	}
	size := map[string]any{}
	if request.Dimensions != nil {
		size = request.Dimensions.coreMap()
	}
	return i2core.CreateEnclosureInput{
		Code: request.Code, RackCode: request.RackCode, LevelCode: request.LevelCode, Capacity: request.Capacity,
		Dimensions: size, Equipment: append([]string(nil), request.Equipment...),
	}, nil
}

func (request i2WeightCreateRequest) coreInput() (i2core.CreateWeightInput, error) {
	recordedAt, err := parseI2DateTime(request.RecordedAt)
	if err != nil {
		return i2core.CreateWeightInput{}, validationError("recorded_at", "称重时间格式不正确")
	}
	measurementKind := strings.TrimSpace(request.MeasurementKind)
	if measurementKind == "" {
		measurementKind = "individual"
	}
	source := strings.TrimSpace(request.Source)
	if source == "" {
		return i2core.CreateWeightInput{}, validationError("source", "称重来源不能为空")
	}
	subjectType := ""
	subjects := 0
	if request.HamsterID != nil {
		subjectType, subjects = "hamster", subjects+1
	}
	if request.PupIdentityID != nil {
		subjectType, subjects = "pup_identity", subjects+1
	}
	if request.LitterID != nil {
		subjectType, subjects = "litter", subjects+1
	}
	if subjects != 1 || request.Notes != nil && len(*request.Notes) > 1000 {
		return i2core.CreateWeightInput{}, i2core.ErrInvalidWeight
	}
	// A correction must say why: the audit chain is worthless without a reason.
	var correctionReason *string
	if request.CorrectsWeightRecordID != nil {
		if *request.CorrectsWeightRecordID == uuid.Nil {
			return i2core.CreateWeightInput{}, validationError("corrects_weight_record_id", "被纠错的体重记录 ID 无效")
		}
		reason := ""
		if request.CorrectionReason != nil {
			reason = strings.TrimSpace(*request.CorrectionReason)
		}
		if reason == "" || len(reason) > 500 {
			return i2core.CreateWeightInput{}, validationError("correction_reason", "纠错时必须填写 1-500 字的纠错原因")
		}
		correctionReason = &reason
	}
	return i2core.CreateWeightInput{
		SubjectType: subjectType, HamsterID: request.HamsterID, PupIdentityID: request.PupIdentityID, LitterID: request.LitterID,
		MeasurementKind: measurementKind, SubjectCount: request.SubjectCount, WeightG: request.WeightG,
		RecordedAt: recordedAt, Source: source, AcquisitionKey: request.DeviceReadingID,
		CorrectsWeightRecordID: request.CorrectsWeightRecordID, CorrectionReason: correctionReason,
	}, nil
}

func (dimensions i2EnclosureDimensionsRequest) valid() bool {
	return dimensions.Length > 0 && dimensions.Width > 0 && dimensions.Height > 0 && (dimensions.Unit == "" || dimensions.Unit == "mm")
}

func (dimensions i2EnclosureDimensionsRequest) coreMap() map[string]any {
	return map[string]any{"length": dimensions.Length, "width": dimensions.Width, "height": dimensions.Height, "unit": "mm"}
}
