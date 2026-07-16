// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retry_import_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RetryImportRequestCWProxy {
  RetryImportRequest scope(RetryImportRequestScopeEnum scope);

  RetryImportRequest rowNumbers(Set<int>? rowNumbers);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RetryImportRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RetryImportRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RetryImportRequest call({
    RetryImportRequestScopeEnum scope,
    Set<int>? rowNumbers,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRetryImportRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRetryImportRequest.copyWith.fieldName(...)`
class _$RetryImportRequestCWProxyImpl implements _$RetryImportRequestCWProxy {
  const _$RetryImportRequestCWProxyImpl(this._value);

  final RetryImportRequest _value;

  @override
  RetryImportRequest scope(RetryImportRequestScopeEnum scope) =>
      this(scope: scope);

  @override
  RetryImportRequest rowNumbers(Set<int>? rowNumbers) =>
      this(rowNumbers: rowNumbers);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RetryImportRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RetryImportRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RetryImportRequest call({
    Object? scope = const $CopyWithPlaceholder(),
    Object? rowNumbers = const $CopyWithPlaceholder(),
  }) {
    return RetryImportRequest(
      scope: scope == const $CopyWithPlaceholder()
          ? _value.scope
          // ignore: cast_nullable_to_non_nullable
          : scope as RetryImportRequestScopeEnum,
      rowNumbers: rowNumbers == const $CopyWithPlaceholder()
          ? _value.rowNumbers
          // ignore: cast_nullable_to_non_nullable
          : rowNumbers as Set<int>?,
    );
  }
}

extension $RetryImportRequestCopyWith on RetryImportRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRetryImportRequest.copyWith(...)` or like so:`instanceOfRetryImportRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RetryImportRequestCWProxy get copyWith =>
      _$RetryImportRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetryImportRequest _$RetryImportRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RetryImportRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['scope']);
      final val = RetryImportRequest(
        scope: $checkedConvert(
          'scope',
          (v) => $enumDecode(_$RetryImportRequestScopeEnumEnumMap, v),
        ),
        rowNumbers: $checkedConvert(
          'row_numbers',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'rowNumbers': 'row_numbers'});

Map<String, dynamic> _$RetryImportRequestToJson(RetryImportRequest instance) =>
    <String, dynamic>{
      'scope': _$RetryImportRequestScopeEnumEnumMap[instance.scope]!,
      'row_numbers': ?instance.rowNumbers?.toList(),
    };

const _$RetryImportRequestScopeEnumEnumMap = {
  RetryImportRequestScopeEnum.allFailedRows: 'all_failed_rows',
  RetryImportRequestScopeEnum.selectedRows: 'selected_rows',
};
