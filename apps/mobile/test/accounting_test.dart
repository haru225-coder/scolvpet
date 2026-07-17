import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/accounting/accounting.dart';

void main() {
  test('MemoryAccountingRepository income/expense and summary', () async {
    final repo = MemoryAccountingRepository();
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
    final summary = await repo.getSummary();
    expect(summary.incomeCents, 80000);
    expect(summary.expenseCents, 4500);
    expect(summary.netCents, 75500);
    expect(summary.recordCount, 2);
    expect(summary.byCategory.length, 2);
  });

  testWidgets('AccountingHubPage creates expense record', (tester) async {
    final controller = AccountingController(
      repository: MemoryAccountingRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: AccountingHubPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('财务收支'), findsOneWidget);

    await tester.tap(find.byKey(const Key('acct-fab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('acct-record-title')), '买垫料');
    await tester.enterText(find.byKey(const Key('acct-record-amount')), '32.5');
    await tester.tap(find.byKey(const Key('acct-record-submit')));
    await tester.pumpAndSettle();

    expect(find.text('买垫料'), findsOneWidget);
    expect(find.textContaining('32.50'), findsWidgets);
  });
}
