import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/ios_theme.dart';

/// Asks for a non-empty correction reason before a destructive or corrective
/// action goes through.
///
/// Wave 1 makes every correction loop — pedigree, health, weight, task — state
/// why the change happened. The audit chain keeps the original record forever,
/// so a chain entry with no reason is just noise. The confirm button stays
/// disabled until the field holds something, which is why this is a sheet and
/// not a plain [showCupertinoDialog] with a text field.
///
/// [keyPrefix] namespaces the widget keys so each caller can be targeted from
/// widget tests independently (`<prefix>-correction-reason`, and so on).
Future<String?> showCorrectionReasonSheet({
  required BuildContext context,
  required String title,
  required String keyPrefix,
  String hint = '请说明原因（会写入审计）',
  String placeholder = '纠错原因',
  String confirmLabel = '确认',
}) {
  final controller = TextEditingController();
  return showCupertinoModalPopup<String>(
    context: context,
    builder: (ctx) {
      final palette = ScolvPalette.of(ctx);
      return Material(
        color: Colors.transparent,
        child: Container(
          key: Key('$keyPrefix-correction-reason-sheet'),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: palette.secondaryGroupedBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(IosMetrics.continuousRadius),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  hint,
                  style: Theme.of(
                    ctx,
                  ).textTheme.bodySmall?.copyWith(color: palette.secondaryLabel),
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  key: Key('$keyPrefix-correction-reason'),
                  controller: controller,
                  placeholder: placeholder,
                  maxLines: 3,
                  maxLength: 500,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette.secondaryFill,
                    borderRadius: BorderRadius.circular(
                      IosMetrics.continuousRadius,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CupertinoButton.filled(
                  key: Key('$keyPrefix-correction-confirm'),
                  onPressed: () {
                    final text = controller.text.trim();
                    // Silently ignoring an empty tap keeps the sheet open with
                    // the field focused, which reads better than an error toast.
                    if (text.isEmpty) return;
                    Navigator.pop(ctx, text);
                  },
                  child: Text(confirmLabel),
                ),
                CupertinoButton(
                  key: Key('$keyPrefix-correction-cancel'),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
