part of '../screens.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, required this.state});

  final AppState state;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late final TextEditingController nameController;
  int _step = 0;

  static const _steps = [
    _SetupStep(label: '名称', subtitle: '熊舍名称'),
    _SetupStep(label: '规则', subtitle: '基础规则'),
    _SetupStep(label: '开始', subtitle: '准备就绪'),
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.state.organization?.name == '我的熊舍'
          ? ''
          : widget.state.organization?.name,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _complete();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _complete() async {
    await widget.state.completeSetup(
      nameController.text.trim().isEmpty ? '我的熊舍' : nameController.text.trim(),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final disabled = widget.state.offline || widget.state.busy;
    return Scaffold(
      body: BearSoftBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              0,
              12,
              0,
              IosMetrics.bottomSafePadding,
            ),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: IosMetrics.pagePadding,
                ),
                child: IosLargeTitle(
                  '创建个人熊舍',
                  subtitle: '先安顿好舍名与基础资料，再进入繁殖者工作台',
                ),
              ),
              const SizedBox(height: IosMetrics.listGap),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: IosMetrics.pagePadding,
                ),
                child: _SetupStepIndicator(steps: _steps, current: _step),
              ),
              const SizedBox(height: IosMetrics.sectionGap),
              AnimatedSwitcher(
                duration: IosMetrics.spring,
                transitionBuilder: (child, animation) {
                  final offset = animation.status == AnimationStatus.reverse
                      ? const Offset(-0.06, 0)
                      : const Offset(0.06, 0);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: offset,
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  key: ValueKey<int>(_step),
                  padding: const EdgeInsets.symmetric(
                    horizontal: IosMetrics.pagePadding,
                  ),
                  child: _buildStep(disabled),
                ),
              ),
              const SizedBox(height: IosMetrics.sectionGap),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: IosMetrics.pagePadding,
                ),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: disabled ? null : _back,
                          icon: const Icon(
                            CupertinoIcons.chevron_back,
                            size: 16,
                          ),
                          label: const Text('上一步'),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _PrimaryButton(
                        label: widget.state.busy
                            ? '创建中…'
                            : _step == _steps.length - 1
                            ? '创建并进入'
                            : '下一步',
                        icon: _step == _steps.length - 1
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.chevron_forward,
                        onPressed: disabled ? null : _next,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.state.offline)
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    IosMetrics.pagePadding,
                    IosMetrics.sectionGap,
                    IosMetrics.pagePadding,
                    0,
                  ),
                  child: IosBanner(
                    icon: CupertinoIcons.cloud,
                    text: '暂时离线，联网后会自动继续',
                    color: IosColors.systemOrange,
                  ),
                ),
              if (widget.state.lastError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    IosMetrics.pagePadding,
                    IosMetrics.listGap,
                    IosMetrics.pagePadding,
                    0,
                  ),
                  child: IosBanner(
                    icon: CupertinoIcons.exclamationmark_circle,
                    text: widget.state.lastError!,
                    color: IosColors.systemRed,
                  ),
                ),
              const SizedBox(height: IosMetrics.sectionGap),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: IosMetrics.pagePadding,
                ),
                child: Text(
                  '熊舍名称随时可以修改，资料也可以之后再慢慢补齐。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.secondaryLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(bool disabled) {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(IosMetrics.largeRadius),
              child: Image.asset(
                BearAssets.onboardingSetup,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: IosMetrics.sectionGap),
            const IosSectionHeader('熊舍名称'),
            TextField(
              controller: nameController,
              enabled: !disabled,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _next(),
              decoration: const InputDecoration(
                hintText: '例如：雪团熊舍',
                prefixIcon: Icon(CupertinoIcons.house, size: 20),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IosSectionHeader('基础设置'),
            IosGroupedSection(
              children: [
                IosListTile(
                  leading: const BearGlyphTile(
                    icon: CupertinoIcons.settings,
                    semanticLabel: '繁育规则',
                    size: 32,
                    padding: 4,
                  ),
                  title: widget.state.systemRules.isEmpty
                      ? '正在准备繁育规则'
                      : '金丝熊繁育规则',
                  subtitle: '配对、孕期和断奶会有合适的默认值',
                  showChevron: false,
                ),
              ],
            ),
            const SizedBox(height: IosMetrics.listGap),
            Text(
              '创建后会自动准备一套适合日常繁育的规则，之后也可以在设置里调整。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IosSectionHeader('准备开始'),
            IosGroupedSection(
              children: [
                IosListTile(
                  leading: const Icon(CupertinoIcons.checkmark_seal),
                  title: '先从首页开始',
                  subtitle: '仓鼠、笼舍和繁育记录都可以随时补充',
                  showChevron: false,
                ),
              ],
            ),
          ],
        );
    }
    return const SizedBox.shrink();
  }
}

@immutable
class _SetupStep {
  const _SetupStep({required this.label, required this.subtitle});
  final String label;
  final String subtitle;
}

class _SetupStepIndicator extends StatelessWidget {
  const _SetupStepIndicator({required this.steps, required this.current});

  final List<_SetupStep> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                _StepDot(index: i, current: current),
                const SizedBox(height: 6),
                Text(
                  steps[i].label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: i <= current ? palette.label : palette.tertiaryLabel,
                  ),
                ),
              ],
            ),
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: i < current ? palette.accent : palette.separator,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.current});

  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final completed = index < current;
    final active = index == current;
    final size = active ? 28.0 : 24.0;
    return AnimatedContainer(
      duration: IosMetrics.press,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: completed || active ? palette.accent : palette.secondaryFill,
        shape: BoxShape.circle,
        border: active ? Border.all(color: palette.accentSoft, width: 3) : null,
      ),
      alignment: Alignment.center,
      child: completed
          ? const Icon(CupertinoIcons.checkmark, size: 14, color: Colors.white)
          : Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: completed || active ? Colors.white : palette.label,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
