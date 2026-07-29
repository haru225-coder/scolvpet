// Override in 微信开发者工具 local settings or CI inject for production.
// Production must set formal request合法域名 + real AppID (not touristappid).
// 发布注入由 scripts/build-miniprogram-next.sh 负责；本文件的开发默认值只在
// APP_ENV === 'development' 下可用，任何生产语义的组合都 fail-closed。
const APP_ENV = 'development';
const API_BASE = 'https://p.scolv.com:8443';
// 仅供开发构建的一键进入账号；生产构建由 release 脚本覆盖本文件。
const DEV_LOGIN_PHONE = '13800138000';
const DEV_LOGIN_CODE = '123456';

const STAGING_HOST = /(^|\.)p\.scolv\.com(?::|\/|$)/;
const isDevelopment = APP_ENV === 'development';

/** 正式环境只接受：https + 无显式端口 + 非 staging 主机。 */
function isProductionApiBase(base) {
  const value = String(base || '');
  if (!/^https:\/\//.test(value)) return false;
  if (/^https:\/\/[^/]+:\d+/.test(value)) return false;
  return !STAGING_HOST.test(value);
}

function assertRuntimeConfig() {
  if (APP_ENV !== 'development' && APP_ENV !== 'production') {
    throw new Error('release gate: APP_ENV must be development or production, got ' + APP_ENV);
  }
  const isProductionBuild = APP_ENV === 'production';
  if (isProductionBuild && !isProductionApiBase(API_BASE)) {
    throw new Error('release gate: production API_BASE must be https, carry no explicit port, and must not be the staging host');
  }
}

module.exports = {
  APP_ENV,
  API_BASE,
  // 生产语义下强制清空：即使注入脚本漏改了这两行，演示账号也无法出现在可用路径上。
  DEV_LOGIN_PHONE: isDevelopment ? DEV_LOGIN_PHONE : '',
  DEV_LOGIN_CODE: isDevelopment ? DEV_LOGIN_CODE : '',
  isProductionApiBase,
  assertRuntimeConfig,
  // Scene keys: s=slug, h=hamster_id
};
