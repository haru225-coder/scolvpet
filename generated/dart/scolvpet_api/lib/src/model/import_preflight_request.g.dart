// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_preflight_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportPreflightRequestCWProxy {
  ImportPreflightRequest strictReferences(
    ImportPreflightRequestStrictReferencesEnum strictReferences,
  );

  ImportPreflightRequest duplicatePolicy(
    ImportPreflightRequestDuplicatePolicyEnum? duplicatePolicy,
  );

  ImportPreflightRequest historicalLitterPolicy(
    ImportPreflightRequestHistoricalLitterPolicyEnum historicalLitterPolicy,
  );

  ImportPreflightRequest parentageConflictPolicy(
    ImportPreflightRequestParentageConflictPolicyEnum parentageConflictPolicy,
  );

  ImportPreflightRequest existingFieldPolicy(
    ImportPreflightRequestExistingFieldPolicyEnum existingFieldPolicy,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportPreflightRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportPreflightRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportPreflightRequest call({
    ImportPreflightRequestStrictReferencesEnum strictReferences,
    ImportPreflightRequestDuplicatePolicyEnum? duplicatePolicy,
    ImportPreflightRequestHistoricalLitterPolicyEnum historicalLitterPolicy,
    ImportPreflightRequestParentageConflictPolicyEnum parentageConflictPolicy,
    ImportPreflightRequestExistingFieldPolicyEnum existingFieldPolicy,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportPreflightRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportPreflightRequest.copyWith.fieldName(...)`
class _$ImportPreflightRequestCWProxyImpl
    implements _$ImportPreflightRequestCWProxy {
  const _$ImportPreflightRequestCWProxyImpl(this._value);

  final ImportPreflightRequest _value;

  @override
  ImportPreflightRequest strictReferences(
    ImportPreflightRequestStrictReferencesEnum strictReferences,
  ) => this(strictReferences: strictReferences);

  @override
  ImportPreflightRequest duplicatePolicy(
    ImportPreflightRequestDuplicatePolicyEnum? duplicatePolicy,
  ) => this(duplicatePolicy: duplicatePolicy);

  @override
  ImportPreflightRequest historicalLitterPolicy(
    ImportPreflightRequestHistoricalLitterPolicyEnum historicalLitterPolicy,
  ) => this(historicalLitterPolicy: historicalLitterPolicy);

  @override
  ImportPreflightRequest parentageConflictPolicy(
    ImportPreflightRequestParentageConflictPolicyEnum parentageConflictPolicy,
  ) => this(parentageConflictPolicy: parentageConflictPolicy);

  @override
  ImportPreflightRequest existingFieldPolicy(
    ImportPreflightRequestExistingFieldPolicyEnum existingFieldPolicy,
  ) => this(existingFieldPolicy: existingFieldPolicy);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportPreflightRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportPreflightRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportPreflightRequest call({
    Object? strictReferences = const $CopyWithPlaceholder(),
    Object? duplicatePolicy = const $CopyWithPlaceholder(),
    Object? historicalLitterPolicy = const $CopyWithPlaceholder(),
    Object? parentageConflictPolicy = const $CopyWithPlaceholder(),
    Object? existingFieldPolicy = const $CopyWithPlaceholder(),
  }) {
    return ImportPreflightRequest(
      strictReferences: strictReferences == const $CopyWithPlaceholder()
          ? _value.strictReferences
          // ignore: cast_nullable_to_non_nullable
          : strictReferences as ImportPreflightRequestStrictReferencesEnum,
      duplicatePolicy: duplicatePolicy == const $CopyWithPlaceholder()
          ? _value.duplicatePolicy
          // ignore: cast_nullable_to_non_nullable
          : duplicatePolicy as ImportPreflightRequestDuplicatePolicyEnum?,
      historicalLitterPolicy:
          historicalLitterPolicy == const $CopyWithPlaceholder()
          ? _value.historicalLitterPolicy
          // ignore: cast_nullable_to_non_nullable
          : historicalLitterPolicy
                as ImportPreflightRequestHistoricalLitterPolicyEnum,
      parentageConflictPolicy:
          parentageConflictPolicy == const $CopyWithPlaceholder()
          ? _value.parentageConflictPolicy
          // ignore: cast_nullable_to_non_nullable
          : parentageConflictPolicy
                as ImportPreflightRequestParentageConflictPolicyEnum,
      existingFieldPolicy: existingFieldPolicy == const $CopyWithPlaceholder()
          ? _value.existingFieldPolicy
          // ignore: cast_nullable_to_non_nullable
          : existingFieldPolicy
                as ImportPreflightRequestExistingFieldPolicyEnum,
    );
  }
}

extension $ImportPreflightRequestCopyWith on ImportPreflightRequest {
  /// Returns a callable class that can be used as follows: `instanceOfImportPreflightRequest.copyWith(...)` or like so:`instanceOfImportPreflightRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportPreflightRequestCWProxy get copyWith =>
      _$ImportPreflightRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportPreflightRequest _$ImportPreflightRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ImportPreflightRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'strict_references',
        'historical_litter_policy',
        'parentage_conflict_policy',
        'existing_field_policy',
      ],
    );
    final val = ImportPreflightRequest(
      strictReferences: $checkedConvert(
        'strict_references',
        (v) =>
            $enumDecode(_$ImportPreflightRequestStrictReferencesEnumEnumMap, v),
      ),
      duplicatePolicy: $checkedConvert(
        'duplicate_policy',
        (v) =>
            $enumDecodeNullable(
              _$ImportPreflightRequestDuplicatePolicyEnumEnumMap,
              v,
            ) ??
            ImportPreflightRequestDuplicatePolicyEnum.reject,
      ),
      historicalLitterPolicy: $checkedConvert(
        'historical_litter_policy',
        (v) => $enumDecode(
          _$ImportPreflightRequestHistoricalLitterPolicyEnumEnumMap,
          v,
        ),
      ),
      parentageConflictPolicy: $checkedConvert(
        'parentage_conflict_policy',
        (v) => $enumDecode(
          _$ImportPreflightRequestParentageConflictPolicyEnumEnumMap,
          v,
        ),
      ),
      existingFieldPolicy: $checkedConvert(
        'existing_field_policy',
        (v) => $enumDecode(
          _$ImportPreflightRequestExistingFieldPolicyEnumEnumMap,
          v,
        ),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'strictReferences': 'strict_references',
    'duplicatePolicy': 'duplicate_policy',
    'historicalLitterPolicy': 'historical_litter_policy',
    'parentageConflictPolicy': 'parentage_conflict_policy',
    'existingFieldPolicy': 'existing_field_policy',
  },
);

Map<String, dynamic> _$ImportPreflightRequestToJson(
  ImportPreflightRequest instance,
) => <String, dynamic>{
  'strict_references':
      _$ImportPreflightRequestStrictReferencesEnumEnumMap[instance
          .strictReferences]!,
  'duplicate_policy':
      ?_$ImportPreflightRequestDuplicatePolicyEnumEnumMap[instance
          .duplicatePolicy],
  'historical_litter_policy':
      _$ImportPreflightRequestHistoricalLitterPolicyEnumEnumMap[instance
          .historicalLitterPolicy]!,
  'parentage_conflict_policy':
      _$ImportPreflightRequestParentageConflictPolicyEnumEnumMap[instance
          .parentageConflictPolicy]!,
  'existing_field_policy':
      _$ImportPreflightRequestExistingFieldPolicyEnumEnumMap[instance
          .existingFieldPolicy]!,
};

const _$ImportPreflightRequestStrictReferencesEnumEnumMap = {
  ImportPreflightRequestStrictReferencesEnum.true_: 'true',
};

const _$ImportPreflightRequestDuplicatePolicyEnumEnumMap = {
  ImportPreflightRequestDuplicatePolicyEnum.reject: 'reject',
  ImportPreflightRequestDuplicatePolicyEnum.skip: 'skip',
  ImportPreflightRequestDuplicatePolicyEnum.updateWithVersion:
      'update_with_version',
};

const _$ImportPreflightRequestHistoricalLitterPolicyEnumEnumMap = {
  ImportPreflightRequestHistoricalLitterPolicyEnum.createIfComplete:
      'create_if_complete',
  ImportPreflightRequestHistoricalLitterPolicyEnum.requireExisting:
      'require_existing',
};

const _$ImportPreflightRequestParentageConflictPolicyEnumEnumMap = {
  ImportPreflightRequestParentageConflictPolicyEnum.reject: 'reject',
};

const _$ImportPreflightRequestExistingFieldPolicyEnumEnumMap = {
  ImportPreflightRequestExistingFieldPolicyEnum.preserveNonNull:
      'preserve_non_null',
  ImportPreflightRequestExistingFieldPolicyEnum.rejectUpdates: 'reject_updates',
};
