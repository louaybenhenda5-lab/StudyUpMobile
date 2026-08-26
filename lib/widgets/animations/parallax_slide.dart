import 'package:flutter/material.dart';

import '../../models/onboarding_item.dart';
import '../onboarding/illustration_slide.dart';

/// One onboarding illustration page. The illustration drifts on a horizontal
/// parallax + subtle scale tied to the [controller] so swiping feels layered.
class ParallaxSlide extends StatelessWidget {
  const ParallaxSlide({
    super.key,
    required this.controller,
    required this.index,
    required this.type,
  });

  final PageController controller;
  final int index;
  final OnboardingIllustration type;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final page = controller.hasClients
            ? (controller.page ?? index.toDouble())
            : index.toDouble();
        final progress = (page - index).clamp(-1.0, 1.0).toDouble();

        final illustrationShift = progress * -36.0;
        final illustrationScale = 1.0 - 0.03 * progress.abs();

        return Center(
          child: Transform.translate(
            offset: Offset(illustrationShift, 0),
            child: Transform.scale(
              scale: illustrationScale,
              child: IllustrationSlide(
                type: type,
                isActive: progress == 0,
                progress: progress,
                size: 260,
              ),
            ),
          ),
        );
      },
    );
  }
}
