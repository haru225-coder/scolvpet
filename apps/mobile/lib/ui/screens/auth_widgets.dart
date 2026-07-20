part of '../screens.dart';

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(IosMetrics.largeRadius),
        border: Border.all(color: palette.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
            child: AspectRatio(
              aspectRatio: 1.78,
              child: Image.asset(
                BearAssets.loginHero,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Center(child: BearMascot(size: 78)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: palette.accentSoft,
              borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
            ),
            child: Text(
              '金丝熊繁育',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.accent,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '熊舍管家',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '建档、繁育、谱系与备份，一处完成。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.secondaryLabel,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      IosPrimaryButton(label: label, icon: icon, onPressed: onPressed);
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: IosBanner(
      icon: CupertinoIcons.exclamationmark_circle,
      text: text,
      color: IosColors.systemRed,
    ),
  );
}
