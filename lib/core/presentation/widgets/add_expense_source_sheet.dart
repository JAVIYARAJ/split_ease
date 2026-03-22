import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:split_ease/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:split_ease/features/groups/presentation/bloc/groups_bloc.dart';

/// Shows the "Add Expense" source chooser from FriendsPage.
/// The user picks to split with a Group or a specific Friend.
Future<bool?> showAddExpenseFromFriendsSheet(BuildContext context) async {
  return await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<GroupsBloc>()),
        BlocProvider.value(value: context.read<FriendsBloc>()),
        BlocProvider.value(value: context.read<ActivityBloc>()),
      ],
      child: _AddExpenseSourceSheet(parentContext: context),
    ),
  );
}

class _AddExpenseSourceSheet extends StatefulWidget {
  final BuildContext parentContext;
  const _AddExpenseSourceSheet({required this.parentContext});

  @override
  State<_AddExpenseSourceSheet> createState() => _AddExpenseSourceSheetState();
}

class _AddExpenseSourceSheetState extends State<_AddExpenseSourceSheet> {
  // 'none' | 'group' | 'friend'
  final ValueNotifier<String> _view = ValueNotifier<String>('none');

  @override
  void dispose() {
    _view.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _view,
      builder: (context, view, child) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.borderGreyLight, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    if (view != 'none')
                      GestureDetector(
                        onTap: () => _view.value = 'none',
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textBlack),
                        ),
                      ),
                    Text(
                      view == 'group'
                          ? "Select a Group"
                          : view == 'friend'
                          ? "Select a Friend"
                          : "Add Expense",
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textBlack),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: view == 'group'
                      ? _GroupList(key: const ValueKey('group'), parentContext: widget.parentContext)
                      : view == 'friend'
                      ? _FriendList(key: const ValueKey('friend'), parentContext: widget.parentContext)
                      : _ModeSelector(
                          key: const ValueKey('none'),
                          onGroupTap: () => _view.value = 'group',
                          onFriendTap: () => _view.value = 'friend',
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final VoidCallback onGroupTap;
  final VoidCallback onFriendTap;

  const _ModeSelector({super.key, required this.onGroupTap, required this.onFriendTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OptionTile(
            icon: Icons.groups_rounded,
            iconColor: AppColors.primaryTeal,
            title: "Split with a Group",
            subtitle: "Add expense inside one of your groups",
            onTap: onGroupTap,
          ),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.person_rounded,
            iconColor: AppColors.primary,
            title: "Split with a Friend",
            subtitle: "Add a non-group expense with a friend",
            onTap: onFriendTap,
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.backgroundLightGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGreyLight),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Group list shown inside the source sheet
// ─────────────────────────────────────────────────────────────────────────────

class _GroupList extends StatelessWidget {
  final BuildContext parentContext;
  const _GroupList({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        if (state.status == GroupsStatus.loading) {
          context.read<GroupsBloc>().add(LoadGroups());
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryTeal)),
          );
        }

        if (state.groups.isEmpty && state.status != GroupsStatus.loading) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                "No groups yet. Create a group first!",
                style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          itemCount: state.groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final group = state.groups[i];
            return _RowTile(
              icon: Icons.groups_rounded,
              label: group.name ?? "Group",
              sublabel: "${group.memberCount ?? 0} members",
              onTap: () async {
                final groupsBloc = context.read<GroupsBloc>();
                final friendsBloc = context.read<FriendsBloc>();
                final activityBloc = context.read<ActivityBloc>();
                Navigator.pop(ctx); // close sheet
                NavigationUtils.handleResult(
                  context: parentContext,
                  navigation: NavigationService.pushNamed(AppRoutes.addExpense, args: {'group': group, 'origin': ExpenseOrigin.group}),
                  onRefresh: () {
                    groupsBloc.add(LoadGroups());
                    friendsBloc.add(LoadFriends());
                    activityBloc.add(LoadActivities());
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Friend list shown inside the source sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FriendList extends StatelessWidget {
  final BuildContext parentContext;
  const _FriendList({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        if (state.status == FriendsStatus.loading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryTeal)),
          );
        }

        if (state.friends.isEmpty && state.status != FriendsStatus.loading) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                "No friends yet. Connect with other to build your split ease group.",
                style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          itemCount: state.friends.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final friend = state.friends[i];
            return _RowTile(
              avatarUrl: friend.imageUrl,
              isFriend: true,
              label: friend.name,
              sublabel: friend.email ?? "",
              onTap: () async {
                final groupsBloc = context.read<GroupsBloc>();
                final friendsBloc = context.read<FriendsBloc>();
                final activityBloc = context.read<ActivityBloc>();
                Navigator.pop(ctx); // close sheet
                NavigationUtils.handleResult(
                  context: parentContext,
                  navigation: NavigationService.pushNamed(AppRoutes.addExpense, args: {'friend': friend, 'origin': ExpenseOrigin.friend}),
                  onRefresh: () {
                    groupsBloc.add(LoadGroups());
                    friendsBloc.add(LoadFriends());
                    activityBloc.add(LoadActivities());
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _RowTile extends StatelessWidget {
  final IconData? icon;
  final String? avatarUrl;
  final bool isFriend;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _RowTile({this.icon, this.avatarUrl, this.isFriend = false, required this.label, required this.sublabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundLightGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGreyLight),
        ),
        child: Row(
          children: [
            if (isFriend)
              AppAvatar(url: avatarUrl, radius: 20)
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon ?? Icons.help_outline_rounded, color: AppColors.primaryTeal, size: 20),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                  ),
                  if (sublabel.isNotEmpty) Text(sublabel, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
