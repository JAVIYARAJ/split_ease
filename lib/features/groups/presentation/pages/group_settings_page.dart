import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/presentation/bloc/group_settings_bloc.dart';
import 'package:split_ease/injection_container.dart';


class GroupSettingsPage extends StatelessWidget {
  final String groupId;

  const GroupSettingsPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<GroupSettingsBloc>()..add(LoadGroupSettings(groupId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Group settings'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        body: BlocConsumer<GroupSettingsBloc, GroupSettingsState>(
          listener: (context, state) {
            if (state is GroupSettingsError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is GroupActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              Navigator.pop(context, true); // Return true to refresh previous screen
            }
          },
          builder: (context, state) {
             if (state is GroupSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GroupSettingsLoaded) {
              return _GroupSettingsContent(group: state.group);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _GroupSettingsContent extends StatelessWidget {
  final GroupEntity group;

  const _GroupSettingsContent({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final userCubit = context.read<AppUserCubit>(); // To check current user for "you" logic if needed

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: group.groupIcon != null
                        ? DecorationImage(
                            image: NetworkImage(group.groupIcon!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.teal, // Placeholder color
                  ),
                  child: group.groupIcon == null
                      ? const Icon(Icons.group, color: Colors.white, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    group.name ?? 'Group Name',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to edit group name/icon if implemented
                  },
                  child: const Text('Edit', style: TextStyle(color: Colors.teal)),
                )
              ],
            ),
          ),
          Divider(color: AppColors.borderGrey,height: 0.2,),

          // Group members
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Group members', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
          
          _buildActionItem(Icons.person_add_alt_1_outlined, 'Add people to group', () {}),
          _buildActionItem(Icons.link, 'Invite via link', () {}),
          
          if (group.members != null)
             ...group.members!.map((member) => _buildMemberItem(member)).toList(),

          const SizedBox(height: 20),

          // Leave group
          ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Leave group'),
              subtitle: const Text('You can\'t leave this group because you have outstanding debts with other group members.'), // Placeholder logic
              onTap: () {
                  // Check debts logic or just trigger event
                  // context.read<GroupSettingsBloc>().add(LeaveGroupEvent(group.id!));
              },
          ),
          
           // Delete group
          ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete group', style: TextStyle(color: Colors.red)),
              onTap: () {
                 context.read<GroupSettingsBloc>().add(DeleteGroupEvent(group.id!));
              },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildMemberItem(dynamic member) {
    return ListTile(
      title: Text(member.fullName),
      subtitle: Text(member.email),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Placeholder for debts. Need debt calculation logic.
          // For now showing empty or static
        ],
      ),
    );
  }
}
