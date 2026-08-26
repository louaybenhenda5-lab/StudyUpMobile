import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Bottom onboarding action. Renders a wide gradient button labelled "Next"
/// on every slide except the last, where it reads "Get Started".
///
/// On the last slide, tapping first collapses the capsule back into a 56×56
/// circle (so the upcoming expand-from-button reveal reads as one continuous
/// motion), then fires [onPressed].
class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.isLast,
    this.onPressed,
  });

  final bool isLast;
  final VoidCallback? onPressed;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _collapsing = false;

  void _handleTap() {
    if (!widget.isLast) {
      widget.onPressed?.call();
      return;
    }
    if (_collapsing) return;
    setState(() => _collapsing = true);
    // Let the capsule settle into a circle, then trigger the reveal.
    Future.delayed(const Duration(milliseconds: 220), () {
      widget.onPressed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final gradient = LinearGradient(
      colors: colors.buttonGradient,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final label = widget.isLast ? 'Get Started' : 'Next';

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _collapsing ? 56.0 : constraints.maxWidth;

        return GestureDetector(
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.fastOutSlowIn,
            height: 56,
            width: width,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: colors.buttonGradient.last.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _collapsing
                ? const SizedBox.shrink()
                : Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
