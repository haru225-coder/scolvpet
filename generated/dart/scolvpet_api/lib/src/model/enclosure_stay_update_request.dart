//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enclosure_stay_update_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnclosureStayUpdateRequest {
  /// Returns a new [EnclosureStayUpdateRequest] instance.
  EnclosureStayUpdateRequest({

     this.endedAt,

     this.reason,

     this.correctionReason,
  });

  @JsonKey(

    name: r'ended_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? endedAt;



  @JsonKey(

    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;



  @JsonKey(

    name: r'correction_reason',
    required: false,
    includeIfNull: false,
  )


  final String? correctionReason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EnclosureStayUpdateRequest &&
      other.endedAt == endedAt &&
      other.reason == reason &&
      other.correctionReason == correctionReason;

    @override
    int get hashCode =>
        endedAt.hashCode +
        (reason == null ? 0 : reason.hashCode) +
        (correctionReason == null ? 0 : correctionReason.hashCode);

  factory EnclosureStayUpdateRequest.fromJson(Map<String, dynamic> json) => _$EnclosureStayUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EnclosureStayUpdateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
