import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/utils/app_assets.dart';
import 'package:split_ease/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';

class SplashPages extends StatefulWidget {
  const SplashPages({super.key});

  @override
  State<SplashPages> createState() => _SplashPagesState();
}

class _SplashPagesState extends State<SplashPages> {
  bool _showEase = false;

  @override
  void initState() {
    super.initState();
    context.read<SplashCubit>().start();
    
    // Trigger the "ease" animation after the Lottie finishes drawing "Split"
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        setState(() => _showEase = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      child: BaseScreen(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Lottie.asset(
                AppAssets.icWelcomeBanner, 
                width: double.maxFinite, 
                height: 200, 
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 155, // Moved down to sit completely underneath "lit"
                right: (MediaQuery.of(context).size.width / 2) - 85, // Aligned its right edge exactly with the right edge of "t"
                child: AnimatedOpacity(
                  opacity: _showEase ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: AnimatedSlide(
                    offset: _showEase ? Offset.zero : const Offset(0.5, 0.0), // Starts from the right
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    child: Text(
                      "ease",
                      style: GoogleFonts.outfit(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        height: 1,
                        letterSpacing: -2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
