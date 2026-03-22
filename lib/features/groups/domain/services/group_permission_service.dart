enum GroupPermission { editGroup, deleteGroup, inviteMembers, addMembers,exitGroup }

class GroupPermissionService {
  static const String roleAdmin = 'admin';
  static const String roleMember = 'user';

  static final Map<String, Set<GroupPermission>> _permissions = {
    roleAdmin: {
      GroupPermission.editGroup,
      GroupPermission.deleteGroup,
      GroupPermission.inviteMembers,
      GroupPermission.addMembers,
      GroupPermission.exitGroup,
    },
    roleMember: {
      GroupPermission.inviteMembers,
      GroupPermission.exitGroup,
    },
  };

  static bool hasPermission(String? role, GroupPermission permission) {
    if (role == null) return false;
    return _permissions[role.toLowerCase()]?.contains(permission) ?? false;
  }
}
