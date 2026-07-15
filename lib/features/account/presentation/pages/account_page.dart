import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/config/feature_flags.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/account/presentation/bloc/account_bloc.dart';
import '../../../../../core/common/cubit/app_user_cubit.dart';

import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/presentation/widgets/profile_picture_dialog.dart';
import 'package:split_ease/core/presentation/widgets/feedback_sheet.dart';
import 'package:split_ease/core/presentation/widgets/animations/staggered_entry_column.dart';
import 'package:flutter/services.dart';
import 'package:split_ease/features/home/presentation/bloc/home_bloc.dart';

import 'package:split_ease/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:split_ease/features/groups/presentation/bloc/groups_bloc.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) {
        if (state.status == AccountStatus.success) {
          AppAlerts.showSuccess(context, state.message);
          NavigationService.pushAndRemoveUntil(AppRoutes.login);
        } else if (state.status == AccountStatus.failure) {
          AppAlerts.showError(context, state.message);
        }
      },
      child: BlocBuilder<AppUserCubit, AppUserState>(
        builder: (context, userState) {
          final homeState = context.watch<HomeBloc>().state;
          final bool isVisible = homeState.tabIndex == 4;

          String userName = "User";
          String userEmail = "email@example.com";
          String? userAvatar;

          if (userState is AppUserLoggedIn) {
            userName = userState.user.name;
            userEmail = userState.user.email;
            userAvatar = userState.user.avatarUrl;
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: StaggeredEntryColumn(
                      animate: isVisible,
                      verticalOffset: 30,
                      children: [
                        _buildProfileHero(context, userName, userEmail, userAvatar, userState),
                        const SizedBox(height: 16),
                        _buildUserStats(context),
                        const SizedBox(height: 32),
                        if (FeatureFlags.isSubscriptionEnabled) ...[
                          _buildProBanner(),
                          const SizedBox(height: 32),
                        ],
                        _buildQuickActions(context, userState),
                        const SizedBox(height: 32),
                        _buildSettingsList(context),
                        const SizedBox(height: 48),
                        _buildLogoutSection(context),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Profile",
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textBlack, letterSpacing: -1.0),
            ),
            Text(
              "Account & Application Settings",
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHero(BuildContext context, String name, String email, String? avatar, AppUserState userState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightGrey,
        borderRadius: BorderRadius.circular(40),
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
          opacity: 0.03,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ProfilePictureDialog.show(
                context,
                avatarUrl: avatar,
                heroTag: 'account_profile_pic',
              );
            },
            child: Hero(
              tag: 'account_profile_pic',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 5),
                  ],
                ),
                child: Stack(
                  children: [
                    AppAvatar(
                      url: avatar,
                      radius: 45,
                      iconSize: 40,
                      backgroundColor: Colors.white,
                      iconColor: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textBlack, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
            child: Text(
              email,
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(BuildContext context) {
    final friendsCount = context.watch<FriendsBloc>().state.friends.length;
    final groupsCount = context.watch<GroupsBloc>().state.groups.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("Friends", friendsCount.toString(), Icons.people_outline_rounded),
          _buildDividerVert(),
          _buildStatItem("Groups", groupsCount.toString(), Icons.layers_outlined),
        ],
      ),
    );
  }

  Widget _buildDividerVert() {
    return Container(height: 24, width: 1, color: AppColors.borderGrey.withValues(alpha: 0.5));
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textGrey),
            const SizedBox(width: 4),
            Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textBlack)),
          ],
        ),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildProBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "UPGRADE TO PRO",
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "Get Advanced Stats",
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: CircleBorder(),
              padding: EdgeInsets.all(16),
            ),
            child: Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppUserState userState) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.qr_code_rounded,
            title: "My QR",
            color: Color(0xFF673AB7),
            onTap: () {
              HapticFeedback.lightImpact();
              if (userState is AppUserLoggedIn) {
                NavigationService.pushNamed(AppRoutes.userQr, args: {
                  'userId': userState.user.id,
                  'userName': userState.user.name,
                  'userAvatar': userState.user.avatarUrl,
                });
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            icon: Icons.edit_note_rounded,
            title: "Edit Profile",
            color: Color(0xFF009688),
            onTap: () {
              HapticFeedback.lightImpact();
              if (userState is AppUserLoggedIn) {
                NavigationService.pushNamed(AppRoutes.editProfile, args: userState.user);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textBlack)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader("PREFERENCES"),
        _buildSettingItem(icon: Icons.notifications_none_rounded, title: "Notifications", onTap: () {}),
        _buildSettingItem(
          icon: Icons.pie_chart_outline_rounded,
          title: "Expense Category Limits",
          onTap: () => NavigationService.pushNamed(AppRoutes.categoryLimits),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader("SUPPORT"),
        _buildSettingItem(icon: Icons.star_outline_rounded, title: "Rate SplitEase", onTap: () => FeedbackSheet.show(context)),
        _buildSettingItem(icon: Icons.mail_outline_rounded, title: "Contact Support", onTap: () {}),
        _buildSettingItem(icon: Icons.info_outline_rounded, title: "About", onTap: () {}),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5),
        ),
      ),
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGrey.withValues(alpha:0.5)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textGrey, size: 22),
              const SizedBox(width: 16),
              Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: AppColors.iconGrey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showLogoutConfirmationDialog(context),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: Text("Sign Out", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.errorRed.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "SplitEase v1.0.0 (BETA)",
          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textGrey.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (_, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.errorRed.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 32),
                  ),
                  const SizedBox(height: 24),
                  Text("End Session?", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textBlack)),
                  const SizedBox(height: 8),
                  Text("Are you sure you want to log out?", textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textGrey)),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Stay", style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textGrey)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<AccountBloc>().add(AccountLogoutEvent());
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: Text("Sign Out", style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
