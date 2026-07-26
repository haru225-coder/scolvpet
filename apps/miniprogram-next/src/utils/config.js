// Override in 微信开发者工具 local settings or CI inject for production.
// Production must set formal request合法域名 + real AppID (not touristappid).
const APP_ENV = 'development';
const API_BASE = 'https://p.scolv.com:8443';

function assertRuntimeConfig() {
  if (APP_ENV === 'production' && /(^|\.)p\.scolv\.com(?::|\/|$)/.test(API_BASE)) {
    throw new Error('Production mini-program API_BASE must use the formal API host');
  }
}

module.exports = {
  APP_ENV,
  API_BASE,
  assertRuntimeConfig,
  // Scene keys: s=slug, h=hamster_id
};
