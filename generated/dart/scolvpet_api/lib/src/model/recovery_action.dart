//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recovery_action.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RecoveryAction {
  /// Returns a new [RecoveryAction] instance.
  RecoveryAction({

    required  this.action,

    required  this.label,

    required  this.method,

    required  this.path,
  });

  @JsonKey(

    name: r'action',
    required: true,
    includeIfNull: false,
  )


  final String action;



  @JsonKey(

    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(

    name: r'method',
    required: true,
    includeIfNull: false,
  )


  final RecoveryActionMethodEnum method;



  @JsonKey(

    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RecoveryAction &&
      other.action == action &&
      other.label == label &&
      other.method == method &&
      other.path == path;

    @override
    int get hashCode =>
        action.hashCode +
        label.hashCode +
        method.hashCode +
        path.hashCode;

  factory RecoveryAction.fromJson(Map<String, dynamic> json) => _$RecoveryActionFromJson(json);

  Map<String, dynamic> toJson() => _$RecoveryActionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum RecoveryActionMethodEnum {
@JsonValue(r'GET')
GET(r'GET'),
@JsonValue(r'POST')
POST(r'POST'),
@JsonValue(r'PUT')
PUT(r'PUT'),
@JsonValue(r'PATCH')
PATCH(r'PATCH'),
@JsonValue(r'DELETE')
DELETE(r'DELETE');

const RecoveryActionMethodEnum(this.value);

final String value;

@override
String toString() => value;
}
