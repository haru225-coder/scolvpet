//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/recovery_action.dart';
import 'package:scolvpet_api/src/model/field_error.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'error_object.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ErrorObject {
  /// Returns a new [ErrorObject] instance.
  ErrorObject({

    required  this.code,

    required  this.message,

    required  this.fieldErrors,

     this.currentVersion,

    required  this.recoveryActions,

     this.details,
  });

  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'field_errors',
    required: true,
    includeIfNull: false,
  )


  final List<FieldError> fieldErrors;



          // minimum: 1
  @JsonKey(
    
    name: r'current_version',
    required: false,
    includeIfNull: false,
  )


  final int? currentVersion;



  @JsonKey(
    
    name: r'recovery_actions',
    required: true,
    includeIfNull: false,
  )


  final List<RecoveryAction> recoveryActions;



  @JsonKey(
    
    name: r'details',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? details;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ErrorObject &&
      other.code == code &&
      other.message == message &&
      other.fieldErrors == fieldErrors &&
      other.currentVersion == currentVersion &&
      other.recoveryActions == recoveryActions &&
      other.details == details;

    @override
    int get hashCode =>
        code.hashCode +
        message.hashCode +
        fieldErrors.hashCode +
        (currentVersion == null ? 0 : currentVersion.hashCode) +
        recoveryActions.hashCode +
        details.hashCode;

  factory ErrorObject.fromJson(Map<String, dynamic> json) => _$ErrorObjectFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorObjectToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

