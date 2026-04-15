import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
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
  bool _isVisible = false;
  bool _hasBeenAnimated = false;

  @override
  Widget build(BuildContext context) {
    // Unique key for VisibilityDetector to avoid issues with scrollable lists
    final detectorKey = Key('counter_${widget.value}_${widget.style.hashCode}');

    return VisibilityDetector(
      key: detectorKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible && mounted) {
          setState(() {
            _isVisible = true;
          });
        }
      },
      child: TweenAnimationBuilder<double>(
        key: ValueKey('${_hasBeenAnimated}_${_isVisible}'),
        tween: Tween<double>(
          begin: (_hasBeenAnimated || !_isVisible) ? widget.value : 0,
          end: widget.value,
        ),
        duration: (_hasBeenAnimated || !_isVisible) 
            ? Duration.zero 
            : widget.duration,
        curve: widget.curve,
        onEnd: () {
          if (mounted && !_hasBeenAnimated && _isVisible) {
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
      ),
    );
  }
}
