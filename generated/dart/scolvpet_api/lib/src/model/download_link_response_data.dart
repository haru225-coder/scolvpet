//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'download_link_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DownloadLinkResponseData {
  /// Returns a new [DownloadLinkResponseData] instance.
  DownloadLinkResponseData({

    required  this.downloadUrl,

    required  this.expiresAt,

    required  this.fileName,

    required  this.sizeBytes,

    required  this.sha256,
  });

  @JsonKey(
    
    name: r'download_url',
    required: true,
    includeIfNull: false,
  )


  final String downloadUrl;



  @JsonKey(
    
    name: r'expires_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime expiresAt;



  @JsonKey(
    
    name: r'file_name',
    required: true,
    includeIfNull: false,
  )


  final String fileName;



          // minimum: 0
  @JsonKey(
    
    name: r'size_bytes',
    required: true,
    includeIfNull: false,
  )


  final int sizeBytes;



  @JsonKey(
    
    name: r'sha256',
    required: true,
    includeIfNull: false,
  )


  final String sha256;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DownloadLinkResponseData &&
      other.downloadUrl == downloadUrl &&
      other.expiresAt == expiresAt &&
      other.fileName == fileName &&
      other.sizeBytes == sizeBytes &&
      other.sha256 == sha256;

    @override
    int get hashCode =>
        downloadUrl.hashCode +
        expiresAt.hashCode +
        fileName.hashCode +
        sizeBytes.hashCode +
        sha256.hashCode;

  factory DownloadLinkResponseData.fromJson(Map<String, dynamic> json) => _$DownloadLinkResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadLinkResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

