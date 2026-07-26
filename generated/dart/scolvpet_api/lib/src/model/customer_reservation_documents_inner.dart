//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_reservation_documents_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerReservationDocumentsInner {
  /// Returns a new [CustomerReservationDocumentsInner] instance.
  CustomerReservationDocumentsInner({

     this.id,

     this.docType,

     this.status,

     this.publicToken,

     this.webPath,
  });

  @JsonKey(

    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(

    name: r'doc_type',
    required: false,
    includeIfNull: false,
  )


  final String? docType;



  @JsonKey(

    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



  @JsonKey(

    name: r'public_token',
    required: false,
    includeIfNull: false,
  )


  final String? publicToken;



  @JsonKey(

    name: r'web_path',
    required: false,
    includeIfNull: false,
  )


  final String? webPath;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerReservationDocumentsInner &&
      other.id == id &&
      other.docType == docType &&
      other.status == status &&
      other.publicToken == publicToken &&
      other.webPath == webPath;

    @override
    int get hashCode =>
        id.hashCode +
        docType.hashCode +
        status.hashCode +
        publicToken.hashCode +
        webPath.hashCode;

  factory CustomerReservationDocumentsInner.fromJson(Map<String, dynamic> json) => _$CustomerReservationDocumentsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerReservationDocumentsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
