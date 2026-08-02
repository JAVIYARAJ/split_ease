import 'dart:math';
import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_colors.dart';

/// Animated ambient background for SplitEase Splash Screen
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
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

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base Rich Gradient Background
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF041816), // Ultra dark deep teal top
          Color(0xFF00332D), // Rich midnight teal
          Color(0xFF004D40), // Deep primary teal bottom
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Ambient Glowing Spotlights (Top-Right Teal Glow & Center Gold Glow)
    final Paint spotTeal = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.35),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.75, size.height * 0.25),
          radius: size.width * 0.7,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.25),
      size.width * 0.7,
      spotTeal,
    );

    final Paint spotGold = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.brandYellow.withValues(alpha: 0.18),
          AppColors.brandYellow.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.3, size.height * 0.65),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.65),
      size.width * 0.6,
      spotGold,
    );

    // 3. Floating Bokeh Particles
    for (final particle in particles) {
      final double currentY = (particle.y - progress * particle.speed) % 1.0;
      final double actualX = particle.x * size.width;
      final double actualY = currentY * size.height;

      final Paint particlePaint = Paint()
        ..color = (particle.radius > 3.5
                ? AppColors.brandYellow
                : Colors.white)
            .withValues(alpha: particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(actualX, actualY),
        particle.radius,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
