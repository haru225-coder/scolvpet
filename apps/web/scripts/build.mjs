import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const output = path.join(root, 'dist');
await fs.mkdir(output, { recursive: true });
await fs.copyFile(path.join(root, 'src/server.mjs'), path.join(output, 'server.mjs'));
console.log('built apps/web/dist/server.mjs');

