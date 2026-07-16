//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// 行级状态不包含 warning；非阻塞警告由 ImportIssue.severity=warning 表达
enum ImportRowStatus {
          /// 行级状态不包含 warning；非阻塞警告由 ImportIssue.severity=warning 表达
      @JsonValue(r'pending')
      pending(r'pending'),
          /// 行级状态不包含 warning；非阻塞警告由 ImportIssue.severity=warning 表达
      @JsonValue(r'valid')
      valid(r'valid'),
          /// 行级状态不包含 warning；非阻塞警告由 ImportIssue.severity=warning 表达
      @JsonValue(r'invalid')
      invalid(r'invalid'),
          /// 行级状态不包含 warning；非阻塞警告由 ImportIssue.severity=warning 表达
      @JsonValue(r'imported')
      imported(r'imported'),
          /// 行级状态不包含 warning；非阻塞警告由 ImportIssue.severity=warning 表达
      @JsonValue(r'skipped')
      skipped(r'skipped'),
          /// 行级状态不包含 warning；非阻塞警告由 ImportIssue.severity=warning 表达
      @JsonValue(r'failed')
      failed(r'failed');

  const ImportRowStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
