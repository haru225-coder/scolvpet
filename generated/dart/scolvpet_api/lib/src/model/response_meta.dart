//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'response_meta.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ResponseMeta {
  /// Returns a new [ResponseMeta] instance.
  ResponseMeta({

    required  this.requestId,

    required  this.generatedAt,

    required  this.timezone,
  });

      /// 请求追踪 ID
  @JsonKey(

    name: r'request_id',
    required: true,
    includeIfNull: false,
  )


  final String requestId;



      /// UTC 响应生成时间
  @JsonKey(

    name: r'generated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime generatedAt;



      /// 本次业务日期计算使用的 IANA 时区
  @JsonKey(

    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ResponseMeta &&
      other.requestId == requestId &&
      other.generatedAt == generatedAt &&
      other.timezone == timezone;

    @override
    int get hashCode =>
        requestId.hashCode +
        generatedAt.hashCode +
        timezone.hashCode;

  factory ResponseMeta.fromJson(Map<String, dynamic> json) => _$ResponseMetaFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseMetaToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
