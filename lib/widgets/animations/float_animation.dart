import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Continuously bobs [child] up and down on a gentle sine wave.
///
/// Runs an infinitely repeating (reverse) animation so no explicit controller
/// is needed by the caller.
class FloatAnimation extends StatefulWidget {
  const FloatAnimation({
    super.key,
    required this.child,
    this.amplitude = 10,
    this.duration = const Duration(milliseconds: 2500),
  });

  final Widget child;
  final double amplitude;
  final Duration duration;

  @override
  State<FloatAnimation> createState() => _FloatAnimationState();
}

class _FloatAnimationState extends State<FloatAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

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
        final wave = math.sin(_controller.value * math.pi * 2);
        return Transform.translate(
          offset: Offset(0, widget.amplitude * wave),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
