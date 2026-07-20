import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scolvpet_api/scolvpet_api.dart';

import '../core/app_state.dart';
import '../core/app_services.dart';
import '../features/i2/i2.dart';
import '../features/i6/data_center.dart';
import '../features/breeding/breeding.dart';
import '../features/litter/litter.dart';
import '../features/calendar/calendar.dart';
import '../features/health/health.dart';
import '../features/accounting/accounting.dart';
import '../features/contracts/contracts.dart';
import '../features/crm/crm.dart';
import '../features/genetic/genetic.dart';
import '../features/home_widget/home_widget.dart';
import '../features/members/members.dart';
import '../features/assistant/assistant.dart';
import '../features/growth/growth.dart';
import '../features/paywall/paywall.dart';
import '../features/pedigree/pedigree.dart';
import '../features/public_site/public_site.dart';
import '../features/shell/home_overview.dart';
import '../features/stud/stud.dart';
import '../features/tasks/tasks.dart';
import '../features/weight/weight_batch_page.dart';
import 'theme/ios_theme.dart';
import 'widgets/bear_brand.dart';
import 'widgets/bear_motion.dart';
import 'widgets/ios_widgets.dart';

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
                child: IosLargeTitle('创建个人熊舍', subtitle: '先把你的熊舍整理起来'),
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

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.services,
  });

  final AppServices services;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  late final GrowthController _growthController;
  late final AssistantController _assistantController;

  void _goTab(int value) {
    if (value == index) return;
    HapticFeedback.selectionClick();
    setState(() => index = value);
  }

  @override
  void initState() {
    super.initState();
    _growthController = GrowthController(repository: widget.services.growthRepository);
    _assistantController = AssistantController(
      repository: widget.services.assistantRepository,
    );
    widget.services.i2Controller.setWritePermission(
      widget.services.state.hasCapability(AppCapability.writeHamster),
    );
    widget.services.i2Controller.restore();
    widget.services.breedingController.refresh();
    widget.services.taskController.initializeNotifications().then((_) {
      return widget.services.taskController.refresh();
    });
  }

  @override
  void dispose() {
    _growthController.dispose();
    _assistantController.dispose();
    super.dispose();
  }

  String? get _speciesRuleVersionId =>
      widget.services.state.ownerRules.isEmpty ? null : widget.services.state.ownerRules.first.id;

  bool _canWrite(String capability) =>
      !widget.services.state.offline && widget.services.state.hasCapability(capability);

  void _showWriteRestricted(String action) {
    final message = widget.services.state.offline || widget.services.i2Controller.offline
        ? '当前离线，只能查看已同步记录'
        : '${memberRoleLabel(widget.services.state.currentMemberRole)}可查看记录，但没有$action权限';
    showIosMessage(context, message);
  }

  bool _requireWrite(String capability, String action) {
    if (_canWrite(capability)) return true;
    _showWriteRestricted(action);
    return false;
  }

  void _showMissingRule() {
    showIosMessage(context, '请先在“我的 → 物种规则”复制熊舍规则');
  }

  Future<void> _openHamsterEditor({I2Hamster? existing}) async {
    if (!_requireWrite(AppCapability.writeHamster, '编辑仓鼠档案')) return;
    final speciesRuleVersionId = _speciesRuleVersionId;
    if (speciesRuleVersionId == null) {
      _showMissingRule();
      return;
    }
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (pageContext) => HamsterEditorPage(
          controller: widget.services.i2Controller,
          speciesRuleVersionId: speciesRuleVersionId,
          existing: existing,
          onSaved: () => Navigator.of(pageContext).pop(true),
        ),
      ),
    );
    if (saved == true && mounted) showIosMessage(context, '仓鼠档案已保存');
    await widget.services.i2Controller.retry();
    if (existing != null) {
      await widget.services.i2Controller.loadHamsterDetail(existing.id);
    }
  }

  Future<void> _openBatchHamsterEditor() async {
    if (!_requireWrite(AppCapability.writeHamster, '批量建档')) return;
    final speciesRuleVersionId = _speciesRuleVersionId;
    if (speciesRuleVersionId == null) {
      _showMissingRule();
      return;
    }
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (pageContext) => BatchHamsterEditorPage(
          controller: widget.services.i2Controller,
          speciesRuleVersionId: speciesRuleVersionId,
          onSaved: () => Navigator.of(pageContext).pop(true),
        ),
      ),
    );
    if (saved == true && mounted) showIosMessage(context, '仓鼠档案已保存');
    await widget.services.i2Controller.retry();
  }

  Future<void> _openWeightEntry(String hamsterId) async {
    if (!_requireWrite(AppCapability.writeWeight, '记录体重')) return;
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (pageContext) => WeightEntryPage(
          controller: widget.services.i2Controller,
          hamsterId: hamsterId,
          onSaved: () => Navigator.of(pageContext).pop(true),
        ),
      ),
    );
    if (saved == true && mounted) showIosMessage(context, '体重已保存');
    await widget.services.i2Controller.loadHamsterDetail(hamsterId);
    await widget.services.i2Controller.retry();
  }

  Future<void> _openBatchWeight() async {
    if (!_requireWrite(AppCapability.writeWeight, '批量称重')) return;
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (pageContext) => WeightBatchPage(
          controller: widget.services.i2Controller,
          onSaved: () => Navigator.of(pageContext).pop(true),
        ),
      ),
    );
    if (saved == true && mounted) showIosMessage(context, '体重已保存');
    await widget.services.i2Controller.retry();
  }

  void _openGeneticHub({GeneticHubPrefill? prefill}) {
    final hamsters =
        widget.services.i2Controller.snapshotState.data?.hamsters ?? const <I2Hamster>[];
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => GeneticHubPage(
          controller: GeneticController(repository: widget.services.geneticRepository),
          hamsters: hamsters,
          breedingController: widget.services.breedingController,
          ruleVersionId: _speciesRuleVersionId,
          prefill: prefill,
        ),
      ),
    );
  }

  Future<void> _openHamsterDetail(I2Hamster hamster) async {
    final canEditHamster = _canWrite(AppCapability.writeHamster);
    final canWriteWeight = _canWrite(AppCapability.writeWeight);
    final healthController = HealthController(
      repository: widget.services.healthRepository,
      taskRepository: widget.services.taskController.repository,
    );
    await Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (detailContext) => HamsterDetailPage(
          controller: widget.services.i2Controller,
          hamsterId: hamster.id,
          taskController: widget.services.taskController,
          healthController: healthController,
          onEdit: canEditHamster
              ? () {
                  final current =
                      widget.services.i2Controller.hamsterDetailState.data?.hamster ??
                      hamster;
                  _openHamsterEditor(existing: current);
                }
              : null,
          onAddWeight: canWriteWeight
              ? () => _openWeightEntry(hamster.id)
              : null,
          onOpenGenetic: () async {
            final current =
                widget.services.i2Controller.hamsterDetailState.data?.hamster ?? hamster;
            final all =
                widget.services.i2Controller.snapshotState.data?.hamsters ??
                const <I2Hamster>[];
            final mate = await showMatePickerSheet(
              context: detailContext,
              self: current,
              allHamsters: all,
            );
            if (mate == null) return;
            if (!context.mounted) return;
            _openGeneticHub(prefill: prefillForPair(current, mate));
          },
          onOpenPedigree: () {
            final current =
                widget.services.i2Controller.hamsterDetailState.data?.hamster ?? hamster;
            Navigator.of(detailContext).push<void>(
              iosPageRoute(
                builder: (_) => PedigreePage(
                  controller: PedigreeController(
                    repository: widget.services.pedigreeRepository,
                  ),
                  hamsterId: current.id,
                  hamsterLabel: current.displayName,
                  generations: 3,
                ),
              ),
            );
          },
          onOpenHealth: () {
            final current =
                widget.services.i2Controller.hamsterDetailState.data?.hamster ?? hamster;
            Navigator.of(detailContext)
                .push<void>(
                  iosPageRoute(
                    builder: (_) => HealthQuickPage(
                      controller: healthController,
                      hamsterId: current.id,
                      hamsterLabel: current.displayName,
                      canWrite: _canWrite(AppCapability.writeHealth),
                    ),
                  ),
                )
                .then((_) => healthController.loadForHamster(current.id));
          },
        ),
      ),
    );
    healthController.dispose();
    await widget.services.i2Controller.retry();
    await widget.services.taskController.refresh();
  }

  Future<void> _openEnclosureAction(
    I2Enclosure enclosure, {
    required bool cleaning,
  }) async {
    if (!_requireWrite(AppCapability.writeEnclosure, '管理笼舍')) return;
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (pageContext) => cleaning
            ? EnclosureCarePage(
                controller: widget.services.i2Controller,
                enclosureId: enclosure.id,
                enclosureVersion: enclosure.version,
                onSaved: () => Navigator.of(pageContext).pop(true),
              )
            : MoveHamsterPage(
                controller: widget.services.i2Controller,
                enclosureId: enclosure.id,
                enclosureVersion: enclosure.version,
                onSaved: () => Navigator.of(pageContext).pop(true),
              ),
      ),
    );
    if (saved == true && mounted) {
      showIosMessage(context, cleaning ? '清洁记录已保存' : '移笼 / 入住已提交');
    }
    await widget.services.i2Controller.loadEnclosureDetail(enclosure.id);
    await widget.services.i2Controller.loadCleaningHistory(enclosure.id);
    await widget.services.i2Controller.retry();
  }

  Future<void> _openEnclosureDetail(I2Enclosure enclosure) async {
    await Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => EnclosureDetailPage(
          controller: widget.services.i2Controller,
          enclosureId: enclosure.id,
          canWrite: _canWrite(AppCapability.writeEnclosure),
          onMove: () {
            final current =
                widget.services.i2Controller.enclosureDetailState.data?.enclosure ??
                enclosure;
            _openEnclosureAction(current, cleaning: false);
          },
          onCare: () {
            final current =
                widget.services.i2Controller.enclosureDetailState.data?.enclosure ??
                enclosure;
            _openEnclosureAction(current, cleaning: true);
          },
        ),
      ),
    );
    await widget.services.i2Controller.retry();
  }

  void _openLitters() {
    final snapshot = widget.services.i2Controller.snapshotState.data;
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => LitterBoardListPage(
          controller: widget.services.litterBoardController,
          enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
          canWrite: _canWrite(AppCapability.writeLitter),
          offline: widget.services.state.offline || widget.services.i2Controller.offline,
          lastSyncLabel: widget.services.i2Controller.lastSyncLabel,
        ),
      ),
    );
  }

  void _openDataCenter() {
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => DataCenterPage(
          i2Controller: widget.services.i2Controller,
          repository: widget.services.dataCenterRepository,
          canWrite: _canWrite(AppCapability.writeImport),
          onOpenMediaLibrary: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _goTab(1);
          },
          onOpenPublicShares: () {
            Navigator.of(context).push<void>(
              iosPageRoute(
                builder: (_) => PublicSiteEditorPage(
                  controller: PublicSiteController(
                    repository: widget.services.publicSiteRepository,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openTasks() {
    final snapshot = widget.services.i2Controller.snapshotState.data;
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => TaskListPage(
          controller: widget.services.taskController,
          canWrite: _canWrite(AppCapability.writeTask),
          offline: widget.services.state.offline || widget.services.i2Controller.offline,
          organizationId: widget.services.state.organization?.id,
          hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
          enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
        ),
      ),
    );
  }

  void _openGrowth() {
    final snapshot = widget.services.i2Controller.snapshotState.data;
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => GrowthHubPage(
          controller: _growthController,
          hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
          onOpenCrm: _openCrm,
          canWrite: _canWrite(AppCapability.writeGrowth),
        ),
      ),
    );
  }

  void _openCalendar() {
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => CalendarMonthPage(
          taskController: widget.services.taskController,
          breedingController: widget.services.breedingController,
          i2Controller: widget.services.i2Controller,
        ),
      ),
    );
  }

  void _openEnclosures() {
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => EnclosureGridPage(
          controller: widget.services.i2Controller,
          onOpenDetail: _openEnclosureDetail,
          canWrite: _canWrite(AppCapability.writeEnclosure),
          onCreate: _openEnclosureEditor,
        ),
      ),
    );
  }

  Future<void> _openEnclosureEditor() async {
    if (!_requireWrite(AppCapability.writeEnclosure, '新增笼舍')) return;
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (_) => EnclosureEditorPage(
          controller: widget.services.i2Controller,
          canWrite: _canWrite(AppCapability.writeEnclosure),
        ),
      ),
    );
    if (saved == true && mounted) showIosMessage(context, '笼盒已添加');
  }

  void _openCrm() {
    final snapshot = widget.services.i2Controller.snapshotState.data;
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => CrmHubPage(
          controller: CrmController(repository: widget.services.crmRepository),
          hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
          canWrite: _canWrite(AppCapability.writeCrm),
          onOpenDocuments: (handover, contact, hamster) {
            _openContracts(
              launchContext: ContractsLaunchContext(
                contactId: handover.contactId,
                contactName: contact?.name ?? handover.contactName,
                handoverId: handover.id,
                hamsterId: handover.hamsterId,
                hamsterName: hamster?.displayName ?? handover.hamsterName,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openContracts({ContractsLaunchContext? launchContext}) {
    final snapshot = widget.services.i2Controller.snapshotState.data;
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => ContractsHubPage(
          controller: ContractsController(
            repository: widget.services.contractsRepository,
          ),
          crmController: CrmController(repository: widget.services.crmRepository),
          hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
          launchContext: launchContext,
          canWrite: _canWrite(AppCapability.writeDocuments),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeOverviewPage(
        state: widget.services.state,
        controller: widget.services.i2Controller,
        taskController: widget.services.taskController,
        onOpenHamsters: () => _goTab(1),
        onOpenEnclosures: _openEnclosures,
        onOpenBreeding: () => _goTab(3),
        onOpenLitters: _openLitters,
        onOpenDataCenter: _openDataCenter,
        onOpenTasks: _openTasks,
        onOpenCalendar: _openCalendar,
        onCreateHamster: () => _openHamsterEditor(),
        onOpenBatchWeight: _openBatchWeight,
      ),
      HamsterListPage(
        controller: widget.services.i2Controller,
        onOpenDetail: _openHamsterDetail,
        onCreate: _canWrite(AppCapability.writeHamster)
            ? () => _openHamsterEditor()
            : null,
        onBatchCreate: _canWrite(AppCapability.writeHamster)
            ? _openBatchHamsterEditor
            : null,
        onOpenLitters: _openLitters,
      ),
      AssistantPage(
        controller: _assistantController,
        i2Controller: widget.services.i2Controller,
        taskController: widget.services.taskController,
        onOpenTasks: _openTasks,
        onCreateTask: _canWrite(AppCapability.writeTask)
            ? () {
                final snapshot = widget.services.i2Controller.snapshotState.data;
                Navigator.of(context).push<void>(
                  iosPageRoute(
                    builder: (_) => TaskComposerPage(
                      controller: widget.services.taskController,
                      canWrite: true,
                      organizationId: widget.services.state.organization?.id,
                      hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
                      enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
                    ),
                  ),
                );
              }
            : null,
        onOpenHamsters: () => _goTab(1),
        onOpenHamsterDetail: _openHamsterDetail,
        onOpenEnclosures: _openEnclosures,
        onOpenEnclosureDetail: _openEnclosureDetail,
        onOpenGrowth: _openGrowth,
        onOpenDataCenter: _openDataCenter,
        onOpenTaskDraft: _canWrite(AppCapability.writeTask)
            ? (draft) {
                final snapshot = widget.services.i2Controller.snapshotState.data;
                Navigator.of(context).push<void>(
                  iosPageRoute(
                    builder: (_) => TaskComposerPage(
                      controller: widget.services.taskController,
                      canWrite: true,
                      organizationId: widget.services.state.organization?.id,
                      hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
                      enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
                      initialDraft: draft,
                    ),
                  ),
                );
              }
            : null,
      ),
      AnimatedBuilder(
        animation: widget.services.i2Controller,
        builder: (context, _) {
          final snapshot = widget.services.i2Controller.snapshotState.data;
          return BreedingHubPage(
            controller: widget.services.breedingController,
            hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
            enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
            ruleVersionId: _speciesRuleVersionId,
            onOpenLitters: _openLitters,
            canWrite: _canWrite(AppCapability.writeBreeding),
            geneticRepository: widget.services.geneticRepository,
            onOpenGenetic: _openGeneticHub,
          );
        },
      ),
      _MinePage(
        state: widget.services.state,
        onOpenDataCenter: _openDataCenter,
        onOpenMembers: () {
          Navigator.of(context).push<void>(
            iosPageRoute(
              builder: (_) => MemberListPage(
                controller: MemberController(
                  repository: widget.services.memberRepository,
                  currentRole: widget.services.state.currentMemberRole,
                ),
              ),
            ),
          );
        },
        onOpenCrm: _openCrm,
        onOpenContracts: _openContracts,
        onOpenAccounting: () {
          Navigator.of(context).push<void>(
            iosPageRoute(
              builder: (_) => AccountingHubPage(
                controller: AccountingController(
                  repository: widget.services.accountingRepository,
                ),
                canWrite: _canWrite(AppCapability.writeAccounting),
              ),
            ),
          );
        },
        onOpenTodayWidget: widget.services.todayWidgetPublisher == null
            ? null
            : () {
                Navigator.of(context).push<void>(
                  iosPageRoute(
                    builder: (_) => TodayWidgetPreviewPage(
                      taskController: widget.services.taskController,
                      publisher: widget.services.todayWidgetPublisher!,
                    ),
                  ),
                );
              },
        onOpenGenetic: () => _openGeneticHub(),
        onOpenPaywall: () {
          Navigator.of(context).push<void>(
            iosPageRoute(
              builder: (_) => PaywallPage(
                controller: PaywallController(
                  repository: widget.services.paywallRepository,
                ),
              ),
            ),
          );
        },
        onOpenPublicSite: () {
          Navigator.of(context).push<void>(
            iosPageRoute(
              builder: (_) => PublicSiteEditorPage(
                controller: PublicSiteController(
                  repository: widget.services.publicSiteRepository,
                ),
              ),
            ),
          );
        },
        onOpenAssistant: () => _goTab(2),
        onOpenStud: () {
          Navigator.of(context).push<void>(
            iosPageRoute(
              builder: (_) => StudHubPage(
                controller: StudController(repository: widget.services.studRepository),
              ),
            ),
          );
        },
      ),
    ];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: IosTabBarChrome(
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: _goTab,
          animationDuration: IosMetrics.spring,
          destinations: const [
            NavigationDestination(
              icon: BearNavIcon(asset: BearAssets.icToday),
              selectedIcon: BearNavIcon(
                asset: BearAssets.icToday,
                selected: true,
              ),
              label: '今日',
            ),
            NavigationDestination(
              icon: BearNavIcon(asset: BearAssets.icHamster),
              selectedIcon: BearNavIcon(
                asset: BearAssets.icHamster,
                selected: true,
              ),
              label: '仓鼠',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.sparkles),
              selectedIcon: Icon(CupertinoIcons.sparkles),
              label: '管家',
            ),
            NavigationDestination(
              icon: BearNavIcon(asset: BearAssets.icBreeding),
              selectedIcon: BearNavIcon(
                asset: BearAssets.icBreeding,
                selected: true,
              ),
              label: '繁育',
            ),
            NavigationDestination(
              icon: BearNavIcon(asset: BearAssets.icMine),
              selectedIcon: BearNavIcon(
                asset: BearAssets.icMine,
                selected: true,
              ),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}

class RulePage extends StatelessWidget {
  const RulePage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('物种规则')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!state.hasCapability(AppCapability.manageMembers)) ...[
            const IosBanner(
              icon: CupertinoIcons.lock_shield,
              color: IosColors.systemOrange,
              text: '当前角色可查看物种规则，复制和维护规则仅由舍主完成。',
            ),
            const SizedBox(height: 16),
          ],
          const _SectionTitle(title: '当前熊舍规则'),
          if (state.ownerRules.isEmpty)
            const _EmptyState(label: '尚未复制规则模板')
          else
            ...state.ownerRules.map(
              (rule) => _RuleCard(rule: rule, owner: true),
            ),
          const SizedBox(height: 24),
          const _SectionTitle(title: '系统模板'),
          ...state.systemRules.map(
            (rule) => _RuleCard(
              rule: rule,
              owner: false,
              onCopy:
                  state.offline ||
                      !state.hasCapability(AppCapability.manageMembers)
                  ? null
                  : () async {
                      await state.copyRule(rule);
                      if (context.mounted) {
                        showIosMessage(context, '已复制为熊舍规则');
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _MinePage extends StatelessWidget {
  const _MinePage({
    required this.state,
    this.onOpenDataCenter,
    this.onOpenMembers,
    this.onOpenCrm,
    this.onOpenContracts,
    this.onOpenAccounting,
    this.onOpenTodayWidget,
    this.onOpenGenetic,
    this.onOpenPaywall,
    this.onOpenPublicSite,
    this.onOpenAssistant,
    this.onOpenStud,
  });

  final AppState state;
  final VoidCallback? onOpenDataCenter;
  final VoidCallback? onOpenMembers;
  final VoidCallback? onOpenCrm;
  final VoidCallback? onOpenContracts;
  final VoidCallback? onOpenAccounting;
  final VoidCallback? onOpenTodayWidget;
  final VoidCallback? onOpenGenetic;
  final VoidCallback? onOpenPaywall;
  final VoidCallback? onOpenPublicSite;
  final VoidCallback? onOpenAssistant;
  final VoidCallback? onOpenStud;

  @override
  Widget build(BuildContext context) {
    final organization = state.organization;
    return BearSoftBackdrop(
      child: BearPageEntrance(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            0,
            12,
            0,
            IosMetrics.bottomSafePadding,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: IosMetrics.pagePadding,
              ),
              child: IosLargeTitle(
                '我的',
                subtitle:
                    '${organization?.name ?? '熊舍'} · ${memberRoleLabel(state.currentMemberRole)}',
                trailing: const BearMascot(size: 44, mood: BearMood.happy),
              ),
            ),
            const SizedBox(height: 12),
            IosGroupedSection(
              header: const IosSectionHeader('数据'),
              children: [
                IosListTile(
                  leading: const BearIconTile(
                    asset: BearAssets.icData,
                    size: 32,
                    padding: 4,
                  ),
                  title: '数据中心',
                  subtitle: state.hasCapability(AppCapability.writeImport)
                      ? '整理、导入和备份你的资料'
                      : '只读浏览 · 导入与备份操作仅舍主可用',
                  onTap: onOpenDataCenter,
                ),
              ],
            ),
            if (onOpenMembers != null ||
                onOpenCrm != null ||
                onOpenContracts != null ||
                onOpenAccounting != null) ...[
              const SizedBox(height: 20),
              IosGroupedSection(
                header: const IosSectionHeader('经营'),
                children: [
                  if (onOpenMembers != null)
                    IosListTile(
                      key: const Key('mine-open-members'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.person_2_fill,
                        semanticLabel: '成员与权限',
                        size: 32,
                        padding: 4,
                      ),
                      title: '成员与权限',
                      subtitle: state.hasCapability(AppCapability.manageMembers)
                          ? '邀请繁育员 / 饲养员 / 客服 / 访客'
                          : '只读浏览 · 成员邀请与角色调整仅舍主可用',
                      onTap: onOpenMembers,
                    ),
                  if (onOpenCrm != null)
                    IosListTile(
                      key: const Key('mine-open-crm'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.person_2_square_stack_fill,
                        semanticLabel: '客户与交付',
                        size: 32,
                        padding: 4,
                      ),
                      title: '客户与交付',
                      subtitle: state.hasCapability(AppCapability.writeCrm)
                          ? '意向客户 · 预订 · 交付交接'
                          : '只读浏览 · 当前角色没有客户写入权限',
                      onTap: onOpenCrm,
                    ),
                  if (onOpenContracts != null)
                    IosListTile(
                      key: const Key('mine-open-contracts'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.doc_text_fill,
                        semanticLabel: '合同与回执',
                        size: 32,
                        padding: 4,
                      ),
                      title: '合同与回执',
                      subtitle:
                          state.hasCapability(AppCapability.writeDocuments)
                          ? '模板 · 草稿签发 · 复制分享'
                          : '只读浏览 · 可预览和输出已生成单据',
                      onTap: onOpenContracts,
                    ),
                  if (onOpenAccounting != null)
                    IosListTile(
                      key: const Key('mine-open-accounting'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.money_yen_circle_fill,
                        semanticLabel: '财务收支',
                        size: 32,
                        padding: 4,
                      ),
                      title: '财务收支',
                      subtitle:
                          state.hasCapability(AppCapability.writeAccounting)
                          ? '记账 · 分类 · 本月汇总'
                          : '只读浏览 · 记账与分类维护仅舍主可用',
                      onTap: onOpenAccounting,
                    ),
                ],
              ),
            ],
            if (onOpenTodayWidget != null ||
                onOpenGenetic != null ||
                onOpenPaywall != null) ...[
              const SizedBox(height: 20),
              IosGroupedSection(
                header: const IosSectionHeader('工具'),
                children: [
                  if (onOpenTodayWidget != null)
                    IosListTile(
                      key: const Key('mine-open-today-widget'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.square_grid_2x2,
                        semanticLabel: '今日待办组件',
                        size: 32,
                        padding: 4,
                      ),
                      title: '今日待办组件',
                      subtitle: '桌面小组件 · 预览与同步',
                      onTap: onOpenTodayWidget,
                    ),
                  if (onOpenGenetic != null)
                    IosListTile(
                      key: const Key('mine-open-genetic'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.lab_flask_solid,
                        semanticLabel: '遗传推算',
                        size: 32,
                        padding: 4,
                      ),
                      title: '遗传推算',
                      subtitle: '配对概率与本窝记录',
                      onTap: onOpenGenetic,
                    ),
                  if (onOpenPaywall != null)
                    IosListTile(
                      key: const Key('mine-open-paywall'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.checkmark_seal,
                        semanticLabel: '套餐与权益',
                        size: 32,
                        padding: 4,
                      ),
                      title: '套餐与权益',
                      subtitle: '查看方案、用量和功能范围',
                      onTap: onOpenPaywall,
                    ),
                ],
              ),
            ],
            if (onOpenPublicSite != null ||
                onOpenAssistant != null ||
                onOpenStud != null) ...[
              const SizedBox(height: 20),
              IosGroupedSection(
                header: const IosSectionHeader('增长'),
                children: [
                  if (onOpenPublicSite != null)
                    IosListTile(
                      key: const Key('mine-open-public-site'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.globe,
                        semanticLabel: '公开主页',
                        size: 32,
                        padding: 4,
                      ),
                      title: '公开主页',
                      subtitle: '轻量展示 · 发布链接',
                      onTap: onOpenPublicSite,
                    ),
                  if (onOpenAssistant != null)
                    IosListTile(
                      key: const Key('mine-open-assistant'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.sparkles,
                        semanticLabel: '问问管家',
                        size: 32,
                        padding: 4,
                      ),
                      title: '问问管家',
                      subtitle: '用一句话找到你的记录',
                      onTap: onOpenAssistant,
                    ),
                  if (onOpenStud != null)
                    IosListTile(
                      key: const Key('mine-open-stud'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.arrow_right_arrow_left,
                        semanticLabel: '配对合作',
                        size: 32,
                        padding: 4,
                      ),
                      title: '配对合作',
                      subtitle: '管理借配与合作记录',
                      onTap: onOpenStud,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            IosGroupedSection(
              header: const IosSectionHeader('系统'),
              children: [
                IosListTile(
                  leading: const BearGlyphTile(
                    icon: CupertinoIcons.settings,
                    semanticLabel: '物种规则',
                    size: 32,
                    padding: 4,
                  ),
                  title: '物种规则',
                  subtitle: state.ownerRules.isEmpty
                      ? '等待首次设置'
                      : '当前 ${state.ownerRules.length} 个版本',
                  onTap: () => Navigator.of(
                    context,
                  ).push(iosPageRoute(builder: (_) => RulePage(state: state))),
                ),
                IosListTile(
                  leading: BearGlyphTile(
                    icon: state.offline
                        ? CupertinoIcons.exclamationmark_triangle
                        : CupertinoIcons.cloud,
                    semanticLabel: state.offline ? '离线' : '在线',
                    size: 32,
                    padding: 4,
                    selected: state.offline,
                  ),
                  title: '离线状态',
                  subtitle: state.offline
                      ? '离线只读 · 联网后重新提交/再操作'
                      : '在线 · 最近数据已同步',
                  showChevron: false,
                ),
              ],
            ),
            const SizedBox(height: 20),
            IosGroupedSection(
              children: [
                IosListTile(
                  leading: const BearGlyphTile(
                    icon: CupertinoIcons.square_arrow_left,
                    semanticLabel: '退出登录',
                    size: 32,
                    padding: 4,
                    selected: true,
                  ),
                  title: '退出登录',
                  destructive: true,
                  showChevron: false,
                  onTap: () => state.logout(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: IosMetrics.pagePadding),
              child: _MineFooter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MineFooter extends StatelessWidget {
  const _MineFooter();

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    return Column(
      children: [
        const BearMascot(size: 48, mood: BearMood.sleepy),
        const SizedBox(height: 8),
        Text(
          '熊舍管家 · 可爱认真地管好每一只小仓鼠',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: palette.secondaryLabel),
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule, required this.owner, this.onCopy});

  final SpeciesRuleVersion rule;
  final bool owner;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final speciesLabel = switch (rule.speciesCode.toLowerCase()) {
      'mesocricetus_auratus' || 'syrian_hamster' => '金丝熊',
      _ => '仓鼠繁育规则',
    };
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: palette.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        border: Border.all(color: palette.separator),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    speciesLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IosStatusBadge(
                  label: owner ? '熊舍版本 ${rule.version}' : '系统模板',
                  color: owner ? palette.accent : IosColors.systemTeal,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '孕期 ${rule.gestationMinDays} 至 ${rule.gestationMaxDays} 天 · 配对 ${rule.pairingMaxMinutes ?? '-'} 分钟',
              style: TextStyle(color: palette.secondaryLabel),
            ),
            if (!owner)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(CupertinoIcons.doc_on_doc, size: 16),
                  label: const Text('复制'),
                ),
              ),
          ],
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => BearEmptyCard(
    title: label,
    subtitle: '可以从系统模板复制一份开始',
    mood: BearMood.sleepy,
    illustration: BearAssets.emptyList,
  );
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
