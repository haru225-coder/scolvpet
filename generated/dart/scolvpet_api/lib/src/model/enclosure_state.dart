//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum EnclosureState {
      @JsonValue(r'vacant')
      vacant(r'vacant'),
      @JsonValue(r'occupied_single')
      occupiedSingle(r'occupied_single'),
      @JsonValue(r'pairing_temp')
      pairingTemp(r'pairing_temp'),
      @JsonValue(r'gestation')
      gestation(r'gestation'),
      @JsonValue(r'dam_with_litter')
      damWithLitter(r'dam_with_litter'),
      @JsonValue(r'isolation')
      isolation(r'isolation'),
      @JsonValue(r'cleaning_due')
      cleaningDue(r'cleaning_due'),
      @JsonValue(r'disabled')
      disabled(r'disabled');

  const EnclosureState(this.value);

  final String value;

  @override
  String toString() => value;
}
