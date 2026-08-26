import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/onboarding_item.dart';

class IllustrationSlide extends StatefulWidget {
  const IllustrationSlide({
    super.key,
    required this.type,
    required this.isActive,
    required this.progress,
    this.size = 260,
  });

  final OnboardingIllustration type;
  final bool isActive;
  final double progress;
  final double size;

  @override
  State<IllustrationSlide> createState() => _IllustrationSlideState();
}

class _IllustrationSlideState extends State<IllustrationSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String asset = switch (widget.type) {
      OnboardingIllustration.books => 'assets/images/book.png',
      OnboardingIllustration.rocket => 'assets/images/rocket.png',
      OnboardingIllustration.career => 'assets/images/curves.png',
    };

    // Page-transition factor: 1 when active, 0 at the neighbour offset.
    final t = (1.0 - widget.progress.abs()).clamp(0.0, 1.0);
    final eased = Curves.easeOutCubic.transform(t);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _float,
        builder: (context, _) {
          // Gentle vertical float (0 -> up -> 0 -> up ...).
          final floatY = math.sin(_float.value * math.pi) * 4;

          return Opacity(
            opacity: eased,
            child: Transform.scale(
              scale: (0.94 + 0.06 * eased),
              child: Transform.translate(
                offset: Offset(0, (1 - eased) * 12 + floatY),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      asset,
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.contain,
                    ),
                    if (widget.type == OnboardingIllustration.rocket)
                      _RocketParticles(
                        controller: _float,
                        size: widget.size,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A few very subtle exhaust-style particles drifting below the rocket.
class _RocketParticles extends StatelessWidget {
  const _RocketParticles({
    required this.controller,
    required this.size,
  });

  final AnimationController controller;
  final double size;

  static const List<_Exhaust> _spec = [
    _Exhaust(dx: -10, phase: 0.00, speed: 1.0, dot: 3.0),
    _Exhaust(dx: 8, phase: 0.30, speed: 1.1, dot: 2.5),
    _Exhaust(dx: -4, phase: 0.60, speed: 0.9, dot: 2.0),
    _Exhaust(dx: 14, phase: 0.15, speed: 1.2, dot: 2.0),
    _Exhaust(dx: -16, phase: 0.45, speed: 1.0, dot: 2.5),
  ];

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).extension<AppColors>()!.buttonGradient.first;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (final p in _spec) _build(p, color),
          ],
        );
      },
    );
  }

  Widget _build(_Exhaust p, Color color) {
    final local = ((controller.value * p.speed) + p.phase) % 1.0;
    final y = size * 0.18 + local * size * 0.4;
    final opacity = (1 - local) * 0.22;
    return Transform.translate(
      offset: Offset(p.dx, y),
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: p.dot,
          height: p.dot,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _Exhaust {
  const _Exhaust({
    required this.dx,
    required this.phase,
    required this.speed,
    required this.dot,
  });

  final double dx;
  final double phase;
  final double speed;
  final double dot;
}
