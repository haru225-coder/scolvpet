// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_batch_create_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordBatchCreateResponseDataCWProxy {
  WeightRecordBatchCreateResponseData transactionStatus(
    BatchTransactionStatus transactionStatus,
  );

  WeightRecordBatchCreateResponseData succeededCount(int succeededCount);

  WeightRecordBatchCreateResponseData failedCount(int failedCount);

  WeightRecordBatchCreateResponseData alertCount(int alertCount);

  WeightRecordBatchCreateResponseData items(
    List<WeightRecordBatchCreateResponseDataItemsInner> items,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordBatchCreateResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordBatchCreateResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordBatchCreateResponseData call({
    BatchTransactionStatus transactionStatus,
    int succeededCount,
    int failedCount,
    int alertCount,
    List<WeightRecordBatchCreateResponseDataItemsInner> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordBatchCreateResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordBatchCreateResponseData.copyWith.fieldName(...)`
class _$WeightRecordBatchCreateResponseDataCWProxyImpl
    implements _$WeightRecordBatchCreateResponseDataCWProxy {
  const _$WeightRecordBatchCreateResponseDataCWProxyImpl(this._value);

  final WeightRecordBatchCreateResponseData _value;

  @override
  WeightRecordBatchCreateResponseData transactionStatus(
    BatchTransactionStatus transactionStatus,
  ) => this(transactionStatus: transactionStatus);

  @override
  WeightRecordBatchCreateResponseData succeededCount(int succeededCount) =>
      this(succeededCount: succeededCount);

  @override
  WeightRecordBatchCreateResponseData failedCount(int failedCount) =>
      this(failedCount: failedCount);

  @override
  WeightRecordBatchCreateResponseData alertCount(int alertCount) =>
      this(alertCount: alertCount);

  @override
  WeightRecordBatchCreateResponseData items(
    List<WeightRecordBatchCreateResponseDataItemsInner> items,
  ) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordBatchCreateResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordBatchCreateResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordBatchCreateResponseData call({
    Object? transactionStatus = const $CopyWithPlaceholder(),
    Object? succeededCount = const $CopyWithPlaceholder(),
    Object? failedCount = const $CopyWithPlaceholder(),
    Object? alertCount = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordBatchCreateResponseData(
      transactionStatus: transactionStatus == const $CopyWithPlaceholder()
          ? _value.transactionStatus
          // ignore: cast_nullable_to_non_nullable
          : transactionStatus as BatchTransactionStatus,
      succeededCount: succeededCount == const $CopyWithPlaceholder()
          ? _value.succeededCount
          // ignore: cast_nullable_to_non_nullable
          : succeededCount as int,
      failedCount: failedCount == const $CopyWithPlaceholder()
          ? _value.failedCount
          // ignore: cast_nullable_to_non_nullable
          : failedCount as int,
      alertCount: alertCount == const $CopyWithPlaceholder()
          ? _value.alertCount
          // ignore: cast_nullable_to_non_nullable
          : alertCount as int,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<WeightRecordBatchCreateResponseDataItemsInner>,
    );
  }
}

extension $WeightRecordBatchCreateResponseDataCopyWith
    on WeightRecordBatchCreateResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordBatchCreateResponseData.copyWith(...)` or like so:`instanceOfWeightRecordBatchCreateResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordBatchCreateResponseDataCWProxy get copyWith =>
      _$WeightRecordBatchCreateResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordBatchCreateResponseData
_$WeightRecordBatchCreateResponseDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeightRecordBatchCreateResponseData',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'transaction_status',
            'succeeded_count',
            'failed_count',
            'alert_count',
            'items',
          ],
        );
        final val = WeightRecordBatchCreateResponseData(
          transactionStatus: $checkedConvert(
            'transaction_status',
            (v) => $enumDecode(_$BatchTransactionStatusEnumMap, v),
          ),
          succeededCount: $checkedConvert(
            'succeeded_count',
            (v) => (v as num).toInt(),
          ),
          failedCount: $checkedConvert(
            'failed_count',
            (v) => (v as num).toInt(),
          ),
          alertCount: $checkedConvert('alert_count', (v) => (v as num).toInt()),
          items: $checkedConvert(
            'items',
            (v) => (v as List<dynamic>)
                .map(
                  (e) => WeightRecordBatchCreateResponseDataItemsInner.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'transactionStatus': 'transaction_status',
        'succeededCount': 'succeeded_count',
        'failedCount': 'failed_count',
        'alertCount': 'alert_count',
      },
    );

Map<String, dynamic> _$WeightRecordBatchCreateResponseDataToJson(
  WeightRecordBatchCreateResponseData instance,
) => <String, dynamic>{
  'transaction_status':
      _$BatchTransactionStatusEnumMap[instance.transactionStatus]!,
  'succeeded_count': instance.succeededCount,
  'failed_count': instance.failedCount,
  'alert_count': instance.alertCount,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

const _$BatchTransactionStatusEnumMap = {
  BatchTransactionStatus.allSucceeded: 'all_succeeded',
  BatchTransactionStatus.partial: 'partial',
  BatchTransactionStatus.allFailed: 'all_failed',
};
