import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(new URL('..', import.meta.url).pathname);
const sourcePath = path.join(root, 'specs/database/schema.sql');
const outputDir = path.resolve(
  process.env.MIGRATIONS_OUTPUT_DIR || path.join(root, 'db/migrations'),
);
const source = fs.readFileSync(sourcePath, 'utf8')
  .replace(/^.*?BEGIN;\s*/s, '')
  .replace(/\s*COMMIT;\s*$/s, '')
  .trim();

const sections = [
  ['0001_extensions_enums.sql', 'CREATE EXTENSION', 'CREATE TABLE account'],
  ['0002_accounts_rules.sql', 'CREATE TABLE account', 'CREATE TABLE domain_event'],
  ['0003_events_outbox.sql', 'CREATE TABLE domain_event', 'CREATE TABLE async_job'],
  ['0004_jobs_media_housing.sql', 'CREATE TABLE async_job', 'CREATE TABLE breeding_plan'],
  ['0005_breeding_litters_pedigree.sql', 'CREATE TABLE breeding_plan', 'CREATE TABLE litter_count_event'],
  ['0006_facts_health.sql', 'CREATE TABLE litter_count_event', 'CREATE TABLE care_task'],
  ['0007_tasks_media_sharing.sql', 'CREATE TABLE care_task', 'CREATE TABLE import_job'],
  ['0008_data_center_usage.sql', 'CREATE TABLE import_job', 'CREATE TABLE idempotency_record'],
  ['0009_triggers_constraints.sql', 'CREATE TABLE idempotency_record', null],
];

fs.mkdirSync(outputDir, { recursive: true });

for (const [fileName, startMarker, endMarker] of sections) {
  const start = source.indexOf(startMarker);
  const end = endMarker ? source.indexOf(endMarker) : source.length;
  if (start < 0 || end < 0 || end <= start) {
    throw new Error(`无法切分 ${fileName}: ${startMarker} -> ${endMarker}`);
  }
  const body = source.slice(start, end).trim();
  const content = [
    '-- Generated from specs/database/schema.sql; do not edit this migration by hand.',
    'BEGIN;',
    '',
    body,
    '',
    'COMMIT;',
    '',
  ].join('\n');
  fs.writeFileSync(path.join(outputDir, fileName), content);
}

console.log(`generated ${sections.length} migrations from ${path.relative(root, sourcePath)}`);
