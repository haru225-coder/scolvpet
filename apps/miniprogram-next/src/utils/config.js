// Override in 微信开发者工具 local settings or CI inject for production.
// Production must set formal request合法域名 + real AppID (not touristappid).
// 发布注入由 scripts/build-miniprogram-next.sh 负责；本文件的开发默认值只在
// APP_ENV === 'development' 下可用，任何生产语义的组合都 fail-closed。
//
// ⚠ 仓库里这份是 DEVELOPMENT 默认，禁止把未注入的源码 zip 直接当送审包。
// 送审必须：
//   MP_APP_ENV=production MP_API_BASE=https://正式域名 MP_APPID=wx… \
//   bash scripts/build-miniprogram-next.sh
// 注入后 config 会出现 RELEASE_INJECTED_AT 痕迹。
const APP_ENV = 'development';
// 真机微信只允许默认 443，且 request 合法域名必须与 API_BASE 主机一致。
// 公众平台已配 pet.scolv.com 时，这里必须打 pet（不要写短别名 staging 主机字面量到源码注释）。
// pet 当前同样是 mock 短信，开发一键登录可用；生产发布仍由脚本注入正式值。
// 非 443 直连端口勿写入小程序默认。
// staging 主机守卫见下方 STAGING_HOST 正则（发布门禁会剥掉该字面量后扫残留）。
const API_BASE = 'https://pet.scolv.com';
// 仅供开发构建的一键进入账号；生产构建由 release 脚本覆盖本文件。
const DEV_LOGIN_PHONE = '13800138000';
const DEV_LOGIN_CODE = '123456';
// C 端无场景值时的公开熊舍兜底（可被 launch/query 覆盖；生产注入可改）。
const DEFAULT_PUBLIC_SLUG = 'demo';
// 微信订阅消息模板 ID（逗号分隔）。用户界面不手填；优先服务端列表，为空再用本配置。
// 正式环境由运营/发布注入真实 tmpl_ 列表。
const WECHAT_SUBSCRIBE_TEMPLATE_IDS = '';
// release 脚本注入时写入 ISO 时间；源码默认为空，门禁测试可据此识别「未注入」。
const RELEASE_INJECTED_AT = '';

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
  if (isProductionBuild && !RELEASE_INJECTED_AT) {
    throw new Error('release gate: production build missing RELEASE_INJECTED_AT (run scripts/build-miniprogram-next.sh)');
  }
  if (isProductionBuild && (DEV_LOGIN_PHONE || DEV_LOGIN_CODE)) {
    throw new Error('release gate: production build must not ship DEV_LOGIN_* credentials');
  }
}

module.exports = {
  APP_ENV,
  API_BASE,
  DEFAULT_PUBLIC_SLUG,
  WECHAT_SUBSCRIBE_TEMPLATE_IDS,
  RELEASE_INJECTED_AT,
  // 生产语义下强制清空：即使注入脚本漏改了这两行，演示账号也无法出现在可用路径上。
  DEV_LOGIN_PHONE: isDevelopment ? DEV_LOGIN_PHONE : '',
  DEV_LOGIN_CODE: isDevelopment ? DEV_LOGIN_CODE : '',
  isProductionApiBase,
  assertRuntimeConfig,
  // Scene keys: s=slug, h=hamster_id
};
