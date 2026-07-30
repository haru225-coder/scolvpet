/** @type {import('eslint').Linter.Config} */
module.exports = {
  root: true,
  env: {
    browser: true,
    es2022: true,
    node: true,
  },
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    ecmaFeatures: { jsx: true },
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint'],
  extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended'],
  ignorePatterns: ['dist/', 'node_modules/'],
  globals: {
    App: 'readonly',
    Behavior: 'readonly',
    Component: 'readonly',
    Page: 'readonly',
    getApp: 'readonly',
    requirePlugin: 'readonly',
    wx: 'readonly',
  },
  // 默认（C 端原生混写页口径）：CommonJS + wx.* 全局 + 运行时日志，保持宽松。
  rules: {
    'no-console': 'off',
    'no-undef': 'off',
    'no-unused-vars': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/no-var-requires': 'off',
    '@typescript-eslint/no-unused-vars': 'off',
  },
  overrides: [
    {
      // B 端 TS/TSX（含 mp-ui 与测试）：恢复真正的静态约束。
      files: [
        'src/**/*.ts',
        'src/**/*.tsx',
        'packages/mp-ui/src/**/*.ts',
        'packages/mp-ui/src/**/*.tsx',
        'tests/**/*.ts',
        'tests/**/*.tsx',
        'config/**/*.ts',
      ],
      rules: {
        'no-console': ['error', { allow: ['warn', 'error'] }],
        '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
        // 生成客户端在 monorepo 外不可解析时仍需透传，先以 warn 计账，不阻断 CI。
        '@typescript-eslint/no-explicit-any': 'warn',
      },
    },
    {
      // C 端原生混写页也纳入基础静态检查；保留 wx/App/Page 等小程序全局，
      // 但不再把未定义变量和未使用变量静默放过。
      files: ['src/pages/**/*.js', 'src/utils/**/*.js'],
      rules: {
        'no-undef': 'error',
        'no-unused-vars': ['error', { args: 'none', varsIgnorePattern: '^_' }],
      },
    },
  ],
}
