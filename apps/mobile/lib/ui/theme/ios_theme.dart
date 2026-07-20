import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 语义色板（随 light/dark 切换）。
/// 业务代码优先 `ScolvPalette.of(context)`；状态色可继续用 [IosColors] 常量。
@immutable
class ScolvPalette extends ThemeExtension<ScolvPalette> {
  const ScolvPalette({
    required this.groupedBackground,
    required this.secondaryGroupedBackground,
    required this.systemBackground,
    required this.secondarySystemBackground,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.quaternaryLabel,
    required this.separator,
    required this.opaqueSeparator,
    required this.fill,
    required this.secondaryFill,
    required this.tertiaryFill,
    required this.accent,
    required this.accentSoft,
    required this.tabBarBackground,
    required this.navBarBackground,
  });

  final Color groupedBackground;
  final Color secondaryGroupedBackground;
  final Color systemBackground;
  final Color secondarySystemBackground;
  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;
  final Color quaternaryLabel;
  final Color separator;
  final Color opaqueSeparator;
  final Color fill;
  final Color secondaryFill;
  final Color tertiaryFill;
  final Color accent;
  final Color accentSoft;
  final Color tabBarBackground;
  final Color navBarBackground;

  static const light = ScolvPalette(
    groupedBackground: Color(0xfff5f4f2),
    secondaryGroupedBackground: Color(0xfffffdfb),
    systemBackground: Color(0xfff5f4f2),
    secondarySystemBackground: Color(0xfffffdfb),
    label: Color(0xff24211f),
    secondaryLabel: Color(0xff706a66),
    tertiaryLabel: Color(0xff96908b),
    quaternaryLabel: Color(0xffbbb5b0),
    separator: Color(0xffded9d5),
    opaqueSeparator: Color(0xffd2ccc7),
    fill: Color(0x2424211f),
    secondaryFill: Color(0x1724211f),
    tertiaryFill: Color(0x0f24211f),
    accent: Color(0xffc77852),
    accentSoft: Color(0xffffeee4),
    tabBarBackground: Color(0xf7fffdfb),
    navBarBackground: Color(0xf7fffdfb),
  );

  static const dark = ScolvPalette(
    groupedBackground: Color(0xff090b0c),
    secondaryGroupedBackground: Color(0xff151718),
    systemBackground: Color(0xff090b0c),
    secondarySystemBackground: Color(0xff151718),
    label: Color(0xfff5eee2),
    secondaryLabel: Color(0xffaaa49c),
    tertiaryLabel: Color(0xff76716a),
    quaternaryLabel: Color(0xff4c4944),
    separator: Color(0x263b3d3d),
    opaqueSeparator: Color(0xff3b3d3d),
    fill: Color(0x35f5eee2),
    secondaryFill: Color(0x24f5eee2),
    tertiaryFill: Color(0x14f5eee2),
    accent: Color(0xffd4926a),
    accentSoft: Color(0x24d4926a),
    tabBarBackground: Color(0xf0090b0c),
    navBarBackground: Color(0xee090b0c),
  );

  static ScolvPalette of(BuildContext context) {
    return Theme.of(context).extension<ScolvPalette>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  ScolvPalette copyWith({
    Color? groupedBackground,
    Color? secondaryGroupedBackground,
    Color? systemBackground,
    Color? secondarySystemBackground,
    Color? label,
    Color? secondaryLabel,
    Color? tertiaryLabel,
    Color? quaternaryLabel,
    Color? separator,
    Color? opaqueSeparator,
    Color? fill,
    Color? secondaryFill,
    Color? tertiaryFill,
    Color? accent,
    Color? accentSoft,
    Color? tabBarBackground,
    Color? navBarBackground,
  }) {
    return ScolvPalette(
      groupedBackground: groupedBackground ?? this.groupedBackground,
      secondaryGroupedBackground:
          secondaryGroupedBackground ?? this.secondaryGroupedBackground,
      systemBackground: systemBackground ?? this.systemBackground,
      secondarySystemBackground:
          secondarySystemBackground ?? this.secondarySystemBackground,
      label: label ?? this.label,
      secondaryLabel: secondaryLabel ?? this.secondaryLabel,
      tertiaryLabel: tertiaryLabel ?? this.tertiaryLabel,
      quaternaryLabel: quaternaryLabel ?? this.quaternaryLabel,
      separator: separator ?? this.separator,
      opaqueSeparator: opaqueSeparator ?? this.opaqueSeparator,
      fill: fill ?? this.fill,
      secondaryFill: secondaryFill ?? this.secondaryFill,
      tertiaryFill: tertiaryFill ?? this.tertiaryFill,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      tabBarBackground: tabBarBackground ?? this.tabBarBackground,
      navBarBackground: navBarBackground ?? this.navBarBackground,
    );
  }

  @override
  ScolvPalette lerp(ThemeExtension<ScolvPalette>? other, double t) {
    if (other is! ScolvPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return ScolvPalette(
      groupedBackground: l(groupedBackground, other.groupedBackground),
      secondaryGroupedBackground: l(
        secondaryGroupedBackground,
        other.secondaryGroupedBackground,
      ),
      systemBackground: l(systemBackground, other.systemBackground),
      secondarySystemBackground: l(
        secondarySystemBackground,
        other.secondarySystemBackground,
      ),
      label: l(label, other.label),
      secondaryLabel: l(secondaryLabel, other.secondaryLabel),
      tertiaryLabel: l(tertiaryLabel, other.tertiaryLabel),
      quaternaryLabel: l(quaternaryLabel, other.quaternaryLabel),
      separator: l(separator, other.separator),
      opaqueSeparator: l(opaqueSeparator, other.opaqueSeparator),
      fill: l(fill, other.fill),
      secondaryFill: l(secondaryFill, other.secondaryFill),
      tertiaryFill: l(tertiaryFill, other.tertiaryFill),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      tabBarBackground: l(tabBarBackground, other.tabBarBackground),
      navBarBackground: l(navBarBackground, other.navBarBackground),
    );
  }
}

/// 兼容旧代码的浅色常量 + 状态色（红绿橙等两模式通用）。
abstract final class IosColors {
  static const Color systemBackground = Color(0xfff2f2f7);
  static const Color secondarySystemBackground = Color(0xffffffff);
  static const Color tertiarySystemBackground = Color(0xfff2f2f7);
  static const Color groupedBackground = Color(0xfff2f2f7);
  static const Color secondaryGroupedBackground = Color(0xffffffff);

  static const Color label = Color(0xff000000);
  static const Color secondaryLabel = Color(0x993c3c43);
  static const Color tertiaryLabel = Color(0x4d3c3c43);
  static const Color quaternaryLabel = Color(0x2e3c3c43);

  static const Color separator = Color(0x5c3c3c43);
  static const Color opaqueSeparator = Color(0xffc6c6c8);
  static const Color fill = Color(0x33787880);
  static const Color secondaryFill = Color(0x29787880);
  static const Color tertiaryFill = Color(0x1f787880);

  static const Color accent = Color(0xffc77852);
  static const Color accentSoft = Color(0xfffff1e8);
  static const Color systemBlue = Color(0xff007aff);
  static const Color systemGreen = Color(0xff34c759);
  static const Color systemRed = Color(0xffff3b30);
  static const Color systemOrange = Color(0xffff9500);
  static const Color systemTeal = Color(0xff5ac8fa);
  static const Color systemIndigo = Color(0xff5856d6);
  static const Color systemPurple = Color(0xffaf52de);
  static const Color systemGray = Color(0xff8e8e93);
  static const Color systemGray5 = Color(0xffe5e5ea);
  static const Color systemGray6 = Color(0xfff2f2f7);

  static const Color tabBarBackground = Color(0xf9f9f9f9);
  static const Color navBarBackground = Color(0xf9f9f9f9);
}

abstract final class IosMetrics {
  static const double continuousRadius = 18;
  static const double largeRadius = 24;
  static const double pillRadius = 980;
  static const double pagePadding = 16;
  // Taste §4.7: 增加呼吸感，分组间距放宽一档。
  static const double sectionGap = 28;
  static const double listGap = 14;
  static const double tilePadding = 18;
  static const double tileVerticalPadding = 14;
  static const double cardPadding = 18;
  static const double bottomSafePadding = 36;
  static const double rowMinHeight = 48;
  static const double hairline = 0.5;
  static const Duration spring = Duration(milliseconds: 280);
  static const Duration press = Duration(milliseconds: 90);
  static const Duration page = Duration(milliseconds: 320);
}

/// 全局弹性滚动 + 去掉 Android 边缘光晕。
class IosScrollBehavior extends MaterialScrollBehavior {
  const IosScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

Route<T> iosPageRoute<T extends Object?>({
  required WidgetBuilder builder,
  RouteSettings? settings,
  bool fullscreenDialog = false,
}) {
  return CupertinoPageRoute<T>(
    builder: builder,
    settings: settings,
    fullscreenDialog: fullscreenDialog,
  );
}

ThemeData buildIosTheme([Brightness brightness = Brightness.light]) {
  final palette = brightness == Brightness.dark
      ? ScolvPalette.dark
      : ScolvPalette.light;
  final isDark = brightness == Brightness.dark;
  final base = ColorScheme.fromSeed(
    seedColor: palette.accent,
    brightness: brightness,
    primary: palette.accent,
    onPrimary: palette.groupedBackground,
    surface: palette.secondaryGroupedBackground,
    onSurface: palette.label,
  );
  final textTheme = _iosTextTheme(palette);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: base,
    extensions: <ThemeExtension<dynamic>>[palette],
    scaffoldBackgroundColor: palette.groupedBackground,
    canvasColor: palette.groupedBackground,
    bottomAppBarTheme: BottomAppBarThemeData(
      color: palette.groupedBackground,
      surfaceTintColor: Colors.transparent,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: palette.tertiaryFill,
    splashColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    dividerColor: palette.separator,
    dividerTheme: DividerThemeData(
      color: palette.separator,
      thickness: IosMetrics.hairline,
      space: IosMetrics.hairline,
    ),
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      backgroundColor: palette.navBarBackground,
      foregroundColor: palette.label,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 17,
        letterSpacing: -0.41,
        color: palette.label,
      ),
      iconTheme: IconThemeData(color: palette.accent, size: 22),
      actionsIconTheme: IconThemeData(color: palette.accent, size: 22),
      toolbarHeight: 44,
    ),
    cardTheme: CardThemeData(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: palette.secondaryGroupedBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    listTileTheme: ListTileThemeData(
      dense: false,
      minVerticalPadding: 10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      iconColor: palette.accent,
      textColor: palette.label,
      titleTextStyle: textTheme.bodyLarge?.copyWith(
        fontSize: 17,
        letterSpacing: -0.41,
        fontWeight: FontWeight.w400,
        color: palette.label,
      ),
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(
        fontSize: 15,
        color: palette.secondaryLabel,
        letterSpacing: -0.24,
      ),
      shape: const RoundedRectangleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? palette.tertiaryFill
          : palette.secondarySystemBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        borderSide: BorderSide(color: palette.accent, width: 1.5),
      ),
      hintStyle: textTheme.bodyLarge?.copyWith(color: palette.tertiaryLabel),
      labelStyle: textTheme.bodyMedium?.copyWith(color: palette.secondaryLabel),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.accent,
        foregroundColor: palette.groupedBackground,
        disabledBackgroundColor: palette.tertiaryFill,
        disabledForegroundColor: palette.tertiaryLabel,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        ),
        textStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          letterSpacing: -0.41,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.accent,
      foregroundColor: palette.groupedBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.accent,
        side: BorderSide(color: palette.opaqueSeparator),
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          letterSpacing: -0.24,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.accent,
        textStyle: textTheme.bodyLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: palette.secondaryFill,
      selectedColor: palette.accentSoft,
      labelStyle: textTheme.labelMedium!.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: palette.label,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
        side: BorderSide.none,
      ),
      side: BorderSide.none,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor: palette.tabBarBackground,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      // P0-1: 轻量 selected，避免大面积胶囊抢视觉
      indicatorColor: palette.accent.withValues(alpha: 0.10),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 10,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          letterSpacing: 0.1,
          color: selected ? palette.accent : palette.secondaryLabel,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? palette.accent : palette.secondaryLabel,
        );
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark
          ? palette.secondaryGroupedBackground
          : const Color(0xe61c1c1e),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: isDark ? palette.label : Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: palette.accent,
      circularTrackColor: palette.tertiaryFill,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.secondaryGroupedBackground;
          }
          return palette.secondaryFill;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.label;
          }
          return palette.secondaryLabel;
        }),
        side: const WidgetStatePropertyAll(BorderSide.none),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        textStyle: WidgetStatePropertyAll(
          textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: brightness,
      primaryColor: palette.accent,
      barBackgroundColor: palette.navBarBackground,
      scaffoldBackgroundColor: palette.groupedBackground,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
    platform: TargetPlatform.iOS,
  );
}

TextTheme _iosTextTheme(ScolvPalette palette) {
  // 使用平台系统字体，避免 Apple 私有字体名在 Android 与测试环境变成缺字方框。
  final base = TextStyle(color: palette.label, decoration: TextDecoration.none);
  return TextTheme(
    displayLarge: base.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.08,
    ),
    displayMedium: base.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      height: 1.10,
    ),
    headlineLarge: base.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      height: 1.10,
    ),
    headlineMedium: base.copyWith(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      height: 1.12,
    ),
    headlineSmall: base.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      height: 1.14,
    ),
    titleLarge: base.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.18,
    ),
    titleMedium: base.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.24,
      height: 1.26,
    ),
    titleSmall: base.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.16,
      height: 1.28,
    ),
    bodyLarge: base.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.16,
      height: 1.52,
    ),
    bodyMedium: base.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.08,
      height: 1.56,
      color: palette.secondaryLabel,
    ),
    bodySmall: base.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      height: 1.48,
      color: palette.secondaryLabel,
    ),
    labelLarge: base.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.16,
      height: 1.4,
    ),
    labelMedium: base.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.0,
      height: 1.38,
      color: palette.secondaryLabel,
    ),
    labelSmall: base.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.05,
      height: 1.36,
      color: palette.tertiaryLabel,
    ),
  );
}
