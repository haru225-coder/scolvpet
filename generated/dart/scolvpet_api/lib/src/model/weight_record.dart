//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/weight_record_one_of2.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_record.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightRecord {
  /// Returns a new [WeightRecord] instance.
  WeightRecord({

    required  this.id,

     this.hamsterId,

     this.pupIdentityId,

     this.litterId,

     this.measurementKind,

     this.subjectCount,

    required  this.weightG,

    required  this.recordedAt,

    required  this.source_,

     this.birthWeightG,

     this.previousWeightG,

     this.changeFromPreviousG,

     this.changeFromBirthG,

    required  this.alertFlags,

     this.notes,

     this.correctsWeightRecordId,

     this.correctionReason,

    required  this.createdAt,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? hamsterId;



  @JsonKey(

    name: r'pup_identity_id',
    required: false,
    includeIfNull: false,
  )


  final String? pupIdentityId;



  @JsonKey(

    name: r'litter_id',
    required: false,
    includeIfNull: false,
  )


  final String? litterId;



  @JsonKey(

    name: r'measurement_kind',
    required: false,
    includeIfNull: false,
  )


  final WeightRecordMeasurementKindEnum? measurementKind;



          // minimum: 1
  @JsonKey(

    name: r'subject_count',
    required: false,
    includeIfNull: false,
  )


  final int? subjectCount;



          // minimum: 0
          // maximum: 5000
  @JsonKey(

    name: r'weight_g',
    required: true,
    includeIfNull: false,
  )


  final num weightG;



  @JsonKey(

    name: r'recorded_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime recordedAt;



  @JsonKey(

    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final WeightRecordSource_Enum source_;



  @JsonKey(

    name: r'birth_weight_g',
    required: false,
    includeIfNull: false,
  )


  final num? birthWeightG;



  @JsonKey(

    name: r'previous_weight_g',
    required: false,
    includeIfNull: false,
  )


  final num? previousWeightG;



  @JsonKey(

    name: r'change_from_previous_g',
    required: false,
    includeIfNull: false,
  )


  final num? changeFromPreviousG;



  @JsonKey(

    name: r'change_from_birth_g',
    required: false,
    includeIfNull: false,
  )


  final num? changeFromBirthG;



  @JsonKey(

    name: r'alert_flags',
    required: true,
    includeIfNull: false,
  )


  final List<WeightRecordAlertFlagsEnum> alertFlags;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



      /// 若非空，本条记录是对该历史记录的纠错，原记录仍然保留。
  @JsonKey(

    name: r'corrects_weight_record_id',
    required: false,
    includeIfNull: false,
  )


  final String? correctsWeightRecordId;



  @JsonKey(

    name: r'correction_reason',
    required: false,
    includeIfNull: false,
  )


  final String? correctionReason;



  @JsonKey(

    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeightRecord &&
      other.id == id &&
      other.hamsterId == hamsterId &&
      other.pupIdentityId == pupIdentityId &&
      other.litterId == litterId &&
      other.measurementKind == measurementKind &&
      other.subjectCount == subjectCount &&
      other.weightG == weightG &&
      other.recordedAt == recordedAt &&
      other.source_ == source_ &&
      other.birthWeightG == birthWeightG &&
      other.previousWeightG == previousWeightG &&
      other.changeFromPreviousG == changeFromPreviousG &&
      other.changeFromBirthG == changeFromBirthG &&
      other.alertFlags == alertFlags &&
      other.notes == notes &&
      other.correctsWeightRecordId == correctsWeightRecordId &&
      other.correctionReason == correctionReason &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        (hamsterId == null ? 0 : hamsterId.hashCode) +
        (pupIdentityId == null ? 0 : pupIdentityId.hashCode) +
        (litterId == null ? 0 : litterId.hashCode) +
        measurementKind.hashCode +
        (subjectCount == null ? 0 : subjectCount.hashCode) +
        weightG.hashCode +
        recordedAt.hashCode +
        source_.hashCode +
        (birthWeightG == null ? 0 : birthWeightG.hashCode) +
        (previousWeightG == null ? 0 : previousWeightG.hashCode) +
        (changeFromPreviousG == null ? 0 : changeFromPreviousG.hashCode) +
        (changeFromBirthG == null ? 0 : changeFromBirthG.hashCode) +
        alertFlags.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        (correctsWeightRecordId == null ? 0 : correctsWeightRecordId.hashCode) +
        (correctionReason == null ? 0 : correctionReason.hashCode) +
        createdAt.hashCode;

  factory WeightRecord.fromJson(Map<String, dynamic> json) => _$WeightRecordFromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum WeightRecordMeasurementKindEnum {
@JsonValue(r'individual')
individual(r'individual'),
@JsonValue(r'litter_total')
litterTotal(r'litter_total'),
@JsonValue(r'litter_average')
litterAverage(r'litter_average');

const WeightRecordMeasurementKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum WeightRecordSource_Enum {
@JsonValue(r'manual')
manual(r'manual'),
@JsonValue(r'bluetooth_scale')
bluetoothScale(r'bluetooth_scale'),
@JsonValue(r'import')
import_(r'import');

const WeightRecordSource_Enum(this.value);

final String value;

@override
String toString() => value;
}



enum WeightRecordAlertFlagsEnum {
@JsonValue(r'drop_from_previous')
dropFromPrevious(r'drop_from_previous'),
@JsonValue(r'below_birth_weight')
belowBirthWeight(r'below_birth_weight'),
@JsonValue(r'outside_reference')
outsideReference(r'outside_reference');

const WeightRecordAlertFlagsEnum(this.value);

final String value;

@override
String toString() => value;
}
