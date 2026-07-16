// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sex_and_separate_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SexAndSeparateResponseDataCWProxy {
  SexAndSeparateResponseData litterId(String litterId);

  SexAndSeparateResponseData litterState(LitterState litterState);

  SexAndSeparateResponseData separatedAt(DateTime separatedAt);

  SexAndSeparateResponseData processedCount(int processedCount);

  SexAndSeparateResponseData uncertainCount(int uncertainCount);

  SexAndSeparateResponseData itemResults(List<ActionItemResult> itemResults);

  SexAndSeparateResponseData createdTaskIds(List<String> createdTaskIds);

  SexAndSeparateResponseData version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SexAndSeparateResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SexAndSeparateResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  SexAndSeparateResponseData call({
    String litterId,
    LitterState litterState,
    DateTime separatedAt,
    int processedCount,
    int uncertainCount,
    List<ActionItemResult> itemResults,
    List<String> createdTaskIds,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSexAndSeparateResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSexAndSeparateResponseData.copyWith.fieldName(...)`
class _$SexAndSeparateResponseDataCWProxyImpl
    implements _$SexAndSeparateResponseDataCWProxy {
  const _$SexAndSeparateResponseDataCWProxyImpl(this._value);

  final SexAndSeparateResponseData _value;

  @override
  SexAndSeparateResponseData litterId(String litterId) =>
      this(litterId: litterId);

  @override
  SexAndSeparateResponseData litterState(LitterState litterState) =>
      this(litterState: litterState);

  @override
  SexAndSeparateResponseData separatedAt(DateTime separatedAt) =>
      this(separatedAt: separatedAt);

  @override
  SexAndSeparateResponseData processedCount(int processedCount) =>
      this(processedCount: processedCount);

  @override
  SexAndSeparateResponseData uncertainCount(int uncertainCount) =>
      this(uncertainCount: uncertainCount);

  @override
  SexAndSeparateResponseData itemResults(List<ActionItemResult> itemResults) =>
      this(itemResults: itemResults);

  @override
  SexAndSeparateResponseData createdTaskIds(List<String> createdTaskIds) =>
      this(createdTaskIds: createdTaskIds);

  @override
  SexAndSeparateResponseData version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SexAndSeparateResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SexAndSeparateResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  SexAndSeparateResponseData call({
    Object? litterId = const $CopyWithPlaceholder(),
    Object? litterState = const $CopyWithPlaceholder(),
    Object? separatedAt = const $CopyWithPlaceholder(),
    Object? processedCount = const $CopyWithPlaceholder(),
    Object? uncertainCount = const $CopyWithPlaceholder(),
    Object? itemResults = const $CopyWithPlaceholder(),
    Object? createdTaskIds = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return SexAndSeparateResponseData(
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as String,
      litterState: litterState == const $CopyWithPlaceholder()
          ? _value.litterState
          // ignore: cast_nullable_to_non_nullable
          : litterState as LitterState,
      separatedAt: separatedAt == const $CopyWithPlaceholder()
          ? _value.separatedAt
          // ignore: cast_nullable_to_non_nullable
          : separatedAt as DateTime,
      processedCount: processedCount == const $CopyWithPlaceholder()
          ? _value.processedCount
          // ignore: cast_nullable_to_non_nullable
          : processedCount as int,
      uncertainCount: uncertainCount == const $CopyWithPlaceholder()
          ? _value.uncertainCount
          // ignore: cast_nullable_to_non_nullable
          : uncertainCount as int,
      itemResults: itemResults == const $CopyWithPlaceholder()
          ? _value.itemResults
          // ignore: cast_nullable_to_non_nullable
          : itemResults as List<ActionItemResult>,
      createdTaskIds: createdTaskIds == const $CopyWithPlaceholder()
          ? _value.createdTaskIds
          // ignore: cast_nullable_to_non_nullable
          : createdTaskIds as List<String>,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $SexAndSeparateResponseDataCopyWith on SexAndSeparateResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfSexAndSeparateResponseData.copyWith(...)` or like so:`instanceOfSexAndSeparateResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SexAndSeparateResponseDataCWProxy get copyWith =>
      _$SexAndSeparateResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SexAndSeparateResponseData _$SexAndSeparateResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'SexAndSeparateResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'litter_id',
        'litter_state',
        'separated_at',
        'processed_count',
        'uncertain_count',
        'item_results',
        'created_task_ids',
        'version',
      ],
    );
    final val = SexAndSeparateResponseData(
      litterId: $checkedConvert('litter_id', (v) => v as String),
      litterState: $checkedConvert(
        'litter_state',
        (v) => $enumDecode(_$LitterStateEnumMap, v),
      ),
      separatedAt: $checkedConvert(
        'separated_at',
        (v) => DateTime.parse(v as String),
      ),
      processedCount: $checkedConvert(
        'processed_count',
        (v) => (v as num).toInt(),
      ),
      uncertainCount: $checkedConvert(
        'uncertain_count',
        (v) => (v as num).toInt(),
      ),
      itemResults: $checkedConvert(
        'item_results',
        (v) => (v as List<dynamic>)
            .map((e) => ActionItemResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      createdTaskIds: $checkedConvert(
        'created_task_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'litterId': 'litter_id',
    'litterState': 'litter_state',
    'separatedAt': 'separated_at',
    'processedCount': 'processed_count',
    'uncertainCount': 'uncertain_count',
    'itemResults': 'item_results',
    'createdTaskIds': 'created_task_ids',
  },
);

Map<String, dynamic> _$SexAndSeparateResponseDataToJson(
  SexAndSeparateResponseData instance,
) => <String, dynamic>{
  'litter_id': instance.litterId,
  'litter_state': _$LitterStateEnumMap[instance.litterState]!,
  'separated_at': instance.separatedAt.toIso8601String(),
  'processed_count': instance.processedCount,
  'uncertain_count': instance.uncertainCount,
  'item_results': instance.itemResults.map((e) => e.toJson()).toList(),
  'created_task_ids': instance.createdTaskIds,
  'version': instance.version,
};

const _$LitterStateEnumMap = {
  LitterState.newborn: 'newborn',
  LitterState.nursing: 'nursing',
  LitterState.weaningDue: 'weaning_due',
  LitterState.sexingDue: 'sexing_due',
  LitterState.individualizing: 'individualizing',
  LitterState.closed: 'closed',
  LitterState.voided: 'voided',
};
