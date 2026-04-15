import 'package:flutter/material.dart';
import 'package:split_ease/core/utils/app_formatter.dart';

class AnimatedCounterText extends StatefulWidget {
  final double value;
  final TextStyle style;
  final Duration duration;
  final Curve curve;

  const AnimatedCounterText({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.fastOutSlowIn,
  });

  @override
  State<AnimatedCounterText> createState() => _AnimatedCounterTextState();
}

class _AnimatedCounterTextState extends State<AnimatedCounterText> {
  double _displayValue = 0;
  bool _hasBeenAnimated = false;

  @override
  void initState() {
    super.initState();
    // Start with 0 if it hasn't been animated yet
    if (!_hasBeenAnimated) {
      _displayValue = 0;
      _startAnimation();
    } else {
      _displayValue = widget.value;
    }
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _displayValue = widget.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(_hasBeenAnimated),
      tween: Tween<double>(begin: _hasBeenAnimated ? widget.value : 0, end: widget.value),
      duration: _hasBeenAnimated ? Duration.zero : const Duration(milliseconds: 2500),
      curve: Curves.easeOutExpo,
      onEnd: () {
        if (mounted && !_hasBeenAnimated) {
          setState(() {
            _hasBeenAnimated = true;
          });
        }
      },
      builder: (context, value, child) {
        return Text(
          AppFormatter.formatCurrency(value),
          style: widget.style,
        );
      },
    );
  }
}
