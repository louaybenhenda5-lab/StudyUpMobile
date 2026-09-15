import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/enums/Status.dart';
import '../providers/ClassroomViewModel.dart';
import '../providers/SessionViewModel.dart';
import '../providers/UserViewModel.dart';
import 'attendance/attendance_history_page.dart';

/// Per-class attendance statistics for the teacher.
///
/// Backend provides no statistics endpoint (only WS write
/// `/app/student.status` + last-value `User.status`), so counts are
/// computed client-side from real `student-by-class` data:
/// present / absent / marked (actually recorded) / total.
class TeacherStatsScreen extends StatefulWidget {
  const TeacherStatsScreen({super.key});

  @override
  State<TeacherStatsScreen> createState() => _TeacherStatsScreenState();
}

class _TeacherStatsScreenState extends State<TeacherStatsScreen> {
  bool _loading = false;
  String? _error;
  List<_ClassStat> _stats = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final userVm = context.read<UserViewModel>();
    final sessionVm = context.read<SessionViewModel>();
    final classroomVm = context.read<ClassroomViewModel>();
    final token = userVm.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (sessionVm.mySessions.isEmpty) {
        await sessionVm.loadMySessions(token);
      }
      if (classroomVm.classrooms == null) {
        await classroomVm.loadClassrooms(token);
      }

      final ids = <String>{};
      for (final s in sessionVm.mySessions) {
        if ((s.classroomId ?? '').isNotEmpty) ids.add(s.classroomId!);
      }
      final byClassroom = {for (final c in (classroomVm.classrooms ?? [])) c.id: c};

      final stats = <_ClassStat>[];
      for (final id in ids) {
        // Real backend read per class.
        final students = await sessionVm.loadStudentsByClass(token, id);
        var present = 0;
        var absent = 0;
        for (final st in students) {
          if (st.status == Status.PRESENT) present++;
          if (st.status == Status.ABSENT) absent++;
        }
        stats.add(_ClassStat(
          classroomId: id,
          className: byClassroom[id]?.name ?? 'Class',
          present: present,
          absent: absent,
          total: students.length,
        ));
      }
      stats.sort((a, b) => a.className.compareTo(b.className));
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[TeacherStats] load error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Couldn\'t load statistics. Pull to retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1B2233);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Text('Attendance Statistics',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textPrimary)),
            const SizedBox(height: 4),
            Text('Live student status per class',
                style: TextStyle(fontSize: 13, color: colors.subtitleText)),
            const SizedBox(height: 16),
            if (_loading && _stats.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.buttonGradient[1]),
                ),
              )
            else if (_error != null && _stats.isEmpty)
              _messageCard(colors, textPrimary, Icons.error_outline, _error!)
            else if (_stats.isEmpty)
              _messageCard(colors, textPrimary, Icons.bar_chart_outlined,
                  'No classes with students yet.')
            else
              for (final s in _stats) ...[
                _statCard(colors, textPrimary, s),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }

  Widget _messageCard(
      AppColors colors, Color textPrimary, IconData icon, String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colors.subtitleText),
          const SizedBox(height: 10),
          Text(msg,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colors.subtitleText)),
        ],
      ),
    );
  }

  Widget _statCard(AppColors colors, Color textPrimary, _ClassStat s) {
    final marked = s.present + s.absent;
    final pct = s.total == 0 ? 0.0 : marked / s.total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(s.className,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary)),
              ),
              Text('$marked/${s.total} marked',
                  style:
                      TextStyle(fontSize: 12, color: colors.subtitleText)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: colors.signupBg,
              valueColor: AlwaysStoppedAnimation<Color>(
                  colors.buttonGradient[1]),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _pill(context, colors, 'Present ${s.present}',
                  const Color(0xFF27AE60)),
              const SizedBox(width: 8),
              _pill(context, colors, 'Absent ${s.absent}',
                  const Color(0xFFE74C3C)),
              const SizedBox(width: 8),
              _pill(context, colors, 'Total ${s.total}', colors.subtitleText,
                  filled: false),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AttendanceHistoryPage(
                    classroomId: s.classroomId,
                    classroomName: s.className,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2E7CF6),
                backgroundColor:
                    const Color(0xFF2E7CF6).withValues(alpha: 0.10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View history',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, AppColors colors, String label,
      Color color,
      {bool filled = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : colors.signupBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _ClassStat {
  final String classroomId;
  final String className;
  final int present;
  final int absent;
  final int total;

  _ClassStat(
      {required this.classroomId,
      required this.className,
      required this.present,
      required this.absent,
      required this.total});
}
