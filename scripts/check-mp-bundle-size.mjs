#!/usr/bin/env node
// 分包体积门禁(docs/33 M0-1):单分包(含主包)硬限 2MB,预警线 1.6MB。
// 用法:node scripts/check-mp-bundle-size.mjs [distDir]
// distDir 默认 apps/miniprogram-next/dist;读取 dist/app.json 的 subPackages
// 作为分包地图真源,主包 = dist 下除分包根外的全部文件。
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const HARD_LIMIT = 2 * 1024 * 1024;
const WARN_LIMIT = 1.6 * 1024 * 1024;

const distDir = path.resolve(process.argv[2] || 'apps/miniprogram-next/dist');
const appJsonPath = path.join(distDir, 'app.json');
if (!fs.existsSync(appJsonPath)) {
  console.error(`bundle-size gate: ${appJsonPath} not found — run the weapp build first`);
  process.exit(1);
}

const appJson = JSON.parse(fs.readFileSync(appJsonPath, 'utf8'));
const subRoots = (appJson.subPackages || appJson.subpackages || []).map((p) =>
  p.root.replace(/\/+$/, ''),
);

function dirSize(dir) {
  let total = 0;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) total += dirSize(full);
    else total += fs.statSync(full).size;
  }
  return total;
}

function isInsideSubPackage(relPath) {
  return subRoots.some((root) => relPath === root || relPath.startsWith(`${root}/`));
}

function mainPackageSize() {
  let total = 0;
  const walk = (dir) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, entry.name);
      const rel = path.relative(distDir, full).split(path.sep).join('/');
      if (isInsideSubPackage(rel)) continue;
      if (entry.isDirectory()) walk(full);
      else total += fs.statSync(full).size;
    }
  };
  walk(distDir);
  return total;
}

const rows = [{ name: '__main__', size: mainPackageSize() }];
for (const root of subRoots) {
  const dir = path.join(distDir, root);
  rows.push({ name: root, size: fs.existsSync(dir) ? dirSize(dir) : 0 });
}

const fmt = (n) => `${(n / 1024 / 1024).toFixed(3)}MB`;
let failed = false;
for (const { name, size } of rows) {
  let mark = 'ok';
  if (size >= HARD_LIMIT) {
    mark = 'FAIL(>2MB)';
    failed = true;
  } else if (size >= WARN_LIMIT) {
    mark = 'WARN(>1.6MB)';
  }
  console.log(`${mark.padEnd(13)} ${fmt(size).padStart(10)}  ${name}`);
}
const total = rows.reduce((acc, r) => acc + r.size, 0);
console.log(`${'total'.padEnd(13)} ${fmt(total).padStart(10)}  (WeChat 总包上限 30MB)`);
if (failed) {
  console.error('bundle-size gate: subpackage over 2MB hard limit');
  process.exit(1);
}
