//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/recovery_action.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'individualization_eligibility_blocker.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IndividualizationEligibilityBlocker {
  /// Returns a new [IndividualizationEligibilityBlocker] instance.
  IndividualizationEligibilityBlocker({

    required  this.code,

    required  this.message,

    required  this.pupIdentityIds,

    required  this.recoveryActions,
  });

  @JsonKey(

    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final IndividualizationEligibilityBlockerCodeEnum code;



  @JsonKey(

    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(

    name: r'pup_identity_ids',
    required: true,
    includeIfNull: false,
  )


  final Set<String> pupIdentityIds;



  @JsonKey(

    name: r'recovery_actions',
    required: true,
    includeIfNull: false,
  )


  final List<RecoveryAction> recoveryActions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IndividualizationEligibilityBlocker &&
      other.code == code &&
      other.message == message &&
      other.pupIdentityIds == pupIdentityIds &&
      other.recoveryActions == recoveryActions;

    @override
    int get hashCode =>
        code.hashCode +
        message.hashCode +
        pupIdentityIds.hashCode +
        recoveryActions.hashCode;

  factory IndividualizationEligibilityBlocker.fromJson(Map<String, dynamic> json) => _$IndividualizationEligibilityBlockerFromJson(json);

  Map<String, dynamic> toJson() => _$IndividualizationEligibilityBlockerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum IndividualizationEligibilityBlockerCodeEnum {
@JsonValue(r'LITTER_STATE_NOT_READY')
LITTER_STATE_NOT_READY(r'LITTER_STATE_NOT_READY'),
@JsonValue(r'COUNT_MISMATCH')
COUNT_MISMATCH(r'COUNT_MISMATCH'),
@JsonValue(r'PUP_NOT_WEANED')
PUP_NOT_WEANED(r'PUP_NOT_WEANED'),
@JsonValue(r'SEX_RECHECK_REQUIRED')
SEX_RECHECK_REQUIRED(r'SEX_RECHECK_REQUIRED'),
@JsonValue(r'ENCLOSURE_REQUIRED')
ENCLOSURE_REQUIRED(r'ENCLOSURE_REQUIRED'),
@JsonValue(r'ENCLOSURE_CONFLICT')
ENCLOSURE_CONFLICT(r'ENCLOSURE_CONFLICT'),
@JsonValue(r'ALREADY_INDIVIDUALIZED')
ALREADY_INDIVIDUALIZED(r'ALREADY_INDIVIDUALIZED');

const IndividualizationEligibilityBlockerCodeEnum(this.value);

final String value;

@override
String toString() => value;
}
