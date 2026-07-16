// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hamster_batch_create_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HamsterBatchCreateResponseDataCWProxy {
  HamsterBatchCreateResponseData transactionStatus(
    BatchTransactionStatus transactionStatus,
  );

  HamsterBatchCreateResponseData succeededCount(int succeededCount);

  HamsterBatchCreateResponseData failedCount(int failedCount);

  HamsterBatchCreateResponseData items(
    List<HamsterBatchCreateResponseDataItemsInner> items,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterBatchCreateResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterBatchCreateResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterBatchCreateResponseData call({
    BatchTransactionStatus transactionStatus,
    int succeededCount,
    int failedCount,
    List<HamsterBatchCreateResponseDataItemsInner> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHamsterBatchCreateResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHamsterBatchCreateResponseData.copyWith.fieldName(...)`
class _$HamsterBatchCreateResponseDataCWProxyImpl
    implements _$HamsterBatchCreateResponseDataCWProxy {
  const _$HamsterBatchCreateResponseDataCWProxyImpl(this._value);

  final HamsterBatchCreateResponseData _value;

  @override
  HamsterBatchCreateResponseData transactionStatus(
    BatchTransactionStatus transactionStatus,
  ) => this(transactionStatus: transactionStatus);

  @override
  HamsterBatchCreateResponseData succeededCount(int succeededCount) =>
      this(succeededCount: succeededCount);

  @override
  HamsterBatchCreateResponseData failedCount(int failedCount) =>
      this(failedCount: failedCount);

  @override
  HamsterBatchCreateResponseData items(
    List<HamsterBatchCreateResponseDataItemsInner> items,
  ) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterBatchCreateResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterBatchCreateResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterBatchCreateResponseData call({
    Object? transactionStatus = const $CopyWithPlaceholder(),
    Object? succeededCount = const $CopyWithPlaceholder(),
    Object? failedCount = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return HamsterBatchCreateResponseData(
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
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<HamsterBatchCreateResponseDataItemsInner>,
    );
  }
}

extension $HamsterBatchCreateResponseDataCopyWith
    on HamsterBatchCreateResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfHamsterBatchCreateResponseData.copyWith(...)` or like so:`instanceOfHamsterBatchCreateResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HamsterBatchCreateResponseDataCWProxy get copyWith =>
      _$HamsterBatchCreateResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HamsterBatchCreateResponseData _$HamsterBatchCreateResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'HamsterBatchCreateResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'transaction_status',
        'succeeded_count',
        'failed_count',
        'items',
      ],
    );
    final val = HamsterBatchCreateResponseData(
      transactionStatus: $checkedConvert(
        'transaction_status',
        (v) => $enumDecode(_$BatchTransactionStatusEnumMap, v),
      ),
      succeededCount: $checkedConvert(
        'succeeded_count',
        (v) => (v as num).toInt(),
      ),
      failedCount: $checkedConvert('failed_count', (v) => (v as num).toInt()),
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map(
              (e) => HamsterBatchCreateResponseDataItemsInner.fromJson(
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
  },
);

Map<String, dynamic> _$HamsterBatchCreateResponseDataToJson(
  HamsterBatchCreateResponseData instance,
) => <String, dynamic>{
  'transaction_status':
      _$BatchTransactionStatusEnumMap[instance.transactionStatus]!,
  'succeeded_count': instance.succeededCount,
  'failed_count': instance.failedCount,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

const _$BatchTransactionStatusEnumMap = {
  BatchTransactionStatus.allSucceeded: 'all_succeeded',
  BatchTransactionStatus.partial: 'partial',
  BatchTransactionStatus.allFailed: 'all_failed',
};
