part of 'screens.dart';

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
