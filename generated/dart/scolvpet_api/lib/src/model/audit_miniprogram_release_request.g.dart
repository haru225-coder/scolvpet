// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_miniprogram_release_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AuditMiniprogramReleaseRequestCWProxy {
  AuditMiniprogramReleaseRequest decision(
    AuditMiniprogramReleaseRequestDecisionEnum decision,
  );

  AuditMiniprogramReleaseRequest note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuditMiniprogramReleaseRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuditMiniprogramReleaseRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AuditMiniprogramReleaseRequest call({
    AuditMiniprogramReleaseRequestDecisionEnum decision,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAuditMiniprogramReleaseRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAuditMiniprogramReleaseRequest.copyWith.fieldName(...)`
class _$AuditMiniprogramReleaseRequestCWProxyImpl
    implements _$AuditMiniprogramReleaseRequestCWProxy {
  const _$AuditMiniprogramReleaseRequestCWProxyImpl(this._value);

  final AuditMiniprogramReleaseRequest _value;

  @override
  AuditMiniprogramReleaseRequest decision(
    AuditMiniprogramReleaseRequestDecisionEnum decision,
  ) => this(decision: decision);

  @override
  AuditMiniprogramReleaseRequest note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuditMiniprogramReleaseRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuditMiniprogramReleaseRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AuditMiniprogramReleaseRequest call({
    Object? decision = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return AuditMiniprogramReleaseRequest(
      decision: decision == const $CopyWithPlaceholder()
          ? _value.decision
          // ignore: cast_nullable_to_non_nullable
          : decision as AuditMiniprogramReleaseRequestDecisionEnum,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $AuditMiniprogramReleaseRequestCopyWith
    on AuditMiniprogramReleaseRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAuditMiniprogramReleaseRequest.copyWith(...)` or like so:`instanceOfAuditMiniprogramReleaseRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AuditMiniprogramReleaseRequestCWProxy get copyWith =>
      _$AuditMiniprogramReleaseRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditMiniprogramReleaseRequest _$AuditMiniprogramReleaseRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AuditMiniprogramReleaseRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['decision']);
  final val = AuditMiniprogramReleaseRequest(
    decision: $checkedConvert(
      'decision',
      (v) =>
          $enumDecode(_$AuditMiniprogramReleaseRequestDecisionEnumEnumMap, v),
    ),
    note: $checkedConvert('note', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AuditMiniprogramReleaseRequestToJson(
  AuditMiniprogramReleaseRequest instance,
) => <String, dynamic>{
  'decision':
      _$AuditMiniprogramReleaseRequestDecisionEnumEnumMap[instance.decision]!,
  'note': ?instance.note,
};

const _$AuditMiniprogramReleaseRequestDecisionEnumEnumMap = {
  AuditMiniprogramReleaseRequestDecisionEnum.approve: 'approve',
  AuditMiniprogramReleaseRequestDecisionEnum.reject: 'reject',
};
