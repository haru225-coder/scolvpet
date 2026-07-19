//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/media_variant.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_share_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicShareResponseData {
  /// Returns a new [PublicShareResponseData] instance.
  PublicShareResponseData({

    required  this.shareId,

    required  this.subjectType,

    required  this.display,

    required  this.media,

     this.expiresAt,
  });

  @JsonKey(

    name: r'share_id',
    required: true,
    includeIfNull: false,
  )


  final String shareId;



  @JsonKey(

    name: r'subject_type',
    required: true,
    includeIfNull: false,
  )


  final PublicShareResponseDataSubjectTypeEnum subjectType;



      /// 仅包含创建分享时显式选择的公开字段
  @JsonKey(

    name: r'display',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> display;



  @JsonKey(

    name: r'media',
    required: true,
    includeIfNull: false,
  )


  final List<MediaVariant> media;



  @JsonKey(

    name: r'expires_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicShareResponseData &&
      other.shareId == shareId &&
      other.subjectType == subjectType &&
      other.display == display &&
      other.media == media &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        shareId.hashCode +
        subjectType.hashCode +
        display.hashCode +
        media.hashCode +
        (expiresAt == null ? 0 : expiresAt.hashCode);

  factory PublicShareResponseData.fromJson(Map<String, dynamic> json) => _$PublicShareResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$PublicShareResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PublicShareResponseDataSubjectTypeEnum {
@JsonValue(r'hamster')
hamster(r'hamster'),
@JsonValue(r'litter')
litter(r'litter');

const PublicShareResponseDataSubjectTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
