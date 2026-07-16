//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'revoke_share_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RevokeShareRequest {
  /// Returns a new [RevokeShareRequest] instance.
  RevokeShareRequest({

    required  this.reason,
  });

  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RevokeShareRequest &&
      other.reason == reason;

    @override
    int get hashCode =>
        reason.hashCode;

  factory RevokeShareRequest.fromJson(Map<String, dynamic> json) => _$RevokeShareRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RevokeShareRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

