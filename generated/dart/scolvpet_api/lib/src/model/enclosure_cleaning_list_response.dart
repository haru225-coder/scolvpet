//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/enclosure_cleaning.dart';
import 'package:scolvpet_api/src/model/page_info.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enclosure_cleaning_list_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnclosureCleaningListResponse {
  /// Returns a new [EnclosureCleaningListResponse] instance.
  EnclosureCleaningListResponse({

    required  this.data,

    required  this.page,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final List<EnclosureCleaning> data;



  @JsonKey(

    name: r'page',
    required: true,
    includeIfNull: false,
  )


  final PageInfo page;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EnclosureCleaningListResponse &&
      other.data == data &&
      other.page == page &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        page.hashCode +
        meta.hashCode;

  factory EnclosureCleaningListResponse.fromJson(Map<String, dynamic> json) => _$EnclosureCleaningListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EnclosureCleaningListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
