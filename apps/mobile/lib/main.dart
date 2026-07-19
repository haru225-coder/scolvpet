import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api_client.dart';
import 'core/app_state.dart';
import 'core/session_store.dart';
import 'data/i1_repository.dart';
import 'data/i2_repository.dart';
import 'features/breeding/breeding.dart';
import 'features/health/health.dart';
import 'features/i2/i2.dart';
import 'features/litter/litter.dart';
import 'features/accounting/accounting.dart';
import 'features/contracts/contracts.dart';
import 'features/crm/crm.dart';
import 'features/genetic/genetic.dart';
import 'features/home_widget/home_widget.dart';
import 'features/members/members.dart';
import 'features/assistant/assistant.dart';
import 'features/growth/growth.dart';
import 'features/i6/data_center.dart';
import 'features/miniprogram/miniprogram.dart';
import 'features/paywall/paywall.dart';
import 'features/pedigree/pedigree.dart';
import 'features/public_site/public_site.dart';
import 'features/push/push.dart';
import 'features/stud/stud.dart';
import 'features/tasks/tasks.dart';
import 'ui/screens.dart';
import 'ui/theme/ios_theme.dart';
import 'ui/widgets/ios_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionStore = SessionStore();
  final apiClient = ApiClient(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://p.scolv.com:8443',
    ),
    sessionStore: sessionStore,
  );
  final state = AppState(
    repository: ApiI1Repository(client: apiClient, sessionStore: sessionStore),
    sessionStore: sessionStore,
  );
  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 3),
    );
  } on Object {
    // Storage is an enhancement for offline restore; it must not block the
    // first Flutter frame when an iOS plugin is unavailable or slow to start.
  }
  final i2Controller = I2Controller(
    repository: DefaultApiI2Repository(client: apiClient),
    localStore: preferences == null
        ? null
        : SharedPreferencesI2LocalStore(preferences: preferences),
  );
  final taskRepository = DefaultApiTaskRepository(client: apiClient);
  final todayWidgetPublisher = SharedPreferencesTodayWidgetPublisher();
  final breedingController = BreedingController(
    repository: DefaultApiBreedingRepository(client: apiClient),
    taskRepository: taskRepository,
  );
  final litterBoardController = LitterBoardController(
    repository: DefaultApiLitterBoardRepository(client: apiClient),
  );
  final taskController = TaskController(
    repository: taskRepository,
    notifications: PluginLocalNotificationScheduler(),
    widgetPublisher: todayWidgetPublisher,
  );
  final pedigreeRepository = DefaultApiPedigreeRepository(client: apiClient);
  final healthRepository = DefaultApiHealthRepository(client: apiClient);
  final memberRepository = DefaultApiMemberRepository(client: apiClient);
  final crmRepository = DefaultApiCrmRepository(client: apiClient);
  final contractsRepository = DefaultApiContractsRepository(client: apiClient);
  final accountingRepository = DefaultApiAccountingRepository(
    client: apiClient,
  );
  final geneticRepository = DefaultApiGeneticRepository(client: apiClient);
  final pushRepository = DefaultApiPushRepository(client: apiClient);
  final paywallRepository = DefaultApiPaywallRepository(client: apiClient);
  final publicSiteRepository = DefaultApiPublicSiteRepository(
    client: apiClient,
  );
  final miniprogramRepository = DefaultApiMiniprogramRepository(
    client: apiClient,
  );
  final assistantRepository = DefaultApiAssistantRepository(client: apiClient);
  final dataCenterRepository = DefaultApiDataCenterRepository(
    client: apiClient,
  );
  final studRepository = DefaultApiStudRepository(client: apiClient);
  final growthRepository = DefaultApiGrowthRepository(client: apiClient);
  runApp(
    ScolvPetApp(
      state: state,
      i2Controller: i2Controller,
      breedingController: breedingController,
      litterBoardController: litterBoardController,
      taskController: taskController,
      pedigreeRepository: pedigreeRepository,
      healthRepository: healthRepository,
      memberRepository: memberRepository,
      crmRepository: crmRepository,
      contractsRepository: contractsRepository,
      accountingRepository: accountingRepository,
      geneticRepository: geneticRepository,
      pushRepository: pushRepository,
      paywallRepository: paywallRepository,
      publicSiteRepository: publicSiteRepository,
      miniprogramRepository: miniprogramRepository,
      assistantRepository: assistantRepository,
      dataCenterRepository: dataCenterRepository,
      studRepository: studRepository,
      growthRepository: growthRepository,
      todayWidgetPublisher: todayWidgetPublisher,
    ),
  );
}

class ScolvPetApp extends StatefulWidget {
  const ScolvPetApp({
    super.key,
    required this.state,
    required this.i2Controller,
    required this.breedingController,
    required this.litterBoardController,
    required this.taskController,
    required this.pedigreeRepository,
    required this.healthRepository,
    required this.memberRepository,
    required this.crmRepository,
    required this.contractsRepository,
    required this.accountingRepository,
    required this.geneticRepository,
    required this.pushRepository,
    required this.paywallRepository,
    required this.publicSiteRepository,
    required this.miniprogramRepository,
    required this.assistantRepository,
    this.dataCenterRepository,
    required this.studRepository,
    required this.growthRepository,
    this.todayWidgetPublisher,
  });

  final AppState state;
  final I2Controller i2Controller;
  final BreedingController breedingController;
  final LitterBoardController litterBoardController;
  final TaskController taskController;
  final PedigreeRepository pedigreeRepository;
  final HealthRepository healthRepository;
  final MemberRepository memberRepository;
  final CrmRepository crmRepository;
  final ContractsRepository contractsRepository;
  final AccountingRepository accountingRepository;
  final GeneticRepository geneticRepository;
  final PushRepository pushRepository;
  final PaywallRepository paywallRepository;
  final PublicSiteRepository publicSiteRepository;
  final MiniprogramRepository miniprogramRepository;
  final AssistantRepository assistantRepository;
  final DataCenterRepository? dataCenterRepository;
  final StudRepository studRepository;
  final GrowthRepository growthRepository;
  final TodayWidgetPublisher? todayWidgetPublisher;

  @override
  State<ScolvPetApp> createState() => _ScolvPetAppState();
}

class _ScolvPetAppState extends State<ScolvPetApp> {
  @override
  void initState() {
    super.initState();
    widget.state.restore();
  }

  @override
  void dispose() {
    widget.taskController.dispose();
    widget.litterBoardController.dispose();
    widget.breedingController.dispose();
    widget.i2Controller.dispose();
    widget.state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '熊舍管家',
          theme: buildIosTheme(Brightness.light),
          darkTheme: buildIosTheme(Brightness.dark),
          themeMode: ThemeMode.system,
          scrollBehavior: const IosScrollBehavior(),
          builder: (context, child) =>
              KeyboardDismissOnTap(child: child ?? const SizedBox.shrink()),
          home: switch (widget.state.phase) {
            AppPhase.restoring => const LoadingScreen(),
            AppPhase.login => LoginScreen(state: widget.state),
            AppPhase.code => CodeScreen(state: widget.state),
            AppPhase.setup => SetupScreen(state: widget.state),
            AppPhase.home => HomeShell(
              state: widget.state,
              i2Controller: widget.i2Controller,
              breedingController: widget.breedingController,
              litterBoardController: widget.litterBoardController,
              taskController: widget.taskController,
              pedigreeRepository: widget.pedigreeRepository,
              healthRepository: widget.healthRepository,
              memberRepository: widget.memberRepository,
              crmRepository: widget.crmRepository,
              contractsRepository: widget.contractsRepository,
              accountingRepository: widget.accountingRepository,
              geneticRepository: widget.geneticRepository,
              pushRepository: widget.pushRepository,
              paywallRepository: widget.paywallRepository,
              publicSiteRepository: widget.publicSiteRepository,
              miniprogramRepository: widget.miniprogramRepository,
              assistantRepository: widget.assistantRepository,
              dataCenterRepository: widget.dataCenterRepository,
              growthRepository: widget.growthRepository,
              studRepository: widget.studRepository,
              todayWidgetPublisher: widget.todayWidgetPublisher,
            ),
          },
        );
      },
    );
  }
}
