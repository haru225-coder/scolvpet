//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/weight_record_one_of2.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_record_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightRecordCreateRequest {
  /// Returns a new [WeightRecordCreateRequest] instance.
  WeightRecordCreateRequest({

     this.hamsterId,

     this.pupIdentityId,

     this.litterId,

     this.measurementKind,

     this.subjectCount,

    required  this.weightG,

    required  this.recordedAt,

    required  this.source_,

     this.deviceReadingId,

     this.notes,
  });

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


  final WeightRecordCreateRequestMeasurementKindEnum? measurementKind;



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


  final WeightRecordCreateRequestSource_Enum source_;



  @JsonKey(

    name: r'device_reading_id',
    required: false,
    includeIfNull: false,
  )


  final String? deviceReadingId;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeightRecordCreateRequest &&
      other.hamsterId == hamsterId &&
      other.pupIdentityId == pupIdentityId &&
      other.litterId == litterId &&
      other.measurementKind == measurementKind &&
      other.subjectCount == subjectCount &&
      other.weightG == weightG &&
      other.recordedAt == recordedAt &&
      other.source_ == source_ &&
      other.deviceReadingId == deviceReadingId &&
      other.notes == notes;

    @override
    int get hashCode =>
        (hamsterId == null ? 0 : hamsterId.hashCode) +
        (pupIdentityId == null ? 0 : pupIdentityId.hashCode) +
        (litterId == null ? 0 : litterId.hashCode) +
        measurementKind.hashCode +
        (subjectCount == null ? 0 : subjectCount.hashCode) +
        weightG.hashCode +
        recordedAt.hashCode +
        source_.hashCode +
        (deviceReadingId == null ? 0 : deviceReadingId.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory WeightRecordCreateRequest.fromJson(Map<String, dynamic> json) => _$WeightRecordCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum WeightRecordCreateRequestMeasurementKindEnum {
@JsonValue(r'individual')
individual(r'individual'),
@JsonValue(r'litter_total')
litterTotal(r'litter_total'),
@JsonValue(r'litter_average')
litterAverage(r'litter_average');

const WeightRecordCreateRequestMeasurementKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum WeightRecordCreateRequestSource_Enum {
@JsonValue(r'manual')
manual(r'manual'),
@JsonValue(r'bluetooth_scale')
bluetoothScale(r'bluetooth_scale'),
@JsonValue(r'import')
import_(r'import');

const WeightRecordCreateRequestSource_Enum(this.value);

final String value;

@override
String toString() => value;
}
