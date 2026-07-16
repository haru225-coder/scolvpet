// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountCWProxy {
  Account id(String id);

  Account phoneMasked(String phoneMasked);

  Account displayName(String? displayName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Account(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Account(...).copyWith(id: 12, name: "My name")
  /// ````
  Account call({String id, String phoneMasked, String? displayName});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccount.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccount.copyWith.fieldName(...)`
class _$AccountCWProxyImpl implements _$AccountCWProxy {
  const _$AccountCWProxyImpl(this._value);

  final Account _value;

  @override
  Account id(String id) => this(id: id);

  @override
  Account phoneMasked(String phoneMasked) => this(phoneMasked: phoneMasked);

  @override
  Account displayName(String? displayName) => this(displayName: displayName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Account(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Account(...).copyWith(id: 12, name: "My name")
  /// ````
  Account call({
    Object? id = const $CopyWithPlaceholder(),
    Object? phoneMasked = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
  }) {
    return Account(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      phoneMasked: phoneMasked == const $CopyWithPlaceholder()
          ? _value.phoneMasked
          // ignore: cast_nullable_to_non_nullable
          : phoneMasked as String,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
    );
  }
}

extension $AccountCopyWith on Account {
  /// Returns a callable class that can be used as follows: `instanceOfAccount.copyWith(...)` or like so:`instanceOfAccount.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountCWProxy get copyWith => _$AccountCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Account',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['id', 'phone_masked']);
    final val = Account(
      id: $checkedConvert('id', (v) => v as String),
      phoneMasked: $checkedConvert('phone_masked', (v) => v as String),
      displayName: $checkedConvert('display_name', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'phoneMasked': 'phone_masked',
    'displayName': 'display_name',
  },
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'id': instance.id,
  'phone_masked': instance.phoneMasked,
  'display_name': ?instance.displayName,
};
