import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A row of page dots. The active dot stretches into a pill (8 → 24 px wide)
/// and every change is animated with `AnimatedContainer`.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.index,
    required this.count,
  });

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final active = colors.buttonGradient.last;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? active : colors.dotInactive,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
