import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';

/// Creative Multi-Stage Hero Emblem & Logo Animation for SplitEase Splash Screen
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

    // 1. Central Glass Emblem Pop (0% - 30%)
    _badgeScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOutBack),
    );

    // 2. Pulse Glow around Badge (0% - 100% repeating continuous loop)
    _pulseGlow = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.60, curve: Curves.easeInOut),
    );

    // 3. Floating Split Chips Outward Motion (25% - 60%)
    _splitOffset = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.60, curve: Curves.elasticOut),
    );
    _splitOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.40, curve: Curves.easeIn),
    );

    // 4. "SPLIT" Text Spring Reveal (45% - 75%)
    _textScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOutBack),
    );

    // 5. Divider Line Expansion (55% - 80%)
    _dividerScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.80, curve: Curves.easeOutCubic),
    );

    // 6. "EASE" Text Slide-In (65% - 90%)
    _easeSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 0.90, curve: Curves.easeOutCubic),
    );

    // 7. Tagline Fade & Slide Up (75% - 100%)
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
                        color: AppColors.primary.withValues(alpha: 0.25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 35,
                            spreadRadius: 8,
                          ),
                          BoxShadow(
                            color: AppColors.brandYellow.withValues(alpha: 0.3),
                            blurRadius: 45,
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
                              colors: [
                                Colors.white.withValues(alpha: 0.25),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Center Bill/Receipt Icon
                              const Icon(
                                Icons.receipt_long_rounded,
                                size: 52,
                                color: Colors.white,
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
                                        Colors.white,
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
                                Color(0xFFFFB703)
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
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFE0F2F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "SPLIT",
                      style: GoogleFonts.outfit(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
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
                          Colors.white,
                          AppColors.primary,
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

                // "EASE" Word (Sliding smoothly with glow)
                Transform.translate(
                  offset: Offset((1.0 - _easeSlide.value) * 30.0, 0),
                  child: Opacity(
                    opacity: _easeSlide.value.clamp(0.0, 1.0),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppColors.brandYellow,
                          Color(0xFFFFF176),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        "EASE",
                        style: GoogleFonts.outfit(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          color: AppColors.brandYellow,
                          shadows: [
                            Shadow(
                              color: AppColors.brandYellow.withValues(alpha: 0.6),
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
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    "Split Bills • Share Moments",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
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
