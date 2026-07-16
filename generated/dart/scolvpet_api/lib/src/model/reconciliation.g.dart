// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reconciliation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReconciliationCWProxy {
  Reconciliation initialAliveCount(int initialAliveCount);

  Reconciliation discoveredCount(int discoveredCount);

  Reconciliation deceasedCount(int deceasedCount);

  Reconciliation transferredCount(int transferredCount);

  Reconciliation expectedManagedCount(int expectedManagedCount);

  Reconciliation unindividualizedAliveCount(int unindividualizedAliveCount);

  Reconciliation individualizedAliveCount(int individualizedAliveCount);

  Reconciliation difference(int difference);

  Reconciliation closed(bool closed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reconciliation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reconciliation(...).copyWith(id: 12, name: "My name")
  /// ````
  Reconciliation call({
    int initialAliveCount,
    int discoveredCount,
    int deceasedCount,
    int transferredCount,
    int expectedManagedCount,
    int unindividualizedAliveCount,
    int individualizedAliveCount,
    int difference,
    bool closed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReconciliation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReconciliation.copyWith.fieldName(...)`
class _$ReconciliationCWProxyImpl implements _$ReconciliationCWProxy {
  const _$ReconciliationCWProxyImpl(this._value);

  final Reconciliation _value;

  @override
  Reconciliation initialAliveCount(int initialAliveCount) =>
      this(initialAliveCount: initialAliveCount);

  @override
  Reconciliation discoveredCount(int discoveredCount) =>
      this(discoveredCount: discoveredCount);

  @override
  Reconciliation deceasedCount(int deceasedCount) =>
      this(deceasedCount: deceasedCount);

  @override
  Reconciliation transferredCount(int transferredCount) =>
      this(transferredCount: transferredCount);

  @override
  Reconciliation expectedManagedCount(int expectedManagedCount) =>
      this(expectedManagedCount: expectedManagedCount);

  @override
  Reconciliation unindividualizedAliveCount(int unindividualizedAliveCount) =>
      this(unindividualizedAliveCount: unindividualizedAliveCount);

  @override
  Reconciliation individualizedAliveCount(int individualizedAliveCount) =>
      this(individualizedAliveCount: individualizedAliveCount);

  @override
  Reconciliation difference(int difference) => this(difference: difference);

  @override
  Reconciliation closed(bool closed) => this(closed: closed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reconciliation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reconciliation(...).copyWith(id: 12, name: "My name")
  /// ````
  Reconciliation call({
    Object? initialAliveCount = const $CopyWithPlaceholder(),
    Object? discoveredCount = const $CopyWithPlaceholder(),
    Object? deceasedCount = const $CopyWithPlaceholder(),
    Object? transferredCount = const $CopyWithPlaceholder(),
    Object? expectedManagedCount = const $CopyWithPlaceholder(),
    Object? unindividualizedAliveCount = const $CopyWithPlaceholder(),
    Object? individualizedAliveCount = const $CopyWithPlaceholder(),
    Object? difference = const $CopyWithPlaceholder(),
    Object? closed = const $CopyWithPlaceholder(),
  }) {
    return Reconciliation(
      initialAliveCount: initialAliveCount == const $CopyWithPlaceholder()
          ? _value.initialAliveCount
          // ignore: cast_nullable_to_non_nullable
          : initialAliveCount as int,
      discoveredCount: discoveredCount == const $CopyWithPlaceholder()
          ? _value.discoveredCount
          // ignore: cast_nullable_to_non_nullable
          : discoveredCount as int,
      deceasedCount: deceasedCount == const $CopyWithPlaceholder()
          ? _value.deceasedCount
          // ignore: cast_nullable_to_non_nullable
          : deceasedCount as int,
      transferredCount: transferredCount == const $CopyWithPlaceholder()
          ? _value.transferredCount
          // ignore: cast_nullable_to_non_nullable
          : transferredCount as int,
      expectedManagedCount: expectedManagedCount == const $CopyWithPlaceholder()
          ? _value.expectedManagedCount
          // ignore: cast_nullable_to_non_nullable
          : expectedManagedCount as int,
      unindividualizedAliveCount:
          unindividualizedAliveCount == const $CopyWithPlaceholder()
          ? _value.unindividualizedAliveCount
          // ignore: cast_nullable_to_non_nullable
          : unindividualizedAliveCount as int,
      individualizedAliveCount:
          individualizedAliveCount == const $CopyWithPlaceholder()
          ? _value.individualizedAliveCount
          // ignore: cast_nullable_to_non_nullable
          : individualizedAliveCount as int,
      difference: difference == const $CopyWithPlaceholder()
          ? _value.difference
          // ignore: cast_nullable_to_non_nullable
          : difference as int,
      closed: closed == const $CopyWithPlaceholder()
          ? _value.closed
          // ignore: cast_nullable_to_non_nullable
          : closed as bool,
    );
  }
}

extension $ReconciliationCopyWith on Reconciliation {
  /// Returns a callable class that can be used as follows: `instanceOfReconciliation.copyWith(...)` or like so:`instanceOfReconciliation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReconciliationCWProxy get copyWith => _$ReconciliationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reconciliation _$ReconciliationFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'Reconciliation',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'initial_alive_count',
            'discovered_count',
            'deceased_count',
            'transferred_count',
            'expected_managed_count',
            'unindividualized_alive_count',
            'individualized_alive_count',
            'difference',
            'closed',
          ],
        );
        final val = Reconciliation(
          initialAliveCount: $checkedConvert(
            'initial_alive_count',
            (v) => (v as num).toInt(),
          ),
          discoveredCount: $checkedConvert(
            'discovered_count',
            (v) => (v as num).toInt(),
          ),
          deceasedCount: $checkedConvert(
            'deceased_count',
            (v) => (v as num).toInt(),
          ),
          transferredCount: $checkedConvert(
            'transferred_count',
            (v) => (v as num).toInt(),
          ),
          expectedManagedCount: $checkedConvert(
            'expected_managed_count',
            (v) => (v as num).toInt(),
          ),
          unindividualizedAliveCount: $checkedConvert(
            'unindividualized_alive_count',
            (v) => (v as num).toInt(),
          ),
          individualizedAliveCount: $checkedConvert(
            'individualized_alive_count',
            (v) => (v as num).toInt(),
          ),
          difference: $checkedConvert('difference', (v) => (v as num).toInt()),
          closed: $checkedConvert('closed', (v) => v as bool),
        );
        return val;
      },
      fieldKeyMap: const {
        'initialAliveCount': 'initial_alive_count',
        'discoveredCount': 'discovered_count',
        'deceasedCount': 'deceased_count',
        'transferredCount': 'transferred_count',
        'expectedManagedCount': 'expected_managed_count',
        'unindividualizedAliveCount': 'unindividualized_alive_count',
        'individualizedAliveCount': 'individualized_alive_count',
      },
    );

Map<String, dynamic> _$ReconciliationToJson(Reconciliation instance) =>
    <String, dynamic>{
      'initial_alive_count': instance.initialAliveCount,
      'discovered_count': instance.discoveredCount,
      'deceased_count': instance.deceasedCount,
      'transferred_count': instance.transferredCount,
      'expected_managed_count': instance.expectedManagedCount,
      'unindividualized_alive_count': instance.unindividualizedAliveCount,
      'individualized_alive_count': instance.individualizedAliveCount,
      'difference': instance.difference,
      'closed': instance.closed,
    };
