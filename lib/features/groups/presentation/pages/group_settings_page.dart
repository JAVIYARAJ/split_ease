import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/presentation/bloc/group_settings_bloc.dart';
import 'package:split_ease/injection_container.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import '../../domain/entities/group_member_entity.dart';
import '../widgets/invite_qr_dialog.dart';
import '../../domain/services/group_permission_service.dart';
import '../widgets/group_member_options_sheet.dart';
import '../../domain/entities/group_member_balance_entity.dart';
// intl import removed

class GroupSettingsPage extends StatefulWidget {
  final String groupId;

  const GroupSettingsPage({super.key, required this.groupId});

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  final ValueNotifier<bool> _canPop = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _canPop.dispose();
    super.dispose();
  }

  void _onBack(BuildContext context) {
    _canPop.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<GroupSettingsBloc>().state;
        final hasChanges = state is GroupSettingsLoaded ? state.hasChanges : false;
        NavigationService.pop(arg: hasChanges);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _canPop,
      builder: (context, canPop, child) {
        return BlocProvider(
          create: (context) => sl<GroupSettingsBloc>()..add(LoadGroupSettings(widget.groupId)),
          child: Builder(
            builder: (context) {
              return PopScope(
                canPop: canPop,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) return;
                  _onBack(context);
                },
                child: Scaffold(
                  backgroundColor: AppColors.backgroundLightGrey, // Modern grey background
                  body: BlocConsumer<GroupSettingsBloc, GroupSettingsState>(
                    listener: (context, state) {
                      if (state is GroupSettingsError) {
                        AppAlerts.showError(context, state.message);
                      } else if (state is GroupActionSuccess) {
                        AppAlerts.showSuccess(context, state.message);
                        if (state.shouldPop) {
                          NavigationService.pop(arg: 'refresh-and-pop');
                        }
                      }
                    },
                    builder: (context, state) {
                      GroupEntity? group;
                      String? currentUserId;

                      if (state is GroupSettingsLoaded) {
                        group = state.group;
                        currentUserId = state.currentUserId;
                      } else if (state is GroupSettingsLoading) {
                        group = state.group;
                        currentUserId = state.currentUserId;
                      } else if (state is GroupSettingsError) {
                        group = state.group;
                        currentUserId = state.currentUserId;
                      }

                      if (group != null) {
                        return Stack(
                          children: [
                            _GroupSettingsContent(
                              group: group,
                              onBack: () => _onBack(context),
                              currentUserId: currentUserId,
                              memberBalances: state is GroupSettingsLoaded
                                  ? state.memberBalances
                                  : (state is GroupSettingsLoading ? state.memberBalances : (state is GroupSettingsError ? state.memberBalances : null)),
                            ),
                            if (state is GroupSettingsLoading)
                              Container(
                                color: Colors.black12,
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                          ],
                        );
                      }

                      if (state is GroupSettingsLoading) {
                        return const _GroupSettingsShimmer();
                      }
                      
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _GroupSettingsContent extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback onBack;
  final String? currentUserId;
  final List<GroupMemberBalanceEntity>? memberBalances;

  const _GroupSettingsContent({
    required this.group,
    required this.onBack,
    this.currentUserId,
    this.memberBalances,
  });

  @override
  Widget build(BuildContext context) {
    // Use the passed currentUserId to find the user's role
    final currentUserMember = group.members?.cast<GroupMemberEntity?>().firstWhere(
          (m) => m?.userId == currentUserId,
          orElse: () => null,
    );

    final String? userRole = currentUserMember?.role;
    final bool isCreator = group.createdBy?.id == currentUserId;

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, userRole),
        SliverList(
          delegate: SliverChildListDelegate([
            
            // General Settings Section
            if (GroupPermissionService.hasPermission(userRole, GroupPermission.addMembers) || 
                GroupPermissionService.hasPermission(userRole, GroupPermission.inviteMembers)) ...[
              _buildSectionHeader('General'),
              _buildInsetGroup(
                children: [
                  if (GroupPermissionService.hasPermission(userRole, GroupPermission.addMembers)) ...[
                    _buildSettingsTile(
                      icon: Icons.person_add_rounded,
                      title: 'Add people to group',
                      onTap: () {
                        NavigationService.pushNamed(
                          AppRoutes.addMembers,
                          args: {'groupId': group.id!},
                        ).then((value) {
                          if (value == true && context.mounted) {
                            context.read<GroupSettingsBloc>().add(LoadGroupSettings(group.id!, hasChanges: true));
                          }
                        });
                      },
                      iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                      iconColor: AppColors.primary,
                    ),
                    if (GroupPermissionService.hasPermission(userRole, GroupPermission.inviteMembers))
                       _buildDivider(),
                  ],
                  
                  // Invite QR - Permission Check
                  if (GroupPermissionService.hasPermission(userRole, GroupPermission.inviteMembers)) ...[
                    _buildSettingsTile(
                      icon: Icons.qr_code_rounded,
                      title: 'Invite by QR',
                      onTap: () {
                        if (group.inviteCode != null) {
                          showDialog(
                            context: context,
                            builder: (context) => InviteQrDialog(
                              inviteCode: group.inviteCode!,
                              groupName: group.name ?? "Group",
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No invite code available")),
                          );
                        }
                      },
                      iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                      iconColor: AppColors.primary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
            ],
            
            // Members Section
            _buildSectionHeader('Members'),
            _buildInsetGroup(
              children: _buildMembersList(context, group, userRole, isCreator),
            ),

            const SizedBox(height: 24),
            
            // Danger Zone Section
            if (GroupPermissionService.hasPermission(userRole, GroupPermission.exitGroup) || 
                GroupPermissionService.hasPermission(userRole, GroupPermission.deleteGroup)) ...[
              _buildSectionHeader('Danger Zone', color: AppColors.errorRed),
              _buildInsetGroup(
                children: [
                   if (GroupPermissionService.hasPermission(userRole, GroupPermission.exitGroup)) ...[
                    _buildSettingsTile(
                      icon: Icons.exit_to_app_rounded,
                      title: 'Leave Group',
                      onTap: () {
                        final currentUser = group.members?.cast<GroupMemberEntity?>().firstWhere(
                              (m) => m?.userId == currentUserId,
                              orElse: () => null,
                        );
                        if (currentUser != null) {
                          final balanceEntity = (memberBalances ?? []).cast<GroupMemberBalanceEntity?>().firstWhere(
                                (b) => b?.userId == currentUser.userId,
                                orElse: () => null,
                          );
                          _showMemberOptions(context, currentUser, balanceEntity?.balance ?? 0.0, true, currentUser.role, isCreator);
                        }
                      },
                      iconBgColor: const Color(0xFFFFF3E0),
                      iconColor: const Color(0xFFFB8C00),
                    ),
                    if (GroupPermissionService.hasPermission(userRole, GroupPermission.deleteGroup))
                      _buildDivider(),
                  ],

                  if (GroupPermissionService.hasPermission(userRole, GroupPermission.deleteGroup))
                    _buildSettingsTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete Group',
                      titleColor: AppColors.errorRed,
                      onTap: () {
                         _showDeleteConfirmation(context);
                      },
                      iconBgColor: const Color(0xFFFFEBEE),
                      iconColor: const Color(0xFFE53935),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 40),
          ]),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded, color: AppColors.errorRed, size: 32),
              ),
              const SizedBox(height: 24),
              Text(
                "Delete Group?",
                style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textBlack),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to delete \"${group.name}\"? This will permanently remove all expenses, settlements, and member history. This action cannot be undone.",
                style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textGrey, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.borderGrey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("Cancel", style: GoogleFonts.openSans(fontWeight: FontWeight.w700, color: AppColors.textBlack)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<GroupSettingsBloc>().add(DeleteGroupEvent(group.id!));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text("Delete", style: GoogleFonts.openSans(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSliverAppBar(BuildContext context, String? userRole) {
    return SliverAppBar(
      expandedHeight: 250, // Increased height
      pinned: true,
      backgroundColor: AppColors.backgroundLightGrey,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textBlack),
        ),
        onPressed: onBack,
      ),
      actions: [
        // Edit Button - Permission Check
        if (GroupPermissionService.hasPermission(userRole, GroupPermission.editGroup))
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                NavigationService.pushNamed(AppRoutes.createGroup, args: {'is_edit': true, 'group': group}).then((value) {
                  if (value == true) {
                    if (context.mounted) {
                      context.read<GroupSettingsBloc>().add(LoadGroupSettings(group.id!, hasChanges: true));
                    }
                  }
                });
              },
              style: TextButton.styleFrom(
                 backgroundColor: Colors.white,
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                "Edit",
                style: GoogleFonts.openSans(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Hero(
              tag: 'group_image_${group.id}',
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  image: group.groupIcon != null ? DecorationImage(image: NetworkImage(group.groupIcon!), fit: BoxFit.cover) : null,
                ),
                child: group.groupIcon == null ? const Icon(Icons.group, color: AppColors.primary, size: 40) : null,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                group.name ?? 'Group Name',
                style: GoogleFonts.openSans(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textBlack),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_alt_rounded, size: 14, color: AppColors.textGrey),
                  const SizedBox(width: 6),
                  Text(
                    '${group.members?.length ?? 0} members',
                    style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w700, color: color ?? AppColors.textGrey, letterSpacing: 0.8),
      ),
    );
  }
  
  Widget _buildInsetGroup({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  List<Widget> _buildMembersList(BuildContext context, GroupEntity group, String? currentUserRole, bool isCreator) {
    if (group.members == null || group.members!.isEmpty) {
      return [const SizedBox.shrink()];
    }

    final balances = memberBalances ?? [];
    
    // Sort members: Current user first
    final List<GroupMemberEntity> sortedMembers = List.from(group.members!);
    sortedMembers.sort((a, b) {
      if (a.userId == currentUserId) return -1;
      if (b.userId == currentUserId) return 1;
      return 0;
    });

    return List.generate(sortedMembers.length, (index) {
      final member = sortedMembers[index];
      // Find balance for this member
      final balanceEntity = balances.cast<GroupMemberBalanceEntity?>().firstWhere(
            (b) => b?.userId == member.userId,
            orElse: () => null,
      );
      final double balance = balanceEntity?.balance ?? 0.0;
      final bool isCurrentUser = member.userId == currentUserId;
      
      final bool isFirst = index == 0;
      final bool isLast = index == group.members!.length - 1;

      return Column(children: [
        _buildMemberTile(context, member, balance, isCurrentUser, isFirst, isLast, currentUserRole, isCreator), 
        if (!isLast) _buildDivider()
      ]);
    });
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconBgColor,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Fits strictly if first/last
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor ?? AppColors.primary.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor ?? AppColors.textBlack),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: AppColors.borderGrey.withValues(alpha: 0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, GroupMemberEntity member, double balance, bool isCurrentUser, bool isFirst, bool isLast, String? currentUserRole, bool isCreator) {
    final bool isOwed = balance > 0.01;
    final bool owes = balance < -0.01;
    
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(16) : Radius.zero,
      bottom: isLast ? const Radius.circular(16) : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: () => _showMemberOptions(context, member, balance, isCurrentUser, currentUserRole, isCreator),
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              AppAvatar(
                url: member.avtar,
                radius: 24,
                backgroundColor: AppColors.backgroundLightGrey,
                iconColor: Colors.grey.shade400,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            member.fullName ?? "Unknown",
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textBlack),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                             const SizedBox(width: 6),
                             Text("(you)", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                        ],
                        if (member.role?.toLowerCase() == 'admin') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              'ADMIN',
                              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
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
              if (isOwed || owes) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isOwed ? "gets back" : "owes",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: isOwed ? AppColors.successGreen : AppColors.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "₹${balance.abs().toStringAsFixed(2)}",
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: isOwed ? AppColors.successGreen : AppColors.errorRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMemberOptions(BuildContext context, GroupMemberEntity member, double balance, bool isCurrentUser, String? currentUserRole, bool isCreator) {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GroupMemberOptionsSheet(
        member: member, 
        balance: balance, 
        isCurrentUser: isCurrentUser,
        currentUserRole: currentUserRole,
        isCreator: isCreator,
        onLeaveGroup: () {
          Navigator.pop(ctx);
          context.read<GroupSettingsBloc>().add(LeaveGroupEvent(group.id!));
        },
        onRemoveFromGroup: () {
          Navigator.pop(ctx);
          context.read<GroupSettingsBloc>().add(RemoveMemberEvent(group.id!, member.userId!));
        },
        onViewSettings: () {
          Navigator.pop(ctx);
          // Navigation to user profile or similar
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderGrey.withValues(alpha: 0.2),
      indent: 84, // Align with text start
      endIndent: 0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton for Group Settings Page
// ─────────────────────────────────────────────────────────────────────────────

class _GroupSettingsShimmer extends StatelessWidget {
  const _GroupSettingsShimmer();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        slivers: [
          // Simulated App Bar
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.backgroundLightGrey,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textBlack),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Bone.square(
                    size: 90,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  const SizedBox(height: 16),
                  Bone.text(width: 140, fontSize: 24),
                  const SizedBox(height: 8),
                  Bone.text(width: 80, fontSize: 16),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // General Section
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 0, 24, 8),
                child: Bone.text(width: 80, fontSize: 13),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildFakeSettingsTile(),
                    Divider(height: 1, thickness: 1, color: AppColors.borderGrey.withValues(alpha: 0.2), indent: 84, endIndent: 0),
                    _buildFakeSettingsTile(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Members Section
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 0, 24, 8),
                child: Bone.text(width: 80, fontSize: 13),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      _buildFakeMemberTile(),
                      if (i < 2) Divider(height: 1, thickness: 1, color: AppColors.borderGrey.withValues(alpha: 0.2), indent: 84, endIndent: 0),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildFakeSettingsTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Bone.square(size: 40, borderRadius: BorderRadius.circular(10)),
          const SizedBox(width: 16),
          Expanded(child: Bone.text(width: 150, fontSize: 16)),
          Bone.icon(size: 16),
        ],
      ),
    );
  }

  Widget _buildFakeMemberTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Bone.square(size: 48, borderRadius: BorderRadius.circular(14)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Bone.text(width: 120, fontSize: 16),
                SizedBox(height: 6),
                Bone.text(width: 180, fontSize: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

