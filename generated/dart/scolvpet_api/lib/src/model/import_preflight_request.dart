//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_preflight_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportPreflightRequest {
  /// Returns a new [ImportPreflightRequest] instance.
  ImportPreflightRequest({

    required  this.strictReferences,

     this.duplicatePolicy = ImportPreflightRequestDuplicatePolicyEnum.reject,

    required  this.historicalLitterPolicy,

    required  this.parentageConflictPolicy,

    required  this.existingFieldPolicy,
  });

      /// 父母、窝次和笼位引用缺失时必须报错
  @JsonKey(
    
    name: r'strict_references',
    required: true,
    includeIfNull: false,
  )


  final ImportPreflightRequestStrictReferencesEnum strictReferences;



  @JsonKey(
    defaultValue: ImportPreflightRequestDuplicatePolicyEnum.reject,
    name: r'duplicate_policy',
    required: false,
    includeIfNull: false,
  )


  final ImportPreflightRequestDuplicatePolicyEnum? duplicatePolicy;



      /// create_if_complete 仅在同一历史窝次编号的出生时间、双亲和物种规则一致时， 自动规划创建一个历史窝次；信息缺失或冲突时产生阻塞问题。 
  @JsonKey(
    
    name: r'historical_litter_policy',
    required: true,
    includeIfNull: false,
  )


  final ImportPreflightRequestHistoricalLitterPolicyEnum historicalLitterPolicy;



      /// 导入父母与既有已接受谱系边或同窝父母不一致时拒绝相关行
  @JsonKey(
    
    name: r'parentage_conflict_policy',
    required: true,
    includeIfNull: false,
  )


  final ImportPreflightRequestParentageConflictPolicyEnum parentageConflictPolicy;



      /// 默认不覆盖已有非空字段；更新候选必须在提交时逐项确认并带版本
  @JsonKey(
    
    name: r'existing_field_policy',
    required: true,
    includeIfNull: false,
  )


  final ImportPreflightRequestExistingFieldPolicyEnum existingFieldPolicy;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportPreflightRequest &&
      other.strictReferences == strictReferences &&
      other.duplicatePolicy == duplicatePolicy &&
      other.historicalLitterPolicy == historicalLitterPolicy &&
      other.parentageConflictPolicy == parentageConflictPolicy &&
      other.existingFieldPolicy == existingFieldPolicy;

    @override
    int get hashCode =>
        strictReferences.hashCode +
        duplicatePolicy.hashCode +
        historicalLitterPolicy.hashCode +
        parentageConflictPolicy.hashCode +
        existingFieldPolicy.hashCode;

  factory ImportPreflightRequest.fromJson(Map<String, dynamic> json) => _$ImportPreflightRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ImportPreflightRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// 父母、窝次和笼位引用缺失时必须报错
enum ImportPreflightRequestStrictReferencesEnum {
    /// 父母、窝次和笼位引用缺失时必须报错
@JsonValue('true')
true_('true');

const ImportPreflightRequestStrictReferencesEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ImportPreflightRequestDuplicatePolicyEnum {
@JsonValue(r'reject')
reject(r'reject'),
@JsonValue(r'skip')
skip(r'skip'),
@JsonValue(r'update_with_version')
updateWithVersion(r'update_with_version');

const ImportPreflightRequestDuplicatePolicyEnum(this.value);

final String value;

@override
String toString() => value;
}


/// create_if_complete 仅在同一历史窝次编号的出生时间、双亲和物种规则一致时， 自动规划创建一个历史窝次；信息缺失或冲突时产生阻塞问题。 
enum ImportPreflightRequestHistoricalLitterPolicyEnum {
    /// create_if_complete 仅在同一历史窝次编号的出生时间、双亲和物种规则一致时， 自动规划创建一个历史窝次；信息缺失或冲突时产生阻塞问题。 
@JsonValue(r'create_if_complete')
createIfComplete(r'create_if_complete'),
    /// create_if_complete 仅在同一历史窝次编号的出生时间、双亲和物种规则一致时， 自动规划创建一个历史窝次；信息缺失或冲突时产生阻塞问题。 
@JsonValue(r'require_existing')
requireExisting(r'require_existing');

const ImportPreflightRequestHistoricalLitterPolicyEnum(this.value);

final String value;

@override
String toString() => value;
}


/// 导入父母与既有已接受谱系边或同窝父母不一致时拒绝相关行
enum ImportPreflightRequestParentageConflictPolicyEnum {
    /// 导入父母与既有已接受谱系边或同窝父母不一致时拒绝相关行
@JsonValue(r'reject')
reject(r'reject');

const ImportPreflightRequestParentageConflictPolicyEnum(this.value);

final String value;

@override
String toString() => value;
}


/// 默认不覆盖已有非空字段；更新候选必须在提交时逐项确认并带版本
enum ImportPreflightRequestExistingFieldPolicyEnum {
    /// 默认不覆盖已有非空字段；更新候选必须在提交时逐项确认并带版本
@JsonValue(r'preserve_non_null')
preserveNonNull(r'preserve_non_null'),
    /// 默认不覆盖已有非空字段；更新候选必须在提交时逐项确认并带版本
@JsonValue(r'reject_updates')
rejectUpdates(r'reject_updates');

const ImportPreflightRequestExistingFieldPolicyEnum(this.value);

final String value;

@override
String toString() => value;
}


