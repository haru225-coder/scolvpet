//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/assistant_capabilities.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_capabilities_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantCapabilitiesResponse {
  /// Returns a new [AssistantCapabilitiesResponse] instance.
  AssistantCapabilitiesResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(
    
    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final AssistantCapabilities data;



  @JsonKey(
    
    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantCapabilitiesResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory AssistantCapabilitiesResponse.fromJson(Map<String, dynamic> json) => _$AssistantCapabilitiesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantCapabilitiesResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

