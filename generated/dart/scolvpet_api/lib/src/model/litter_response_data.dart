//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/reconciliation.dart';
import 'package:scolvpet_api/src/model/litter.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'litter_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LitterResponseData {
  /// Returns a new [LitterResponseData] instance.
  LitterResponseData({

    required  this.litter,

    required  this.reconciliation,
  });

  @JsonKey(

    name: r'litter',
    required: true,
    includeIfNull: false,
  )


  final Litter litter;



  @JsonKey(

    name: r'reconciliation',
    required: true,
    includeIfNull: false,
  )


  final Reconciliation reconciliation;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LitterResponseData &&
      other.litter == litter &&
      other.reconciliation == reconciliation;

    @override
    int get hashCode =>
        litter.hashCode +
        reconciliation.hashCode;

  factory LitterResponseData.fromJson(Map<String, dynamic> json) => _$LitterResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$LitterResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
