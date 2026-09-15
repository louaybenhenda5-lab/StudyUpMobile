import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/enums/Status.dart';

/// UI-only attendance helpers. No backend changes: [Status] is the existing
/// backend enum (PRESENT/ABSENT only — Excused is intentionally hidden).
class AttendancePoint {
  final String label;
  final double value; // 0..100

  const AttendancePoint({required this.label, required this.value});
}

class RecentSessionInfo {
  final String title;
  final String subtitle;
  final double percentage; // 0..100
  final int presentCount;
  final int totalCount;

  const RecentSessionInfo({
    required this.title,
    required this.subtitle,
    required this.percentage,
    required this.presentCount,
    required this.totalCount,
  });
}

/// Tint set for a stat tile / pill. Works in light + dark via alpha blends.
class StatusColors {
  final Color background;
  final Color foreground;
  final Color border;

  const StatusColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  static StatusColors of(BuildContext context, Status status) {
    switch (status) {
      case Status.PRESENT:
        const fg = Color(0xFF27AE60);
        return StatusColors(
          background: fg.withValues(alpha: 0.12),
          foreground: fg,
          border: fg.withValues(alpha: 0.25),
        );
      case Status.ABSENT:
        const fg = Color(0xFFE74C3C);
        return StatusColors(
          background: fg.withValues(alpha: 0.12),
          foreground: fg,
          border: fg.withValues(alpha: 0.25),
        );
    }
  }

  static StatusColors average(BuildContext context) {
    const fg = Color(0xFF2E7CF6);
    return StatusColors(
      background: fg.withValues(alpha: 0.12),
      foreground: fg,
      border: fg.withValues(alpha: 0.25),
    );
  }

  /// Neutral container colors derived from the app theme (dark-mode safe).
  static StatusColors neutral(BuildContext context) {
    final colors = context.appColors;
    return StatusColors(
      background: colors.signupBg,
      foreground: colors.subtitleText,
      border: colors.dividerColor,
    );
  }
}
