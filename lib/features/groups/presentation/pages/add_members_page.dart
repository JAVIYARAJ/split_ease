import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          final selectedCount = state.selectedUserIds.length;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textBlack),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Add Members',
                style: GoogleFonts.openSans(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            floatingActionButton: selectedCount > 0
                ? FloatingActionButton.extended(
                    onPressed: state.submitStatus == AddMembersSubmitStatus.submitting
                        ? null
                        : () {
                            context.read<AddMembersBloc>().add(SubmitSelectedFriends(widget.groupId));
                          },
                    backgroundColor: AppColors.primaryTeal,
                    elevation: 4,
                    icon: state.submitStatus == AddMembersSubmitStatus.submitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      "Add ($selectedCount)",
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                : null,
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AddMembersState state) {
    if (state.status == AddMembersStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
    }

    if (state.status == AddMembersStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            state.errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(fontSize: 15, color: AppColors.textGrey),
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textBlack),
            decoration: InputDecoration(
              hintText: 'Search friends by name...',
              hintStyle: GoogleFonts.openSans(fontSize: 16, color: AppColors.textGrey.withValues(alpha: 0.6)),
              prefixIcon: Icon(Icons.search, color: AppColors.textGrey.withValues(alpha: 0.6), size: 24),
              filled: true,
              fillColor: AppColors.backgroundLightGrey,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
              ),
            ),
          ),
        ),

        // Friend Lists
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100), // Space for FAB
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
                if (filteredInGroup.isNotEmpty) const SizedBox(height: 16),
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
                  padding: const EdgeInsets.only(top: 64),
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: AppColors.textGrey.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty ? 'No friends match "$_searchQuery"' : 'No friends found',
                        style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textGrey),
                      ),
                    ],
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.openSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textGrey,
          letterSpacing: 1.0,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled
            ? null
            : () => context.read<AddMembersBloc>().add(ToggleFriendSelection(friend.userId)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundLightGrey,
                  image: friend.avatarUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(friend.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: friend.avatarUrl == null
                    ? Center(
                        child: Text(
                          friend.fullName.isNotEmpty ? friend.fullName[0].toUpperCase() : '?',
                          style: GoogleFonts.openSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Name + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.fullName,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDisabled ? AppColors.textGrey : AppColors.textBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isDisabled) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Already in group',
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Selection Indicator
              if (!isDisabled)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primaryTeal : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryTeal : AppColors.borderGrey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                )
              else
                 Icon(Icons.check_circle, color: AppColors.textGrey.withValues(alpha: 0.3), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
