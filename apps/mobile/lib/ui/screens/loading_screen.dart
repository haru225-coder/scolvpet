part of '../screens.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BearSoftBackdrop(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BearPopIn(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(IosMetrics.largeRadius),
                child: Image.asset(
                  BearAssets.loadingWake,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const BearMascot(size: 96),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '熊舍管家',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '正在唤醒小仓鼠…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ScolvPalette.of(context).secondaryLabel,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      ),
    ),
  );
}
