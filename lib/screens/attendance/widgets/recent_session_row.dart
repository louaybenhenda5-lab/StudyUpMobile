import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/Session.dart';
import '../models/attendance_ui_models.dart';

/// Single row inside the "Recent Sessions" card.
class RecentSessionRow extends StatelessWidget {
  final Session session;
  final int presentCount;
  final int totalCount;

  const RecentSessionRow({
    super.key,
    required this.session,
    required this.presentCount,
    required this.totalCount,
  });

  double get _pct =>
      totalCount == 0 ? 0.0 : presentCount * 100 / totalCount;

  /// Convenience constructor from precomputed info (kept for reference parity).
  factory RecentSessionRow.fromInfo(
    Session session,
    RecentSessionInfo info,
  ) {
    return RecentSessionRow(
      session: session,
      presentCount: info.presentCount,
      totalCount: info.totalCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final pct = _pct;
    final pillColor = pct >= 75
        ? const Color(0xFF27AE60)
        : pct >= 50
            ? const Color(0xFFE67E22)
            : const Color(0xFFE74C3C);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7CF6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_available_outlined,
              size: 20,
              color: Color(0xFF2E7CF6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.subject?.displayName ?? 'Session'} • ${session.day?.shortName ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.startTimeFormatted} - ${session.endTimeFormatted} • $presentCount/$totalCount present',
                  style: TextStyle(
                      fontSize: 12, color: colors.subtitleText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: pillColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: pillColor.withValues(alpha: 0.30)),
            ),
            child: Text(
              '${pct.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: pillColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
