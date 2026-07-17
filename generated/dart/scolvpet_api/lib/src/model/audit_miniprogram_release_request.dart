//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'audit_miniprogram_release_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AuditMiniprogramReleaseRequest {
  /// Returns a new [AuditMiniprogramReleaseRequest] instance.
  AuditMiniprogramReleaseRequest({

    required  this.decision,

     this.note,
  });

  @JsonKey(
    
    name: r'decision',
    required: true,
    includeIfNull: false,
  )


  final AuditMiniprogramReleaseRequestDecisionEnum decision;



  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AuditMiniprogramReleaseRequest &&
      other.decision == decision &&
      other.note == note;

    @override
    int get hashCode =>
        decision.hashCode +
        (note == null ? 0 : note.hashCode);

  factory AuditMiniprogramReleaseRequest.fromJson(Map<String, dynamic> json) => _$AuditMiniprogramReleaseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AuditMiniprogramReleaseRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AuditMiniprogramReleaseRequestDecisionEnum {
@JsonValue(r'approve')
approve(r'approve'),
@JsonValue(r'reject')
reject(r'reject');

const AuditMiniprogramReleaseRequestDecisionEnum(this.value);

final String value;

@override
String toString() => value;
}


