import 'package:flutter/material.dart';

class StaggeredEntryColumn extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration totalDuration;
  final Curve curve;
  final double verticalOffset;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const StaggeredEntryColumn({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 500),
    this.totalDuration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    this.verticalOffset = 20.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  State<StaggeredEntryColumn> createState() => _StaggeredEntryColumnState();
}

class _StaggeredEntryColumnState extends State<StaggeredEntryColumn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.totalDuration,
    );

    // Start immediately
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
      builder: (context, _) {
        return Column(
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          children: List.generate(widget.children.length, (index) {
            final child = widget.children[index];
            
            // Calculate stagger
            // We want even spacing across the total duration
            final double startTime = (index * 0.1).clamp(0.0, 0.8); // 10% staggered
            final double itemDurationFraction = widget.itemDuration.inMilliseconds / widget.totalDuration.inMilliseconds;
            final double endTime = (startTime + itemDurationFraction).clamp(0.0, 1.0);

            // Curve transformation
            final double curveValue = Interval(
              startTime,
              endTime,
              curve: widget.curve,
            ).transform(_controller.value);

            if (curveValue == 0.0) {
              return Opacity(opacity: 0, child: child);
            }

            return Opacity(
              opacity: curveValue.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, widget.verticalOffset * (1 - curveValue)),
                child: child,
              ),
            );
          }),
        );
      },
    );
  }
}
