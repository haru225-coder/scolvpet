/// Build-time application endpoints.
///
/// Development defaults remain explicit for local smoke usage. Release builds
/// must inject `API_BASE_URL` and `PUBLIC_SITE_HOST` through dart-define.
const String appApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://p.scolv.com:8443',
);

const String publicSiteHost = String.fromEnvironment(
  'PUBLIC_SITE_HOST',
  defaultValue: 'https://p.scolv.com',
);
