import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/i2/i2.dart';

void main() {
  testWidgets('successful empty state does not suggest retry by default', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: I2AsyncStateView<List<String>>(
            state: const I2AsyncState.empty(message: '暂无记录'),
            onRetry: () => retries++,
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(find.text('暂无记录'), findsOneWidget);
    expect(find.text('新建或同步记录后会显示在这里。'), findsOneWidget);
    expect(find.text('重试'), findsNothing);
    expect(retries, 0);
  });

  testWidgets('explicitly retryable empty state keeps a refresh action', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: I2AsyncStateView<List<String>>(
            state: const I2AsyncState.empty(message: '缓存为空', retryable: true),
            onRetry: () => retries++,
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(find.text('下拉或点重试，同步最新记录。'), findsOneWidget);
    await tester.tap(find.text('重试'));
    expect(retries, 1);
  });
}
