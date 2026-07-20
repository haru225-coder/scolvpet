part of '../screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.state});

  final AppState state;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = controller.text.trim();
    final phone = raw.startsWith('+')
        ? raw
        : (raw.startsWith('86') ? '+$raw' : '+86$raw');
    controller.text = phone;
    await widget.state.requestCode(phone);
  }

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    return Scaffold(
      body: BearSoftBackdrop(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: widget.state,
            builder: (context, _) {
              final busy = widget.state.busy;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  const BearPopIn(child: _BrandPanel()),
                  const SizedBox(height: IosMetrics.sectionGap),
                  const IosSectionHeader('中国大陆手机号'),
                  TextField(
                    controller: controller,
                    enabled: !busy,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!busy) _submit();
                    },
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: '请输入手机号',
                      prefixIcon: Icon(CupertinoIcons.phone, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PrimaryButton(
                    label: busy ? '发送中…' : '获取验证码',
                    icon: CupertinoIcons.chat_bubble_text,
                    onPressed: busy ? null : _submit,
                  ),
                  if (widget.state.lastError != null)
                    _ErrorText(widget.state.lastError!),
                  const SizedBox(height: 16),
                  Text(
                    '首次登录会创建个人熊舍',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.secondaryLabel,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

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
              color: palette.label,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '专业金丝熊繁育管理 · 专业数据 × 行业深度 × 温暖陪伴',
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
