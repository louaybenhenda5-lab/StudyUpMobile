import 'package:flutter/material.dart';

import '../../../models/enums/Status.dart';
import '../models/attendance_ui_models.dart';

/// Attendance status pill with dropdown (Present / Absent only).
///
/// Backend `Status` has no EXCUSED — Excused is intentionally hidden.
class StatusDropdownPill extends StatelessWidget {
  final Status? status;
  final ValueChanged<Status> onChanged;

  const StatusDropdownPill({
    super.key,
    required this.status,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effective = status ?? Status.ABSENT;
    final c = StatusColors.of(context, effective);

    return PopupMenuButton<Status>(
      onSelected: onChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (context) => [
        _menuItem(context, Status.PRESENT),
        _menuItem(context, Status.ABSENT),
      ],
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: c.foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              effective.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.foreground,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: c.foreground,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<Status> _menuItem(BuildContext context, Status s) {
    final c = StatusColors.of(context, s);
    return PopupMenuItem<Status>(
      value: s,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: c.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(s.displayName),
        ],
      ),
    );
  }
}
