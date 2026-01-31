enum GroupPermission { editGroup, deleteGroup, inviteMembers }

class GroupPermissionService {
  static const String roleAdmin = 'admin';
  static const String roleMember = 'member';

  static final Map<String, Set<GroupPermission>> _permissions = {
    roleAdmin: {GroupPermission.editGroup, GroupPermission.deleteGroup, GroupPermission.inviteMembers},
    roleMember: {},
  };

  static bool hasPermission(String? role, GroupPermission permission) {
    if (role == null) return false;
    return _permissions[role.toLowerCase()]?.contains(permission) ?? false;
  }
}
