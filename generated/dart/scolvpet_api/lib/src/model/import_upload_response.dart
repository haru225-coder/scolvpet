//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:scolvpet_api/src/model/upload_session.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_upload_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportUploadResponse {
  /// Returns a new [ImportUploadResponse] instance.
  ImportUploadResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final UploadSession data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportUploadResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory ImportUploadResponse.fromJson(Map<String, dynamic> json) => _$ImportUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ImportUploadResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
