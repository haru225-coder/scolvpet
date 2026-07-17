// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_accounting_category_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateAccountingCategoryRequestCWProxy {
  CreateAccountingCategoryRequest entryType(
    CreateAccountingCategoryRequestEntryTypeEnum entryType,
  );

  CreateAccountingCategoryRequest name(String name);

  CreateAccountingCategoryRequest sortOrder(int? sortOrder);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateAccountingCategoryRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateAccountingCategoryRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateAccountingCategoryRequest call({
    CreateAccountingCategoryRequestEntryTypeEnum entryType,
    String name,
    int? sortOrder,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateAccountingCategoryRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateAccountingCategoryRequest.copyWith.fieldName(...)`
class _$CreateAccountingCategoryRequestCWProxyImpl
    implements _$CreateAccountingCategoryRequestCWProxy {
  const _$CreateAccountingCategoryRequestCWProxyImpl(this._value);

  final CreateAccountingCategoryRequest _value;

  @override
  CreateAccountingCategoryRequest entryType(
    CreateAccountingCategoryRequestEntryTypeEnum entryType,
  ) => this(entryType: entryType);

  @override
  CreateAccountingCategoryRequest name(String name) => this(name: name);

  @override
  CreateAccountingCategoryRequest sortOrder(int? sortOrder) =>
      this(sortOrder: sortOrder);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateAccountingCategoryRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateAccountingCategoryRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateAccountingCategoryRequest call({
    Object? entryType = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
  }) {
    return CreateAccountingCategoryRequest(
      entryType: entryType == const $CopyWithPlaceholder()
          ? _value.entryType
          // ignore: cast_nullable_to_non_nullable
          : entryType as CreateAccountingCategoryRequestEntryTypeEnum,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int?,
    );
  }
}

extension $CreateAccountingCategoryRequestCopyWith
    on CreateAccountingCategoryRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateAccountingCategoryRequest.copyWith(...)` or like so:`instanceOfCreateAccountingCategoryRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateAccountingCategoryRequestCWProxy get copyWith =>
      _$CreateAccountingCategoryRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAccountingCategoryRequest _$CreateAccountingCategoryRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateAccountingCategoryRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['entry_type', 'name']);
    final val = CreateAccountingCategoryRequest(
      entryType: $checkedConvert(
        'entry_type',
        (v) => $enumDecode(
          _$CreateAccountingCategoryRequestEntryTypeEnumEnumMap,
          v,
        ),
      ),
      name: $checkedConvert('name', (v) => v as String),
      sortOrder: $checkedConvert('sort_order', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {'entryType': 'entry_type', 'sortOrder': 'sort_order'},
);

Map<String, dynamic> _$CreateAccountingCategoryRequestToJson(
  CreateAccountingCategoryRequest instance,
) => <String, dynamic>{
  'entry_type':
      _$CreateAccountingCategoryRequestEntryTypeEnumEnumMap[instance
          .entryType]!,
  'name': instance.name,
  'sort_order': ?instance.sortOrder,
};

const _$CreateAccountingCategoryRequestEntryTypeEnumEnumMap = {
  CreateAccountingCategoryRequestEntryTypeEnum.income: 'income',
  CreateAccountingCategoryRequestEntryTypeEnum.expense: 'expense',
};
