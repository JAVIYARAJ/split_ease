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
import 'package:split_ease/core/presentation/widgets/app_image_view.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/presentation/widgets/profile_picture_dialog.dart';
import 'package:split_ease/core/presentation/widgets/feedback_sheet.dart';

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
          String userName = "User";
          String userEmail = "email@example.com";
          String? userAvatar;

          if (userState is AppUserLoggedIn) {
            userName = userState.user.name;
            userEmail = userState.user.email;
            userAvatar = userState.user.avatarUrl;
          }

          return Scaffold(
            backgroundColor: AppColors.backgroundWhite,
            body: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                   const SizedBox(height: 50),
                   
                  // 1. Centered Profile Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              ProfilePictureDialog.show(
                                context,
                                avatarUrl: userAvatar,
                                heroTag: 'account_profile_pic',
                              );
                            },
                            child: Hero(
                              tag: 'account_profile_pic',
                              child: AppAvatar(
                                url: userAvatar,
                                radius: 50,
                                iconSize: 50,
                                backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
                                iconColor: AppColors.primaryTeal.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: GoogleFonts.openSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                             if (userState is AppUserLoggedIn) {
                                NavigationService.pushNamed(AppRoutes.editProfile, args: userState.user);
                             }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textBlack,
                            side: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                          child: Text(
                            "Edit Profile",
                            style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 2. Pro Banner (if enabled)
                  if (FeatureFlags.isSubscriptionEnabled) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF8B85FF)], // Modern purple gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                           BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(Icons.diamond_rounded, size: 36, color: Colors.white),
                            const SizedBox(height: 12),
                            Text(
                              "Upgrade to Splitwise Pro",
                              style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                             const SizedBox(height: 6),
                            Text(
                              "Get charts, currency conversion, and search.",
                              style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.9)),
                               textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF6C63FF),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Get Pro",
                                  style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // 3. General Settings
                  _buildSectionHeader("Data & Privacy"),
                  _buildInsetGroup(
                    children: [
                      _buildListItem(
                        icon: Icons.qr_code_rounded,
                        title: "My QR Code",
                        onTap: () {
                          if (userState is AppUserLoggedIn) {
                            NavigationService.pushNamed(
                              AppRoutes.userQr,
                              args: {
                                'userId': userState.user.id,
                                'userName': userState.user.name,
                                'userAvatar': userState.user.avatarUrl,
                              },
                            );
                          } else {
                            AppAlerts.showError(context, "Please log in to see your QR code.");
                          }
                        },
                      ),
                      _buildDivider(),
                       _buildListItem(
                        icon: Icons.security_rounded,
                         title: "Security", 
                         onTap: () {}
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                   // 4. Preferences
                  _buildSectionHeader("Preferences"),
                  _buildInsetGroup(
                    children: [
                      _buildListItem(
                        icon: Icons.notifications_none_rounded,
                        title: "Notifications", 
                         onTap: () {}
                       ),
                    ],
                  ),

                   const SizedBox(height: 24),

                  // 5. Feedback
                  _buildSectionHeader("Support"),
                  _buildInsetGroup(
                    children: [
                      _buildListItem(
                        icon: Icons.star_outline_rounded,
                        title: "Rate Splitwise", 
                        onTap: () {
                          FeedbackSheet.show(context);
                        }
                      ),
                      _buildDivider(),
                      _buildListItem(
                        icon: Icons.mail_outline_rounded,
                        title: "Contact us", 
                        onTap: () {}
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                   // 6. Logout
                  TextButton.icon(
                    onPressed: () => _showLogoutConfirmationDialog(context),
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: Text(
                       "Log out",
                       style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                       foregroundColor: AppColors.errorRed,
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                       backgroundColor: AppColors.errorRed.withValues(alpha: 0.05),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                   Text(
                      "Version 1.0.0",
                      style: GoogleFonts.openSans(color: AppColors.textGrey.withValues(alpha: 0.5), fontSize: 12),
                   ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 1.0),
        ),
      ),
    );
  }

  Widget _buildInsetGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListItem({IconData? icon, Color? iconColor, required String title, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Ensures ripple respects container if strict
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              if (icon != null) ...[
                 Icon(icon, color: iconColor ?? AppColors.textBlack.withValues(alpha: 0.8), size: 22),
                 const SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textBlack, fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: AppColors.borderGrey.withValues(alpha: 0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
     return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderGrey.withValues(alpha: 0.2),
      indent: 58, 
      endIndent: 0,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (_, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Log out?",
                    style: GoogleFonts.openSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textBlack),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Are you sure you want to log out of your account?", 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(fontSize: 15, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: AppColors.backgroundLightGrey,
                            foregroundColor: AppColors.textBlack,
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<AccountBloc>().add(AccountLogoutEvent());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                            "Log out",
                            style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
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
      },
    );
  }
}
