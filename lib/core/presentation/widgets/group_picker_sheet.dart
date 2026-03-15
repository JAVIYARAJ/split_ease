import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/presentation/bloc/groups_bloc.dart';

/// Called from GroupsPage / FriendsPage (GroupsBloc is in the tree).
/// Reuses the already-loaded groups — no extra API call.
Future<GroupEntity?> showGroupPickerSheet(BuildContext context) {
  final groups = context.read<GroupsBloc>().state.groups;
  return _openSheet(context, groups);
}

/// Called from AddExpensePage (GroupsBloc is NOT in the tree).
/// Accepts a pre-fetched list of groups directly.
Future<GroupEntity?> showGroupPickerFromList(BuildContext context, List<GroupEntity> groups) {
  return _openSheet(context, groups);
}

Future<GroupEntity?> _openSheet(BuildContext context, List<GroupEntity> groups) {
  return showModalBottomSheet<GroupEntity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GroupPickerSheet(groups: groups),
  );
}

class _GroupPickerSheet extends StatelessWidget {
  final List<GroupEntity> groups;

  const _GroupPickerSheet({required this.groups});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.borderGreyLight, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Select a Group",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textBlack),
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
                        style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textGrey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final group = groups[index];
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
          color: AppColors.backgroundLightGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGreyLight),
        ),
        child: Row(
          children: [
            // Icon / image
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surfaceWhite,
                image: group.groupIcon != null ? DecorationImage(image: CachedNetworkImageProvider(group.groupIcon!), fit: BoxFit.cover) : null,
              ),
              child: group.groupIcon == null ? const Icon(Icons.groups_rounded, color: AppColors.primaryTeal, size: 24) : null,
            ),
            const SizedBox(width: 14),
            // Name + member count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name ?? "Unnamed Group",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (group.members != null)
                    Text(
                      "${group.members!.length} member${group.members!.length == 1 ? '' : 's'}",
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
