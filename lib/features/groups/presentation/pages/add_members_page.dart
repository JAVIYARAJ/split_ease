import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/groups/domain/entities/group_friend_entity.dart';
import 'package:split_ease/features/groups/presentation/bloc/add_members_bloc.dart';
import 'package:split_ease/injection_container.dart';
import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/core/presentation/widgets/app_empty_state.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';

class AddMembersPage extends StatefulWidget {
  final String groupId;

  const AddMembersPage({super.key, required this.groupId});

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final TextEditingController _searchController = TextEditingController();

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
            backgroundColor: Theme.of(context).ext.scaffoldBg,
            appBar: AppBar(
              backgroundColor: Theme.of(context).ext.scaffoldBg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).ext.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Add Members',
                style: GoogleFonts.openSans(
                  color: Theme.of(context).ext.textPrimary,
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
                        color: Theme.of(context).ext.surface,
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
            style: GoogleFonts.openSans(fontSize: 15, color: Theme.of(context).ext.textSecondary),
          ),
        ),
      );
    }

    if (state.status == AddMembersStatus.loaded && state.friends.isEmpty) {
      return BlocBuilder<AppUserCubit, AppUserState>(
        builder: (context, userState) {
          return AppEmptyState(
            icon: Icons.person_add_rounded,
            title: 'No Friends Yet',
            subtitle: 'You don\'t have any friends on SplitEase yet. Share your profile QR code with others to start splitting expenses!',
            actionButton: ElevatedButton.icon(
              onPressed: () {
                if (userState is AppUserLoggedIn) {
                  NavigationService.pushNamed(
                    AppRoutes.userQr,
                    args: {
                      'userId': userState.user.id,
                      'userName': userState.user.name,
                      'userAvatar': userState.user.avatarUrl,
                    },
                  );
                }
              },
              icon: const Icon(Icons.qr_code_rounded, color: Colors.white),
              label: Text(
                "Share My QR",
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          );
        },
      );
    }

    final filteredInGroup = state.filteredInGroup;
    final filteredNotInGroup = state.filteredNotInGroup;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => context.read<AddMembersBloc>().add(ChangeSearchQuery(value)),
            style: GoogleFonts.openSans(fontSize: 16, color: Theme.of(context).ext.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search friends by name...',
              hintStyle: GoogleFonts.openSans(fontSize: 16, color: Theme.of(context).ext.textTertiary),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).ext.textTertiary, size: 24),
              filled: true,
              fillColor: Theme.of(context).ext.inputFill,
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
                      Icon(Icons.search_off_rounded, size: 48, color: Theme.of(context).ext.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        state.searchQuery.isNotEmpty ? 'No friends match "${state.searchQuery}"' : 'No friends found',
                        style: GoogleFonts.openSans(fontSize: 16, color: Theme.of(context).ext.textSecondary),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.openSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).ext.textSecondary,
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
              AppAvatar(
                url: friend.avatarUrl,
                radius: 25,
                backgroundColor: Theme.of(context).ext.backgroundGrey,
                iconColor: AppColors.primaryTeal,
              ),
              const SizedBox(width: 16),

              // Name + subtitle + Role selection
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.fullName,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDisabled ? Theme.of(context).ext.textTertiary : Theme.of(context).ext.textPrimary,
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
                          color: Theme.of(context).ext.textTertiary,
                        ),
                      ),
                    ] else if (isSelected) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildRoleChip(
                            context,
                            friend.userId,
                            role: 'user',
                            isSelected: context.read<AddMembersBloc>().state.selectedRoles[friend.userId] == 'user',
                          ),
                          const SizedBox(width: 8),
                          _buildRoleChip(
                            context,
                            friend.userId,
                            role: 'admin',
                            isSelected: context.read<AddMembersBloc>().state.selectedRoles[friend.userId] == 'admin',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Selection Indicator
              if (!isDisabled)
                GestureDetector(
                  onTap: () => context.read<AddMembersBloc>().add(ToggleFriendSelection(friend.userId)),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primaryTeal : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryTeal : Theme.of(context).ext.border,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                )
              else
                 Icon(Icons.check_circle, color: Theme.of(context).ext.textTertiary, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(BuildContext context, String userId, {required String role, required bool isSelected}) {
    final Color roleColor = role == 'user' 
        ? AppColors.primaryTeal 
        : (role == 'admin' ? Colors.blue : AppColors.errorRed);

    final IconData icon = role == 'user' 
        ? Icons.person_outline 
        : (role == 'admin' ? Icons.shield_outlined : Icons.verified_user_outlined);

    return InkWell(
      onTap: () => context.read<AddMembersBloc>().add(ChangeFriendRole(userId, role)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? roleColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? roleColor
                : Theme.of(context).ext.border.withValues(alpha: 0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? roleColor : Theme.of(context).ext.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              role.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSelected ? roleColor : Theme.of(context).ext.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
