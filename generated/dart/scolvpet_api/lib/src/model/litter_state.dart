//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// voided 为服务端纠错作废后的只读状态，不提供客户端状态动作
enum LitterState {
          /// voided 为服务端纠错作废后的只读状态，不提供客户端状态动作
      @JsonValue(r'newborn')
      newborn(r'newborn'),
          /// voided 为服务端纠错作废后的只读状态，不提供客户端状态动作
      @JsonValue(r'nursing')
      nursing(r'nursing'),
          /// voided 为服务端纠错作废后的只读状态，不提供客户端状态动作
      @JsonValue(r'weaning_due')
      weaningDue(r'weaning_due'),
          /// voided 为服务端纠错作废后的只读状态，不提供客户端状态动作
      @JsonValue(r'sexing_due')
      sexingDue(r'sexing_due'),
          /// voided 为服务端纠错作废后的只读状态，不提供客户端状态动作
      @JsonValue(r'individualizing')
      individualizing(r'individualizing'),
          /// voided 为服务端纠错作废后的只读状态，不提供客户端状态动作
      @JsonValue(r'closed')
      closed(r'closed'),
          /// voided 为服务端纠错作废后的只读状态，不提供客户端状态动作
      @JsonValue(r'voided')
      voided(r'voided');

  const LitterState(this.value);

  final String value;

  @override
  String toString() => value;
}
