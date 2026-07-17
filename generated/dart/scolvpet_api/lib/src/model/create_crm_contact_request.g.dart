// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_crm_contact_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateCrmContactRequestCWProxy {
  CreateCrmContactRequest name(String name);

  CreateCrmContactRequest phone(String? phone);

  CreateCrmContactRequest wechat(String? wechat);

  CreateCrmContactRequest notes(String? notes);

  CreateCrmContactRequest status(CreateCrmContactRequestStatusEnum? status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCrmContactRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCrmContactRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCrmContactRequest call({
    String name,
    String? phone,
    String? wechat,
    String? notes,
    CreateCrmContactRequestStatusEnum? status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateCrmContactRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateCrmContactRequest.copyWith.fieldName(...)`
class _$CreateCrmContactRequestCWProxyImpl
    implements _$CreateCrmContactRequestCWProxy {
  const _$CreateCrmContactRequestCWProxyImpl(this._value);

  final CreateCrmContactRequest _value;

  @override
  CreateCrmContactRequest name(String name) => this(name: name);

  @override
  CreateCrmContactRequest phone(String? phone) => this(phone: phone);

  @override
  CreateCrmContactRequest wechat(String? wechat) => this(wechat: wechat);

  @override
  CreateCrmContactRequest notes(String? notes) => this(notes: notes);

  @override
  CreateCrmContactRequest status(CreateCrmContactRequestStatusEnum? status) =>
      this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateCrmContactRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateCrmContactRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateCrmContactRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? wechat = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return CreateCrmContactRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String?,
      wechat: wechat == const $CopyWithPlaceholder()
          ? _value.wechat
          // ignore: cast_nullable_to_non_nullable
          : wechat as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CreateCrmContactRequestStatusEnum?,
    );
  }
}

extension $CreateCrmContactRequestCopyWith on CreateCrmContactRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateCrmContactRequest.copyWith(...)` or like so:`instanceOfCreateCrmContactRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateCrmContactRequestCWProxy get copyWith =>
      _$CreateCrmContactRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCrmContactRequest _$CreateCrmContactRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateCrmContactRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['name']);
  final val = CreateCrmContactRequest(
    name: $checkedConvert('name', (v) => v as String),
    phone: $checkedConvert('phone', (v) => v as String?),
    wechat: $checkedConvert('wechat', (v) => v as String?),
    notes: $checkedConvert('notes', (v) => v as String?),
    status: $checkedConvert(
      'status',
      (v) =>
          $enumDecodeNullable(_$CreateCrmContactRequestStatusEnumEnumMap, v) ??
          CreateCrmContactRequestStatusEnum.lead,
    ),
  );
  return val;
});

Map<String, dynamic> _$CreateCrmContactRequestToJson(
  CreateCrmContactRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'phone': ?instance.phone,
  'wechat': ?instance.wechat,
  'notes': ?instance.notes,
  'status': ?_$CreateCrmContactRequestStatusEnumEnumMap[instance.status],
};

const _$CreateCrmContactRequestStatusEnumEnumMap = {
  CreateCrmContactRequestStatusEnum.lead: 'lead',
  CreateCrmContactRequestStatusEnum.active: 'active',
  CreateCrmContactRequestStatusEnum.archived: 'archived',
};
