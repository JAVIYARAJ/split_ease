import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_member_balance_entity.dart';
import '../../domain/entities/group_member_entity.dart';
import '../../domain/services/group_permission_service.dart';

/// A utility class that encapsulates the complex permission and financial
/// logic for the Group Settings screen and Member actions.
class GroupSettingsLogicHelper {
  final GroupEntity group;
  final String? currentUserId;
  final List<GroupMemberBalanceEntity>? memberBalances;
  final double? overallBalance;

  GroupSettingsLogicHelper({
    required this.group,
    this.currentUserId,
    this.memberBalances,
    this.overallBalance,
  });

  /// The member object representing the user currently viewing the settings.
  late final GroupMemberEntity? currentUserMember = group.members?.cast<GroupMemberEntity?>().firstWhere(
        (m) => m?.userId == currentUserId,
        orElse: () => null,
      );

  /// The role (e.g., 'admin', 'user') of the current user within this group.
  late final String? userRole = currentUserMember?.role;

  /// Whether the current user is the original creator of this group.
  late final bool isCreator = group.createdBy?.id == currentUserId;

  /// Whether any member in the group has a non-zero balance.
  late final bool hasGroupDebts = (memberBalances ?? []).any((b) => b.balance.abs() > 0.01);

  /// The current user's personal balance in the group.
  /// Primarily uses the [overallBalance] from the BLoC state, falling back
  /// to the [memberBalances] list if necessary.
  late final double currentUserBalance = overallBalance ??
      (memberBalances ?? []).cast<GroupMemberBalanceEntity?>().firstWhere(
            (b) => b?.userId == currentUserId,
            orElse: () => null,
          )?.balance ??
      0.0;

  /// Whether the current user has any outstanding debts or credits in the group.
  late final bool isCurrentUserUnsettled = currentUserBalance.abs() > 0.01;

  // --- LEAVE GROUP LOGIC ---

  /// Whether the current user is blocked from leaving the group.
  /// 1. Creators cannot leave (they must delete the group instead).
  /// 2. Members with unsettled balances (debts/credits) cannot leave.
  bool get blockLeave => isCreator || isCurrentUserUnsettled;

  /// Descriptive message explaining why the "Leave Group" action is disabled.
  String? get leaveSubtitle => getLeaveGroupWarning(isCreator: isCreator, hasDebt: isCurrentUserUnsettled);

  /// Helper for static-context leave evaluation (e.g. Action Sheets).
  static bool canLeaveGroup({required bool isCreator, required bool hasDebt}) {
    return !isCreator && !hasDebt;
  }

  /// Helper for static-context leave warnings (e.g. Action Sheets).
  static String? getLeaveGroupWarning({required bool isCreator, required bool hasDebt}) {
    if (isCreator) {
      return "The creator cannot leave the group.";
    }
    if (hasDebt) {
      return "You can't leave this group because you have outstanding debts with other group members. Please make sure all of your debts have been settled up, and try again.";
    }
    return null;
  }

  // --- DELETE GROUP LOGIC ---

  /// Whether the "Delete Group" action should be blocked.
  /// Groups with active debts cannot be deleted to protect financial records.
  bool get blockDelete => hasGroupDebts;

  /// Descriptive message explaining why "Delete Group" is blocked.
  String? get deleteSubtitle =>
      hasGroupDebts ? "You cannot delete this group because there are still unsettled expenses among members." : null;

  // --- MEMBER REMOVAL LOGIC ---

  /// Hierarchical logic for removing a member from the group.
  /// [isTargetCreator]: Is the person we want to remove the creator? (Always false)
  /// [targetRole]: the role of the person being evaluated for removal.
  /// [targetBalance]: the balance of the person being evaluated for removal. (Must be 0)
  static bool canRemoveMember({
    required bool isCurrentUserCreator,
    required String? currentUserRole,
    required bool isTargetCreator,
    required String? targetRole,
    required double targetBalance,
  }) {
    // 1. You can never remove the creator.
    if (isTargetCreator) return false;

    // 2. You can never remove someone with an unsettled balance.
    if (targetBalance.abs() > 0.01) return false;

    // 3. The Group Creator can remove anyone else (as long as balance is 0).
    if (isCurrentUserCreator) return true;

    // 4. Admins can remove regular users only.
    if (currentUserRole == GroupPermissionService.roleAdmin && targetRole == GroupPermissionService.roleMember) {
      return true;
    }

    // 5. Regular users cannot remove anyone.
    return false;
  }

  /// Label explaining why a member cannot be removed.
  static String? getRemovalWarning({
    required bool isTargetCreator,
    required double targetBalance,
    required bool isCurrentUserCreator,
    required String? currentUserRole,
    required String? targetRole,
  }) {
    if (isTargetCreator) return "The group creator cannot be removed.";
    if (targetBalance.abs() > 0.01) return "Members with unsettled balances cannot be removed.";
    
    // Check hierarchy
    if (!isCurrentUserCreator && 
        currentUserRole == GroupPermissionService.roleAdmin && 
        targetRole == GroupPermissionService.roleAdmin) {
      return "Only the group creator can remove another administrator.";
    }
    
    return null;
  }
}
