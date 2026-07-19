//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_crm_contact_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateCrmContactRequest {
  /// Returns a new [CreateCrmContactRequest] instance.
  CreateCrmContactRequest({

    required  this.name,

     this.phone,

     this.wechat,

     this.notes,

     this.status = CreateCrmContactRequestStatusEnum.lead,
  });

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
    defaultValue: CreateCrmContactRequestStatusEnum.lead,
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final CreateCrmContactRequestStatusEnum? status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateCrmContactRequest &&
      other.name == name &&
      other.phone == phone &&
      other.wechat == wechat &&
      other.notes == notes &&
      other.status == status;

    @override
    int get hashCode =>
        name.hashCode +
        (phone == null ? 0 : phone.hashCode) +
        (wechat == null ? 0 : wechat.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        status.hashCode;

  factory CreateCrmContactRequest.fromJson(Map<String, dynamic> json) => _$CreateCrmContactRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCrmContactRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CreateCrmContactRequestStatusEnum {
@JsonValue(r'lead')
lead(r'lead'),
@JsonValue(r'active')
active(r'active'),
@JsonValue(r'archived')
archived(r'archived');

const CreateCrmContactRequestStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
