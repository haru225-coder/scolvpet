//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/customer_verification_code_response_data.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_verification_code_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerVerificationCodeResponse {
  /// Returns a new [CustomerVerificationCodeResponse] instance.
  CustomerVerificationCodeResponse({

     this.data,

     this.meta,
  });

  @JsonKey(

    name: r'data',
    required: false,
    includeIfNull: false,
  )


  final CustomerVerificationCodeResponseData? data;



  @JsonKey(

    name: r'meta',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerVerificationCodeResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory CustomerVerificationCodeResponse.fromJson(Map<String, dynamic> json) => _$CustomerVerificationCodeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerVerificationCodeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
