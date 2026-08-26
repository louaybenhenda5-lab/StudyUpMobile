import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 120,
    this.fit = BoxFit.contain,
    this.showWordmark = false,
  });

  final double height;
  final BoxFit fit;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/images/Glogo.png',
      height: height,
      fit: fit,
      gaplessPlayback: true,
    );

    if (!showWordmark) return logo;

    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studyColor = isDark ? Colors.white : colors.textPrimary;
    final wordmark = Text.rich(
      TextSpan(
        text: 'Study',
        style: TextStyle(
          fontSize: height * 0.42,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: studyColor,
        ),
        children: [
          TextSpan(
            text: 'Up',
            style: TextStyle(color: colors.buttonGradient.last),
          ),
        ],
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logo,
        SizedBox(width: height * 0.24),
        wordmark,
      ],
    );
  }
}
