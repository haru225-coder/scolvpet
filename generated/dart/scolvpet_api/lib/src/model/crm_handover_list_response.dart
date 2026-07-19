//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/crm_handover.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'crm_handover_list_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CrmHandoverListResponse {
  /// Returns a new [CrmHandoverListResponse] instance.
  CrmHandoverListResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final List<CrmHandover> data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CrmHandoverListResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory CrmHandoverListResponse.fromJson(Map<String, dynamic> json) => _$CrmHandoverListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CrmHandoverListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
