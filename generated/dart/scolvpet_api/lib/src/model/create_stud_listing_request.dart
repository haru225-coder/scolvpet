//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_stud_listing_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateStudListingRequest {
  /// Returns a new [CreateStudListingRequest] instance.
  CreateStudListingRequest({

    required  this.sireLabel,

     this.title,

     this.feeCents,

     this.currency = 'CNY',

     this.notes,

     this.published = true,
  });

  @JsonKey(

    name: r'sire_label',
    required: true,
    includeIfNull: false,
  )


  final String sireLabel;



  @JsonKey(

    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



          // minimum: 0
  @JsonKey(

    name: r'fee_cents',
    required: false,
    includeIfNull: false,
  )


  final int? feeCents;



  @JsonKey(
    defaultValue: 'CNY',
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



  @JsonKey(
    defaultValue: true,
    name: r'published',
    required: false,
    includeIfNull: false,
  )


  final bool? published;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateStudListingRequest &&
      other.sireLabel == sireLabel &&
      other.title == title &&
      other.feeCents == feeCents &&
      other.currency == currency &&
      other.notes == notes &&
      other.published == published;

    @override
    int get hashCode =>
        sireLabel.hashCode +
        title.hashCode +
        feeCents.hashCode +
        currency.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        (published == null ? 0 : published.hashCode);

  factory CreateStudListingRequest.fromJson(Map<String, dynamic> json) => _$CreateStudListingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateStudListingRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
