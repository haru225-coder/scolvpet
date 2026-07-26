import path from 'node:path'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  resolve: {
    alias: {
      // 测试环境用 DOM 桩替代小程序运行时组件/API
      '@tarojs/components': path.resolve(__dirname, 'tests/stubs/taro-components.tsx'),
      '@tarojs/taro': path.resolve(__dirname, 'tests/stubs/taro.ts'),
      '@scolvpet/mp-ui': path.resolve(__dirname, 'packages/mp-ui/src'),
      '@scolvpet/api-client': path.resolve(__dirname, '..', '..', 'generated/ts/scolvpet-api/src'),
      '@api': path.resolve(__dirname, 'src/api')
    }
  },
  esbuild: {
    jsx: 'automatic'
  },
  test: {
    environment: 'jsdom',
    globals: true,
    include: ['packages/**/*.test.{ts,tsx}', 'tests/**/*.test.{ts,tsx}']
  }
})
