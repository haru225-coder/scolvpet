// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_account_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CurrentAccountResponseDataCWProxy {
  CurrentAccountResponseData account(Account account);

  CurrentAccountResponseData currentOrganization(
    Organization currentOrganization,
  );

  CurrentAccountResponseData capabilities(List<String> capabilities);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CurrentAccountResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CurrentAccountResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CurrentAccountResponseData call({
    Account account,
    Organization currentOrganization,
    List<String> capabilities,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCurrentAccountResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCurrentAccountResponseData.copyWith.fieldName(...)`
class _$CurrentAccountResponseDataCWProxyImpl
    implements _$CurrentAccountResponseDataCWProxy {
  const _$CurrentAccountResponseDataCWProxyImpl(this._value);

  final CurrentAccountResponseData _value;

  @override
  CurrentAccountResponseData account(Account account) => this(account: account);

  @override
  CurrentAccountResponseData currentOrganization(
    Organization currentOrganization,
  ) => this(currentOrganization: currentOrganization);

  @override
  CurrentAccountResponseData capabilities(List<String> capabilities) =>
      this(capabilities: capabilities);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CurrentAccountResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CurrentAccountResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CurrentAccountResponseData call({
    Object? account = const $CopyWithPlaceholder(),
    Object? currentOrganization = const $CopyWithPlaceholder(),
    Object? capabilities = const $CopyWithPlaceholder(),
  }) {
    return CurrentAccountResponseData(
      account: account == const $CopyWithPlaceholder()
          ? _value.account
          // ignore: cast_nullable_to_non_nullable
          : account as Account,
      currentOrganization: currentOrganization == const $CopyWithPlaceholder()
          ? _value.currentOrganization
          // ignore: cast_nullable_to_non_nullable
          : currentOrganization as Organization,
      capabilities: capabilities == const $CopyWithPlaceholder()
          ? _value.capabilities
          // ignore: cast_nullable_to_non_nullable
          : capabilities as List<String>,
    );
  }
}

extension $CurrentAccountResponseDataCopyWith on CurrentAccountResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfCurrentAccountResponseData.copyWith(...)` or like so:`instanceOfCurrentAccountResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CurrentAccountResponseDataCWProxy get copyWith =>
      _$CurrentAccountResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentAccountResponseData _$CurrentAccountResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CurrentAccountResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['account', 'current_organization', 'capabilities'],
    );
    final val = CurrentAccountResponseData(
      account: $checkedConvert(
        'account',
        (v) => Account.fromJson(v as Map<String, dynamic>),
      ),
      currentOrganization: $checkedConvert(
        'current_organization',
        (v) => Organization.fromJson(v as Map<String, dynamic>),
      ),
      capabilities: $checkedConvert(
        'capabilities',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'currentOrganization': 'current_organization'},
);

Map<String, dynamic> _$CurrentAccountResponseDataToJson(
  CurrentAccountResponseData instance,
) => <String, dynamic>{
  'account': instance.account.toJson(),
  'current_organization': instance.currentOrganization.toJson(),
  'capabilities': instance.capabilities,
};
