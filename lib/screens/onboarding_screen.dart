import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/onboarding_item.dart';
import '../widgets/animations/parallax_slide.dart';
import '../widgets/app_logo.dart';
import '../widgets/onboarding/action_button.dart';
import '../widgets/onboarding/page_indicator.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int get _slideCount => kOnboardingItems.length;

  final PageController _controller = PageController();

  /// Tracks the "Get Started" button so the expanding mask reveal can start
  /// from its exact on-screen position.
  final GlobalKey _actionKey = GlobalKey();

  /// Drives the full-screen expanding-circle cover that plays after the
  /// "Get Started" button morphs into a circle.
  late final AnimationController _coverController;

  /// Drives the opacity fade of the cover once it fully covers the screen,
  /// revealing the LoginScreen underneath.
  late final AnimationController _fadeController;

  int _index = 0;
  bool _navigating = false;
  bool _showLogin = false;
  bool _done = false;

  Offset _coverOrigin = Offset.zero;
  double _coverRadius = 0;
  List<Color> _coverColors = const [
    Color(0xFF5AA3FB),
    Color(0xFF2E7CF6),
  ];

  @override
  void initState() {
    super.initState();
    _coverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 540),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _revealLogin();
      });
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) setState(() => _done = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _coverController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    if (_navigating) return;
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  void _next() {
    if (_index < _slideCount - 1) {
      _goTo(_index + 1);
    } else {
      _finish();
    }
  }

  void _skip() => _goTo(_slideCount - 1);

  void _finish() {
    if (_navigating) return;

    // Origin + size for the expanding circle = the "Get Started" button.
    final screenSize = MediaQuery.of(context).size;
    final renderBox = _actionKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final topLeft = renderBox.localToGlobal(Offset.zero);
      _coverOrigin = topLeft +
          Offset(renderBox.size.width / 2, renderBox.size.height / 2);
    } else {
      // Fallback: bottom-center of the screen.
      _coverOrigin = Offset(screenSize.width / 2, screenSize.height - 80);
    }
    _coverRadius = math.sqrt(screenSize.width * screenSize.width +
            screenSize.height * screenSize.height) +
        120;

    final colors = Theme.of(context).extension<AppColors>()!;
    // Circle colour matched to the Login background for a seamless blend.
    _coverColors = [colors.headerBackground, colors.headerBackground];

    // Grow the circle to fully cover the screen, then reveal the Login screen.
    setState(() => _navigating = true);
    _coverController.forward();
  }

  void _revealLogin() {
    if (!_navigating) return;
    // Swap the base layer to the LoginScreen (hidden behind the opaque,
    // full-screen cover). Wait one frame so Login is laid out underneath
    // before the cover's opacity begins to drop.
    setState(() => _showLogin = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _navigating && !_done) _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isLast = _index == _slideCount - 1;
    final item = kOnboardingItems[_index];

    return Stack(
      children: [
        if (_showLogin)
          const LoginScreen()
        else
          Scaffold(
            backgroundColor: colors.cardBackground,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar: brand left, Skip right.
                    Padding(
                      padding: EdgeInsets.only(
                        top: 12,
                        left: constraints.maxWidth < 360 ? 24.0 : 32.0,
                        right: constraints.maxWidth < 360 ? 20.0 : 24.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppLogo(height: 40, showWordmark: true),
                          if (!isLast)
                            TextButton(
                              onPressed: _skip,
                              style: TextButton.styleFrom(
                                foregroundColor: colors.subtitleText,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                minimumSize: const Size(0, 40),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.03),
                    // Main image area.
                    Expanded(
                      flex: 5,
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _slideCount,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder: (context, i) {
                          return ParallaxSlide(
                            controller: _controller,
                            index: i,
                            type: kOnboardingItems[i].illustration,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: h * 0.025),
                    // Page indicators.
                    Center(
                      child: PageIndicator(index: _index, count: _slideCount),
                    ),
                    SizedBox(height: h * 0.03),
                    // Text section (animated per page).
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth < 360 ? 24.0 : 32.0,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                        child: Column(
                          key: ValueKey<int>(_index),
                          children: [
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: colors.subtitleText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.55,
                                color: colors.subtitleText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.04),
                    // Bottom action button.
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth < 360 ? 24.0 : 32.0,
                      ).copyWith(bottom: 8),
                      child: ActionButton(
                        key: _actionKey,
                        isLast: isLast,
                        onPressed: _next,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        if (_navigating && !_done)
          AnimatedBuilder(
            animation: _coverController,
            builder: (context, _) {
              final d = _coverRadius * 2 * _coverController.value;
              final opacity = 1.0 - _fadeController.value;
              return Positioned(
                left: _coverOrigin.dx - d / 2,
                top: _coverOrigin.dy - d / 2,
                width: d,
                height: d,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: _coverColors),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
