import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/app_state.dart';
import 'core/session_store.dart';
import 'data/i1_repository.dart';
import 'ui/screens.dart';

void main() {
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
  runApp(ScolvPetApp(state: state));
}

class ScolvPetApp extends StatefulWidget {
  const ScolvPetApp({super.key, required this.state});

  final AppState state;

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
            AppPhase.home => HomeShell(state: widget.state),
          },
        );
      },
    );
  }
}
