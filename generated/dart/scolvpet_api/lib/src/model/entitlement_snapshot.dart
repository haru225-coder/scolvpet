//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/entitlement_feature.dart';
import 'package:scolvpet_api/src/model/entitlement_limit.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_snapshot.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EntitlementSnapshot {
  /// Returns a new [EntitlementSnapshot] instance.
  EntitlementSnapshot({

    required  this.planCode,

    required  this.planTitle,

    required  this.enforcement,

    required  this.source_,

    required  this.effectiveAt,

     this.expiresAt,

    required  this.features,

    required  this.limits,

    required  this.overLimit,

     this.paywallHint,
  });

  @JsonKey(

    name: r'plan_code',
    required: true,
    includeIfNull: false,
  )


  final String planCode;



  @JsonKey(

    name: r'plan_title',
    required: true,
    includeIfNull: false,
  )


  final String planTitle;



  @JsonKey(

    name: r'enforcement',
    required: true,
    includeIfNull: false,
  )


  final EntitlementSnapshotEnforcementEnum enforcement;



  @JsonKey(

    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final String source_;



  @JsonKey(

    name: r'effective_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime effectiveAt;



  @JsonKey(

    name: r'expires_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;



  @JsonKey(

    name: r'features',
    required: true,
    includeIfNull: false,
  )


  final List<EntitlementFeature> features;



  @JsonKey(

    name: r'limits',
    required: true,
    includeIfNull: false,
  )


  final List<EntitlementLimit> limits;



  @JsonKey(

    name: r'over_limit',
    required: true,
    includeIfNull: false,
  )


  final bool overLimit;



  @JsonKey(

    name: r'paywall_hint',
    required: false,
    includeIfNull: false,
  )


  final String? paywallHint;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EntitlementSnapshot &&
      other.planCode == planCode &&
      other.planTitle == planTitle &&
      other.enforcement == enforcement &&
      other.source_ == source_ &&
      other.effectiveAt == effectiveAt &&
      other.expiresAt == expiresAt &&
      other.features == features &&
      other.limits == limits &&
      other.overLimit == overLimit &&
      other.paywallHint == paywallHint;

    @override
    int get hashCode =>
        planCode.hashCode +
        planTitle.hashCode +
        enforcement.hashCode +
        source_.hashCode +
        effectiveAt.hashCode +
        (expiresAt == null ? 0 : expiresAt.hashCode) +
        features.hashCode +
        limits.hashCode +
        overLimit.hashCode +
        (paywallHint == null ? 0 : paywallHint.hashCode);

  factory EntitlementSnapshot.fromJson(Map<String, dynamic> json) => _$EntitlementSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementSnapshotToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum EntitlementSnapshotEnforcementEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'soft')
soft(r'soft'),
@JsonValue(r'hard')
hard(r'hard');

const EntitlementSnapshotEnforcementEnum(this.value);

final String value;

@override
String toString() => value;
}
