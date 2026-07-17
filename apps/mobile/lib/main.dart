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
import 'features/pedigree/pedigree.dart';
import 'features/tasks/tasks.dart';
import 'ui/screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionStore = SessionStore();
  final apiClient = ApiClient(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8080',
    ),
    sessionStore: sessionStore,
  );
  final state = AppState(
    repository: ApiI1Repository(client: apiClient, sessionStore: sessionStore),
    sessionStore: sessionStore,
  );
  final preferences = await SharedPreferences.getInstance();
  final i2Controller = I2Controller(
    repository: DefaultApiI2Repository(client: apiClient),
    localStore: SharedPreferencesI2LocalStore(preferences: preferences),
  );
  final taskRepository = DefaultApiTaskRepository(client: apiClient);
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
  );
  final pedigreeRepository = DefaultApiPedigreeRepository(client: apiClient);
  final healthRepository = DefaultApiHealthRepository(client: apiClient);
  runApp(
    ScolvPetApp(
      state: state,
      i2Controller: i2Controller,
      breedingController: breedingController,
      litterBoardController: litterBoardController,
      taskController: taskController,
      pedigreeRepository: pedigreeRepository,
      healthRepository: healthRepository,
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
  });

  final AppState state;
  final I2Controller i2Controller;
  final BreedingController breedingController;
  final LitterBoardController litterBoardController;
  final TaskController taskController;
  final PedigreeRepository pedigreeRepository;
  final HealthRepository healthRepository;

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
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xffc77852),
            ),
            scaffoldBackgroundColor: const Color(0xfff7f5ef),
            cardTheme: const CardThemeData(
              margin: EdgeInsets.zero,
              elevation: 0,
            ),
          ),
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
            ),
          },
        );
      },
    );
  }
}
