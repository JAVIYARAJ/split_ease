import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/utils/auth_utils.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../login/widgets/primary_button.dart';

class RegisterSuccessPage extends StatefulWidget {
  const RegisterSuccessPage({super.key});

  @override
  State<RegisterSuccessPage> createState() => _RegisterSuccessPageState();
}

class _RegisterSuccessPageState extends State<RegisterSuccessPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeIn)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9, curve: Curves.easeOutBack)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).ext.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // 2. Animated Success Hero
              ScaleTransition(
                scale: _scaleAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.successGreen, Color(0xFF27AE60)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x402ECC71), blurRadius: 20, offset: Offset(0, 10)),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // 3. Welcome Copy
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        "Account Created!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).ext.textPrimary,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Welcome to the community. You're now ready to manage group expenses with professional ease.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Theme.of(context).ext.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 4. Verification Action Card (The "Killer" Detail)
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).ext.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Theme.of(context).ext.backgroundGrey, shape: BoxShape.circle),
                              child: const Icon(Icons.mark_email_unread_rounded, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Verify Your Email",
                                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Theme.of(context).ext.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "We've sent a link to your inbox. Please verify to enjoy full app functionality.",
                                    style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).ext.textSecondary, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => AuthUtils.openMailApp(),
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).ext.backgroundGrey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            "Check Inbox",
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 5. Final Move
              FadeTransition(
                opacity: _fadeAnimation,
                child: AppPrimaryButton(
                  text: "Proceed to Login",
                  onPressed: () {
                    NavigationService.pushNamed(AppRoutes.login);
                  },
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "Log in once you've verified your email",
                  style: GoogleFonts.outfit(fontSize: 14, color: Theme.of(context).ext.textTertiary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeSphere(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
