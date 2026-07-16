//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'individualize_litter_request_items_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IndividualizeLitterRequestItemsInner {
  /// Returns a new [IndividualizeLitterRequestItemsInner] instance.
  IndividualizeLitterRequestItemsInner({

    required  this.pupIdentityId,

    required  this.internalCode,

     this.name,

     this.varietyCode,

     this.coverMediaId,

     this.notes,
  });

  @JsonKey(
    
    name: r'pup_identity_id',
    required: true,
    includeIfNull: false,
  )


  final String pupIdentityId;



  @JsonKey(
    
    name: r'internal_code',
    required: true,
    includeIfNull: false,
  )


  final String internalCode;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'variety_code',
    required: false,
    includeIfNull: false,
  )


  final String? varietyCode;



  @JsonKey(
    
    name: r'cover_media_id',
    required: false,
    includeIfNull: false,
  )


  final String? coverMediaId;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IndividualizeLitterRequestItemsInner &&
      other.pupIdentityId == pupIdentityId &&
      other.internalCode == internalCode &&
      other.name == name &&
      other.varietyCode == varietyCode &&
      other.coverMediaId == coverMediaId &&
      other.notes == notes;

    @override
    int get hashCode =>
        pupIdentityId.hashCode +
        internalCode.hashCode +
        (name == null ? 0 : name.hashCode) +
        (varietyCode == null ? 0 : varietyCode.hashCode) +
        (coverMediaId == null ? 0 : coverMediaId.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory IndividualizeLitterRequestItemsInner.fromJson(Map<String, dynamic> json) => _$IndividualizeLitterRequestItemsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$IndividualizeLitterRequestItemsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

