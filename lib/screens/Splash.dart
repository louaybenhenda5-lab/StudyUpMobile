import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _totalMs = 3100;
  static const _brandBlue = Color(0xFF2E7CF6);

  late final AnimationController _c;

  // ---- STEP 1: ambient glow ----
  late final Animation<double> _ambientGlow;

  // ---- STEP 2: book appears ----
  late final Animation<double> _bookOpacity;
  late final Animation<double> _bookScale;
  late final Animation<Offset> _bookOffset;

  // ---- STEP 3: book "opening" illusion ----
  late final Animation<double> _bookFlipAngle; // rotateY, returns to 0
  late final Animation<double> _bookStretch; // scaleY overshoot, returns to 1

  // ---- STEP 4: graduation cap emerges ----
  late final Animation<double> _capOpacity;
  late final Animation<double> _capScale;
  late final Animation<Offset> _capOffset;

  // ---- STEP 5: crossfade into combined StudyUp mark + wordmark ----
  late final Animation<double> _markGroupOpacity; // book+cap fade out
  late final Animation<double> _finalLogoOpacity; // Glogo fades in
  late final Animation<double> _wordmarkOpacity;
  late final Animation<double> _wordmarkScale;
  late final Animation<Offset> _wordmarkOffset;

  // ---- STEP 6: premium glow + breathing ----
  late final Animation<double> _premiumGlowOpacity;
  late final Animation<double> _breathScale;

  // ---- STEP 7: tagline ----
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineOffset;

  // ---- background scene (very subtle) ----
  late final Animation<double> _bgSceneOpacity;

  // ---- STEP 8: exit ----
  late final Animation<double> _exitOpacity;
  late final Animation<Offset> _exitOffset;

  Animation<double> _interval(double begin, double end, Curve curve) {
    return CurvedAnimation(
      parent: _c,
      curve: Interval(begin, end, curve: curve),
    );
  }

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );

    // Helper to convert ms -> fraction of total duration.
    double f(int ms) => ms / _totalMs;

    // STEP 1 — clean start / ambient glow (0.0s -> 0.35s, lingers)
    _ambientGlow = Tween(begin: 0.0, end: 1.0).animate(
      _interval(f(0), f(500), Curves.easeOut),
    );

    // STEP 2 — book appears (0.35s -> 0.85s)
    _bookOpacity = Tween(begin: 0.0, end: 1.0).animate(
      _interval(f(350), f(850), Curves.easeOutCubic),
    );
    _bookScale = Tween(begin: 0.75, end: 1.0).animate(
      _interval(f(350), f(850), Curves.easeOutCubic),
    );
    _bookOffset = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(_interval(f(350), f(850), Curves.easeOutCubic));

    // STEP 3 — book "opening" illusion (0.85s -> 1.25s), settles back to 0/1
    _bookFlipAngle = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.18)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.18, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 45,
      ),
    ]).animate(_interval(f(850), f(1250), Curves.linear));

    _bookStretch = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 45,
      ),
    ]).animate(_interval(f(850), f(1250), Curves.linear));

    // STEP 4 — graduation cap emerges (1.20s -> 1.70s)
    _capOpacity = Tween(begin: 0.0, end: 1.0).animate(
      _interval(f(1200), f(1700), Curves.easeOutCubic),
    );
    _capScale = Tween(begin: 0.80, end: 1.0).animate(
      _interval(f(1200), f(1700), Curves.easeOutBack),
    );
    _capOffset = Tween(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(_interval(f(1200), f(1700), Curves.easeOutCubic));

    // STEP 5 — crossfade book+cap into combined mark, reveal wordmark
    // (1.65s -> 2.15s)
    _markGroupOpacity = Tween(begin: 1.0, end: 0.0).animate(
      _interval(f(1750), f(2150), Curves.easeInOutCubic),
    );
    _finalLogoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      _interval(f(1750), f(2150), Curves.easeInOutCubic),
    );
    _wordmarkOpacity = Tween(begin: 0.0, end: 1.0).animate(
      _interval(f(1750), f(2150), Curves.easeOutCubic),
    );
    _wordmarkScale = Tween(begin: 0.95, end: 1.0).animate(
      _interval(f(1750), f(2150), Curves.easeOutCubic),
    );
    _wordmarkOffset = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(_interval(f(1750), f(2150), Curves.easeOutCubic));

    // STEP 6 — premium glow + breathing (2.10s -> 2.45s)
    _premiumGlowOpacity = Tween(begin: 0.0, end: 1.0).animate(
      _interval(f(2100), f(2450), Curves.easeOut),
    );
    _breathScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.02)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.02, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_interval(f(2100), f(2450), Curves.linear));

    // STEP 7 — tagline (2.35s -> 2.70s)
    _taglineOpacity = Tween(begin: 0.0, end: 1.0).animate(
      _interval(f(2350), f(2700), Curves.easeOutCubic),
    );
    _taglineOffset = Tween(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(_interval(f(2350), f(2700), Curves.easeOutCubic));

    // Subtle educational background scene, fades in slowly, stays faint
    _bgSceneOpacity = Tween(begin: 0.0, end: 1.0).animate(
      _interval(f(0), f(2000), Curves.easeOut),
    );

    // STEP 8 — exit (2.70s -> 3.10s)
    _exitOpacity = Tween(begin: 1.0, end: 0.0).animate(
      _interval(f(2700), f(3100), Curves.easeInOutCubic),
    );
    _exitOffset = Tween(begin: Offset.zero, end: const Offset(0, -0.05))
        .animate(_interval(f(2700), f(3100), Curves.easeInOutCubic));

    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToLogin();
      }
    });

    _c.forward();
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
        const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final textColor = isDark ? Colors.white : const Color(0xFF1B2233);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colors.headerBackground,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return Opacity(
              opacity: _exitOpacity.value,
              child: FractionalTranslation(
                translation: _exitOffset.value,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ---------- SUBTLE EDUCATIONAL BACKGROUND ----------
                    Opacity(
                      opacity: _bgSceneOpacity.value * (isDark ? 0.05 : 0.08),
                      child: ImageFiltered(
                        imageFilter:
                        ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Image.asset(
                          'assets/images/mb.png',
                          fit: BoxFit.cover,
                          width: size.width,
                          height: size.height,
                          color: isDark
                              ? Colors.black.withOpacity(0.4)
                              : null,
                          colorBlendMode:
                          isDark ? BlendMode.darken : null,
                        ),
                      ),
                    ),

                    // ---------- SUBTLE BOOK + PLANT ACCENT ----------
                    Positioned(
                      right: -20,
                      bottom: -10,
                      child: Opacity(
                        opacity: _taglineOpacity.value *
                            (isDark ? 0.12 : 0.16),
                        child: Image.asset(
                          'assets/images/login.png',
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // ---------- AMBIENT CENTER GLOW ----------
                    Center(
                      child: Opacity(
                        opacity: _ambientGlow.value * (isDark ? 0.35 : 0.5),
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _brandBlue.withOpacity(isDark ? 0.28 : 0.18),
                                _brandBlue.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ---------- PREMIUM BREATHING GLOW (STEP 6) ----------
                    Center(
                      child: Opacity(
                        opacity:
                        _premiumGlowOpacity.value * (isDark ? 0.3 : 0.4),
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _brandBlue.withOpacity(0.35),
                                _brandBlue.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ---------- MAIN CONTENT COLUMN ----------
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ----- LOGO STAGE (book -> cap -> combined mark) -----
                          Transform.scale(
                            scale: _breathScale.value,
                            child: SizedBox(
                              width: 160,
                              height: 160,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Book + Cap group (steps 2-4)
                                  Opacity(
                                    opacity: _markGroupOpacity.value,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Graduation cap (step 4)
                                        FractionalTranslation(
                                          translation: _capOffset.value,
                                          child: Opacity(
                                            opacity: _capOpacity.value,
                                            child: Transform.scale(
                                              scale: _capScale.value,
                                              child: Image.asset(
                                                'assets/images/cap.png',
                                                width: 64,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        // Book (steps 2-3)
                                        FractionalTranslation(
                                          translation: _bookOffset.value,
                                          child: Opacity(
                                            opacity: _bookOpacity.value,
                                            child: Transform(
                                              alignment: Alignment.center,
                                              transform: Matrix4.identity()
                                                ..setEntry(3, 2, 0.0015)
                                                ..rotateY(
                                                    _bookFlipAngle.value)
                                                ..scale(
                                                  _bookScale.value,
                                                  _bookScale.value *
                                                      _bookStretch.value,
                                                ),
                                              child: Image.asset(
                                                'assets/images/book.png',
                                                width: 100,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Final combined StudyUp mark (step 5)
                                  Opacity(
                                    opacity: _finalLogoOpacity.value,
                                    child: Image.asset(
                                      'assets/images/Glogo.png',
                                      width: 128,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ----- WORDMARK (step 5) -----
                          FractionalTranslation(
                            translation: _wordmarkOffset.value,
                            child: Opacity(
                              opacity: _wordmarkOpacity.value,
                              child: Transform.scale(
                                scale: _wordmarkScale.value *
                                    _breathScale.value,
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Study'),
                                      TextSpan(
                                        text: 'Up',
                                        style:
                                        TextStyle(color: _brandBlue),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ----- TAGLINE (step 7) -----
                          FractionalTranslation(
                            translation: _taglineOffset.value,
                            child: Opacity(
                              opacity: _taglineOpacity.value,
                              child: Text(
                                'Learn • Connect • Grow',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.4,
                                  color: colors.subtitleText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}