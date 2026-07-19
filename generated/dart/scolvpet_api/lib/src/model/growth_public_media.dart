//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'growth_public_media.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrowthPublicMedia {
  /// Returns a new [GrowthPublicMedia] instance.
  GrowthPublicMedia({

    required  this.id,

    required  this.url,

    required  this.kind,

     this.status,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



      /// API 媒体读取路径；Web 公开页通过同源代理渲染。
  @JsonKey(

    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(

    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final GrowthPublicMediaKindEnum kind;



  @JsonKey(

    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final GrowthPublicMediaStatusEnum? status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrowthPublicMedia &&
      other.id == id &&
      other.url == url &&
      other.kind == kind &&
      other.status == status;

    @override
    int get hashCode =>
        id.hashCode +
        url.hashCode +
        kind.hashCode +
        status.hashCode;

  factory GrowthPublicMedia.fromJson(Map<String, dynamic> json) => _$GrowthPublicMediaFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthPublicMediaToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum GrowthPublicMediaKindEnum {
@JsonValue(r'cover')
cover(r'cover'),
@JsonValue(r'thumbnail')
thumbnail(r'thumbnail'),
@JsonValue(r'preview')
preview(r'preview');

const GrowthPublicMediaKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum GrowthPublicMediaStatusEnum {
@JsonValue(r'ready')
ready(r'ready'),
@JsonValue(r'processing')
processing(r'processing'),
@JsonValue(r'failed')
failed(r'failed');

const GrowthPublicMediaStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
