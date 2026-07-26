/// Product surface freeze after v0.0.4+6 functional-closure audit.
///
/// Rules (docs/28): open one chain fully; hide anything that cannot finish.
/// Backend APIs may still exist — this only controls **user-facing entry points**.
///
/// Wave 0 · 2026-07-25
abstract final class ProductSurface {
  /// Export / backup jobs stay `queued` with no worker → hide create UX.
  static const bool exposeExportBackup = false;

  /// Stud "network" is single-owner deal log, not bilateral network.
  static const bool exposeStudNetwork = false;

  /// iOS home-screen widget is not a closed production surface.
  static const bool exposeTodayWidget = false;

  /// Paywall / plan switch is not on the breeding main chain.
  static const bool exposePaywall = false;

  /// Miniprogram release sandbox must never look like WeChat publish.
  static const bool exposeMiniprogramRelease = false;

  /// Push channel is incomplete as a product promise.
  static const bool exposePushSettings = false;
}
