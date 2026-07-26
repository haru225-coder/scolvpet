//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_verification_code_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerVerificationCodeResponseData {
  /// Returns a new [CustomerVerificationCodeResponseData] instance.
  CustomerVerificationCodeResponseData({

     this.verificationId,

     this.expiresInSeconds,

     this.retryAfterSeconds,
  });

  @JsonKey(

    name: r'verification_id',
    required: false,
    includeIfNull: false,
  )


  final String? verificationId;



  @JsonKey(

    name: r'expires_in_seconds',
    required: false,
    includeIfNull: false,
  )


  final int? expiresInSeconds;



  @JsonKey(

    name: r'retry_after_seconds',
    required: false,
    includeIfNull: false,
  )


  final int? retryAfterSeconds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerVerificationCodeResponseData &&
      other.verificationId == verificationId &&
      other.expiresInSeconds == expiresInSeconds &&
      other.retryAfterSeconds == retryAfterSeconds;

    @override
    int get hashCode =>
        verificationId.hashCode +
        expiresInSeconds.hashCode +
        retryAfterSeconds.hashCode;

  factory CustomerVerificationCodeResponseData.fromJson(Map<String, dynamic> json) => _$CustomerVerificationCodeResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerVerificationCodeResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
