import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/config/feature_flags.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/account/presentation/bloc/account_bloc.dart';
import '../../../../../core/common/cubit/app_user_cubit.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/theme/app_colors.dart';

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

          if (userState is AppUserLoggedIn) {
            userName = userState.user.name ?? "User";
            userEmail = userState.user.email;
          }

          return BaseScreen(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                "Account",
                style: GoogleFonts.openSans(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.search, color: Colors.black87, size: 28),
                onPressed: () {},
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 1. Profile Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const CircleAvatar(
                              radius: 36,
                              backgroundColor: Color(0xFFA00030), // Dark Red
                              // Replace with actual image if available
                              child: Icon(Icons.person, size: 40, color: Colors.white24),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              Text(userEmail, style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Edit",
                            style: GoogleFonts.openSans(
                              color: const Color(0xFF00C853), // Green
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Pro Banner
                  if (FeatureFlags.isSubscriptionEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF3E5F5), // Light purple
                              Colors.deepPurple.shade50,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Diamond Icon (simulated)
                              const Icon(Icons.diamond, size: 40, color: Colors.deepPurple),
                              const SizedBox(height: 12),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.openSans(fontSize: 16, color: Colors.black87),
                                  children: [
                                    const TextSpan(text: "Do more with "),
                                    TextSpan(
                                      text: "Splitwise Pro",
                                      style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: "."),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7E40C8), // Purple
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "Get Splitwise Pro",
                                    style: GoogleFonts.openSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // 3. Settings List
                  _buildListItem(icon: Icons.qr_code_scanner, title: "Scan code", onTap: () {}),
                  _buildListItem(icon: Icons.diamond_outlined, title: "Splitwise Pro", iconColor: Colors.deepPurple, onTap: () {}),

                  const SizedBox(height: 20),
                  _buildSectionHeader("Preferences"),
                  _buildListItem(
                    // No icon in screenshot for these? Actually regular lists usually don't have icons in Settings on iOS/Splitwise?
                    // Looking at the second screenshot, "Notifications", "Security" seem to NOT have icons on the left?
                    // Wait, the screenshot shows "Scan code" has an icon. "Splitwise Pro" has an icon.
                    // "Notifications" and "Security" do NOT show icons in the second screenshot provided?
                    // Let me re-examine the user's second screenshot.
                    // Ah, looking closely at uploaded_image_1... "Scan code" has QR icon. "Splitwise Pro" has diamond.
                    // "Preferences" is a header. "Notifications" does NOT have an icon. "Security" does NOT have an icon.
                    // "Feedback" is a header. "Rate Splitwise" NO icon. "Contact us" NO icon.
                    title: "Notifications",
                    onTap: () {},
                  ),
                  _buildListItem(title: "Security", onTap: () {}),

                  const SizedBox(height: 20),
                  _buildSectionHeader("Feedback"),
                  _buildListItem(title: "Rate Splitwise", onTap: () {}),
                  _buildListItem(title: "Contact us", onTap: () {}),

                  const SizedBox(height: 40),

                  // 4. Footer
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.read<AccountBloc>().add(AccountLogoutEvent());
                      },
                      child: Text(
                        "Log out",
                        style: GoogleFonts.openSans(color: const Color(0xFF00C853), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        Text("Made with :) in Providence, RI, USA", style: GoogleFonts.openSans(color: Colors.grey, fontSize: 12)),
                        Text("Copyright © 2026 Splitwise, Inc.", style: GoogleFonts.openSans(color: Colors.grey, fontSize: 12)),
                        Text("P.S. Kittens!", style: GoogleFonts.openSans(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text("25.12.2/985", style: GoogleFonts.openSans(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Bottom padding
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
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 8),
      child: Text(
        title,
        style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildListItem({IconData? icon, Color? iconColor, required String title, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: icon != null
          ? Icon(icon, color: iconColor ?? Colors.black87, size: 24)
          // If no icon, we typically don't show anything, or maybe indent?
          // In the screenshot, the text starts aligned with the title of items with icons?
          // No, looking at "Notifications", it seems to be aligned left, maybe slightly indented or just standard leading.
          // If I use ListTile without leading, the title moves to the left.
          // In the screenshot 1: "Scan code" (Icon) ...
          // In screenshot 2: "Notifications" (No icon).
          // It seems "Notifications" text aligns with "Scan code" text.
          // So I should keep a placeholder or just standard content padding.
          // Let's assume standard content padding handles it or they just don't have icons.
          // If alignment is needed, I can add a SizedBox(width: 24) as leading.
          : null,
      title: Text(
        title,
        style: GoogleFonts.openSans(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      minLeadingWidth: icon != null ? 24 : 0, // Minimize space if no icon
    );
  }
}
