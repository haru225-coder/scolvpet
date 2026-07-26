import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(new URL('..', import.meta.url).pathname);
const generated = path.resolve(process.env.GENERATED_DART_ROOT || path.join(root, 'generated/dart/scolvpet_api'));
const pubspecPath = path.join(generated, 'pubspec.yaml');
let pubspec = fs.readFileSync(pubspecPath, 'utf8');
pubspec = pubspec.replace(/sdk: '>=3\.5\.0 <4\.0\.0'/, "sdk: '>=3.8.0 <4.0.0'");
fs.writeFileSync(pubspecPath, pubspec);

const modelDir = path.join(generated, 'lib/src/model');
const unusedImports = new Map([
  ['default_api.dart', ['error_response.dart']],
  ['confirm_birth_response_data.dart', ['confirm_birth_no_litter_data.dart', 'confirm_birth_live_litter_data.dart']],
  ['litter_member.dart', ['litter_member_one_of.dart', 'litter_member_one_of1.dart']],
  ['weight_record.dart', ['weight_record_one_of.dart', 'weight_record_one_of1.dart']],
  ['weight_record_create_request.dart', ['weight_record_one_of.dart', 'weight_record_one_of1.dart']],
]);
for (const file of fs.readdirSync(modelDir)) {
  if (!file.endsWith('.dart')) continue;
  const filePath = path.join(modelDir, file);
  let source = fs.readFileSync(filePath, 'utf8');
  source = source.replaceAll("''true''", "'true'").replaceAll("''false''", "'false'");
  source = source.replaceAll("import 'package:scolvpet_api/src/model/model_null.dart';\n", '');
  source = source.replaceAll("import 'package:copy_with_extension/copy_with_extension.dart';\n", file === 'import_template_response_data_columns_inner_example.dart' ? '' : "import 'package:copy_with_extension/copy_with_extension.dart';\n");
  source = source.replaceAll('ModelNull?', 'Object?');
  source = source.replaceAll('const ImportPreflightRequestDuplicatePolicyEnum.reject', 'ImportPreflightRequestDuplicatePolicyEnum.reject');
  source = source.replaceAll('const MediaEditRecipeRequestOutputFormatEnum.jpeg', 'MediaEditRecipeRequestOutputFormatEnum.jpeg');
  source = source.replaceAll("const ImportPreflightRequestDuplicatePolicyEnum._('reject')", 'ImportPreflightRequestDuplicatePolicyEnum.reject');
  source = source.replaceAll("const MediaEditRecipeRequestOutputFormatEnum._('jpeg')", 'MediaEditRecipeRequestOutputFormatEnum.jpeg');
  source = source.replaceAll("const CreateCrmContactRequestStatusEnum._('lead')", 'CreateCrmContactRequestStatusEnum.lead');
  source = source.replaceAll("const CreateGeneticProfileRequestConfidenceEnum._('unknown')", 'CreateGeneticProfileRequestConfidenceEnum.unknown');
  source = source.replaceAll("const SandboxActivatePlanRequestPlanCodeEnum._('pro')", 'SandboxActivatePlanRequestPlanCodeEnum.pro');
  source = source.replaceAll("const SendCustomerVerificationCodeRequestPurposeEnum._('login')", 'SendCustomerVerificationCodeRequestPurposeEnum.login');
  if (file === 'import_preflight_request.dart') {
    source = source.replaceAll(
      "defaultValue: 'reject'",
      'defaultValue: ImportPreflightRequestDuplicatePolicyEnum.reject',
    );
  }
  if (file === 'media_edit_recipe_request.dart') {
    source = source.replaceAll(
      "defaultValue: 'jpeg'",
      'defaultValue: MediaEditRecipeRequestOutputFormatEnum.jpeg',
    );
  }
  if (file === 'create_crm_contact_request.dart') {
    source = source.replaceAll("defaultValue: 'lead'", 'defaultValue: CreateCrmContactRequestStatusEnum.lead');
  }
  if (file === 'create_genetic_profile_request.dart') {
    source = source.replaceAll("defaultValue: 'unknown'", 'defaultValue: CreateGeneticProfileRequestConfidenceEnum.unknown');
  }
  if (file === 'sandbox_activate_plan_request.dart') {
    source = source.replaceAll("defaultValue: 'pro'", 'defaultValue: SandboxActivatePlanRequestPlanCodeEnum.pro');
  }
  if (file === 'send_customer_verification_code_request.dart') {
    source = source.replaceAll(
      "defaultValue: 'login'",
      'defaultValue: SendCustomerVerificationCodeRequestPurposeEnum.login',
    );
  }
  for (const importName of unusedImports.get(file) ?? []) {
    source = source.replaceAll(`import 'package:scolvpet_api/src/model/${importName}';\n`, '');
  }
  fs.writeFileSync(filePath, source);
}

for (const file of fs.readdirSync(modelDir).filter((name) => name.endsWith('.g.dart'))) {
  const filePath = path.join(modelDir, file);
  let source = fs.readFileSync(filePath, 'utf8');
  source = source.replace(
    /\$enumDecodeNullable\(\n\s+_\$ImportPreflightRequestDuplicatePolicyEnumEnumMap,\n\s+v,\n\s+\) \?\?\n\s+'reject'/,
    '$enumDecodeNullable(\n              _$ImportPreflightRequestDuplicatePolicyEnumEnumMap,\n              v,\n            ) ??\n            ImportPreflightRequestDuplicatePolicyEnum.reject',
  );
  source = source.replace(
    /\$enumDecodeNullable\(\n\s+_\$MediaEditRecipeRequestOutputFormatEnumEnumMap,\n\s+v,\n\s+\) \?\?\n\s+'jpeg'/,
    '$enumDecodeNullable(\n              _$MediaEditRecipeRequestOutputFormatEnumEnumMap,\n              v,\n            ) ??\n            MediaEditRecipeRequestOutputFormatEnum.jpeg',
  );
  source = source.replace(
    /\$enumDecodeNullable\(\n\s+_\$CreateCrmContactRequestStatusEnumEnumMap,\n\s+v,\n\s+\) \?\?\n\s+'lead'/,
    '$enumDecodeNullable(\n              _$CreateCrmContactRequestStatusEnumEnumMap,\n              v,\n            ) ??\n            CreateCrmContactRequestStatusEnum.lead',
  );
  source = source.replace(
    /\$enumDecodeNullable\(\n\s+_\$CreateGeneticProfileRequestConfidenceEnumEnumMap,\n\s+v,\n\s+\) \?\?\n\s+'unknown'/,
    '$enumDecodeNullable(\n              _$CreateGeneticProfileRequestConfidenceEnumEnumMap,\n              v,\n            ) ??\n            CreateGeneticProfileRequestConfidenceEnum.unknown',
  );
  source = source.replace(
    /\$enumDecodeNullable\(\n\s+_\$SandboxActivatePlanRequestPlanCodeEnumEnumMap,\n\s+v,\n\s+\) \?\?\n\s+'pro'/,
    '$enumDecodeNullable(\n              _$SandboxActivatePlanRequestPlanCodeEnumEnumMap,\n              v,\n            ) ??\n            SandboxActivatePlanRequestPlanCodeEnum.pro',
  );
  source = source.replace(
    /\$enumDecodeNullable\(\n\s+_\$SendCustomerVerificationCodeRequestPurposeEnumEnumMap,\n\s+v,\n\s+\) \?\?\n\s+'login'/,
    '$enumDecodeNullable(\n              _$SendCustomerVerificationCodeRequestPurposeEnumEnumMap,\n              v,\n            ) ??\n            SendCustomerVerificationCodeRequestPurposeEnum.login',
  );
  fs.writeFileSync(filePath, source);
}

const apiPath = path.join(generated, 'lib/src/api/default_api.dart');
if (fs.existsSync(apiPath)) {
  let source = fs.readFileSync(apiPath, 'utf8');
  source = source.replaceAll("import 'package:scolvpet_api/src/model/error_response.dart';\n", '');
  fs.writeFileSync(apiPath, source);
}

// OpenAPI Generator leaves trailing spaces on some doc/comment lines; strip
// them so git diff --check and CI whitespace gates stay green.
function stripTrailingWhitespaceTree(dirPath) {
  if (!fs.existsSync(dirPath)) return;
  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    const full = path.join(dirPath, entry.name);
    if (entry.isDirectory()) {
      if (entry.name === '.dart_tool' || entry.name === '.openapi-generator') {
        continue;
      }
      stripTrailingWhitespaceTree(full);
      continue;
    }
    if (!/\.(dart|md|yaml|yml|json|txt)$/.test(entry.name)) continue;
    const original = fs.readFileSync(full, 'utf8');
    const cleaned = original.replace(/[ \t]+$/gm, '').replace(/\s+$/u, '\n');
    if (cleaned !== original) {
      fs.writeFileSync(full, cleaned);
    }
  }
}
stripTrailingWhitespaceTree(generated);

const emptyExample = path.join(modelDir, 'import_template_response_data_columns_inner_example.dart');
if (fs.existsSync(emptyExample)) {
  let source = fs.readFileSync(emptyExample, 'utf8');
  source = source.replace('@CopyWith()\n', '');
  source = source.replace(/ImportTemplateResponseDataColumnsInnerExample\(\{\n\s*\}\);/, 'ImportTemplateResponseDataColumnsInnerExample();');
  source = source.replace(
    /@override\n\s*bool operator ==\(Object other\) => identical\(this, other\) \|\| other is ImportTemplateResponseDataColumnsInnerExample &&\n\s*\n\s*@override\n\s*int get hashCode =>\n\s*\n/s,
    '@override\n  bool operator ==(Object other) => identical(this, other);\n\n  @override\n  int get hashCode => runtimeType.hashCode;\n\n',
  );
  fs.writeFileSync(emptyExample, source);
}

console.log('prepared generated dart client for Dart 3.8+ serialization');
