//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/import_mapping_request_mappings_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_mapping_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportMappingRequest {
  /// Returns a new [ImportMappingRequest] instance.
  ImportMappingRequest({

    required  this.timezone,

    required  this.mappings,
  });

  @JsonKey(

    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;



  @JsonKey(

    name: r'mappings',
    required: true,
    includeIfNull: false,
  )


  final List<ImportMappingRequestMappingsInner> mappings;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportMappingRequest &&
      other.timezone == timezone &&
      other.mappings == mappings;

    @override
    int get hashCode =>
        timezone.hashCode +
        mappings.hashCode;

  factory ImportMappingRequest.fromJson(Map<String, dynamic> json) => _$ImportMappingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ImportMappingRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
