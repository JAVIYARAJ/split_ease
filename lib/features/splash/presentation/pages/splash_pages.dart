import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:split_ease/features/splash/presentation/widgets/splash_background.dart';
import 'package:split_ease/features/splash/presentation/widgets/splash_split_logo.dart';

class SplashPages extends StatefulWidget {
  const SplashPages({super.key});

  @override
  State<SplashPages> createState() => _SplashPagesState();
}

class _SplashPagesState extends State<SplashPages>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    // Start splash business logic
    context.read<SplashCubit>().start();

    // Progress bar animation for visual feedback (2.8 seconds duration)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).isDark;
    final AppColorTokens tokens = Theme.of(context).ext;

    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToWelcome) {
          NavigationService.pushReplacement(AppRoutes.welcome);
        } else if (state is SplashNavigateToLogin) {
          NavigationService.pushReplacement(AppRoutes.login);
        } else if (state is SplashNavigateToHome) {
          NavigationService.pushReplacement(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: tokens.scaffoldBg,
        body: SplashBackground(
          child: SafeArea(
            child: Stack(
              children: [
                // 1. Central Hero Emblem & Brand Typography
                const Center(
                  child: SplashSplitLogo(),
                ),

                // 2. Bottom Loading Progress Bar & Version Info
                Positioned(
                  left: 32,
                  right: 32,
                  bottom: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Loading Status Text
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          final double val = _progressController.value;
                          String statusText = "Initializing...";
                          if (val > 0.7) {
                            statusText = "Syncing balances...";
                          } else if (val > 0.4) {
                            statusText = "Preparing experience...";
                          }

                          return Text(
                            statusText,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: tokens.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // Animated Progress Bar Pill
                      Container(
                        height: 4,
                        width: 140,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: tokens.border.withValues(alpha: isDark ? 0.2 : 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: Curves.easeOutCubic
                                  .transform(_progressController.value),
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.brandYellow,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Version Indicator Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.surface.withValues(alpha: isDark ? 0.2 : 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: tokens.border.withValues(alpha: isDark ? 0.15 : 0.5),
                          ),
                        ),
                        child: Text(
                          "v1.0.0",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: tokens.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
