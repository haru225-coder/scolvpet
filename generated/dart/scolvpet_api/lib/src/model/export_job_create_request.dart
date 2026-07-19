//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'export_job_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExportJobCreateRequest {
  /// Returns a new [ExportJobCreateRequest] instance.
  ExportJobCreateRequest({

    required  this.datasets,

    required  this.format,

    required  this.timezone,

     this.filters,
  });

  @JsonKey(

    name: r'datasets',
    required: true,
    includeIfNull: false,
  )


  final Set<ExportJobCreateRequestDatasetsEnum> datasets;



  @JsonKey(

    name: r'format',
    required: true,
    includeIfNull: false,
  )


  final ExportJobCreateRequestFormatEnum format;



  @JsonKey(

    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;



  @JsonKey(

    name: r'filters',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? filters;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ExportJobCreateRequest &&
      other.datasets == datasets &&
      other.format == format &&
      other.timezone == timezone &&
      other.filters == filters;

    @override
    int get hashCode =>
        datasets.hashCode +
        format.hashCode +
        timezone.hashCode +
        filters.hashCode;

  factory ExportJobCreateRequest.fromJson(Map<String, dynamic> json) => _$ExportJobCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ExportJobCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ExportJobCreateRequestDatasetsEnum {
@JsonValue(r'hamsters')
hamsters(r'hamsters'),
@JsonValue(r'enclosures')
enclosures(r'enclosures'),
@JsonValue(r'breeding')
breeding(r'breeding'),
@JsonValue(r'litters')
litters(r'litters'),
@JsonValue(r'weights')
weights(r'weights'),
@JsonValue(r'health')
health(r'health'),
@JsonValue(r'pedigree')
pedigree(r'pedigree');

const ExportJobCreateRequestDatasetsEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ExportJobCreateRequestFormatEnum {
@JsonValue(r'csv_zip')
csvZip(r'csv_zip'),
@JsonValue(r'json')
json(r'json');

const ExportJobCreateRequestFormatEnum(this.value);

final String value;

@override
String toString() => value;
}
