import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/features/welcome/presentation/cubit/welcome_cubit.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/navigation_service.dart';
import '../../../../core/theme/app_colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Split Your Way",
      subtitle: "VERSATILE COST SPLITTING",
      description: "Equal shares, exact amounts, percentages, or shares. We handle complex math so your group doesn't have to.",
      icon: Icons.pie_chart_rounded,
      color: const Color(0xFF009688),
      benefit: "Equally, Exact, or %, Shares",
    ),
    OnboardingData(
      title: "Action History & Undo",
      subtitle: "ADVANCED ACTIVITY LOG",
      description: "Monitor every edit and deletion. Made a mistake? Restore deleted expenses instantly with our unique Undo feature.",
      icon: Icons.history_rounded,
      color: const Color(0xFF3F51B5),
      benefit: "Live tracking & Restoration",
    ),
    OnboardingData(
      title: "Settle Up & Sync Fast",
      subtitle: "REAL-TIME BALANCES",
      description: "Record payments to clear balances and invite group members via QR codes. Stay synchronized wherever you are.",
      icon: Icons.qr_code_scanner_rounded,
      color: const Color(0xFFFFD428),
      benefit: "QR Invites & Quick Settle",
    ),
    OnboardingData(
      title: "Pro Export Reports",
      subtitle: "FINANCIAL CLARITY",
      description: "Need a summary for a trip or tax record? Generate and share professional PDF reports of your group history in seconds.",
      icon: Icons.picture_as_pdf_rounded,
      color: const Color(0xFFE91E63),
      benefit: "Instant PDF Generation",
    ),
    OnboardingData(
      title: "Global Social Sync",
      subtitle: "USER NETWORK",
      description: "Connect with anyone instantly. Send friend requests and search globally to keep your social circle synced with your finances.",
      icon: Icons.supervised_user_circle_rounded,
      color: const Color(0xFF673AB7),
      benefit: "Find friends globally",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<WelcomeCubit, WelcomeState>(
      listener: (context, state) {
        if (state is WelcomeNavigateToAuth) {
          NavigationService.pushReplacement(AppRoutes.login);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: Theme.of(context).ext.scaffoldBg,
          body: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return _OnboardingSlide(data: _pages[index]);
                },
              ),
              Positioned(
                bottom: 40,
                left: 24,
                right: 24,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildIndicator(index == _currentPage),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Navigation Buttons
                    SizedBox(
                      height: 64,
                      child: Row(
                        children: [
                          // 1. Animated Skip Button (Disappears on last slide)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            width: _currentPage == _pages.length - 1 ? 0 : 80,
                            height: 64,
                            child: ClipRect(
                              child: IgnorePointer(
                                ignoring: _currentPage == _pages.length - 1,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: _currentPage == _pages.length - 1 ? 0.0 : 1.0,
                                  child: Center(
                                    child: TextButton(
                                      onPressed: () => _pageController.jumpToPage(_pages.length - 1),
                                      child: Text(
                                        "Skip",
                                        maxLines: 1,
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          color: Theme.of(context).ext.textTertiary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2. Animated Action Button (Expands to Full Width)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_currentPage < _pages.length - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOutQuint,
                                  );
                                } else {
                                  context.read<WelcomeCubit>().navigateToAuth();
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.fastOutSlowIn,
                                margin: EdgeInsets.only(
                                  left: _currentPage == _pages.length - 1 ? 0 : 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(scale: animation, child: child),
                                    );
                                  },
                                  child: Center(
                                    // Only animate when reaching the last slide (Boolean Key)
                                    key: ValueKey<bool>(_currentPage == _pages.length - 1),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _currentPage == _pages.length - 1 ? "Start Splitting Now" : "Next",
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        if (_currentPage < _pages.length - 1) ...[
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 32 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Theme.of(context).ext.border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String benefit;

  OnboardingData({
    required this.title,
    required this.description,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.benefit,
  });
}

class _OnboardingSlide extends StatelessWidget {
  final OnboardingData data;
  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(data.icon, size: 64, color: data.color),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).ext.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    data.benefit,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: (data.color == const Color(0xFFFFD428)) ? const Color(0xFFDAB318) : data.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Text(
            data.subtitle,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).ext.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Theme.of(context).ext.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
