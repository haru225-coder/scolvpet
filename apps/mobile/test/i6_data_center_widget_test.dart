import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/data/i2_repository.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/i6/data_center.dart';

void main() {
  testWidgets('data center exposes import, task, usage and media entries', (
    tester,
  ) async {
    final i2Controller = I2Controller(repository: MemoryI2Repository());
    final dataCenter = DataCenterController();

    await tester.pumpWidget(
      MaterialApp(
        home: DataCenterPage(
          i2Controller: i2Controller,
          controller: dataCenter,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('数据与备份'), findsOneWidget);
    expect(find.text('批量导入'), findsOneWidget);
    expect(find.text('导出数据'), findsOneWidget);
    expect(find.text('备份数据'), findsOneWidget);
    expect(find.text('暂无任务、备份和用量数据'), findsOneWidget);

    await tester.tap(find.text('导出数据').first);
    await tester.pumpAndSettle();
    expect(find.byType(DataCenterTaskPage), findsOneWidget);
    expect(find.text('暂无导出记录'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('用量摘要'), findsOneWidget);
    expect(find.text('媒体与分享'), findsOneWidget);
  });

  testWidgets('data center renders loading and then empty state', (
    tester,
  ) async {
    final completer = Completer<DataCenterSnapshot>();
    final controller = DataCenterController(loader: () => completer.future);
    final i2Controller = I2Controller(repository: MemoryI2Repository());

    await tester.pumpWidget(
      MaterialApp(
        home: DataCenterPage(
          i2Controller: i2Controller,
          controller: controller,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('正在加载数据中心摘要'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(DataCenterSnapshot.empty);
    await tester.pumpAndSettle();
    expect(find.text('暂无任务、备份和用量数据'), findsOneWidget);
  });

  testWidgets('data center renders retryable error state', (tester) async {
    final controller = DataCenterController(
      loader: () async => throw StateError('fixture'),
    );
    final i2Controller = I2Controller(repository: MemoryI2Repository());

    await tester.pumpWidget(
      MaterialApp(
        home: DataCenterPage(
          i2Controller: i2Controller,
          controller: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('数据中心摘要加载失败，请稍后重试'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '重试'), findsOneWidget);
  });

  testWidgets('usage page keeps six metric slots for a connected snapshot', (
    tester,
  ) async {
    final controller = DataCenterController(
      initial: DataCenterSnapshot(
        usage: DataCenterUsageSummary(
          measuredAt: DateTime.utc(2026, 7, 16, 10),
          metrics: const [
            DataCenterUsageMetric(
              key: 'active_hamsters',
              label: '活跃仓鼠',
              value: 4,
              unit: '只',
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: DataCenterUsagePage(controller: controller)),
    );

    expect(find.text('账号用量'), findsOneWidget);
    expect(find.text('活跃仓鼠'), findsOneWidget);
    expect(find.text('4 只'), findsOneWidget);
    expect(find.text('活跃窝次'), findsOneWidget);
    expect(find.text('备份空间'), findsOneWidget);
  });

  testWidgets('media page connects media library and public share entries', (
    tester,
  ) async {
    var openedMedia = false;
    var openedShares = false;
    await tester.pumpWidget(
      MaterialApp(
        home: DataCenterMediaPage(
          controller: DataCenterController(),
          onOpenMediaLibrary: () => openedMedia = true,
          onOpenPublicShares: () => openedShares = true,
        ),
      ),
    );

    await tester.tap(find.text('媒体库'));
    await tester.tap(find.text('公开分享'));

    expect(openedMedia, isTrue);
    expect(openedShares, isTrue);
    expect(find.textContaining('即将开放'), findsNothing);
  });

  testWidgets('succeeded task exposes file details and download link action', (
    tester,
  ) async {
    final task = DataCenterTask(
      id: 'export-1',
      kind: DataCenterTaskKind.export,
      status: DataCenterTaskStatus.succeeded,
      progressPercent: 100,
      detail: '文件已生成',
      fileName: '熊舍记录.json',
      sizeLabel: '2.4 MB',
      sha256:
          '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      expiresAt: DateTime.utc(2099, 1, 1),
    );
    final controller = DataCenterController(
      initial: DataCenterSnapshot(exportTasks: [task]),
      downloadAction: (_) async => DataCenterDownloadLink(
        url: 'https://download.example/export-1',
        fileName: '熊舍记录.json',
        sizeLabel: '2.4 MB',
        sha256:
            '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
        expiresAt: DateTime.utc(2099, 1, 1),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DataCenterTaskPage(
          controller: controller,
          kind: DataCenterTaskKind.export,
        ),
      ),
    );

    expect(find.text('文件：熊舍记录.json · 2.4 MB'), findsOneWidget);
    expect(find.textContaining('校验值：1234567890ab'), findsOneWidget);
    expect(find.text('当前步骤：文件已生成'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '获取下载链接'), findsOneWidget);

    final link = await controller.getDownloadLink(task);
    expect(link?.url, 'https://download.example/export-1');
    expect(controller.lastActionMessage, contains('下载链接已准备'));
  });

  testWidgets('usage summary chips include metric labels', (tester) async {
    final i2Controller = I2Controller(repository: MemoryI2Repository());
    final controller = DataCenterController(
      initial: const DataCenterSnapshot(
        usage: DataCenterUsageSummary(
          metrics: [
            DataCenterUsageMetric(
              key: 'active_hamsters',
              label: '活跃仓鼠',
              value: 4,
              unit: '只',
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DataCenterPage(
          i2Controller: i2Controller,
          controller: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('活跃仓鼠 4 只'), findsOneWidget);
    expect(find.text('活跃窝次 暂无'), findsOneWidget);
  });
}
