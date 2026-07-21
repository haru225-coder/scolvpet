//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_growth_reservation_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicGrowthReservationRequest {
  /// Returns a new [PublicGrowthReservationRequest] instance.
  PublicGrowthReservationRequest({

    required  this.hamsterId,

    required  this.name,

     this.phone,

     this.wechat,

     this.notes,
  });

      /// 真实仓鼠 ID；禁止客户端自造商品 ID
  @JsonKey(

    name: r'hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String hamsterId;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicGrowthReservationRequest &&
      other.hamsterId == hamsterId &&
      other.name == name &&
      other.phone == phone &&
      other.wechat == wechat &&
      other.notes == notes;

    @override
    int get hashCode =>
        hamsterId.hashCode +
        name.hashCode +
        phone.hashCode +
        wechat.hashCode +
        notes.hashCode;

  factory PublicGrowthReservationRequest.fromJson(Map<String, dynamic> json) => _$PublicGrowthReservationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PublicGrowthReservationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
