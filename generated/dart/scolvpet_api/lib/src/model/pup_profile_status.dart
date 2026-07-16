//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// 幼崽从临时监护身份到正式个体档案的进度
enum PupProfileStatus {
          /// 幼崽从临时监护身份到正式个体档案的进度
      @JsonValue(r'unindividualized')
      unindividualized(r'unindividualized'),
          /// 幼崽从临时监护身份到正式个体档案的进度
      @JsonValue(r'individualized')
      individualized(r'individualized'),
          /// 幼崽从临时监护身份到正式个体档案的进度
      @JsonValue(r'voided')
      voided(r'voided');

  const PupProfileStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
