// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounting_category.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountingCategoryCWProxy {
  AccountingCategory id(String id);

  AccountingCategory entryType(AccountingCategoryEntryTypeEnum entryType);

  AccountingCategory name(String name);

  AccountingCategory sortOrder(int sortOrder);

  AccountingCategory version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingCategory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingCategory(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingCategory call({
    String id,
    AccountingCategoryEntryTypeEnum entryType,
    String name,
    int sortOrder,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountingCategory.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountingCategory.copyWith.fieldName(...)`
class _$AccountingCategoryCWProxyImpl implements _$AccountingCategoryCWProxy {
  const _$AccountingCategoryCWProxyImpl(this._value);

  final AccountingCategory _value;

  @override
  AccountingCategory id(String id) => this(id: id);

  @override
  AccountingCategory entryType(AccountingCategoryEntryTypeEnum entryType) =>
      this(entryType: entryType);

  @override
  AccountingCategory name(String name) => this(name: name);

  @override
  AccountingCategory sortOrder(int sortOrder) => this(sortOrder: sortOrder);

  @override
  AccountingCategory version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountingCategory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountingCategory(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountingCategory call({
    Object? id = const $CopyWithPlaceholder(),
    Object? entryType = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return AccountingCategory(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      entryType: entryType == const $CopyWithPlaceholder()
          ? _value.entryType
          // ignore: cast_nullable_to_non_nullable
          : entryType as AccountingCategoryEntryTypeEnum,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $AccountingCategoryCopyWith on AccountingCategory {
  /// Returns a callable class that can be used as follows: `instanceOfAccountingCategory.copyWith(...)` or like so:`instanceOfAccountingCategory.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountingCategoryCWProxy get copyWith =>
      _$AccountingCategoryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountingCategory _$AccountingCategoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AccountingCategory',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'entry_type',
            'name',
            'sort_order',
            'version',
          ],
        );
        final val = AccountingCategory(
          id: $checkedConvert('id', (v) => v as String),
          entryType: $checkedConvert(
            'entry_type',
            (v) => $enumDecode(_$AccountingCategoryEntryTypeEnumEnumMap, v),
          ),
          name: $checkedConvert('name', (v) => v as String),
          sortOrder: $checkedConvert('sort_order', (v) => (v as num).toInt()),
          version: $checkedConvert('version', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {'entryType': 'entry_type', 'sortOrder': 'sort_order'},
    );

Map<String, dynamic> _$AccountingCategoryToJson(
  AccountingCategory instance,
) => <String, dynamic>{
  'id': instance.id,
  'entry_type': _$AccountingCategoryEntryTypeEnumEnumMap[instance.entryType]!,
  'name': instance.name,
  'sort_order': instance.sortOrder,
  'version': instance.version,
};

const _$AccountingCategoryEntryTypeEnumEnumMap = {
  AccountingCategoryEntryTypeEnum.income: 'income',
  AccountingCategoryEntryTypeEnum.expense: 'expense',
};
