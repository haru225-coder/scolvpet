//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_record_one_of2.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightRecordOneOf2 {
  /// Returns a new [WeightRecordOneOf2] instance.
  WeightRecordOneOf2({

     this.hamsterId,

     this.pupIdentityId,

    required  this.measurementKind,
  });

  @JsonKey(
    
    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final Object? hamsterId;



  @JsonKey(
    
    name: r'pup_identity_id',
    required: false,
    includeIfNull: false,
  )


  final Object? pupIdentityId;



  @JsonKey(
    
    name: r'measurement_kind',
    required: true,
    includeIfNull: false,
  )


  final WeightRecordOneOf2MeasurementKindEnum measurementKind;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeightRecordOneOf2 &&
      other.hamsterId == hamsterId &&
      other.pupIdentityId == pupIdentityId &&
      other.measurementKind == measurementKind;

    @override
    int get hashCode =>
        hamsterId.hashCode +
        pupIdentityId.hashCode +
        measurementKind.hashCode;

  factory WeightRecordOneOf2.fromJson(Map<String, dynamic> json) => _$WeightRecordOneOf2FromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordOneOf2ToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum WeightRecordOneOf2MeasurementKindEnum {
@JsonValue(r'litter_total')
litterTotal(r'litter_total'),
@JsonValue(r'litter_average')
litterAverage(r'litter_average');

const WeightRecordOneOf2MeasurementKindEnum(this.value);

final String value;

@override
String toString() => value;
}


