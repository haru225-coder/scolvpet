//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Account {
  /// Returns a new [Account] instance.
  Account({

    required  this.id,

    required  this.phoneMasked,

     this.displayName,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'phone_masked',
    required: true,
    includeIfNull: false,
  )


  final String phoneMasked;



  @JsonKey(

    name: r'display_name',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Account &&
      other.id == id &&
      other.phoneMasked == phoneMasked &&
      other.displayName == displayName;

    @override
    int get hashCode =>
        id.hashCode +
        phoneMasked.hashCode +
        (displayName == null ? 0 : displayName.hashCode);

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
