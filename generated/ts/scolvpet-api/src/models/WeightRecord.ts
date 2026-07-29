// @ts-nocheck — generated code; see tools/prepare-generated-ts.mjs
export interface WeightRecord {
  id: string;
  hamsterId?: string | null;
  pupIdentityId?: string | null;
  litterId?: string | null;
  measurementKind: string;
  subjectCount?: number | null;
  weightG: number;
  recordedAt: Date;
  source: string;
  birthWeightG?: number | null;
  previousWeightG?: number | null;
  changeFromPreviousG?: number | null;
  changeFromBirthG?: number | null;
  alertFlags: string[];
  notes?: string | null;
  correctsWeightRecordId?: string | null;
  correctionReason?: string | null;
  createdAt: Date;
}

export function WeightRecordFromJSON(json: any): WeightRecord {
  return {
    id: json.id,
    hamsterId: json.hamster_id ?? null,
    pupIdentityId: json.pup_identity_id ?? null,
    litterId: json.litter_id ?? null,
    measurementKind: json.measurement_kind,
    subjectCount: json.subject_count ?? null,
    weightG: json.weight_g,
    recordedAt: new Date(json.recorded_at),
    source: json.source,
    birthWeightG: json.birth_weight_g ?? null,
    previousWeightG: json.previous_weight_g ?? null,
    changeFromPreviousG: json.change_from_previous_g ?? null,
    changeFromBirthG: json.change_from_birth_g ?? null,
    alertFlags: json.alert_flags || [],
    notes: json.notes ?? null,
    correctsWeightRecordId: json.corrects_weight_record_id ?? null,
    correctionReason: json.correction_reason ?? null,
    createdAt: new Date(json.created_at)
  };
}

export function WeightRecordToJSON(value?: WeightRecord | null): any {
  if (value == null) return value;
  return {
    id: value.id,
    hamster_id: value.hamsterId,
    pup_identity_id: value.pupIdentityId,
    litter_id: value.litterId,
    measurement_kind: value.measurementKind,
    subject_count: value.subjectCount,
    weight_g: value.weightG,
    recorded_at: value.recordedAt instanceof Date ? value.recordedAt.toISOString() : value.recordedAt,
    source: value.source,
    birth_weight_g: value.birthWeightG,
    previous_weight_g: value.previousWeightG,
    change_from_previous_g: value.changeFromPreviousG,
    change_from_birth_g: value.changeFromBirthG,
    alert_flags: value.alertFlags,
    notes: value.notes,
    corrects_weight_record_id: value.correctsWeightRecordId,
    correction_reason: value.correctionReason,
    created_at: value.createdAt instanceof Date ? value.createdAt.toISOString() : value.createdAt
  };
}
export const WeightRecordFromJSONTyped = WeightRecordFromJSON;
export const WeightRecordToJSONTyped = WeightRecordToJSON;
