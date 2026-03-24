import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/domain/services/group_permission_service.dart';
import 'package:split_ease/features/groups/presentation/utils/group_settings_logic_helper.dart';
import '../../domain/entities/group_member_entity.dart';

class GroupMemberOptionsSheet extends StatelessWidget {
  final GroupMemberEntity member;
  final double balance;
  final bool isCurrentUser;
  final String? currentUserRole;
  final bool isCreator;
  final bool isTargetCreator;
  final VoidCallback? onLeaveGroup;
  final VoidCallback? onRemoveFromGroup;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;
  final VoidCallback? onViewSettings;

  const GroupMemberOptionsSheet({
    super.key,
    required this.member,
    required this.balance,
    required this.isCurrentUser,
    this.currentUserRole,
    this.isCreator = false,
    this.isTargetCreator = false,
    this.onLeaveGroup,
    this.onRemoveFromGroup,
    this.onPromote,
    this.onDemote,
    this.onViewSettings,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDebt = balance.abs() > 0.01;
    final bool isOwed = balance > 0.01;
    final bool owes = balance < -0.01;

    return Container(
      padding: const EdgeInsets.only(bottom: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.borderGrey.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Member Profile Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.backgroundLightGrey,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: AppAvatar(url: member.avtar, radius: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.fullName ?? "Unknown",
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textBlack),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member.email ?? "-",
                          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (hasDebt)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isOwed ? "gets back" : "owes",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: isOwed ? AppColors.successGreen : AppColors.errorRed,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          "₹${balance.abs().toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            color: isOwed ? AppColors.successGreen : AppColors.errorRed,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Role Management Options (Accessible to Admins/Creator)
          if (GroupPermissionService.hasPermission(currentUserRole, GroupPermission.changeRole, isOwner: isCreator)) ...[
            if (member.role?.toLowerCase() != 'admin')
              _buildOptionTile(
                icon: Icons.verified_user_outlined,
                title: "Promote to admin",
                subtitle: "Admins can manage group members, settings, and expenses.",
                onTap: onPromote,
              ),
            if (member.role?.toLowerCase() == 'admin' && !isTargetCreator && !isCurrentUser)
              _buildOptionTile(
                icon: Icons.person_outline_rounded,
                title: "Demote to member",
                subtitle: isCurrentUser
                    ? "Warning: You will lose administrative access to this group."
                    : "This member will no longer have administrative permissions.",
                onTap: onDemote,
              ),
          ],

          if (isCurrentUser) ...[
            // Current User Options: Leave Group
            _buildOptionTile(
              icon: Icons.logout_rounded,
              title: "Leave group",
              subtitle: GroupSettingsLogicHelper.getLeaveGroupWarning(isCreator: isCreator, hasDebt: hasDebt),
              onTap: GroupSettingsLogicHelper.canLeaveGroup(isCreator: isCreator, hasDebt: hasDebt) ? onLeaveGroup : null,
              isDestructive: true,
              isDisabled: !GroupSettingsLogicHelper.canLeaveGroup(isCreator: isCreator, hasDebt: hasDebt),
            ),
          ] else ...[
            // Other Member Options
            if (GroupPermissionService.hasPermission(currentUserRole, GroupPermission.removeMember, isOwner: isCreator))
              _buildOptionTile(
                icon: Icons.person_remove_outlined,
                title: "Remove from group",
                subtitle: GroupSettingsLogicHelper.getRemovalWarning(
                  isTargetCreator: isTargetCreator,
                  targetBalance: balance,
                  isCurrentUserCreator: isCreator,
                  currentUserRole: currentUserRole,
                  targetRole: member.role,
                ),
                onTap: GroupSettingsLogicHelper.canRemoveMember(
                  isTargetCreator: isTargetCreator,
                  targetBalance: balance,
                  isCurrentUserCreator: isCreator,
                  currentUserRole: currentUserRole,
                  targetRole: member.role,
                ) ? onRemoveFromGroup : null,
                isDestructive: true,
                isDisabled: !GroupSettingsLogicHelper.canRemoveMember(
                  isTargetCreator: isTargetCreator,
                  targetBalance: balance,
                  isCurrentUserCreator: isCreator,
                  currentUserRole: currentUserRole,
                  targetRole: member.role,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool isDisabled = false,
  }) {
    final Color color = isDestructive ? AppColors.errorRed : AppColors.textBlack;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDestructive && !isDisabled ? AppColors.errorRed.withValues(alpha: 0.1) : AppColors.borderGrey.withValues(alpha: 0.4),
          ),
          boxShadow: [if (!isDisabled) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDestructive ? AppColors.errorRed.withValues(alpha: 0.08) : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color.withValues(alpha: isDisabled ? 0.3 : 1.0), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: color.withValues(alpha: isDisabled ? 0.3 : 1.0),
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppColors.textGrey.withValues(alpha: isDisabled ? 0.6 : 0.8),
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isDisabled)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.backgroundLightGrey, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textGrey.withValues(alpha: 0.5), size: 12),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
