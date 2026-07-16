// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterResponseDataCWProxy {
  LitterResponseData litter(Litter litter);

  LitterResponseData reconciliation(Reconciliation reconciliation);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterResponseData call({Litter litter, Reconciliation reconciliation});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterResponseData.copyWith.fieldName(...)`
class _$LitterResponseDataCWProxyImpl implements _$LitterResponseDataCWProxy {
  const _$LitterResponseDataCWProxyImpl(this._value);

  final LitterResponseData _value;

  @override
  LitterResponseData litter(Litter litter) => this(litter: litter);

  @override
  LitterResponseData reconciliation(Reconciliation reconciliation) =>
      this(reconciliation: reconciliation);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterResponseData call({
    Object? litter = const $CopyWithPlaceholder(),
    Object? reconciliation = const $CopyWithPlaceholder(),
  }) {
    return LitterResponseData(
      litter: litter == const $CopyWithPlaceholder()
          ? _value.litter
          // ignore: cast_nullable_to_non_nullable
          : litter as Litter,
      reconciliation: reconciliation == const $CopyWithPlaceholder()
          ? _value.reconciliation
          // ignore: cast_nullable_to_non_nullable
          : reconciliation as Reconciliation,
    );
  }
}

extension $LitterResponseDataCopyWith on LitterResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfLitterResponseData.copyWith(...)` or like so:`instanceOfLitterResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterResponseDataCWProxy get copyWith =>
      _$LitterResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterResponseData _$LitterResponseDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LitterResponseData', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['litter', 'reconciliation']);
      final val = LitterResponseData(
        litter: $checkedConvert(
          'litter',
          (v) => Litter.fromJson(v as Map<String, dynamic>),
        ),
        reconciliation: $checkedConvert(
          'reconciliation',
          (v) => Reconciliation.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LitterResponseDataToJson(LitterResponseData instance) =>
    <String, dynamic>{
      'litter': instance.litter.toJson(),
      'reconciliation': instance.reconciliation.toJson(),
    };
