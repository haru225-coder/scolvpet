//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/adjust_litter_count_response_data.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'adjust_litter_count_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdjustLitterCountResponse {
  /// Returns a new [AdjustLitterCountResponse] instance.
  AdjustLitterCountResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(
    
    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final AdjustLitterCountResponseData data;



  @JsonKey(
    
    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdjustLitterCountResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory AdjustLitterCountResponse.fromJson(Map<String, dynamic> json) => _$AdjustLitterCountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdjustLitterCountResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

