import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/presentation/bloc/groups_bloc.dart';

import 'app_avatar.dart';

/// Called from GroupsPage / FriendsPage (GroupsBloc is in the tree).
/// Reuses the already-loaded groups — no extra API call.
Future<GroupEntity?> showGroupPickerSheet(BuildContext context) {
  final groups = context.read<GroupsBloc>().state.groups;
  return _openSheet(context, groups);
}

/// Called from AddExpensePage (GroupsBloc is NOT in the tree).
/// Accepts a pre-fetched list of groups directly.
Future<GroupEntity?> showGroupPickerFromList(BuildContext context, List<GroupEntity> groups) {
  return _openSheet(context, groups,isNonGroupVisible: true);
}

Future<GroupEntity?> _openSheet(BuildContext context, List<GroupEntity> groups, {bool isNonGroupVisible = false}) {
  return showModalBottomSheet<GroupEntity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GroupPickerSheet(groups: groups,isNonGroupVisible: isNonGroupVisible,),
  );
}

class _GroupPickerSheet extends StatelessWidget {
  final List<GroupEntity> groups;
  final bool isNonGroupVisible;

  const _GroupPickerSheet({required this.groups,this.isNonGroupVisible=false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Theme.of(context).ext.borderLight, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Select a Group",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: groups.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        "No groups yet. Create a group first!",
                        style: GoogleFonts.outfit(fontSize: 15, color: Theme.of(context).ext.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    itemCount: groups.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        if(!isNonGroupVisible){
                          return SizedBox.shrink();
                        }
                        return _NonGroupTile(onTap: () => Navigator.pop(context, null));
                      }
                      final group = groups[index - 1];
                      return _GroupTile(group: group, onTap: () => Navigator.pop(context, group));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback onTap;

  const _GroupTile({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).ext.backgroundGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).ext.borderLight),
        ),
        child: Row(
          children: [
            // Icon / image
            SizedBox(
              width: 44,
              height: 44,
              child: AppAvatar(
                url: group.groupIcon,
                radius: 22, // Set radius to half of width/height (44/2)
                backgroundColor: Theme.of(context).ext.surface,
              ),
            ),
            const SizedBox(width: 14),
            // Name + member count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name ?? "Non-group expense",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (group.id == null) ...[
                    Text(
                      "Record a personal or outside expense",
                      style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).ext.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ] else ...[
                    if (group.memberCount != null)
                      Text(
                        "${group.memberCount} member${group.memberCount == 1 ? '' : 's'}",
                        style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).ext.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    if (group.memberCount == 1)
                      Text(
                        "You're the only member in this group. Add members to start splitting expenses.",
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.errorRed, fontWeight: FontWeight.w500),
                      ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Theme.of(context).ext.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _NonGroupTile extends StatelessWidget {
  final VoidCallback onTap;

  const _NonGroupTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).ext.backgroundGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).ext.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Theme.of(context).ext.surface),
              child: Icon(Icons.person_outline, color: Theme.of(context).ext.textSecondary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Non-group expense",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary),
                  ),
                  Text(
                    "Record a personal or outside expense",
                    style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).ext.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
