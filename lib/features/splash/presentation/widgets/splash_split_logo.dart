import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';

/// Theme-Aware Multi-Stage Hero Emblem & Logo Animation for SplitEase Splash Screen
class SplashSplitLogo extends StatefulWidget {
  const SplashSplitLogo({super.key});

  @override
  State<SplashSplitLogo> createState() => _SplashSplitLogoState();
}

class _SplashSplitLogoState extends State<SplashSplitLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Staggered Animations
  late final Animation<double> _badgeScale;
  late final Animation<double> _splitOffset;
  late final Animation<double> _splitOpacity;
  late final Animation<double> _textScale;
  late final Animation<double> _easeSlide;
  late final Animation<double> _dividerScale;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // 1. Central Glass Emblem Pop
    _badgeScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOutBack),
    );

    // 2. Pulse Glow around Badge
    _pulseGlow = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.60, curve: Curves.easeInOut),
    );

    // 3. Floating Split Chips Outward Motion
    _splitOffset = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.60, curve: Curves.elasticOut),
    );
    _splitOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.40, curve: Curves.easeIn),
    );

    // 4. "SPLIT" Text Spring Reveal
    _textScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOutBack),
    );

    // 5. Divider Line Expansion
    _dividerScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.80, curve: Curves.easeOutCubic),
    );

    // 6. "EASE" Text Slide-In
    _easeSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 0.90, curve: Curves.easeOutCubic),
    );

    // 7. Tagline Fade & Slide Up
    _taglineOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
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
    final bool isDark = Theme.of(context).isDark;
    final AppColorTokens tokens = Theme.of(context).ext;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double splitDist = _splitOffset.value * 42.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // -----------------------------------------------------------
            // 1. HERO GRAPHIC: Glassmorphic Card + Split Action Icons
            // -----------------------------------------------------------
            ScaleTransition(
              scale: _badgeScale,
              child: SizedBox(
                width: 170,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // A. Outer Pulsing Glow Aura
                    Container(
                      width: 120 + (_pulseGlow.value * 12),
                      height: 120 + (_pulseGlow.value * 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(
                          alpha: isDark ? 0.25 : 0.15,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: isDark ? 0.45 : 0.25,
                            ),
                            blurRadius: 35,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: AppColors.brandYellow.withValues(
                              alpha: isDark ? 0.3 : 0.2,
                            ),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                    // B. Main Glassmorphic Receipt Emblem
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      Colors.white.withValues(alpha: 0.25),
                                      Colors.white.withValues(alpha: 0.05),
                                    ]
                                  : [
                                      Colors.white,
                                      AppColors.backgroundLightGrey,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.35)
                                  : AppColors.primary.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.3)
                                    : AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Center Bill/Receipt Icon
                              Icon(
                                Icons.receipt_long_rounded,
                                size: 52,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.primary,
                              ),

                              // Laser Beam Line Cut Effect
                              Positioned(
                                top: 48,
                                child: Container(
                                  width: 80 * _splitOpacity.value,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppColors.brandYellow,
                                        AppColors.primary,
                                        AppColors.brandYellow,
                                        Colors.transparent,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.brandYellow
                                            .withValues(alpha: 0.8),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // C. Left Floating Split Badge ($ Coin)
                    Positioned(
                      left: 15 - splitDist,
                      top: 15,
                      child: Opacity(
                        opacity: _splitOpacity.value,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.brandYellow,
                                Color(0xFFFFB703),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandYellow
                                    .withValues(alpha: 0.6),
                                blurRadius: 12,
                                offset: const Offset(-2, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "\$",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // D. Right Floating Split Badge (Check/Balance Icon)
                    Positioned(
                      right: 15 - splitDist,
                      bottom: 15,
                      child: Opacity(
                        opacity: _splitOpacity.value,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00E676),
                                AppColors.primary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676)
                                    .withValues(alpha: 0.6),
                                blurRadius: 12,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // -----------------------------------------------------------
            // 2. BRAND TYPOGRAPHY: SPLIT / EASE
            // -----------------------------------------------------------
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // "SPLIT" Word
                Transform.scale(
                  scale: _textScale.value,
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: isDark
                          ? [Colors.white, const Color(0xFFE0F2F1)]
                          : [tokens.textPrimary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "SPLIT",
                      style: GoogleFonts.outfit(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: tokens.textPrimary,
                        shadows: [
                          Shadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : AppColors.primary.withValues(alpha: 0.15),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Diagonal Glowing Divider / Slash
                Transform.scale(
                  scale: _dividerScale.value,
                  child: Container(
                    width: 4,
                    height: 34,
                    transform: Matrix4.skewX(-0.3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.brandYellow,
                          AppColors.primary,
                          AppColors.secondary,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandYellow.withValues(alpha: 0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // "EASE" Word
                Transform.translate(
                  offset: Offset((1.0 - _easeSlide.value) * 30.0, 0),
                  child: Opacity(
                    opacity: _easeSlide.value.clamp(0.0, 1.0),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: isDark
                            ? [AppColors.brandYellow, const Color(0xFFFFF176)]
                            : [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        "EASE",
                        style: GoogleFonts.outfit(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          color: isDark ? AppColors.brandYellow : AppColors.primary,
                          shadows: [
                            Shadow(
                              color: isDark
                                  ? AppColors.brandYellow.withValues(alpha: 0.6)
                                  : AppColors.primary.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // -----------------------------------------------------------
            // 3. TAGLINE: "Split Bills • Share Moments"
            // -----------------------------------------------------------
            Opacity(
              opacity: _taglineOpacity.value,
              child: Transform.translate(
                offset: Offset(0, (1.0 - _taglineOpacity.value) * 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.surface.withValues(alpha: isDark ? 0.15 : 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: tokens.border.withValues(alpha: isDark ? 0.2 : 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Split Bills • Share Moments",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: tokens.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
