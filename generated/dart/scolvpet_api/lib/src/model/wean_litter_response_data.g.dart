// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wean_litter_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeanLitterResponseDataCWProxy {
  WeanLitterResponseData litterId(String litterId);

  WeanLitterResponseData litterState(LitterState litterState);

  WeanLitterResponseData weanedAt(DateTime weanedAt);

  WeanLitterResponseData processedCount(int processedCount);

  WeanLitterResponseData itemResults(List<ActionItemResult> itemResults);

  WeanLitterResponseData createdTaskIds(List<String> createdTaskIds);

  WeanLitterResponseData version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeanLitterResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeanLitterResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  WeanLitterResponseData call({
    String litterId,
    LitterState litterState,
    DateTime weanedAt,
    int processedCount,
    List<ActionItemResult> itemResults,
    List<String> createdTaskIds,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeanLitterResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeanLitterResponseData.copyWith.fieldName(...)`
class _$WeanLitterResponseDataCWProxyImpl
    implements _$WeanLitterResponseDataCWProxy {
  const _$WeanLitterResponseDataCWProxyImpl(this._value);

  final WeanLitterResponseData _value;

  @override
  WeanLitterResponseData litterId(String litterId) => this(litterId: litterId);

  @override
  WeanLitterResponseData litterState(LitterState litterState) =>
      this(litterState: litterState);

  @override
  WeanLitterResponseData weanedAt(DateTime weanedAt) =>
      this(weanedAt: weanedAt);

  @override
  WeanLitterResponseData processedCount(int processedCount) =>
      this(processedCount: processedCount);

  @override
  WeanLitterResponseData itemResults(List<ActionItemResult> itemResults) =>
      this(itemResults: itemResults);

  @override
  WeanLitterResponseData createdTaskIds(List<String> createdTaskIds) =>
      this(createdTaskIds: createdTaskIds);

  @override
  WeanLitterResponseData version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeanLitterResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeanLitterResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  WeanLitterResponseData call({
    Object? litterId = const $CopyWithPlaceholder(),
    Object? litterState = const $CopyWithPlaceholder(),
    Object? weanedAt = const $CopyWithPlaceholder(),
    Object? processedCount = const $CopyWithPlaceholder(),
    Object? itemResults = const $CopyWithPlaceholder(),
    Object? createdTaskIds = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return WeanLitterResponseData(
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as String,
      litterState: litterState == const $CopyWithPlaceholder()
          ? _value.litterState
          // ignore: cast_nullable_to_non_nullable
          : litterState as LitterState,
      weanedAt: weanedAt == const $CopyWithPlaceholder()
          ? _value.weanedAt
          // ignore: cast_nullable_to_non_nullable
          : weanedAt as DateTime,
      processedCount: processedCount == const $CopyWithPlaceholder()
          ? _value.processedCount
          // ignore: cast_nullable_to_non_nullable
          : processedCount as int,
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

extension $WeanLitterResponseDataCopyWith on WeanLitterResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfWeanLitterResponseData.copyWith(...)` or like so:`instanceOfWeanLitterResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeanLitterResponseDataCWProxy get copyWith =>
      _$WeanLitterResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeanLitterResponseData _$WeanLitterResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'WeanLitterResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'litter_id',
        'litter_state',
        'weaned_at',
        'processed_count',
        'item_results',
        'created_task_ids',
        'version',
      ],
    );
    final val = WeanLitterResponseData(
      litterId: $checkedConvert('litter_id', (v) => v as String),
      litterState: $checkedConvert(
        'litter_state',
        (v) => $enumDecode(_$LitterStateEnumMap, v),
      ),
      weanedAt: $checkedConvert(
        'weaned_at',
        (v) => DateTime.parse(v as String),
      ),
      processedCount: $checkedConvert(
        'processed_count',
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
    'weanedAt': 'weaned_at',
    'processedCount': 'processed_count',
    'itemResults': 'item_results',
    'createdTaskIds': 'created_task_ids',
  },
);

Map<String, dynamic> _$WeanLitterResponseDataToJson(
  WeanLitterResponseData instance,
) => <String, dynamic>{
  'litter_id': instance.litterId,
  'litter_state': _$LitterStateEnumMap[instance.litterState]!,
  'weaned_at': instance.weanedAt.toIso8601String(),
  'processed_count': instance.processedCount,
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
