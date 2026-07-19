import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/accounting/accounting.dart';

void main() {
  test('accounting amount labels use Chinese RMB formatting', () {
    expect(formatAccountingAmount(123456), '¥1,234.56');
    expect(formatAccountingAmount(-905), '-¥9.05');
    expect(
      AccountingRecord(
        id: 'r1',
        entryType: 'income',
        amountCents: 123456,
        currency: 'CNY',
        title: '交付收入',
        occurredAt: DateTime.utc(2026, 7, 19),
        version: 1,
      ).amountLabel,
      '+¥1,234.56',
    );
  });

  test('MemoryAccountingRepository income/expense and summary', () async {
    final occurredAt = DateTime.utc(2026, 7, 18, 9, 30);
    final repo = MemoryAccountingRepository(
      contacts: const [AccountingContactOption(id: 'contact-1', name: '林小姐')],
    );
    final incomeCat = await repo.createCategory(
      const AccountingCategoryDraft(entryType: 'income', name: '交付收入'),
    );
    final expenseCat = await repo.createCategory(
      const AccountingCategoryDraft(entryType: 'expense', name: '饲料'),
    );
    await repo.createRecord(
      AccountingRecordDraft(
        entryType: 'income',
        amountCents: 80000,
        title: '雪球交付',
        categoryId: incomeCat.id,
        contactId: 'contact-1',
        occurredAt: occurredAt,
      ),
    );
    await repo.createRecord(
      AccountingRecordDraft(
        entryType: 'expense',
        amountCents: 4500,
        title: '买饲料',
        categoryId: expenseCat.id,
      ),
    );
    final records = await repo.listRecords();
    expect(records.length, 2);
    final income = records.firstWhere((item) => item.isIncome);
    expect(income.contactName, '林小姐');
    expect(income.occurredAt, occurredAt);
    final summary = await repo.getSummary();
    expect(summary.incomeCents, 80000);
    expect(summary.expenseCents, 4500);
    expect(summary.netCents, 75500);
    expect(summary.recordCount, 2);
    expect(summary.byCategory.length, 2);
  });

  testWidgets('AccountingHubPage creates expense record', (tester) async {
    final repository = MemoryAccountingRepository(
      contacts: const [AccountingContactOption(id: 'contact-1', name: '林小姐')],
    );
    final controller = AccountingController(repository: repository);
    await tester.pumpWidget(
      MaterialApp(home: AccountingHubPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('财务收支'), findsOneWidget);

    await tester.tap(find.byKey(const Key('acct-fab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acct-record-contact')), findsOneWidget);
    expect(find.byKey(const Key('acct-record-occurred-at')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('acct-record-title')), '买垫料');
    await tester.enterText(find.byKey(const Key('acct-record-amount')), '0');
    await tester.ensureVisible(find.byKey(const Key('acct-record-submit')));
    await tester.tap(find.byKey(const Key('acct-record-submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acct-record-amount-error')), findsOneWidget);
    final titleField = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('acct-record-title')),
        matching: find.byType(EditableText),
      ),
    );
    expect(titleField.controller.text, '买垫料');

    await tester.enterText(find.byKey(const Key('acct-record-amount')), '32.5');
    await tester.tap(find.byKey(const Key('acct-record-contact')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CupertinoPicker), const Offset(0, -80));
    await tester.pumpAndSettle();
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('acct-record-submit')));
    await tester.tap(find.byKey(const Key('acct-record-submit')));
    await tester.pumpAndSettle();

    expect(find.text('买垫料'), findsOneWidget);
    expect(find.text('-¥32.50'), findsOneWidget);
    final records = await repository.listRecords();
    expect(records, hasLength(1));
    expect(records.single.contactId, 'contact-1');
    expect(records.single.contactName, '林小姐');
  });

  testWidgets('Accounting tabs keep FAB label in sync', (tester) async {
    final controller = AccountingController(
      repository: MemoryAccountingRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: AccountingHubPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('acct-tab-categories')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('acct-fab')),
        matching: find.text('新建分类'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('acct-tab-summary')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('acct-fab')),
        matching: find.text('记一笔'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Accounting read-only mode does not bootstrap categories', (
    tester,
  ) async {
    final repository = MemoryAccountingRepository();
    final controller = AccountingController(repository: repository);
    await tester.pumpWidget(
      MaterialApp(
        home: AccountingHubPage(controller: controller, canWrite: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('acct-fab')), findsNothing);
    expect(find.textContaining('只读'), findsOneWidget);
    expect(await repository.listCategories(), isEmpty);
  });
}
