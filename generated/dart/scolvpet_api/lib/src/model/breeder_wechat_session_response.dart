//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/breeder_wechat_session_response_data.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'breeder_wechat_session_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BreederWechatSessionResponse {
  /// Returns a new [BreederWechatSessionResponse] instance.
  BreederWechatSessionResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final BreederWechatSessionResponseData data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BreederWechatSessionResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory BreederWechatSessionResponse.fromJson(Map<String, dynamic> json) => _$BreederWechatSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BreederWechatSessionResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
