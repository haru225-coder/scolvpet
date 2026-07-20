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
