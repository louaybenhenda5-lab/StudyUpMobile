import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/navigation/page_transitions.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'onboarding_screen.dart';
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final Animation<double> _enterFade =
      CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
  late final Animation<Offset> _enterOffset = Tween<Offset>(
    begin: const Offset(0, 18),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _getStarted() {
    Navigator.of(context).pushReplacement(
      welcomeToOnboardingRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.cardBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final imageSize = (screenWidth * 0.92).clamp(300.0, 460.0);

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 360 ? 24.0 : 32.0,
              ).copyWith(top: 20, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top-left unified brand element.
                  const AppLogo(height: 40, showWordmark: true),
                  SizedBox(height: screenHeight * 0.03),
                  // Large main visual with decorative backdrop.
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _enter,
                            builder: (context, child) => Opacity(
                              opacity: _enterFade.value,
                              child: Transform.translate(
                                offset: _enterOffset.value,
                                child: child,
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/welcome.png',
                              width: imageSize,
                              height: imageSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // Content block.
                  AnimatedBuilder(
                    animation: _enter,
                    builder: (context, child) => Opacity(
                      opacity: _enterFade.value,
                      child: Transform.translate(
                        offset: _enterOffset.value,
                        child: child,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome to StudyUp',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: colors.subtitleText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Your all-in-one study companion. Learn with expert '
                          'trainers, explore curated courses, and grow your '
                          'skills — one focused session at a time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.55,
                            color: colors.subtitleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  // Bottom action.
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      key: const Key('get-started-btn'),
                      onTap: _getStarted,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: colors.buttonGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colors.buttonGradient.last.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Soft decorative circles + gently twinkling particles placed behind the
/// welcome illustration. Kept light: only the particles breathe via a slow
/// opacity/scale pulse, the circles stay still so the hero image reads calm.
class _WelcomeBackdrop extends StatefulWidget {
  const _WelcomeBackdrop({required this.size});

  final double size;

  @override
  State<_WelcomeBackdrop> createState() => _WelcomeBackdropState();
}

class _WelcomeBackdropState extends State<_WelcomeBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  static const List<_Particle> _particles = [
    _Particle(dx: -0.46, dy: -0.34, r: 7, delay: 0.00),
    _Particle(dx: 0.48, dy: -0.22, r: 5, delay: 0.18),
    _Particle(dx: -0.40, dy: 0.30, r: 6, delay: 0.42),
    _Particle(dx: 0.44, dy: 0.36, r: 5, delay: 0.30),
    _Particle(dx: 0.02, dy: -0.50, r: 4, delay: 0.55),
    _Particle(dx: -0.10, dy: 0.52, r: 4, delay: 0.65),
    _Particle(dx: 0.30, dy: -0.46, r: 3, delay: 0.10),
    _Particle(dx: -0.30, dy: -0.44, r: 3, delay: 0.75),
  ];

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final s = widget.size;
    final span = s * 1.9;

    return SizedBox(
      width: span,
      height: span,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Large soft halo behind the image.
          Container(
            width: s * 1.16,
            height: s * 1.16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.onboardingCircleBg,
            ),
          ),
          // Accent circle, top-right.
          Positioned(
            top: span * 0.12,
            right: span * 0.10,
            child: Container(
              width: s * 0.42,
              height: s * 0.42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: colors.buttonGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Accent circle, bottom-left (muted).
          Positioned(
            bottom: span * 0.10,
            left: span * 0.08,
            child: Container(
              width: s * 0.30,
              height: s * 0.30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.headerCircle,
              ),
            ),
          ),
          // Twinkling particles.
          for (final p in _particles)
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                final t = (math.sin(
                            (_pulse.value + p.delay) * math.pi * 2) *
                        0.5 +
                    0.5)
                    .clamp(0.0, 1.0);
                final opacity = (0.25 + 0.6 * t).clamp(0.0, 1.0);
                final scale = 0.8 + 0.35 * t;
                return Positioned(
                  left: span / 2 + p.dx * s - (p.r * scale) / 2,
                  top: span / 2 + p.dy * s - (p.r * scale) / 2,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: p.r * scale,
                      height: p.r * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.buttonGradient.first,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.dx,
    required this.dy,
    required this.r,
    required this.delay,
  });

  final double dx;
  final double dy;
  final double r;
  final double delay;
}
