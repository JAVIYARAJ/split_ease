import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';

class GroupPermissionService {
  static const String roleOwner = 'owner';
  static const String roleAdmin = 'admin';
  static const String roleMember = 'user';

  static final Map<String, Set<GroupPermission>> _permissions = {
    roleOwner: {
      GroupPermission.editGroup,
      GroupPermission.deleteGroup,
      GroupPermission.inviteMembers,
      GroupPermission.addMembers,
      GroupPermission.exitGroup,
      GroupPermission.removeMember,
      GroupPermission.changeRole,
    },
    roleAdmin: {
      GroupPermission.editGroup,
      GroupPermission.inviteMembers,
      GroupPermission.addMembers,
      GroupPermission.exitGroup,
      GroupPermission.removeMember,
      GroupPermission.changeRole,
    },
    roleMember: {
      GroupPermission.inviteMembers,
      GroupPermission.exitGroup,
    },
  };

  static bool hasPermission(String? role, GroupPermission permission, {bool isOwner = false}) {
    if (isOwner) return true; // Owner always has all permissions
    if (role == null) return false;
    return _permissions[role.toLowerCase()]?.contains(permission) ?? false;
  }
}
