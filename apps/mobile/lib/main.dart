import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api_client.dart';
import 'core/app_config.dart';
import 'core/app_services.dart';
import 'core/app_state.dart';
import 'core/session_store.dart';
import 'core/token_refresh.dart';
import 'data/i1_repository.dart';
import 'data/i2_repository.dart';
import 'features/breeding/breeding.dart';
import 'features/i2/i2.dart';
import 'features/litter/litter.dart';
import 'features/accounting/accounting.dart';
import 'features/assistant/assistant.dart';
import 'features/contracts/contracts.dart';
import 'features/crm/crm.dart';
import 'features/genetic/genetic.dart';
import 'features/growth/growth.dart';
import 'features/health/health.dart';
import 'features/home_widget/home_widget.dart';
import 'features/i6/data_center.dart';
import 'features/members/members.dart';
import 'features/miniprogram/miniprogram.dart';
import 'features/paywall/paywall.dart';
import 'features/pedigree/pedigree.dart';
import 'features/public_site/public_site.dart';
import 'features/stud/stud.dart';
import 'features/tasks/tasks.dart';
import 'ui/screens.dart';
import 'ui/theme/ios_theme.dart';
import 'ui/widgets/ios_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionStore = SessionStore();
  final apiClient = ApiClient(
    baseUrl: appApiBaseUrl,
    sessionStore: sessionStore,
  );
  final repository = ApiI1Repository(
    client: apiClient,
    sessionStore: sessionStore,
  );
  apiClient.setTokenRefresher(
    buildTokenRefresher(
      sessionStore: sessionStore,
      refresh: repository.refresh,
    ),
  );
  final state = AppState(repository: repository, sessionStore: sessionStore);
  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 3),
    );
  } on Object {
    // Storage is an enhancement for offline restore; it must not block the
    // first Flutter frame when an iOS plugin is unavailable or slow to start.
  }
  final taskRepository = DefaultApiTaskRepository(client: apiClient);
  final todayWidgetPublisher = SharedPreferencesTodayWidgetPublisher();
  final services = AppServices(
    state: state,
    i2Controller: I2Controller(
      repository: DefaultApiI2Repository(client: apiClient),
      localStore: preferences == null
          ? null
          : SharedPreferencesI2LocalStore(preferences: preferences),
    ),
    breedingController: BreedingController(
      repository: DefaultApiBreedingRepository(client: apiClient),
      taskRepository: taskRepository,
    ),
    litterBoardController: LitterBoardController(
      repository: DefaultApiLitterBoardRepository(client: apiClient),
    ),
    taskController: TaskController(
      repository: taskRepository,
      notifications: PluginLocalNotificationScheduler(),
      widgetPublisher: todayWidgetPublisher,
    ),
    pedigreeRepository: DefaultApiPedigreeRepository(client: apiClient),
    healthRepository: DefaultApiHealthRepository(client: apiClient),
    memberRepository: DefaultApiMemberRepository(client: apiClient),
    crmRepository: DefaultApiCrmRepository(client: apiClient),
    contractsRepository: DefaultApiContractsRepository(client: apiClient),
    accountingRepository: DefaultApiAccountingRepository(client: apiClient),
    geneticRepository: DefaultApiGeneticRepository(client: apiClient),
    paywallRepository: DefaultApiPaywallRepository(client: apiClient),
    publicSiteRepository: DefaultApiPublicSiteRepository(client: apiClient),
    miniprogramRepository: DefaultApiMiniprogramRepository(client: apiClient),
    assistantRepository: DefaultApiAssistantRepository(client: apiClient),
    dataCenterRepository: DefaultApiDataCenterRepository(client: apiClient),
    studRepository: DefaultApiStudRepository(client: apiClient),
    growthRepository: DefaultApiGrowthRepository(client: apiClient),
    todayWidgetPublisher: todayWidgetPublisher,
  );
  runApp(ScolvPetApp(services: services));
}

class ScolvPetApp extends StatefulWidget {
  const ScolvPetApp({super.key, required this.services});

  final AppServices services;

  @override
  State<ScolvPetApp> createState() => _ScolvPetAppState();
}

class _ScolvPetAppState extends State<ScolvPetApp> {
  AppServices get services => widget.services;

  @override
  void initState() {
    super.initState();
    services.state.restore();
  }

  @override
  void dispose() {
    services.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: services.state,
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
          home: switch (services.state.phase) {
            AppPhase.restoring => const LoadingScreen(),
            AppPhase.login => LoginScreen(state: services.state),
            AppPhase.code => CodeScreen(state: services.state),
            AppPhase.setup => SetupScreen(state: services.state),
            AppPhase.home => HomeShell(services: services),
          },
        );
      },
    );
  }
}
