import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class RotatingLogo extends StatefulWidget {
  final double size;
  final double iconSize;

  const RotatingLogo({
    super.key,
    this.size = 80,
    this.iconSize = 40,
  });

  @override
  State<RotatingLogo> createState() => _RotatingLogoState();
}

class _RotatingLogoState extends State<RotatingLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Slower, premium rotation
    );
    
    // Smooth curve for the rotation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack, 
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
      animation: _animation,
      builder: (context, child) {
        // Horizontal Rotation (Y-axis)
        // 2 * pi = 360 degrees
        final angle = _animation.value * 2 * 3.14159; 
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(angle),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: AppColors.primaryAccent.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.attach_money_rounded,
          color: const Color(0xFFB39200),
          size: widget.iconSize,
        ),
      ),
    );
  }
}
