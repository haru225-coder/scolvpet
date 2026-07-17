// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_contact.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CrmContactCWProxy {
  CrmContact id(String id);

  CrmContact name(String name);

  CrmContact phone(String? phone);

  CrmContact wechat(String? wechat);

  CrmContact notes(String? notes);

  CrmContact status(CrmContactStatusEnum status);

  CrmContact version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmContact(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmContact(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmContact call({
    String id,
    String name,
    String? phone,
    String? wechat,
    String? notes,
    CrmContactStatusEnum status,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCrmContact.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCrmContact.copyWith.fieldName(...)`
class _$CrmContactCWProxyImpl implements _$CrmContactCWProxy {
  const _$CrmContactCWProxyImpl(this._value);

  final CrmContact _value;

  @override
  CrmContact id(String id) => this(id: id);

  @override
  CrmContact name(String name) => this(name: name);

  @override
  CrmContact phone(String? phone) => this(phone: phone);

  @override
  CrmContact wechat(String? wechat) => this(wechat: wechat);

  @override
  CrmContact notes(String? notes) => this(notes: notes);

  @override
  CrmContact status(CrmContactStatusEnum status) => this(status: status);

  @override
  CrmContact version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmContact(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmContact(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmContact call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? wechat = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return CrmContact(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
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
          : status as CrmContactStatusEnum,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $CrmContactCopyWith on CrmContact {
  /// Returns a callable class that can be used as follows: `instanceOfCrmContact.copyWith(...)` or like so:`instanceOfCrmContact.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CrmContactCWProxy get copyWith => _$CrmContactCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrmContact _$CrmContactFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CrmContact', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name', 'status', 'version']);
      final val = CrmContact(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        phone: $checkedConvert('phone', (v) => v as String?),
        wechat: $checkedConvert('wechat', (v) => v as String?),
        notes: $checkedConvert('notes', (v) => v as String?),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$CrmContactStatusEnumEnumMap, v),
        ),
        version: $checkedConvert('version', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$CrmContactToJson(CrmContact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': ?instance.phone,
      'wechat': ?instance.wechat,
      'notes': ?instance.notes,
      'status': _$CrmContactStatusEnumEnumMap[instance.status]!,
      'version': instance.version,
    };

const _$CrmContactStatusEnumEnumMap = {
  CrmContactStatusEnum.lead: 'lead',
  CrmContactStatusEnum.active: 'active',
  CrmContactStatusEnum.archived: 'archived',
};
