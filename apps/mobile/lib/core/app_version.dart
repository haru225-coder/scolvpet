/// Single source for app version reported to the API.
///
/// Keep in sync with `apps/mobile/pubspec.yaml` `version:` (CI asserts this).
const String appVersionLabel = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '0.0.4+6',
);
