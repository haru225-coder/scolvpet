//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'retry_import_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RetryImportRequest {
  /// Returns a new [RetryImportRequest] instance.
  RetryImportRequest({

    required  this.scope,

     this.rowNumbers,
  });

  @JsonKey(

    name: r'scope',
    required: true,
    includeIfNull: false,
  )


  final RetryImportRequestScopeEnum scope;



  @JsonKey(

    name: r'row_numbers',
    required: false,
    includeIfNull: false,
  )


  final Set<int>? rowNumbers;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RetryImportRequest &&
      other.scope == scope &&
      other.rowNumbers == rowNumbers;

    @override
    int get hashCode =>
        scope.hashCode +
        rowNumbers.hashCode;

  factory RetryImportRequest.fromJson(Map<String, dynamic> json) => _$RetryImportRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RetryImportRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum RetryImportRequestScopeEnum {
@JsonValue(r'all_failed_rows')
allFailedRows(r'all_failed_rows'),
@JsonValue(r'selected_rows')
selectedRows(r'selected_rows');

const RetryImportRequestScopeEnum(this.value);

final String value;

@override
String toString() => value;
}
