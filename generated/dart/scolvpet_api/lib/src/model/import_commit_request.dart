//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/import_commit_request_approved_updates_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_commit_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportCommitRequest {
  /// Returns a new [ImportCommitRequest] instance.
  ImportCommitRequest({

    required  this.preflightVersion,

    required  this.batchKey,

    required  this.partialFailurePolicy,

     this.approvedUpdates,
  });

          // minimum: 1
  @JsonKey(

    name: r'preflight_version',
    required: true,
    includeIfNull: false,
  )


  final int preflightVersion;



  @JsonKey(

    name: r'batch_key',
    required: true,
    includeIfNull: false,
  )


  final String batchKey;



  @JsonKey(

    name: r'partial_failure_policy',
    required: true,
    includeIfNull: false,
  )


  final ImportCommitRequestPartialFailurePolicyEnum partialFailurePolicy;



      /// 预检列出的更新候选逐项确认；未列出的已有非空字段保持不变
  @JsonKey(

    name: r'approved_updates',
    required: false,
    includeIfNull: false,
  )


  final Set<ImportCommitRequestApprovedUpdatesInner>? approvedUpdates;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportCommitRequest &&
      other.preflightVersion == preflightVersion &&
      other.batchKey == batchKey &&
      other.partialFailurePolicy == partialFailurePolicy &&
      other.approvedUpdates == approvedUpdates;

    @override
    int get hashCode =>
        preflightVersion.hashCode +
        batchKey.hashCode +
        partialFailurePolicy.hashCode +
        approvedUpdates.hashCode;

  factory ImportCommitRequest.fromJson(Map<String, dynamic> json) => _$ImportCommitRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ImportCommitRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ImportCommitRequestPartialFailurePolicyEnum {
@JsonValue(r'continue_and_report')
continueAndReport(r'continue_and_report'),
@JsonValue(r'rollback_all')
rollbackAll(r'rollback_all');

const ImportCommitRequestPartialFailurePolicyEnum(this.value);

final String value;

@override
String toString() => value;
}
