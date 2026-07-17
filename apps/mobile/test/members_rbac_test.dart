import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/members/members.dart';

void main() {
  test('memberCan matrix covers owner/viewer/breeder/caretaker', () {
    expect(memberCan('owner', MemberCapability.manageMembers), isTrue);
    expect(memberCan('viewer', MemberCapability.writeTask), isFalse);
    expect(memberCan('breeder', MemberCapability.writeBreeding), isTrue);
    expect(memberCan('breeder', MemberCapability.manageMembers), isFalse);
    expect(memberCan('caretaker', MemberCapability.writeEnclosure), isTrue);
    expect(memberCan('caretaker', MemberCapability.writeBreeding), isFalse);
    expect(memberCan('staff', MemberCapability.writeHamster), isTrue);
    expect(memberCan('staff', MemberCapability.writeBreeding), isFalse);
  });

  test('MemoryMemberRepository invite update revoke happy path', () async {
    final repo = MemoryMemberRepository();
    var list = await repo.listMembers();
    expect(list.single.role, 'owner');

    final invited = await repo.invite(
      const MemberInviteDraft(
        phone: '13900001111',
        role: 'caretaker',
        displayName: '小助手',
      ),
    );
    expect(invited.status, 'invited');
    expect(invited.role, 'caretaker');

    final updated = await repo.updateRole(
      memberId: invited.id,
      version: invited.version,
      role: 'breeder',
    );
    expect(updated.role, 'breeder');
    expect(updated.version, invited.version + 1);

    final revoked = await repo.revoke(
      memberId: updated.id,
      version: updated.version,
    );
    expect(revoked.status, 'revoked');
    list = await repo.listMembers();
    expect(list.where((m) => m.id == invited.id), isEmpty);
  });

  test('MemberController invite requires manage permission', () async {
    final repo = MemoryMemberRepository();
    final viewer = MemberController(repository: repo, currentRole: 'viewer');
    final denied = await viewer.invite(
      const MemberInviteDraft(phone: '13900002222', role: 'viewer'),
    );
    expect(denied, isFalse);

    final owner = MemberController(repository: repo, currentRole: 'owner');
    await owner.refresh();
    final ok = await owner.invite(
      const MemberInviteDraft(phone: '13900002222', role: 'viewer'),
    );
    expect(ok, isTrue);
    expect(owner.listState.data!.any((m) => m.phone == '13900002222'), isTrue);
  });

  testWidgets('MemberListPage invites a caretaker', (tester) async {
    final controller = MemberController(
      repository: MemoryMemberRepository(),
      currentRole: 'owner',
    );
    await tester.pumpWidget(
      MaterialApp(home: MemberListPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('成员与权限'), findsOneWidget);
    expect(find.textContaining('舍主'), findsWidgets);

    await tester.tap(find.byKey(const Key('member-invite')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('member-invite-phone')),
      '13700001111',
    );
    await tester.enterText(
      find.byKey(const Key('member-invite-name')),
      '饲养甲',
    );
    await tester.tap(find.byKey(const Key('member-invite-submit')));
    await tester.pumpAndSettle();

    expect(find.textContaining('饲养甲'), findsOneWidget);
    expect(find.textContaining('饲养员'), findsWidgets);
  });
}
