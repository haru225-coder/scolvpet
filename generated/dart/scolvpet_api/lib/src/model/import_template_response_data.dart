//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/import_template_type.dart';
import 'package:scolvpet_api/src/model/import_template_response_data_columns_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_template_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportTemplateResponseData {
  /// Returns a new [ImportTemplateResponseData] instance.
  ImportTemplateResponseData({

    required  this.templateType,

    required  this.version,

    required  this.downloadUrl,

    required  this.expiresAt,

    required  this.columns,
  });

  @JsonKey(
    
    name: r'template_type',
    required: true,
    includeIfNull: false,
  )


  final ImportTemplateType templateType;



  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final String version;



  @JsonKey(
    
    name: r'download_url',
    required: true,
    includeIfNull: false,
  )


  final String downloadUrl;



  @JsonKey(
    
    name: r'expires_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime expiresAt;



  @JsonKey(
    
    name: r'columns',
    required: true,
    includeIfNull: false,
  )


  final List<ImportTemplateResponseDataColumnsInner> columns;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportTemplateResponseData &&
      other.templateType == templateType &&
      other.version == version &&
      other.downloadUrl == downloadUrl &&
      other.expiresAt == expiresAt &&
      other.columns == columns;

    @override
    int get hashCode =>
        templateType.hashCode +
        version.hashCode +
        downloadUrl.hashCode +
        expiresAt.hashCode +
        columns.hashCode;

  factory ImportTemplateResponseData.fromJson(Map<String, dynamic> json) => _$ImportTemplateResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$ImportTemplateResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

