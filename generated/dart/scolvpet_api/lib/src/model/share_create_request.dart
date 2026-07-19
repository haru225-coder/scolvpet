//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/share_public_field.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'share_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ShareCreateRequest {
  /// Returns a new [ShareCreateRequest] instance.
  ShareCreateRequest({

    required  this.subjectType,

    required  this.subjectId,

    required  this.fields,

    required  this.mediaIds,

     this.expiresAt,
  });

  @JsonKey(

    name: r'subject_type',
    required: true,
    includeIfNull: false,
  )


  final ShareCreateRequestSubjectTypeEnum subjectType;



  @JsonKey(

    name: r'subject_id',
    required: true,
    includeIfNull: false,
  )


  final String subjectId;



  @JsonKey(

    name: r'fields',
    required: true,
    includeIfNull: false,
  )


  final Set<SharePublicField> fields;



  @JsonKey(

    name: r'media_ids',
    required: true,
    includeIfNull: false,
  )


  final Set<String> mediaIds;



  @JsonKey(

    name: r'expires_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShareCreateRequest &&
      other.subjectType == subjectType &&
      other.subjectId == subjectId &&
      other.fields == fields &&
      other.mediaIds == mediaIds &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        subjectType.hashCode +
        subjectId.hashCode +
        fields.hashCode +
        mediaIds.hashCode +
        (expiresAt == null ? 0 : expiresAt.hashCode);

  factory ShareCreateRequest.fromJson(Map<String, dynamic> json) => _$ShareCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ShareCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ShareCreateRequestSubjectTypeEnum {
@JsonValue(r'hamster')
hamster(r'hamster'),
@JsonValue(r'litter')
litter(r'litter');

const ShareCreateRequestSubjectTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
