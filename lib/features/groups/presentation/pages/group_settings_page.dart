import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/presentation/widgets/app_image_view.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/presentation/bloc/group_settings_bloc.dart';
import 'package:split_ease/injection_container.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import '../../domain/entities/group_member_entity.dart';

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
      child: Builder(builder: (context) {
        return PopScope(
          canPop: _canPop,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _onBack(context);
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundLightGrey,
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
                  return _GroupSettingsContent(
                    group: state.group,
                    onBack: () => _onBack(context),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      }),
    );
  }
}

class _GroupSettingsContent extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback onBack;

  const _GroupSettingsContent({required this.group, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionHeader('General'),
              const SizedBox(height: 12),
              _buildActionsSection(context),
              const SizedBox(height: 32),
              _buildSectionHeader('Members'),
              const SizedBox(height: 12),
              _buildMembersSection(group),
              const SizedBox(height: 32),
              _buildSectionHeader('Danger Zone', color: AppColors.errorRed),
              const SizedBox(height: 12),
              _buildDangerZone(context),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.backgroundWhite,
      surfaceTintColor: AppColors.backgroundWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textBlack),
        ),
        onPressed: onBack,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            onPressed: () {
               NavigationService.pushNamed(
                AppRoutes.createGroup,
                args: {
                  'is_edit': true,
                  'group': group,
                },
              ).then((value) {
                if (value == true) {
                  if (context.mounted) {
                    context.read<GroupSettingsBloc>().add(LoadGroupSettings(group.id!, hasChanges: true));
                  }
                }
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                 color: AppColors.primaryTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_rounded, size: 20, color: AppColors.primaryTeal),
            ),
          ),
        )
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundLightGrey,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (group.groupIcon != null)
                Opacity(
                  opacity: 0.15,
                  child: Image.network(
                    group.groupIcon!,
                    fit: BoxFit.cover,
                  ),
                ),
              Container(
                 decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryTeal.withValues(alpha: 0.1),
                       AppColors.backgroundLightGrey.withValues(alpha: 0.8),
                      AppColors.backgroundLightGrey,
                    ],
                  ),
                ),
              ),
              Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60), 
              Hero(
                tag: 'group_image_${group.id}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: group.groupIcon != null
                        ? DecorationImage(image: NetworkImage(group.groupIcon!), fit: BoxFit.cover)
                        : null,
                     color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  ),
                   child: group.groupIcon == null
                      ? const Icon(Icons.group, color: AppColors.primaryTeal, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                group.name ?? 'Group Name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBlack,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Text(
                  '${group.members?.length ?? 0} Members',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
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

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color ?? AppColors.textGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.person_add_rounded,
            title: 'Add people to group',
            onTap: () {},
            iconBgColor: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF1E88E5),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Divider(height: 1, color: AppColors.borderGrey.withValues(alpha: 0.3)),
          ),
          _buildSettingsTile(
            icon: Icons.link_rounded,
            title: 'Invite via link',
            onTap: () {},
            iconBgColor: const Color(0xFFF3E5F5),
            iconColor: const Color(0xFF8E24AA),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(GroupEntity group) {
    if (group.members == null || group.members!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: group.members!.length,
        separatorBuilder: (context, index) => Padding(
           padding: const EdgeInsets.only(left: 64),
          child: Divider(
            height: 1,
            color: AppColors.borderGrey.withValues(alpha: 0.3),
          ),
        ),
        itemBuilder: (context, index) {
          return _buildMemberTile(group.members![index]);
        },
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.exit_to_app_rounded,
            title: 'Leave Group',
             onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot leave group with outstanding debts.")));
            },
             iconBgColor: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFFB8C00),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Divider(height: 1, color: AppColors.borderGrey.withValues(alpha: 0.3)),
          ),
          _buildSettingsTile(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Group',
             titleColor: AppColors.errorRed,
             onTap: () {
              context.read<GroupSettingsBloc>().add(DeleteGroupEvent(group.id!));
            },
            iconBgColor: const Color(0xFFFFEBEE),
            iconColor: const Color(0xFFE53935),
          ),
        ],
      ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor ?? AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor ?? AppColors.primaryTeal, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? AppColors.textBlack,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.borderGrey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile(GroupMemberEntity member) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          (member.avtar == null || member.avtar!.isEmpty)
              ? Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.person, color: Colors.grey.shade400, size: 28),
                )
              : AppImageView(
                  url: member.avtar,
                  height: 48,
                  width: 48,
                  radius: 16,
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.role?.toLowerCase() == 'admin') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1), // Very light teal
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ADMIN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryTealDark,
                            letterSpacing: 0.5
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member.email ?? "-",
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
