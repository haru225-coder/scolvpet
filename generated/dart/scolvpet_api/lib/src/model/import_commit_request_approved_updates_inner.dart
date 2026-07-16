//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_commit_request_approved_updates_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportCommitRequestApprovedUpdatesInner {
  /// Returns a new [ImportCommitRequestApprovedUpdatesInner] instance.
  ImportCommitRequestApprovedUpdatesInner({

    required  this.rowNumber,

    required  this.resourceId,

    required  this.expectedVersion,

    required  this.fields,
  });

          // minimum: 1
  @JsonKey(
    
    name: r'row_number',
    required: true,
    includeIfNull: false,
  )


  final int rowNumber;



  @JsonKey(
    
    name: r'resource_id',
    required: true,
    includeIfNull: false,
  )


  final String resourceId;



          // minimum: 1
  @JsonKey(
    
    name: r'expected_version',
    required: true,
    includeIfNull: false,
  )


  final int expectedVersion;



  @JsonKey(
    
    name: r'fields',
    required: true,
    includeIfNull: false,
  )


  final Set<String> fields;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportCommitRequestApprovedUpdatesInner &&
      other.rowNumber == rowNumber &&
      other.resourceId == resourceId &&
      other.expectedVersion == expectedVersion &&
      other.fields == fields;

    @override
    int get hashCode =>
        rowNumber.hashCode +
        resourceId.hashCode +
        expectedVersion.hashCode +
        fields.hashCode;

  factory ImportCommitRequestApprovedUpdatesInner.fromJson(Map<String, dynamic> json) => _$ImportCommitRequestApprovedUpdatesInnerFromJson(json);

  Map<String, dynamic> toJson() => _$ImportCommitRequestApprovedUpdatesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

