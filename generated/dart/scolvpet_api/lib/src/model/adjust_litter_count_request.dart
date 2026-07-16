//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'adjust_litter_count_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdjustLitterCountRequest {
  /// Returns a new [AdjustLitterCountRequest] instance.
  AdjustLitterCountRequest({

    required  this.eventType,

    required  this.delta,

    required  this.occurredAt,

    required  this.reason,

     this.newTemporaryCodes,

     this.affectedPupIdentityIds,
  });

  @JsonKey(
    
    name: r'event_type',
    required: true,
    includeIfNull: false,
  )


  final AdjustLitterCountRequestEventTypeEnum eventType;



      /// discovered 必须为正；death/transferred_out 必须为负；correction 非零
  @JsonKey(
    
    name: r'delta',
    required: true,
    includeIfNull: false,
  )


  final int delta;



  @JsonKey(
    
    name: r'occurred_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime occurredAt;



  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;



  @JsonKey(
    
    name: r'new_temporary_codes',
    required: false,
    includeIfNull: false,
  )


  final Set<String>? newTemporaryCodes;



  @JsonKey(
    
    name: r'affected_pup_identity_ids',
    required: false,
    includeIfNull: false,
  )


  final Set<String>? affectedPupIdentityIds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdjustLitterCountRequest &&
      other.eventType == eventType &&
      other.delta == delta &&
      other.occurredAt == occurredAt &&
      other.reason == reason &&
      other.newTemporaryCodes == newTemporaryCodes &&
      other.affectedPupIdentityIds == affectedPupIdentityIds;

    @override
    int get hashCode =>
        eventType.hashCode +
        delta.hashCode +
        occurredAt.hashCode +
        reason.hashCode +
        newTemporaryCodes.hashCode +
        affectedPupIdentityIds.hashCode;

  factory AdjustLitterCountRequest.fromJson(Map<String, dynamic> json) => _$AdjustLitterCountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdjustLitterCountRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AdjustLitterCountRequestEventTypeEnum {
@JsonValue(r'discovered')
discovered(r'discovered'),
@JsonValue(r'death')
death(r'death'),
@JsonValue(r'transferred_out')
transferredOut(r'transferred_out'),
@JsonValue(r'correction')
correction(r'correction');

const AdjustLitterCountRequestEventTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


