import '../features/accounting/accounting_repository.dart';
import '../features/assistant/assistant_repository.dart';
import '../features/breeding/breeding_controller.dart';
import '../features/contracts/contracts_repository.dart';
import '../features/crm/crm_repository.dart';
import '../features/genetic/genetic_repository.dart';
import '../features/growth/growth_repository.dart';
import '../features/health/health_repository.dart';
import '../features/home_widget/today_widget_publisher.dart';
import '../features/i2/i2_controller.dart';
import '../features/i6/data_center.dart';
import '../features/litter/litter_board_controller.dart';
import '../features/members/member_repository.dart';
import '../features/miniprogram/miniprogram_repository.dart';
import '../features/paywall/paywall_repository.dart';
import '../features/pedigree/pedigree_repository.dart';
import '../features/public_site/public_site_repository.dart';
import '../features/stud/stud_repository.dart';
import '../features/tasks/task_controller.dart';
import 'app_state.dart';

/// Explicit root dependency bundle.
///
/// Constructed in `main` (or tests) and passed into [ScolvPetApp] /
/// [HomeShell]. Not a service locator: every field is still injected
/// at the call site.
class AppServices {
  const AppServices({
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
  final PaywallRepository paywallRepository;
  final PublicSiteRepository publicSiteRepository;
  final MiniprogramRepository miniprogramRepository;
  final AssistantRepository assistantRepository;
  final DataCenterRepository? dataCenterRepository;
  final StudRepository studRepository;
  final GrowthRepository growthRepository;
  final TodayWidgetPublisher? todayWidgetPublisher;

  void disposeControllers() {
    taskController.dispose();
    litterBoardController.dispose();
    breedingController.dispose();
    i2Controller.dispose();
    state.dispose();
  }
}
