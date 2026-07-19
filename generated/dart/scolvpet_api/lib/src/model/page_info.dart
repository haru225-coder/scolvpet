//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'page_info.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PageInfo {
  /// Returns a new [PageInfo] instance.
  PageInfo({

     this.nextCursor,

    required  this.hasMore,

     this.count,
  });

      /// 下一页游标；无下一页时为 null
  @JsonKey(

    name: r'next_cursor',
    required: false,
    includeIfNull: false,
  )


  final String? nextCursor;



  @JsonKey(

    name: r'has_more',
    required: true,
    includeIfNull: false,
  )


  final bool hasMore;



      /// 本页项目数
          // minimum: 0
  @JsonKey(

    name: r'count',
    required: false,
    includeIfNull: false,
  )


  final int? count;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PageInfo &&
      other.nextCursor == nextCursor &&
      other.hasMore == hasMore &&
      other.count == count;

    @override
    int get hashCode =>
        (nextCursor == null ? 0 : nextCursor.hashCode) +
        hasMore.hashCode +
        count.hashCode;

  factory PageInfo.fromJson(Map<String, dynamic> json) => _$PageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PageInfoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
