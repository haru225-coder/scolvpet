//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/organization.dart';
import 'package:scolvpet_api/src/model/account.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'current_account_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CurrentAccountResponseData {
  /// Returns a new [CurrentAccountResponseData] instance.
  CurrentAccountResponseData({

    required  this.account,

    required  this.currentOrganization,

    required  this.capabilities,
  });

  @JsonKey(
    
    name: r'account',
    required: true,
    includeIfNull: false,
  )


  final Account account;



  @JsonKey(
    
    name: r'current_organization',
    required: true,
    includeIfNull: false,
  )


  final Organization currentOrganization;



  @JsonKey(
    
    name: r'capabilities',
    required: true,
    includeIfNull: false,
  )


  final List<String> capabilities;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CurrentAccountResponseData &&
      other.account == account &&
      other.currentOrganization == currentOrganization &&
      other.capabilities == capabilities;

    @override
    int get hashCode =>
        account.hashCode +
        currentOrganization.hashCode +
        capabilities.hashCode;

  factory CurrentAccountResponseData.fromJson(Map<String, dynamic> json) => _$CurrentAccountResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentAccountResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

