import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/ios_theme.dart';

/// 柔和入场动画：淡入 + 轻微上滑。
/// 适合列表项、卡片、页面主体内容。
class BearFadeIn extends StatefulWidget {
  const BearFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration,
    this.slideOffset = 16,
  });

  final Widget child;
  final Duration delay;
  final Duration? duration;
  final double slideOffset;

  @override
  State<BearFadeIn> createState() => _BearFadeInState();
}

class _BearFadeInState extends State<BearFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _slide;
  Timer? _delayTimer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? IosMetrics.spring,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<double>(
      begin: widget.slideOffset,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// 列表 stagger 入场。
/// 对每个子元素自动加一个递增 delay。
class BearStaggered extends StatelessWidget {
  const BearStaggered({
    super.key,
    required this.children,
    this.baseDelay = Duration.zero,
    this.step = Duration.zero,
    this.slideOffset = 16,
  });

  final List<Widget> children;
  final Duration baseDelay;
  final Duration step;
  final double slideOffset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++)
          BearFadeIn(
            delay: baseDelay + step * i,
            slideOffset: slideOffset,
            child: children[i],
          ),
      ],
    );
  }
}

/// 页面主体内容的柔和入场。
/// 常用于进入新页面时包裹整个 ListView / Column。
class BearPageEntrance extends StatelessWidget {
  const BearPageEntrance({super.key, required this.child, this.delay});

  final Widget child;
  final Duration? delay;

  @override
  Widget build(BuildContext context) => BearFadeIn(
    delay: delay ?? const Duration(milliseconds: 80),
    slideOffset: 24,
    child: child,
  );
}
