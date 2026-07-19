import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/ios_theme.dart';

/// Taste 资产路径（Grok2API 手绘插图，见 assets/TASTE_VISUAL_SYSTEM.md）
abstract final class BearAssets {
  static const mascotHappy = 'assets/brand/mascot_happy.png';
  static const mascotSleepy = 'assets/brand/mascot_sleepy.png';
  static const mascotWorried = 'assets/brand/mascot_worried.png';
  static const appIcon = 'assets/brand/app_icon.png';
  static const loginHero = 'assets/brand/login_hero.png';
  static const emptyCare = 'assets/illustrations/empty_care.png';
  static const emptyAttention = 'assets/illustrations/empty_attention.png';
  static const emptyList = 'assets/illustrations/empty_list.png';
  static const loadingWake = 'assets/illustrations/loading_wake.png';
  static const onboardingSetup = 'assets/illustrations/onboarding_setup.png';

  static const icToday = 'assets/icons/ic_today.png';
  static const icHamster = 'assets/icons/ic_hamster.png';
  static const icEnclosure = 'assets/icons/ic_enclosure.png';
  static const icBreeding = 'assets/icons/ic_breeding.png';
  static const icLitter = 'assets/icons/ic_litter.png';
  static const icTasks = 'assets/icons/ic_tasks.png';
  static const icWeight = 'assets/icons/ic_weight.png';
  static const icCalendar = 'assets/icons/ic_calendar.png';
  static const icData = 'assets/icons/ic_data.png';
  static const icMine = 'assets/icons/ic_mine.png';

  static String mascotFor(BearMood mood) => switch (mood) {
    BearMood.happy => mascotHappy,
    BearMood.sleepy => mascotSleepy,
    BearMood.worried => mascotWorried,
  };
}

enum BearMood { happy, sleepy, worried }

/// 熊舍管家品牌装饰：优先用生成插图，缺资源时回退矢量绘制。
class BearMascot extends StatelessWidget {
  const BearMascot({super.key, this.size = 88, this.mood = BearMood.happy});

  final double size;
  final BearMood mood;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.asset(
          BearAssets.mascotFor(mood),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => _DrawnMascot(size: size, mood: mood),
        ),
      ),
    );
  }
}

/// 仓鼠头像：有远端头像时展示图片，缺失/加载失败时回退到稳定的首字占位。
/// 统一在列表、详情和笼舍看板复用，后续接入媒体上传时只需传入 imageUrl。
class HamsterAvatar extends StatelessWidget {
  const HamsterAvatar({
    super.key,
    required this.label,
    this.imageUrl,
    this.imageBytes,
    this.size = 44,
    this.statusColor,
  });

  final String label;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double size;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final ring = statusColor ?? palette.accent;
    final trimmed = label.trim();
    final initial = trimmed.isEmpty
        ? ''
        : String.fromCharCode(trimmed.runes.first);
    final fallback = _HamsterAvatarFallback(
      initial: initial,
      size: size,
      color: ring,
    );
    final image = imageUrl?.trim();
    return Semantics(
      image: true,
      label: '$trimmed头像',
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ring.withValues(alpha: 0.16),
          border: Border.all(color: ring.withValues(alpha: 0.48), width: 1),
        ),
        child: ClipOval(
          child: imageBytes != null && imageBytes!.isNotEmpty
              ? Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => fallback,
                )
              : image == null || image.isEmpty
              ? fallback
              : Image.network(
                  image,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => fallback,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : fallback,
                ),
        ),
      ),
    );
  }
}

class _HamsterAvatarFallback extends StatelessWidget {
  const _HamsterAvatarFallback({
    required this.initial,
    required this.size,
    required this.color,
  });

  final String initial;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = initial.isEmpty ? null : initial;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.18)!,
            color.withValues(alpha: 0.78),
          ],
        ),
      ),
      child: Center(
        child: text == null
            ? Icon(CupertinoIcons.paw, size: size * 0.42, color: Colors.white)
            : Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

/// 功能图标瓷砖（Taste 生成手绘 icon）
class BearIconTile extends StatelessWidget {
  const BearIconTile({
    super.key,
    required this.asset,
    this.size = 40,
    this.padding = 6,
    this.selected = false,
  });

  final String asset;
  final double size;
  final double padding;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return AnimatedContainer(
      duration: IosMetrics.press,
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: selected ? p.accent.withValues(alpha: 0.18) : p.accentSoft,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: p.accent.withValues(alpha: selected ? 0.32 : 0.14),
          width: IosMetrics.hairline,
        ),
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) =>
            Icon(CupertinoIcons.paw, color: p.accent, size: size * 0.45),
      ),
    );
  }
}

/// 缺少专属水彩图标时使用的同体系语义图标瓷砖。
///
/// 经营模块不能为了“有图”而复用错误的仓鼠、今日或数据图标；Cupertino
/// 图标在这里沿用同一底色、边框和圆角，保持视觉一致并保证语义准确。
class BearGlyphTile extends StatelessWidget {
  const BearGlyphTile({
    super.key,
    required this.icon,
    this.semanticLabel,
    this.size = 40,
    this.padding = 6,
    this.selected = false,
  });

  final IconData icon;
  final String? semanticLabel;
  final double size;
  final double padding;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return AnimatedContainer(
      duration: IosMetrics.press,
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: selected ? p.accent.withValues(alpha: 0.18) : p.accentSoft,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: p.accent.withValues(alpha: selected ? 0.32 : 0.14),
          width: IosMetrics.hairline,
        ),
      ),
      child: Icon(
        icon,
        semanticLabel: semanticLabel,
        color: p.accent,
        size: size - padding * 2,
      ),
    );
  }
}

/// Tab / 导航用小图标（无底砖，仅图）
class BearNavIcon extends StatelessWidget {
  const BearNavIcon({
    super.key,
    required this.asset,
    this.size = 26,
    this.selected = false,
  });

  final String asset;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: selected ? 1 : 0.72,
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Icon(
          CupertinoIcons.circle,
          size: size * 0.85,
          color: selected
              ? ScolvPalette.of(context).accent
              : ScolvPalette.of(context).secondaryLabel,
        ),
      ),
    );
  }
}

class _DrawnMascot extends StatelessWidget {
  const _DrawnMascot({required this.size, required this.mood});
  final double size;
  final BearMood mood;

  @override
  Widget build(BuildContext context) {
    final ear = size * 0.28;
    final p = ScolvPalette.of(context);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          left: size * 0.06,
          top: size * 0.02,
          child: _Ear(size: ear),
        ),
        Positioned(
          right: size * 0.06,
          top: size * 0.02,
          child: _Ear(size: ear),
        ),
        Container(
          width: size * 0.82,
          height: size * 0.82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(p.accent, Colors.white, 0.18)!,
                p.accent,
                Color.lerp(p.accent, const Color(0xff8b4a2f), 0.25)!,
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: size * 0.26,
                left: size * 0.2,
                child: _Eye(size: size * 0.07, blink: mood == BearMood.sleepy),
              ),
              Positioned(
                top: size * 0.26,
                right: size * 0.2,
                child: _Eye(size: size * 0.07, blink: mood == BearMood.sleepy),
              ),
              Positioned(
                top: size * 0.38,
                child: Container(
                  width: size * 0.16,
                  height: size * 0.12,
                  decoration: BoxDecoration(
                    color: const Color(0xffffd6c2),
                    borderRadius: BorderRadius.circular(size * 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: size * 0.18,
                child: CustomPaint(
                  size: Size(size * 0.22, size * 0.1),
                  painter: _SmilePainter(
                    color: Colors.white.withValues(alpha: 0.92),
                    happy: mood != BearMood.worried,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Ear extends StatelessWidget {
  const _Ear({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.accent,
        border: Border.all(color: p.accentSoft, width: 2),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.45,
        height: size * 0.45,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xffffd6c2),
        ),
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size, this.blink = false});
  final double size;
  final bool blink;

  @override
  Widget build(BuildContext context) {
    if (blink) {
      return Container(
        width: size * 1.4,
        height: 2,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.45,
        height: size * 0.45,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xff3c2a22),
        ),
      ),
    );
  }
}

class _SmilePainter extends CustomPainter {
  _SmilePainter({required this.color, required this.happy});
  final Color color;
  final bool happy;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final path = Path();
    if (happy) {
      path.moveTo(0, size.height * 0.2);
      path.quadraticBezierTo(
        size.width / 2,
        size.height * 1.1,
        size.width,
        size.height * 0.2,
      );
    } else {
      path.moveTo(0, size.height * 0.7);
      path.quadraticBezierTo(
        size.width / 2,
        size.height * -0.1,
        size.width,
        size.height * 0.7,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SmilePainter oldDelegate) =>
      oldDelegate.happy != happy || oldDelegate.color != color;
}

/// 品牌软背景（登录/空态用）
class BearSoftBackdrop extends StatelessWidget {
  const BearSoftBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final glow = Color.alphaBlend(
      p.accent.withValues(alpha: 0.08),
      p.groupedBackground,
    );
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.2, -0.8),
                radius: 1.2,
                colors: [glow, p.groupedBackground],
                stops: const [0, 0.86],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// 暖萌空态卡
class BearEmptyCard extends StatelessWidget {
  const BearEmptyCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.mood = BearMood.happy,
    this.illustration,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final BearMood mood;
  final String? illustration;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final art = illustration;
    final p = ScolvPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.secondaryGroupedBackground,
          borderRadius: BorderRadius.circular(IosMetrics.largeRadius),
          border: Border.all(color: p.separator, width: IosMetrics.hairline),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
              child: SizedBox(
                width: 96,
                height: 96,
                child: art != null
                    ? Image.asset(
                        art,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) =>
                            BearMascot(size: 64, mood: mood),
                      )
                    : BearMascot(size: 64, mood: mood),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: p.secondaryLabel,
                      height: 1.35,
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 轻弹入场（空态/品牌用）
class BearPopIn extends StatefulWidget {
  const BearPopIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<BearPopIn> createState() => _BearPopInState();
}

class _BearPopInState extends State<BearPopIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: IosMetrics.spring,
  );
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  Timer? _delayTimer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _delayTimer?.cancel();
      _started = true;
      _controller.value = 1;
      return;
    }
    if (_started) return;
    _started = true;
    _delayTimer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1).animate(_scale),
        child: widget.child,
      ),
    );
  }
}
