//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_session_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerSessionResponseData {
  /// Returns a new [CustomerSessionResponseData] instance.
  CustomerSessionResponseData({

     this.tokenType,

    required  this.accessToken,

     this.expiresInSeconds,

    required  this.phone,
  });

  @JsonKey(

    name: r'token_type',
    required: false,
    includeIfNull: false,
  )


  final String? tokenType;



      /// opaque ct_ token
  @JsonKey(

    name: r'access_token',
    required: true,
    includeIfNull: false,
  )


  final String accessToken;



  @JsonKey(

    name: r'expires_in_seconds',
    required: false,
    includeIfNull: false,
  )


  final int? expiresInSeconds;



  @JsonKey(

    name: r'phone',
    required: true,
    includeIfNull: false,
  )


  final String phone;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerSessionResponseData &&
      other.tokenType == tokenType &&
      other.accessToken == accessToken &&
      other.expiresInSeconds == expiresInSeconds &&
      other.phone == phone;

    @override
    int get hashCode =>
        tokenType.hashCode +
        accessToken.hashCode +
        expiresInSeconds.hashCode +
        phone.hashCode;

  factory CustomerSessionResponseData.fromJson(Map<String, dynamic> json) => _$CustomerSessionResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerSessionResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
