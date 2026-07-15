import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:split_ease/core/utils/app_formatter.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class CounterVisibilityCubit extends Cubit<bool> {
  CounterVisibilityCubit() : super(false);

  void markVisible() {
    if (!state) emit(true);
  }
}

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
  late final Key _detectorKey;

  @override
  void initState() {
    super.initState();
    _detectorKey = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterVisibilityCubit(),
      child: BlocBuilder<CounterVisibilityCubit, bool>(
        builder: (context, isVisible) {
          return VisibilityDetector(
            key: _detectorKey,
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0.1 && !isVisible && mounted) {
                context.read<CounterVisibilityCubit>().markVisible();
              }
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: isVisible ? widget.value : 0,
              ),
              duration: widget.duration,
              curve: widget.curve,
              builder: (context, value, child) {
                return Text(
                  AppFormatter.formatCurrency(value.abs()),
                  style: widget.style.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  softWrap: false,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
