//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'crm_contact.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CrmContact {
  /// Returns a new [CrmContact] instance.
  CrmContact({

    required  this.id,

    required  this.name,

     this.phone,

     this.wechat,

     this.notes,

    required  this.status,

    required  this.version,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'phone',
    required: false,
    includeIfNull: false,
  )


  final String? phone;



  @JsonKey(
    
    name: r'wechat',
    required: false,
    includeIfNull: false,
  )


  final String? wechat;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final CrmContactStatusEnum status;



          // minimum: 1
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CrmContact &&
      other.id == id &&
      other.name == name &&
      other.phone == phone &&
      other.wechat == wechat &&
      other.notes == notes &&
      other.status == status &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        (phone == null ? 0 : phone.hashCode) +
        (wechat == null ? 0 : wechat.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        status.hashCode +
        version.hashCode;

  factory CrmContact.fromJson(Map<String, dynamic> json) => _$CrmContactFromJson(json);

  Map<String, dynamic> toJson() => _$CrmContactToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CrmContactStatusEnum {
@JsonValue(r'lead')
lead(r'lead'),
@JsonValue(r'active')
active(r'active'),
@JsonValue(r'archived')
archived(r'archived');

const CrmContactStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


