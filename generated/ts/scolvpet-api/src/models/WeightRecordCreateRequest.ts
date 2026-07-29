// @ts-nocheck — generated code; see tools/prepare-generated-ts.mjs
export interface WeightRecordCreateRequest {
  hamsterId?: string | null;
  pupIdentityId?: string | null;
  litterId?: string | null;
  measurementKind?: string;
  subjectCount?: number | null;
  weightG: number;
  recordedAt: Date;
  source: string;
  deviceReadingId?: string | null;
  notes?: string | null;
  correctsWeightRecordId?: string | null;
  correctionReason?: string | null;
}

export function WeightRecordCreateRequestFromJSON(json: any): WeightRecordCreateRequest {
  return {
    hamsterId: json.hamster_id ?? null,
    pupIdentityId: json.pup_identity_id ?? null,
    litterId: json.litter_id ?? null,
    measurementKind: json.measurement_kind,
    subjectCount: json.subject_count ?? null,
    weightG: json.weight_g,
    recordedAt: new Date(json.recorded_at),
    source: json.source,
    deviceReadingId: json.device_reading_id ?? null,
    notes: json.notes ?? null,
    correctsWeightRecordId: json.corrects_weight_record_id ?? null,
    correctionReason: json.correction_reason ?? null
  };
}

export function WeightRecordCreateRequestToJSON(value?: WeightRecordCreateRequest | null): any {
  if (value == null) return value;
  return {
    hamster_id: value.hamsterId,
    pup_identity_id: value.pupIdentityId,
    litter_id: value.litterId,
    measurement_kind: value.measurementKind,
    subject_count: value.subjectCount,
    weight_g: value.weightG,
    recorded_at: value.recordedAt instanceof Date ? value.recordedAt.toISOString() : value.recordedAt,
    source: value.source,
    device_reading_id: value.deviceReadingId,
    notes: value.notes,
    corrects_weight_record_id: value.correctsWeightRecordId,
    correction_reason: value.correctionReason
  };
}
export const WeightRecordCreateRequestFromJSONTyped = WeightRecordCreateRequestFromJSON;
export const WeightRecordCreateRequestToJSONTyped = WeightRecordCreateRequestToJSON;
