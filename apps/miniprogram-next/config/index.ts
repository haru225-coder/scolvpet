import { defineConfig, type UserConfigExport } from '@tarojs/cli'
import fs from 'node:fs'
import path from 'node:path'

import devConfig from './dev'
import prodConfig from './prod'

// 构建前门禁：宁可构建失败，也不能默默把开发配置/演示账号打进生产包。
// 发布流水线请设 MP_REQUIRE_PRODUCTION_CONFIG=1，注入缺失时直接崩。
function assertBuildConfig() {
  const root = path.resolve(__dirname, '..')
  const source = fs.readFileSync(path.join(root, 'src/utils/config.js'), 'utf8')
  const appEnv = source.match(/const APP_ENV = '([^']*)'/)?.[1]
  const apiBase = source.match(/const API_BASE = '([^']*)'/)?.[1] ?? ''
  const devPhone = source.match(/const DEV_LOGIN_PHONE = '([^']*)'/)?.[1] ?? ''
  const devCode = source.match(/const DEV_LOGIN_CODE = '([^']*)'/)?.[1] ?? ''
  const fail = (reason: string) => {
    throw new Error(`build gate: ${reason}`)
  }

  if (appEnv !== 'development' && appEnv !== 'production') {
    fail(`src/utils/config.js APP_ENV must be development or production, got "${appEnv}"`)
  }
  if (process.env.MP_REQUIRE_PRODUCTION_CONFIG === '1' && appEnv !== 'production') {
    fail('MP_REQUIRE_PRODUCTION_CONFIG=1 but src/utils/config.js is still the development default; run scripts/build-miniprogram-next.sh first')
  }
  if (appEnv === 'production') {
    if (!/^https:\/\//.test(apiBase)) fail(`production API_BASE must use https, got "${apiBase}"`)
    if (/^https:\/\/[^/]+:\d+/.test(apiBase)) fail(`production API_BASE must not carry an explicit port, got "${apiBase}"`)
    if (/(^|\.)p\.scolv\.com(?::|\/|$)/.test(apiBase)) fail('production API_BASE must not be the staging host')
    if (devPhone || devCode) fail('production build must not ship DEV_LOGIN_* credentials')
    const project = JSON.parse(fs.readFileSync(path.join(root, 'project.config.json'), 'utf8'))
    if (project.setting?.urlCheck !== true) fail('project.config.json setting.urlCheck must be true for production')
    if (project.setting?.uploadWithSourceMap === true) fail('project.config.json setting.uploadWithSourceMap must be false for production')
    if (!/^wx[0-9a-f]{16}$/.test(String(project.appid))) fail(`project.config.json appid looks invalid: "${project.appid}"`)
  }

  const generatedClient = path.resolve(root, '..', '..', 'generated/ts/scolvpet-api/src')
  if (!fs.existsSync(generatedClient)) {
    fail(`@scolvpet/api-client is missing at ${generatedClient}; run "make generate-ts-client" from the repository root (this app cannot be built outside the monorepo)`)
  }
}

// https://taro-docs.jd.com/docs/next/config
export default defineConfig<'webpack5'>(async (merge) => {
  assertBuildConfig()
  const baseConfig: UserConfigExport<'webpack5'> = {
    projectName: 'scolvpet-miniprogram-next',
    date: '2026-7-27',
    designWidth: 375,
    deviceRatio: {
      640: 2.34 / 2,
      750: 1,
      375: 2,
      828: 1.81 / 2
    },
    sourceRoot: 'src',
    outputRoot: 'dist',
    plugins: [],
    defineConstants: {},
    // C 端 7 页原生混写(docs/32 §1):Taro 对 app.config 中声明的原生页
    // 走混写编译管线(utils require 一并打包),无需手工 copy;
    // 页面路径保持 pages/... 不变以兼容既有小程序码 scene 深链。
    copy: {
      patterns: [
        { from: 'src/sitemap.json', to: 'dist/sitemap.json' },
        // 原生 tabBar 降级图标（custom:true 不生效时用）
        { from: 'src/assets/tab/', to: 'dist/assets/tab/' }
      ],
      options: {}
    },
    framework: 'react',
    compiler: {
      type: 'webpack5',
      prebundle: { enable: false }
    },
    cache: {
      enable: false
    },
    alias: {
      '@scolvpet/mp-ui': path.resolve(__dirname, '..', 'packages/mp-ui/src'),
      '@scolvpet/api-client': path.resolve(__dirname, '..', '..', '..', 'generated/ts/scolvpet-api/src'),
      '@api': path.resolve(__dirname, '..', 'src/api')
    },
    mini: {
      // 工程内 package(@scolvpet/mp-ui)与仓库级 generated TS 客户端都在 src 外,
      // 需显式纳入 babel 编译范围。
      compile: {
        include: [
          path.resolve(__dirname, '..', 'packages'),
          path.resolve(__dirname, '..', '..', '..', 'generated', 'ts', 'scolvpet-api', 'src')
        ]
      },
      postcss: {
        pxtransform: {
          enable: true,
          config: {}
        },
        cssModules: {
          enable: false
        }
      }
    },
    h5: {}
  }
  if (process.env.NODE_ENV === 'development') {
    return merge({}, baseConfig, devConfig)
  }
  return merge({}, baseConfig, prodConfig)
})
