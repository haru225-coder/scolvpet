import { defineConfig, type UserConfigExport } from '@tarojs/cli'
import path from 'node:path'

import devConfig from './dev'
import prodConfig from './prod'

// https://taro-docs.jd.com/docs/next/config
export default defineConfig<'webpack5'>(async (merge) => {
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
        { from: 'src/sitemap.json', to: 'dist/sitemap.json' }
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
