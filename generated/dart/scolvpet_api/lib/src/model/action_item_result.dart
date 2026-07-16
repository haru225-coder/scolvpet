//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/batch_item_status.dart';
import 'package:scolvpet_api/src/model/error_object.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'action_item_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActionItemResult {
  /// Returns a new [ActionItemResult] instance.
  ActionItemResult({

    required  this.pupIdentityId,

    required  this.status,

     this.enclosureStayId,

     this.error,
  });

  @JsonKey(
    
    name: r'pup_identity_id',
    required: true,
    includeIfNull: false,
  )


  final String pupIdentityId;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final BatchItemStatus status;



  @JsonKey(
    
    name: r'enclosure_stay_id',
    required: false,
    includeIfNull: false,
  )


  final String? enclosureStayId;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final ErrorObject? error;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActionItemResult &&
      other.pupIdentityId == pupIdentityId &&
      other.status == status &&
      other.enclosureStayId == enclosureStayId &&
      other.error == error;

    @override
    int get hashCode =>
        pupIdentityId.hashCode +
        status.hashCode +
        (enclosureStayId == null ? 0 : enclosureStayId.hashCode) +
        (error == null ? 0 : error.hashCode);

  factory ActionItemResult.fromJson(Map<String, dynamic> json) => _$ActionItemResultFromJson(json);

  Map<String, dynamic> toJson() => _$ActionItemResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

