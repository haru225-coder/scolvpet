//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// 幼崽的生存/离舍结果，与是否已建立正式档案正交
enum PupOutcomeStatus {
          /// 幼崽的生存/离舍结果，与是否已建立正式档案正交
      @JsonValue(r'alive')
      alive(r'alive'),
          /// 幼崽的生存/离舍结果，与是否已建立正式档案正交
      @JsonValue(r'deceased')
      deceased(r'deceased'),
          /// 幼崽的生存/离舍结果，与是否已建立正式档案正交
      @JsonValue(r'transferred_out')
      transferredOut(r'transferred_out');

  const PupOutcomeStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
