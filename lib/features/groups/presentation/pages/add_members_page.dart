import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/groups/domain/entities/group_friend_entity.dart';
import 'package:split_ease/features/groups/presentation/bloc/add_members_bloc.dart';
import 'package:split_ease/injection_container.dart';

class AddMembersPage extends StatefulWidget {
  final String groupId;

  const AddMembersPage({super.key, required this.groupId});

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddMembersBloc>()..add(LoadFriendsForGroup(widget.groupId)),
      child: BlocConsumer<AddMembersBloc, AddMembersState>(
        listener: (context, state) {
          if (state.submitStatus == AddMembersSubmitStatus.success) {
            AppAlerts.showSuccess(context, 'Members added successfully!');
            Navigator.pop(context, true);
          } else if (state.submitStatus == AddMembersSubmitStatus.failure) {
            AppAlerts.showError(context, state.errorMessage);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leadingWidth: 80,
              leading: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              title: Text(
                'Add group members',
                style: GoogleFonts.outfit(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              actions: [
                if (state.selectedUserIds.isNotEmpty)
                  TextButton(
                    onPressed: state.submitStatus == AddMembersSubmitStatus.submitting
                        ? null
                        : () {
                            context.read<AddMembersBloc>().add(SubmitSelectedFriends(widget.groupId));
                          },
                    child: state.submitStatus == AddMembersSubmitStatus.submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        : Text(
                            'Done',
                            style: GoogleFonts.outfit(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                const SizedBox(width: 4),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AddMembersState state) {
    if (state.status == AddMembersStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.status == AddMembersStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            state.errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textGrey),
          ),
        ),
      );
    }

    final alreadyInGroup = state.alreadyInGroup;
    final notInGroup = state.notInGroup;

    // Apply search filter
    final filteredInGroup = _filterFriends(alreadyInGroup);
    final filteredNotInGroup = _filterFriends(notInGroup);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            style: GoogleFonts.outfit(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search friends...',
              hintStyle: GoogleFonts.outfit(fontSize: 15, color: AppColors.iconGrey),
              prefixIcon: const Icon(Icons.search, color: AppColors.iconGrey, size: 22),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Friend Lists
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // Already in group section
              if (filteredInGroup.isNotEmpty) ...[
                _buildSectionHeader('Already in group'),
                ...filteredInGroup.map((f) => _buildFriendTile(
                      context,
                      friend: f,
                      isSelected: true,
                      isDisabled: true,
                    )),
              ],

              // Friends section
              if (filteredNotInGroup.isNotEmpty) ...[
                _buildSectionHeader('Friends on SplitEase'),
                ...filteredNotInGroup.map((f) => _buildFriendTile(
                      context,
                      friend: f,
                      isSelected: state.selectedUserIds.contains(f.userId),
                      isDisabled: false,
                    )),
              ],

              if (filteredInGroup.isEmpty && filteredNotInGroup.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text(
                      _searchQuery.isNotEmpty ? 'No friends match your search' : 'No friends found',
                      style: GoogleFonts.outfit(fontSize: 15, color: AppColors.iconGrey),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<GroupFriendEntity> _filterFriends(List<GroupFriendEntity> friends) {
    if (_searchQuery.isEmpty) return friends;
    return friends.where((f) {
      return f.fullName.toLowerCase().contains(_searchQuery) ||
          (f.email?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textGrey,
        ),
      ),
    );
  }

  Widget _buildFriendTile(
    BuildContext context, {
    required GroupFriendEntity friend,
    required bool isSelected,
    required bool isDisabled,
  }) {
    return InkWell(
      onTap: isDisabled
          ? null
          : () => context.read<AddMembersBloc>().add(ToggleFriendSelection(friend.userId)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundImage: friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: friend.avatarUrl == null
                  ? Text(
                      friend.fullName.isNotEmpty ? friend.fullName[0].toUpperCase() : '?',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.fullName,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isDisabled) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Already in group',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.iconGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Checkmark / Circle
            _buildSelectionIndicator(isSelected, isDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected, bool isDisabled) {
    if (isSelected) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    }
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderGrey, width: 2),
      ),
    );
  }
}
