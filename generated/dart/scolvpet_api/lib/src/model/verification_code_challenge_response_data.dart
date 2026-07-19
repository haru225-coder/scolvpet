//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verification_code_challenge_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerificationCodeChallengeResponseData {
  /// Returns a new [VerificationCodeChallengeResponseData] instance.
  VerificationCodeChallengeResponseData({

    required  this.verificationId,

    required  this.expiresInSeconds,

    required  this.retryAfterSeconds,
  });

  @JsonKey(

    name: r'verification_id',
    required: true,
    includeIfNull: false,
  )


  final String verificationId;



          // minimum: 60
  @JsonKey(

    name: r'expires_in_seconds',
    required: true,
    includeIfNull: false,
  )


  final int expiresInSeconds;



          // minimum: 1
  @JsonKey(

    name: r'retry_after_seconds',
    required: true,
    includeIfNull: false,
  )


  final int retryAfterSeconds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is VerificationCodeChallengeResponseData &&
      other.verificationId == verificationId &&
      other.expiresInSeconds == expiresInSeconds &&
      other.retryAfterSeconds == retryAfterSeconds;

    @override
    int get hashCode =>
        verificationId.hashCode +
        expiresInSeconds.hashCode +
        retryAfterSeconds.hashCode;

  factory VerificationCodeChallengeResponseData.fromJson(Map<String, dynamic> json) => _$VerificationCodeChallengeResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationCodeChallengeResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
