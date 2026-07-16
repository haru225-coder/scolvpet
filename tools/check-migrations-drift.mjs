import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const root = path.resolve(new URL('..', import.meta.url).pathname);
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'scolvpet-migrations-'));

try {
  const result = spawnSync(process.execPath, [path.join(root, 'tools/split-schema.mjs')], {
    cwd: root,
    env: { ...process.env, MIGRATIONS_OUTPUT_DIR: temp },
    encoding: 'utf8',
  });
  if (result.status !== 0) {
    process.stderr.write(result.stderr || result.stdout || 'migration generation failed\n');
    process.exit(result.status || 1);
  }

  const expected = fs.readdirSync(temp).filter((name) => /^000[1-9]_.*\.sql$/.test(name)).sort();
  const actual = fs.readdirSync(path.join(root, 'db/migrations'))
    .filter((name) => /^000[1-9]_.*\.sql$/.test(name)).sort();
  if (expected.join('\n') !== actual.join('\n')) {
    throw new Error(`migration file set drift: expected=${expected.join(',')} actual=${actual.join(',')}`);
  }
  for (const name of expected) {
    const generated = fs.readFileSync(path.join(temp, name));
    const checkedIn = fs.readFileSync(path.join(root, 'db/migrations', name));
    if (!generated.equals(checkedIn)) throw new Error(`migration content drift: ${name}`);
  }
  console.log(`migration drift check passed: ${expected.length} source migrations`);
} finally {
  fs.rmSync(temp, { recursive: true, force: true });
}
