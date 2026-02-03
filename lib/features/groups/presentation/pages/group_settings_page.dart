import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/app_image_view.dart';
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

class GroupSettingsPage extends StatefulWidget {
  final String groupId;

  const GroupSettingsPage({super.key, required this.groupId});

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  bool _canPop = false;

  void _onBack(BuildContext context) {
    setState(() {
      _canPop = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<GroupSettingsBloc>().state;
        final hasChanges = state is GroupSettingsLoaded ? state.hasChanges : false;
        Navigator.pop(context, hasChanges);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<GroupSettingsBloc>()..add(LoadGroupSettings(widget.groupId)),
      child: Builder(
        builder: (context) {
          return PopScope(
            canPop: _canPop,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _onBack(context);
            },
            child: Scaffold(
              backgroundColor: AppColors.backgroundWhite,
              body: BlocConsumer<GroupSettingsBloc, GroupSettingsState>(
                listener: (context, state) {
                  if (state is GroupSettingsError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                  } else if (state is GroupActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                    Navigator.pop(context, true);
                  }
                },
                builder: (context, state) {
                  if (state is GroupSettingsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GroupSettingsLoaded) {
                    return _GroupSettingsContent(group: state.group, onBack: () => _onBack(context));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupSettingsContent extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback onBack;

  const _GroupSettingsContent({required this.group, required this.onBack});

  @override
  @override
  Widget build(BuildContext context) {
    // Find current user's member entity
    final currentUserMember = group.members?.cast<GroupMemberEntity?>().firstWhere(
          (m) => m?.userId == (context.read<GroupSettingsBloc>().state is GroupSettingsLoaded ? (context.read<GroupSettingsBloc>().state as GroupSettingsLoaded).currentUserId : null),
          orElse: () => null,
    );

    final userRole = currentUserMember?.role;

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, userRole),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 16),
            _buildSectionHeader('General'),
            // _buildSettingsTile(
            //   icon: Icons.person_add_rounded,
            //   title: 'Add people to group',
            //   onTap: () {},
            //   iconBgColor: AppColors.primary.withValues(alpha: 0.1),
            //   iconColor: AppColors.primary,
            // ),
            _buildDivider(),
            
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

            const SizedBox(height: 24),
            _buildSectionHeader('Members'),
            _buildMembersList(group),

            const SizedBox(height: 24),
            
            // Danger Zone - Permission Check
             if (GroupPermissionService.hasPermission(userRole, GroupPermission.deleteGroup)) ...[
              _buildSectionHeader('Danger Zone', color: AppColors.errorRed),
              _buildSettingsTile(
                icon: Icons.exit_to_app_rounded,
                title: 'Leave Group',
                onTap: () {
                  AppAlerts.showError(context, "Cannot leave group with outstanding debts.");
                },
                iconBgColor: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFFB8C00),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Group',
                titleColor: AppColors.errorRed,
                onTap: () {
                  //context.read<GroupSettingsBloc>().add(DeleteGroupEvent(group.id!));
                },
                iconBgColor: const Color(0xFFFFEBEE),
                iconColor: const Color(0xFFE53935),
              ),
             ],
            const SizedBox(height: 40),
          ]),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String? userRole) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textBlack),
        onPressed: onBack,
      ),
      actions: [
        // Edit Button - Permission Check
        if (GroupPermissionService.hasPermission(userRole, GroupPermission.editGroup))
          TextButton(
            onPressed: () {
              NavigationService.pushNamed(AppRoutes.createGroup, args: {'is_edit': true, 'group': group}).then((value) {
                if (value == true) {
                  if (context.mounted) {
                    context.read<GroupSettingsBloc>().add(LoadGroupSettings(group.id!, hasChanges: true));
                  }
                }
              });
            },
            child: Text(
              "Edit",
              style: GoogleFonts.openSans(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Hero(
              tag: 'group_image_${group.id}',
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary.withValues(alpha: 0.1),
                  image: group.groupIcon != null ? DecorationImage(image: NetworkImage(group.groupIcon!), fit: BoxFit.cover) : null,
                ),
                child: group.groupIcon == null ? const Icon(Icons.group, color: AppColors.primary, size: 40) : null,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                group.name ?? 'Group Name',
                style: GoogleFonts.openSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textBlack),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${group.members?.length ?? 0} members',
                    style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w700, color: color ?? AppColors.textGrey, letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildMembersList(GroupEntity group) {
    if (group.members == null || group.members!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: List.generate(group.members!.length, (index) {
        final member = group.members![index];
        return Column(children: [_buildMemberTile(member), if (index != group.members!.length - 1) _buildDivider()]);
      }),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconBgColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBgColor ?? AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500, color: titleColor ?? AppColors.textBlack),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: AppColors.borderGrey.withValues(alpha: 0.8), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(GroupMemberEntity member) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          (member.avtar == null || member.avtar!.isEmpty)
              ? Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.person, color: Colors.grey.shade400, size: 24),
                )
              : AppImageView(url: member.avtar, height: 44, width: 44, radius: 12),
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
                        style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.role?.toLowerCase() == 'admin') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          'ADMIN',
                          style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member.email ?? "-",
                  style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderGrey.withValues(alpha: 0.3),
      indent: 88,
      // Aligned with text start (24 padding + 40 icon size + 16 gap ~= 80)
      endIndent: 24,
    );
  }
}
