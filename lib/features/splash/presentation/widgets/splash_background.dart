import 'dart:math';
import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';

/// Theme-aware animated background for SplitEase Splash Screen
class SplashBackground extends StatefulWidget {
  final Widget child;

  const SplashBackground({super.key, required this.child});

  @override
  State<SplashBackground> createState() => _SplashBackgroundState();
}

class _SplashBackgroundState extends State<SplashBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate floating ambient light particles
    for (int i = 0; i < 22; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: _random.nextDouble() * 4 + 1.5,
          speed: _random.nextDouble() * 0.08 + 0.02,
          opacity: _random.nextDouble() * 0.45 + 0.15,
        ),
      );
    }
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
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            isDark: isDark,
            tokens: tokens,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  final double radius;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final bool isDark;
  final AppColorTokens tokens;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.isDark,
    required this.tokens,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // 1. Theme-adapted Base Canvas Gradient
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                const Color(0xFF0A1628), // Deep Dark Obsidian
                const Color(0xFF0F172A), // App Theme Dark Scaffold Bg
                const Color(0xFF003832), // Dark Teal Brand Depth
              ]
            : [
                AppColors.backgroundWhite, // App Theme Light Scaffold Bg
                AppColors.backgroundLightGrey, // Light Grey Surface
                AppColors.primary.withValues(alpha: 0.08), // Light Teal Wash
              ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Ambient Spotlights matching Primary Teal & Brand Yellow
    final Paint spotTeal = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.15),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.2),
          radius: size.width * 0.7,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.7,
      spotTeal,
    );

    final Paint spotGold = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.brandYellow.withValues(alpha: isDark ? 0.20 : 0.12),
          AppColors.brandYellow.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.25, size.height * 0.7),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.7),
      size.width * 0.6,
      spotGold,
    );

    // 3. Floating Bokeh Particles
    for (final particle in particles) {
      final double currentY = (particle.y - progress * particle.speed) % 1.0;
      final double actualX = particle.x * size.width;
      final double actualY = currentY * size.height;

      final Color particleColor = particle.radius > 3.5
          ? AppColors.brandYellow
          : (isDark ? Colors.white : AppColors.primary);

      final Paint particlePaint = Paint()
        ..color = particleColor.withValues(
            alpha: isDark ? particle.opacity : particle.opacity * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(actualX, actualY),
        particle.radius,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.progress != progress;
}
