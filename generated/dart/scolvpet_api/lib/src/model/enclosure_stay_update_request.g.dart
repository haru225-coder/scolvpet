// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_stay_update_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureStayUpdateRequestCWProxy {
  EnclosureStayUpdateRequest endedAt(DateTime? endedAt);

  EnclosureStayUpdateRequest reason(String? reason);

  EnclosureStayUpdateRequest correctionReason(String? correctionReason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureStayUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureStayUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureStayUpdateRequest call({
    DateTime? endedAt,
    String? reason,
    String? correctionReason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureStayUpdateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureStayUpdateRequest.copyWith.fieldName(...)`
class _$EnclosureStayUpdateRequestCWProxyImpl
    implements _$EnclosureStayUpdateRequestCWProxy {
  const _$EnclosureStayUpdateRequestCWProxyImpl(this._value);

  final EnclosureStayUpdateRequest _value;

  @override
  EnclosureStayUpdateRequest endedAt(DateTime? endedAt) =>
      this(endedAt: endedAt);

  @override
  EnclosureStayUpdateRequest reason(String? reason) => this(reason: reason);

  @override
  EnclosureStayUpdateRequest correctionReason(String? correctionReason) =>
      this(correctionReason: correctionReason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureStayUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureStayUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureStayUpdateRequest call({
    Object? endedAt = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? correctionReason = const $CopyWithPlaceholder(),
  }) {
    return EnclosureStayUpdateRequest(
      endedAt: endedAt == const $CopyWithPlaceholder()
          ? _value.endedAt
          // ignore: cast_nullable_to_non_nullable
          : endedAt as DateTime?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
      correctionReason: correctionReason == const $CopyWithPlaceholder()
          ? _value.correctionReason
          // ignore: cast_nullable_to_non_nullable
          : correctionReason as String?,
    );
  }
}

extension $EnclosureStayUpdateRequestCopyWith on EnclosureStayUpdateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureStayUpdateRequest.copyWith(...)` or like so:`instanceOfEnclosureStayUpdateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureStayUpdateRequestCWProxy get copyWith =>
      _$EnclosureStayUpdateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureStayUpdateRequest _$EnclosureStayUpdateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'EnclosureStayUpdateRequest',
  json,
  ($checkedConvert) {
    final val = EnclosureStayUpdateRequest(
      endedAt: $checkedConvert(
        'ended_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      reason: $checkedConvert('reason', (v) => v as String?),
      correctionReason: $checkedConvert(
        'correction_reason',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'endedAt': 'ended_at',
    'correctionReason': 'correction_reason',
  },
);

Map<String, dynamic> _$EnclosureStayUpdateRequestToJson(
  EnclosureStayUpdateRequest instance,
) => <String, dynamic>{
  'ended_at': ?instance.endedAt?.toIso8601String(),
  'reason': ?instance.reason,
  'correction_reason': ?instance.correctionReason,
};
