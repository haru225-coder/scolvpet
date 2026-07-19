//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:scolvpet_api/src/model/miniprogram_config.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'miniprogram_config_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MiniprogramConfigResponse {
  /// Returns a new [MiniprogramConfigResponse] instance.
  MiniprogramConfigResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final MiniprogramConfig data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MiniprogramConfigResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory MiniprogramConfigResponse.fromJson(Map<String, dynamic> json) => _$MiniprogramConfigResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MiniprogramConfigResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
