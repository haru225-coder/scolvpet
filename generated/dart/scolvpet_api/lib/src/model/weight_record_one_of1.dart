//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_record_one_of1.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightRecordOneOf1 {
  /// Returns a new [WeightRecordOneOf1] instance.
  WeightRecordOneOf1({

     this.hamsterId,

     this.litterId,

     this.measurementKind,

     this.subjectCount,
  });

  @JsonKey(
    
    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final Object? hamsterId;



  @JsonKey(
    
    name: r'litter_id',
    required: false,
    includeIfNull: false,
  )


  final Object? litterId;



  @JsonKey(
    
    name: r'measurement_kind',
    required: false,
    includeIfNull: false,
  )


  final WeightRecordOneOf1MeasurementKindEnum? measurementKind;



  @JsonKey(
    
    name: r'subject_count',
    required: false,
    includeIfNull: false,
  )


  final Object? subjectCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeightRecordOneOf1 &&
      other.hamsterId == hamsterId &&
      other.litterId == litterId &&
      other.measurementKind == measurementKind &&
      other.subjectCount == subjectCount;

    @override
    int get hashCode =>
        hamsterId.hashCode +
        litterId.hashCode +
        measurementKind.hashCode +
        subjectCount.hashCode;

  factory WeightRecordOneOf1.fromJson(Map<String, dynamic> json) => _$WeightRecordOneOf1FromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordOneOf1ToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum WeightRecordOneOf1MeasurementKindEnum {
@JsonValue(r'individual')
individual(r'individual');

const WeightRecordOneOf1MeasurementKindEnum(this.value);

final String value;

@override
String toString() => value;
}


