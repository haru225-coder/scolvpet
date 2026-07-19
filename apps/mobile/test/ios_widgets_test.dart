import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scolvpet_mobile/features/genetic/option_or_custom_field.dart';
import 'package:scolvpet_mobile/ui/theme/ios_theme.dart';
import 'package:scolvpet_mobile/ui/widgets/ios_widgets.dart';

void main() {
  testWidgets('IosPressable exposes button semantics and keyboard activation', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildIosTheme(),
        home: Scaffold(
          body: IosPressable(
            key: const Key('accessible-pressable'),
            autofocus: true,
            haptic: false,
            onTap: () => taps++,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('打开详情'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('accessible-pressable')), findsOneWidget);
    expect(find.text('打开详情'), findsOneWidget);

    await tester.tap(find.byKey(const Key('accessible-pressable')));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(taps, greaterThanOrEqualTo(2));
  });

  testWidgets('IosPickerField returns a value from a long picker', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildIosTheme(),
        home: Scaffold(
          body: IosPickerField<int>(
            label: '表型',
            items: [
              for (var i = 0; i < 12; i++)
                IosPickerItem(value: i, label: '选项 $i'),
            ],
            selected: selected,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('请选择'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPicker), findsOneWidget);

    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();
    expect(selected, isNotNull);
  });

  testWidgets('IosPickerField uses the same wheel picker for short lists', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildIosTheme(),
        home: Scaffold(
          body: IosPickerField<String>(
            label: '品种',
            items: const [
              IosPickerItem(value: 'golden', label: '金色'),
              IosPickerItem(value: 'black', label: '黑色'),
            ],
            selected: selected,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('请选择'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPicker), findsOneWidget);
    expect(find.byType(CupertinoActionSheet), findsNothing);

    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();
    expect(selected, 'golden');
  });

  testWidgets('IosPickerField keeps the value when the picker is cancelled', (
    tester,
  ) async {
    var callbackCount = 0;
    String? callbackValue = 'black';
    await tester.pumpWidget(
      MaterialApp(
        theme: buildIosTheme(),
        home: Scaffold(
          body: IosPickerField<String?>(
            label: '表型',
            selected: 'black',
            items: const [
              IosPickerItem(value: 'black', label: '黑色'),
              IosPickerItem(value: null, label: '未选择'),
            ],
            onSelected: (value) {
              callbackCount++;
              callbackValue = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('黑色'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(callbackCount, 0);
    expect(callbackValue, 'black');
  });

  testWidgets(
    'KeyboardDismissOnTap unfocuses an input when tapping blank space',
    (tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildIosTheme(),
          home: KeyboardDismissOnTap(
            child: Scaffold(
              body: Column(
                children: [
                  TextField(
                    key: const Key('keyboard-dismiss-input'),
                    focusNode: focusNode,
                  ),
                  const SizedBox(height: 120, width: double.infinity),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('keyboard-dismiss-input')));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      // 点击输入框下方仍在可视区内的空白区域，避免键盘顶起布局后坐标越界。
      await tester.tapAt(const Offset(20, 100));
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);
      focusNode.dispose();
    },
  );

  testWidgets(
    'OptionOrCustomField keeps hand entry open after selecting custom',
    (tester) async {
      String? value;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildIosTheme(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => OptionOrCustomField(
                label: '表型',
                options: const ['黑色'],
                value: value,
                onChanged: (next) {
                  value = next;
                  setState(() {});
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('（未选）'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CupertinoPicker), const Offset(0, -96));
      await tester.pumpAndSettle();
      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), '奶油');
      expect(value, '奶油');
    },
  );
}
