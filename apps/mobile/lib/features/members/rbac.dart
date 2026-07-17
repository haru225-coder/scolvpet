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
      return capability == MemberCapability.writeHamster;
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
