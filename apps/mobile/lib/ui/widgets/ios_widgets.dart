import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/ios_theme.dart';

/// 仅在点击非输入控件区域时收起软键盘。
///
/// 输入控件会在手势竞争中优先处理自己的点击，因此不会影响点按输入框
/// 重新聚焦或切换字段；此包装器只负责页面空白和普通内容区域的点击。
class KeyboardDismissOnTap extends StatelessWidget {
  const KeyboardDismissOnTap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}

/// iOS 大标题（Large Title）
class IosLargeTitle extends StatelessWidget {
  const IosLargeTitle(this.title, {super.key, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // Taste §11.D lever 1: type hierarchy; 更大标题 + 更宽松的副标题行高。
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ScolvPalette.of(context).secondaryLabel,
                      height: 1.48,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 模块入口摘要：用一段清晰说明和少量真实指标代替开发态说明文字。
class IosModuleIntro extends StatelessWidget {
  const IosModuleIntro({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.metrics = const <IosModuleMetric>[],
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<IosModuleMetric> metrics;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    // UI V2：经营模块头卡统一奶油暖面
    final surface = Color.alphaBlend(
      palette.accentSoft.withValues(alpha: 0.4),
      palette.secondaryGroupedBackground,
    );
    return Container(
      margin: const EdgeInsets.fromLTRB(
        IosMetrics.pagePadding,
        12,
        IosMetrics.pagePadding,
        0,
      ),
      padding: const EdgeInsets.all(IosMetrics.cardPadding),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(IosMetrics.largeRadius),
        border: Border.all(
          color: palette.accent.withValues(alpha: 0.12),
          width: IosMetrics.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IosGlyph(icon: icon, size: 40, color: palette.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: palette.label,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.secondaryLabel,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            ],
          ),
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final width =
                    (constraints.maxWidth - (metrics.length - 1) * 8) /
                    metrics.length;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final metric in metrics)
                      SizedBox(
                        width: width.clamp(82, 160),
                        child: _IosModuleMetricTile(metric: metric),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class IosModuleMetric {
  const IosModuleMetric({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;
}

class _IosModuleMetricTile extends StatelessWidget {
  const _IosModuleMetricTile({required this.metric});

  final IosModuleMetric metric;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final color = metric.color ?? palette.accent;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              metric.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: palette.secondaryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// 语义状态徽标，统一成员、CRM、合同等经营模块的状态表达。
class IosStatusBadge extends StatelessWidget {
  const IosStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// iOS Settings 风格 section 小标题
class IosSectionHeader extends StatelessWidget {
  const IosSectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ScolvPalette.of(context).accent,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 分组 inset 面板容器（圆角 + 深层底色）
class IosGroupedSection extends StatelessWidget {
  const IosGroupedSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<Widget> children;
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) header!,
          Material(
            color: p.secondaryGroupedBackground,
            elevation: 1,
            shadowColor: p.label.withValues(alpha: 0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
              side: BorderSide(color: p.separator, width: IosMetrics.hairline),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: IosMetrics.tilePadding + 40 + 12,
                      ),
                      child: IosHairline(color: p.separator),
                    ),
                ],
              ],
            ),
          ),
          if (footer != null) ...[const SizedBox(height: 6), footer!],
        ],
      ),
    );
  }
}

class IosHairline extends StatelessWidget {
  const IosHairline({super.key, this.indent = 0, this.color});

  final double indent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent),
      height: IosMetrics.hairline,
      color: color ?? ScolvPalette.of(context).separator,
    );
  }
}

/// 轻量按压高亮（无 Material splash，避免顿挫感）。
class IosPressable extends StatefulWidget {
  const IosPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.pressedColor,
    this.enabled = true,
    this.haptic = true,
    this.focusNode,
    this.autofocus = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? pressedColor;
  final bool enabled;
  final bool haptic;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<IosPressable> createState() => _IosPressableState();
}

class _IosPressableState extends State<IosPressable> {
  bool _pressed = false;
  bool _focused = false;

  void _setPressed(bool value) {
    if (!widget.enabled || widget.onTap == null) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (!widget.enabled) return;
    if (widget.haptic) HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius;
    final palette = ScolvPalette.of(context);
    final pressed = widget.pressedColor ?? palette.tertiaryFill;
    final interactive = widget.onTap != null;
    final canActivate = widget.enabled && interactive;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : IosMetrics.press;
    return MergeSemantics(
      child: Semantics(
        container: true,
        button: interactive,
        enabled: canActivate,
        onTap: canActivate ? _handleTap : null,
        child: FocusableActionDetector(
          enabled: canActivate,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          mouseCursor: canActivate
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _handleTap();
                return null;
              },
            ),
          },
          onShowFocusHighlight: (value) {
            if (_focused == value) return;
            setState(() => _focused = value);
          },
          child: GestureDetector(
            excludeFromSemantics: true,
            behavior: HitTestBehavior.opaque,
            onTapDown: canActivate ? (_) => _setPressed(true) : null,
            onTapCancel: canActivate ? () => _setPressed(false) : null,
            onTapUp: canActivate ? (_) => _setPressed(false) : null,
            onTap: canActivate ? _handleTap : null,
            child: AnimatedScale(
              scale: _pressed ? 0.985 : 1.0,
              duration: duration,
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: _pressed ? pressed : Colors.transparent,
                  borderRadius: radius,
                  border: _focused
                      ? Border.all(color: palette.accent, width: 2)
                      : null,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// iOS 列表行
class IosListTile extends StatelessWidget {
  const IosListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.destructive = false,
    this.minHeight = IosMetrics.rowMinHeight,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool destructive;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: destructive ? IosColors.systemRed : p.label,
      fontWeight: FontWeight.w400,
    );
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: IosMetrics.tilePadding,
          vertical: IosMetrics.tileVerticalPadding,
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: titleStyle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (showChevron && onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 16,
                color: p.tertiaryLabel,
              ),
            ],
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return IosPressable(onTap: onTap, child: row);
  }
}

/// 图标圆角色块（Settings 风格 leading）
class IosGlyph extends StatelessWidget {
  const IosGlyph({super.key, required this.icon, this.color, this.size = 29});

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? ScolvPalette.of(context).accent;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.26),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.24),
          width: IosMetrics.hairline,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: effectiveColor, size: size * 0.55),
    );
  }
}

/// 统计卡（Health 风格数字）
class IosStatCard extends StatelessWidget {
  const IosStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
    this.emphasize = false,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;
  final bool emphasize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final effectiveAccent = accent ?? p.accent;
    final child = Container(
      padding: const EdgeInsets.all(IosMetrics.cardPadding),
      decoration: BoxDecoration(
        color: emphasize
            ? effectiveAccent.withValues(alpha: 0.14)
            : p.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        border: Border.all(
          color: emphasize
              ? effectiveAccent.withValues(alpha: 0.36)
              : p.separator.withValues(alpha: 0.45),
          width: IosMetrics.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: effectiveAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 13, color: effectiveAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: effectiveAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: -0.08,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style:
                (emphasize
                        ? Theme.of(context).textTheme.headlineLarge
                        : Theme.of(context).textTheme.headlineMedium)
                    ?.copyWith(
                      color: emphasize ? effectiveAccent : p.label,
                      height: 1.05,
                    ),
          ),
        ],
      ),
    );
    if (onTap == null) return child;
    return IosPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      child: child,
    );
  }
}

/// iOS 风格主按钮
class IosPrimaryButton extends StatelessWidget {
  const IosPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );
    return FilledButton(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      child: child,
    );
  }
}

/// 统一轻提示（浮动 SnackBar，走主题）
void showIosMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// 轻量 banner
class IosBanner extends StatelessWidget {
  const IosBanner({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String text;
  final Color color;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
          width: IosMetrics.hairline,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: color),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// 底栏上方 hairline 包装，贴近 iOS TabBar
class IosTabBarChrome extends StatelessWidget {
  const IosTabBarChrome({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.tabBarBackground,
        border: Border(
          top: BorderSide(color: p.separator, width: IosMetrics.hairline),
        ),
        boxShadow: [
          BoxShadow(
            color: p.label.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 加载指示（Cupertino）
class IosLoading extends StatelessWidget {
  const IosLoading({super.key, this.showSkeleton = false, this.lines = 3});

  final bool showSkeleton;
  final int lines;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: '正在加载',
    child: Center(
      child: showSkeleton
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CupertinoActivityIndicator(radius: 11),
                    const SizedBox(height: 18),
                    for (var index = 0; index < lines; index++) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: index.isEven ? 1 : 0.72,
                          child: Container(
                            height: index == 0 ? 54 : 42,
                            decoration: BoxDecoration(
                              color: ScolvPalette.of(context).tertiaryFill,
                              borderRadius: BorderRadius.circular(
                                IosMetrics.continuousRadius,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (index < lines - 1) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            )
          : const CupertinoActivityIndicator(radius: 12),
    ),
  );
}

/// iOS 风格分段控制器（替代 Material TabBar）。
class IosSegmentedControl<T extends Object> extends StatelessWidget {
  const IosSegmentedControl({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  final List<IosSegmentTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return CupertinoSlidingSegmentedControl<T>(
      groupValue: selected,
      onValueChanged: (v) {
        if (v != null) onSelect(v);
      },
      thumbColor: p.secondaryGroupedBackground,
      backgroundColor: p.tertiaryFill,
      children: {
        for (final t in tabs)
          t.value: Padding(
            key: t.key,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              t.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected == t.value ? p.label : p.secondaryLabel,
              ),
            ),
          ),
      },
    );
  }
}

class IosSegmentTab<T extends Object> {
  const IosSegmentTab({required this.value, required this.label, this.key});
  final T value;
  final String label;
  final Key? key;
}

/// 显示 iOS 风格 AlertDialog。
Future<bool?> showIosAlert({
  required BuildContext context,
  required String title,
  String? message,
  String cancelLabel = '取消',
  String confirmLabel = '确认',
  bool destructive = false,
}) {
  return showCupertinoDialog<bool>(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: destructive,
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// 显示 iOS 风格 ActionSheet（底部弹出选项）。
Future<T?> showIosActionSheet<T>({
  required BuildContext context,
  String? title,
  String? message,
  required List<IosActionItem<T>> items,
  String cancelLabel = '取消',
}) {
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (ctx) => CupertinoActionSheet(
      title: title == null ? null : Text(title),
      message: message == null ? null : Text(message),
      actions: [
        for (final item in items)
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, item.value),
            child: Text(item.label),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(ctx),
        child: Text(cancelLabel),
      ),
    ),
  );
}

class IosActionItem<T> {
  const IosActionItem({required this.value, required this.label});
  final T value;
  final String label;
}

/// 让可为空的选项值与“取消”保持区分。
class _IosPickerChoice<T> {
  const _IosPickerChoice(this.value);
  final T value;
}

/// iOS 风格选择字段（替代 DropdownButtonFormField）。
/// 所有选项统一从底部弹出 CupertinoPicker，避免短列表和长列表出现两套交互。
class IosPickerField<T> extends StatelessWidget {
  const IosPickerField({
    super.key,
    required this.label,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.displayName,
    this.hint = '请选择',
    this.enabled = true,
  });

  final bool enabled;

  final String label;
  final List<IosPickerItem<T>> items;
  final T? selected;
  final ValueChanged<T?> onSelected;
  final String Function(T)? displayName;
  final String hint;

  String get _currentLabel {
    if (selected == null) return hint;
    final item = items.firstWhere(
      (i) => i.value == selected,
      orElse: () => IosPickerItem(value: selected as T, label: hint),
    );
    return displayName?.call(item.value) ?? item.label;
  }

  Future<void> _pick(BuildContext context) async {
    if (!enabled || items.isEmpty) return;
    final p = ScolvPalette.of(context);
    final initialIndex = selected == null
        ? 0
        : items
              .indexWhere((i) => i.value == selected)
              .clamp(0, items.length - 1);
    final ctrl = FixedExtentScrollController(initialItem: initialIndex);
    try {
      final choice = await showCupertinoModalPopup<_IosPickerChoice<T>>(
        context: context,
        builder: (ctx) => Container(
          color: p.secondaryGroupedBackground,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: p.separator)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('取消', style: TextStyle(color: p.label)),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          final idx = ctrl.selectedItem;
                          Navigator.pop(
                            ctx,
                            _IosPickerChoice<T>(items[idx].value),
                          );
                        },
                        child: Text(
                          '完成',
                          style: TextStyle(
                            color: p.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 216,
                  child: CupertinoPicker(
                    scrollController: ctrl,
                    itemExtent: 36,
                    onSelectedItemChanged: (_) {},
                    children: [
                      for (final item in items)
                        Center(
                          child: Text(
                            item.label,
                            style: TextStyle(color: p.label, fontSize: 17),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
      if (choice != null) onSelected(choice.value);
    } finally {
      ctrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final selected = this.selected != null;
    return IosPressable(
      onTap: enabled ? () => _pick(context) : null,
      enabled: enabled,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: IosMetrics.tilePadding,
          vertical: IosMetrics.tileVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: enabled ? p.secondaryGroupedBackground : p.secondaryFill,
          borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
          border: Border.all(
            color: enabled
                ? p.separator.withValues(alpha: 0.5)
                : p.separator.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 2),
                  Text(
                    _currentLabel,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: selected ? p.label : p.tertiaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_down, size: 16, color: p.tertiaryLabel),
          ],
        ),
      ),
    );
  }
}

class IosPickerItem<T> {
  const IosPickerItem({required this.value, required this.label});
  final T value;
  final String label;
}
