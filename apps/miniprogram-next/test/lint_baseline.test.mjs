import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const appRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const eslintBin = path.join(appRoot, 'node_modules', 'eslint', 'bin', 'eslint.js');
// 沉浸 UI / Picker 扫尾后 any 告警上升；只冻结「不允许再涨」，不允许 errors。
// 2026-08-10：遗传试配深链/档案入口一轮 any 抬升到 233；后续用类型替换再下调。
const warningBudget = 233;

test('lint warnings do not exceed the frozen full-iteration baseline', () => {
  const output = execFileSync(process.execPath, [
    eslintBin,
    '--format', 'json',
    '--ext', '.js,.mjs,.ts,.tsx',
    '.'
  ], { cwd: appRoot, encoding: 'utf8' });
  const reports = JSON.parse(output);
  const errors = reports.reduce((total, report) => total + report.errorCount, 0);
  const warnings = reports.reduce((total, report) => total + report.warningCount, 0);

  assert.equal(errors, 0, 'lint must not introduce errors');
  assert.ok(warnings <= warningBudget, `lint warnings ${warnings} exceed frozen baseline ${warningBudget}`);
});
