//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_record_one_of.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightRecordOneOf {
  /// Returns a new [WeightRecordOneOf] instance.
  WeightRecordOneOf({

     this.pupIdentityId,
  });

  @JsonKey(
    
    name: r'pup_identity_id',
    required: false,
    includeIfNull: false,
  )


  final Object? pupIdentityId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeightRecordOneOf &&
      other.pupIdentityId == pupIdentityId;

    @override
    int get hashCode =>
        pupIdentityId.hashCode;

  factory WeightRecordOneOf.fromJson(Map<String, dynamic> json) => _$WeightRecordOneOfFromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordOneOfToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

