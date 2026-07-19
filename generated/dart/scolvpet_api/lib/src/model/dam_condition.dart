//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dam_condition.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DamCondition {
  /// Returns a new [DamCondition] instance.
  DamCondition({

    required  this.status,

     this.structuredChecks,

     this.notes,
  });

  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final DamConditionStatusEnum status;



  @JsonKey(

    name: r'structured_checks',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? structuredChecks;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DamCondition &&
      other.status == status &&
      other.structuredChecks == structuredChecks &&
      other.notes == notes;

    @override
    int get hashCode =>
        status.hashCode +
        structuredChecks.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory DamCondition.fromJson(Map<String, dynamic> json) => _$DamConditionFromJson(json);

  Map<String, dynamic> toJson() => _$DamConditionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum DamConditionStatusEnum {
@JsonValue(r'stable')
stable(r'stable'),
@JsonValue(r'needs_observation')
needsObservation(r'needs_observation'),
@JsonValue(r'requires_care')
requiresCare(r'requires_care'),
@JsonValue(r'deceased')
deceased(r'deceased');

const DamConditionStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
