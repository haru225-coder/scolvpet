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
  });

  @JsonKey(
    
    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final Object? hamsterId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeightRecordOneOf1 &&
      other.hamsterId == hamsterId;

    @override
    int get hashCode =>
        hamsterId.hashCode;

  factory WeightRecordOneOf1.fromJson(Map<String, dynamic> json) => _$WeightRecordOneOf1FromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordOneOf1ToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

