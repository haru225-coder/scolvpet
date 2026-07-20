import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/contracts/contracts.dart';
import 'package:scolvpet_mobile/features/contracts/document_pdf.dart';
import 'support/memory_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MemoryContractsRepository template → contract → issue', () async {
    final repo = MemoryContractsRepository();
    final tpl = await repo.createTemplate(
      'contract',
      const DocTemplateDraft(name: '交接协议'),
    );
    final doc = await repo.createContract(
      ContractDraft(
        templateId: tpl.id,
        title: '雪球交付',
        contactName: '阿花',
        hamsterName: '雪球',
      ),
    );
    expect(doc.status, 'draft');
    expect(doc.bodyFilled, contains('阿花'));
    expect(doc.bodyFilled, contains('雪球'));
    final issued = await repo.issueDocument('contract', doc.id, doc.version);
    expect(issued.status, 'issued');
    expect(issued.issuedAt, isNotNull);
  });

  test('MemoryContractsRepository receipt amount fill', () async {
    final repo = MemoryContractsRepository();
    final tpl = await repo.createTemplate(
      'receipt',
      const DocTemplateDraft(name: '订金回执'),
    );
    final doc = await repo.createReceipt(
      ReceiptDraft(
        templateId: tpl.id,
        title: '订金',
        amountCents: 50000,
        contactName: '小李',
      ),
    );
    expect(doc.amountCents, 50000);
    expect(doc.bodyFilled, contains('500.00'));
    expect(doc.bodyFilled, contains('小李'));
  });

  test('buildDocumentPdf returns a non-empty PDF document', () async {
    final bytes = await buildDocumentPdf(
      DocDocument(
        id: 'doc-1',
        templateId: 'tpl-1',
        kind: 'contract',
        contactId: 'contact-1',
        handoverId: 'handover-1',
        title: '雪球交接协议',
        bodyFilled: '客户：阿花\n交接个体：雪球\n双方确认交付信息无误。',
        currency: 'CNY',
        status: 'draft',
        issuedAt: null,
        notes: '随附粮食与饲养说明',
        version: 1,
        contactName: '阿花',
      ),
    );

    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  testWidgets('ContractsHubPage creates template and shows it', (tester) async {
    final controller = ContractsController(
      repository: MemoryContractsRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: ContractsHubPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('合同与回执'), findsOneWidget);

    // Switch to 合同模板 tab (index 2)
    await tester.tap(find.byKey(const Key('doc-tab-c-templates')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('doc-fab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('doc-template-name')), '交接协议');
    await tester.tap(find.byKey(const Key('doc-template-submit')));
    await tester.pumpAndSettle();

    expect(find.text('交接协议'), findsWidgets);
  });

  testWidgets('ContractsHubPage keeps previews readable but hides writes', (
    tester,
  ) async {
    final controller = ContractsController(
      repository: MemoryContractsRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ContractsHubPage(controller: controller, canWrite: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('合同与回执'), findsOneWidget);
    expect(find.textContaining('当前角色可查看、复制和输出单据'), findsOneWidget);
    expect(find.byKey(const Key('doc-fab')), findsNothing);
    expect(find.byKey(const Key('doc-refresh')), findsOneWidget);
  });
}
