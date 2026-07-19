//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/backup_job.dart';
import 'package:scolvpet_api/src/model/usage_metric.dart';
import 'package:scolvpet_api/src/model/export_job.dart';
import 'package:scolvpet_api/src/model/import_job.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_center_summary_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DataCenterSummaryResponseData {
  /// Returns a new [DataCenterSummaryResponseData] instance.
  DataCenterSummaryResponseData({

    required  this.recentImports,

    required  this.recentExports,

    required  this.recentBackups,

    required  this.usage,

    required  this.usageStatus,
  });

  @JsonKey(

    name: r'recent_imports',
    required: true,
    includeIfNull: false,
  )


  final List<ImportJob> recentImports;



  @JsonKey(

    name: r'recent_exports',
    required: true,
    includeIfNull: false,
  )


  final List<ExportJob> recentExports;



  @JsonKey(

    name: r'recent_backups',
    required: true,
    includeIfNull: false,
  )


  final List<BackupJob> recentBackups;



      /// 六项固定用量指标各出现一次
  @JsonKey(

    name: r'usage',
    required: true,
    includeIfNull: false,
  )


  final List<UsageMetric> usage;



  @JsonKey(

    name: r'usage_status',
    required: true,
    includeIfNull: false,
  )


  final DataCenterSummaryResponseDataUsageStatusEnum usageStatus;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DataCenterSummaryResponseData &&
      other.recentImports == recentImports &&
      other.recentExports == recentExports &&
      other.recentBackups == recentBackups &&
      other.usage == usage &&
      other.usageStatus == usageStatus;

    @override
    int get hashCode =>
        recentImports.hashCode +
        recentExports.hashCode +
        recentBackups.hashCode +
        usage.hashCode +
        usageStatus.hashCode;

  factory DataCenterSummaryResponseData.fromJson(Map<String, dynamic> json) => _$DataCenterSummaryResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$DataCenterSummaryResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum DataCenterSummaryResponseDataUsageStatusEnum {
@JsonValue(r'current')
current(r'current'),
@JsonValue(r'updating')
updating(r'updating'),
@JsonValue(r'delayed')
delayed(r'delayed');

const DataCenterSummaryResponseDataUsageStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
