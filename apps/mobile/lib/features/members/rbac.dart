// Role permission matrix for T-P1-01 multi-member RBAC.

/// Organization member roles (舍主 / 繁育员 / 饲养员 / 客服 / 只读访客).
const memberRoles = <String>[
  'owner',
  'breeder',
  'caretaker',
  'staff',
  'viewer',
];

/// Roles that can be invited (never owner).
const inviteableRoles = <String>['breeder', 'caretaker', 'staff', 'viewer'];

String memberRoleLabel(String role) => switch (role) {
  'owner' => '舍主',
  'breeder' => '繁育员',
  'caretaker' => '饲养员',
  'staff' => '客服',
  'viewer' => '只读访客',
  _ => role,
};

String memberRoleDescription(String role) => switch (role) {
  'owner' => '管理熊舍资料、成员、经营和全部饲养记录。',
  'breeder' => '负责繁育、窝次、仓鼠档案、体重、健康和任务。',
  'caretaker' => '负责日常饲养、笼舍、称重、健康、窝次和任务。',
  'staff' => '负责客户交付、合同回执、获客内容和基础仓鼠资料，不参与繁育与笼舍操作。',
  'viewer' => '可以查看熊舍记录，不显示任何写入入口。',
  _ => '使用该角色允许的熊舍能力。',
};

List<String> memberRolePermissionLabels(String role) => switch (role) {
  'owner' => const ['全部记录', '成员与权限', '经营与交付', '数据导入导出'],
  'breeder' => const ['繁育与窝次', '仓鼠档案', '称重与健康', '任务与媒体'],
  'caretaker' => const ['笼舍与清洁', '称重与健康', '窝次护理', '日常任务'],
  'staff' => const ['客户与交付', '合同与回执', '获客内容', '仓鼠基础资料'],
  'viewer' => const ['只读浏览'],
  _ => const ['按角色授权'],
};

String memberStatusLabel(String status) => switch (status) {
  'invited' => '已邀请',
  'active' => '已加入',
  'revoked' => '已撤销',
  _ => status,
};

/// Domains used for capability checks on the client.
enum MemberCapability {
  manageMembers,
  writeBreeding,
  writeLitter,
  writeHamster,
  writeEnclosure,
  writeWeight,
  writeTask,
  writeHealth,
  writeImport,
  writeMedia,
  writeCrm,
  writeDocuments,
  writeAccounting,
  writeGrowth,
}

/// Whether [role] may perform [capability].
///
/// - owner: full access
/// - breeder: breeding / litter / hamster / tasks / health / media
/// - caretaker: daily care (enclosure / weight / task / health / hamster)
/// - staff: limited hamster profile notes
/// - viewer: read-only
bool memberCan(String role, MemberCapability capability) {
  switch (role) {
    case 'owner':
      return true;
    case 'viewer':
      return false;
    case 'staff':
      return switch (capability) {
        MemberCapability.writeHamster ||
        MemberCapability.writeCrm ||
        MemberCapability.writeDocuments ||
        MemberCapability.writeGrowth => true,
        _ => false,
      };
    case 'breeder':
      return switch (capability) {
        MemberCapability.manageMembers => false,
        MemberCapability.writeBreeding => true,
        MemberCapability.writeLitter => true,
        MemberCapability.writeHamster => true,
        MemberCapability.writeEnclosure => false,
        MemberCapability.writeWeight => true,
        MemberCapability.writeTask => true,
        MemberCapability.writeHealth => true,
        MemberCapability.writeImport => false,
        MemberCapability.writeMedia => true,
        MemberCapability.writeCrm => false,
        MemberCapability.writeDocuments => false,
        MemberCapability.writeAccounting => false,
        MemberCapability.writeGrowth => false,
      };
    case 'caretaker':
      return switch (capability) {
        MemberCapability.manageMembers => false,
        MemberCapability.writeBreeding => false,
        MemberCapability.writeLitter => true,
        MemberCapability.writeHamster => true,
        MemberCapability.writeEnclosure => true,
        MemberCapability.writeWeight => true,
        MemberCapability.writeTask => true,
        MemberCapability.writeHealth => true,
        MemberCapability.writeImport => false,
        MemberCapability.writeMedia => true,
        MemberCapability.writeCrm => false,
        MemberCapability.writeDocuments => false,
        MemberCapability.writeAccounting => false,
        MemberCapability.writeGrowth => false,
      };
    default:
      return false;
  }
}

/// Broad "show write entry points" flag for shell chrome.
bool memberCanWrite(String role) =>
    role == 'owner' ||
    role == 'breeder' ||
    role == 'caretaker' ||
    role == 'staff';

bool memberCanManageMembers(String role) =>
    memberCan(role, MemberCapability.manageMembers);
