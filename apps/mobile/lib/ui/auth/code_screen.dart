part of '../screens.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key, required this.state});

  final AppState state;

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  Timer? _timer;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || widget.state.busy) return;
    await widget.state.resendCode();
    if (!mounted) return;
    if (widget.state.lastError == null) {
      controller.clear();
      _startCooldown();
      showIosMessage(context, '验证码已重新发送');
    }
  }

  Future<void> _submit() async {
    await widget.state.login(controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('输入验证码'),
        leading: BackButton(onPressed: widget.state.backToLogin),
      ),
      body: BearSoftBackdrop(
        child: AnimatedBuilder(
          animation: widget.state,
          builder: (context, _) {
            final busy = widget.state.busy;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                const Center(child: BearMascot(size: 72, mood: BearMood.happy)),
                const SizedBox(height: 12),
                Text(
                  '已发送至 ${widget.state.phone ?? ''}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: !busy,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    letterSpacing: 8,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    if (value.length == 6 && !busy) {
                      _submit();
                    }
                  },
                  onSubmitted: (_) {
                    if (!busy) _submit();
                  },
                  decoration: const InputDecoration(
                    hintText: '••••••',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: (_secondsLeft > 0 || busy) ? null : _resend,
                    child: Text(
                      _secondsLeft > 0 ? '重新发送 ${_secondsLeft}s' : '重新发送',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _PrimaryButton(
                  label: busy ? '验证中…' : '验证并登录',
                  icon: CupertinoIcons.arrow_right_circle_fill,
                  onPressed: busy ? null : _submit,
                ),
                if (widget.state.lastError != null)
                  _ErrorText(widget.state.lastError!),
              ],
            );
          },
        ),
      ),
    );
  }
}
