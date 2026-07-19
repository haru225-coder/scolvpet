//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/import_row_status.dart';
import 'package:scolvpet_api/src/model/import_issue.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_row_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportRowResult {
  /// Returns a new [ImportRowResult] instance.
  ImportRowResult({

    required  this.rowNumber,

    required  this.status,

    required  this.mappedValues,

     this.resourceId,

    required  this.issues,
  });

          // minimum: 1
  @JsonKey(

    name: r'row_number',
    required: true,
    includeIfNull: false,
  )


  final int rowNumber;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final ImportRowStatus status;



  @JsonKey(

    name: r'mapped_values',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> mappedValues;



  @JsonKey(

    name: r'resource_id',
    required: false,
    includeIfNull: false,
  )


  final String? resourceId;



  @JsonKey(

    name: r'issues',
    required: true,
    includeIfNull: false,
  )


  final List<ImportIssue> issues;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportRowResult &&
      other.rowNumber == rowNumber &&
      other.status == status &&
      other.mappedValues == mappedValues &&
      other.resourceId == resourceId &&
      other.issues == issues;

    @override
    int get hashCode =>
        rowNumber.hashCode +
        status.hashCode +
        mappedValues.hashCode +
        (resourceId == null ? 0 : resourceId.hashCode) +
        issues.hashCode;

  factory ImportRowResult.fromJson(Map<String, dynamic> json) => _$ImportRowResultFromJson(json);

  Map<String, dynamic> toJson() => _$ImportRowResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
