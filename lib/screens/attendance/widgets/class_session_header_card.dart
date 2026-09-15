import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/Session.dart';

/// Class/session header card used by both attendance screens.
///
/// Built from the existing [Session] model only — no new backend fields.
class ClassSessionHeaderCard extends StatelessWidget {
  final Session session;

  const ClassSessionHeaderCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.signupBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  session.subject?.displayName ?? 'Session',
                  style: const TextStyle(
                    color: Color(0xFF2E7CF6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                session.eachTwoWeeks ? 'Every 2 weeks' : 'Weekly',
                style: TextStyle(
                  color: colors.subtitleText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            session.day?.displayName ?? 'Session',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time,
                  size: 16, color: colors.subtitleText),
              const SizedBox(width: 6),
              Text(
                '${session.startTimeFormatted} - ${session.endTimeFormatted}',
                style: TextStyle(fontSize: 13, color: colors.subtitleText),
              ),
            ],
          ),
          if (session.classNum.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.meeting_room_outlined,
                    size: 16, color: colors.subtitleText),
                const SizedBox(width: 6),
                Text(
                  'Class ${session.classNum}',
                  style: TextStyle(fontSize: 13, color: colors.subtitleText),
                ),
              ],
            ),
          ],
          if (session.teacher != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 16, color: colors.subtitleText),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    session.teacher!.displayName,
                    style: TextStyle(
                        fontSize: 13, color: colors.subtitleText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Fallback header when only a classroom id/name is known (e.g. opened from
/// the Stats tab where no single Session is selected).
class ClassroomHeaderCard extends StatelessWidget {
  final String className;
  final String subtitle;

  const ClassroomHeaderCard({
    super.key,
    required this.className,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: colors.signupBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Class',
              style: TextStyle(
                color: Color(0xFF2E7CF6),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            className,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: colors.subtitleText),
          ),
        ],
      ),
    );
  }
}
