import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/Session.dart';
import '../../../models/enums/Status.dart';
import '../../../providers/ClassroomViewModel.dart';
import '../../../providers/SessionViewModel.dart';
import '../../../providers/UserViewModel.dart';
import '../teacher_sessions_screen.dart';
import 'models/attendance_ui_models.dart';
import 'widgets/attendance_line_chart.dart';
import 'widgets/attendance_stat_tile.dart';
import 'widgets/class_session_header_card.dart';
import 'widgets/recent_session_row.dart';

/// "Attendance History" screen — reference screenshot 2.
///
/// No statistics/history endpoint exists on the backend, so everything is
/// derived client-side from real data:
/// * present/absent/total/average from `student-by-class` + last-value
///   `User.status` (PRESENT/ABSENT only — Excused hidden);
/// * chart + recent sessions from `SessionViewModel.mySessions` filtered by
///   classroom (flat line when only the current snapshot exists);
/// * period dropdown re-derives the same snapshot (backend has no date-range
///   API — selection is kept for reference parity).
class AttendanceHistoryPage extends StatefulWidget {
  final Session? session;
  final String? classroomId;
  final String? classroomName;

  const AttendanceHistoryPage({
    super.key,
    this.session,
    this.classroomId,
    this.classroomName,
  });

  @override
  State<AttendanceHistoryPage> createState() =>
      _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  int _tabIndex = 1; // 0 = Day, 1 = Summary (reference default)
  String _selectedPeriod = 'This Month';
  final _periodOptions = const ['This Week', 'This Month', 'This Year'];

  bool _loading = true;
  String? _error;

  int _present = 0;
  int _absent = 0;
  int _total = 0;
  List<AttendancePoint> _points = [];
  List<Session> _recentSessions = [];
  String _className = '';

  String get _classroomId =>
      widget.session?.classroomId ?? widget.classroomId ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final userVm = context.read<UserViewModel>();
    final sessionVm = context.read<SessionViewModel>();
    final classroomVm = context.read<ClassroomViewModel>();
    final token = userVm.token;

    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Please log in again.';
        });
      }
      return;
    }

    try {
      if (sessionVm.mySessions.isEmpty) {
        await sessionVm.loadMySessions(token);
      }
      if (classroomVm.classrooms == null) {
        await classroomVm.loadClassrooms(token);
      }

      final classId = _classroomId;
      List<Session> inClass = [];
      if (classId.isNotEmpty) {
        inClass = sessionVm.mySessions
            .where((s) => s.classroomId == classId)
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
      } else {
        inClass = List.of(sessionVm.mySessions);
      }

      // Resolve class display name.
      String className = widget.classroomName ?? '';
      if (className.isEmpty && widget.session != null) {
        final c = widget.session!.classNum;
        className = c.isNotEmpty ? 'Class $c' : 'Class';
      }
      if (className.isEmpty && classId.isNotEmpty) {
        final match = (classroomVm.classrooms ?? [])
            .where((c) => c.id == classId)
            .toList();
        if (match.isNotEmpty) className = match.first.name;
      }
      className = className.isEmpty ? 'Attendance' : className;

      // Real roster read for the target class.
      int present = 0, absent = 0, total = 0;
      if (classId.isNotEmpty) {
        final students =
            await sessionVm.loadStudentsByClass(token, classId);
        total = students.length;
        for (final s in students) {
          if (s.status == Status.PRESENT) present++;
          if (s.status == Status.ABSENT) absent++;
        }
        // Unmarked students count as present in the Mark screen default;
        // for history honesty show them as unmarked (neither). Keep raw.
        if (sessionVm.error != null && students.isEmpty) {
          debugPrint('[AttendanceHistory] students: ${sessionVm.error}');
        }
      }

      final pct = total == 0 ? 0.0 : present * 100 / total;

      // Chart: one point per recent session (max 6), all derived from the
      // current class snapshot — flat until the backend stores per-session
      // history. Labels use the session day short name.
      final recent = inClass.length > 6
          ? inClass.sublist(inClass.length - 6)
          : inClass;
      final points = [
        for (final s in recent)
          AttendancePoint(
            label: s.day?.shortName ?? 'S',
            value: pct,
          ),
      ];

      if (!mounted) return;
      setState(() {
        _present = present;
        _absent = absent;
        _total = total;
        _points = points;
        _recentSessions = recent.reversed.toList();
        _className = className;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[AttendanceHistory] load error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Couldn't load statistics. Pull to retry.";
      });
    }
  }

  String get _averageLabel {
    if (_total == 0) return '0%';
    return '${(_present * 100 / _total).toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.headerBackground,
      appBar: AppBar(
        backgroundColor: colors.headerBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Attendance History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    _header(),
                    const SizedBox(height: 48),
                    const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5),
                    ),
                  ],
                )
              : ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    _header(),
                    const SizedBox(height: 16),

                    // Day / Summary segmented control.
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.signupBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _segment('Day', 0)),
                          Expanded(
                              child: _segment('Summary', 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_error != null && _total == 0)
                      _errorCard(colors)
                    else if (_tabIndex == 1)
                      ..._buildSummary(context, colors)
                    else
                      _buildDayPlaceholder(colors),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _header() {
    if (widget.session != null) {
      return ClassSessionHeaderCard(session: widget.session!);
    }
    return ClassroomHeaderCard(
      className: _className.isEmpty
          ? (widget.classroomName ?? 'Class')
          : _className,
      subtitle: _total == 0
          ? 'Attendance overview'
          : '$_total students • $_present present',
    );
  }

  Widget _segment(String label, int index) {
    final selected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2E7CF6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : context.appColors.subtitleText,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSummary(BuildContext context, AppColors colors) {
    return [
      // "Attendance Summary" + period dropdown.
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Attendance Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.dividerColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                isDense: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: colors.textPrimary),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
                dropdownColor: colors.cardBackground,
                items: _periodOptions
                    .map((p) =>
                        DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedPeriod = v);
                  // No date-range API on the backend — re-derive snapshot.
                  _load();
                },
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      // Average / Present / Absent tiles (no Excused: backend has none).
      Row(
        children: [
          Expanded(
            child: AttendanceStatTile(
              value: _averageLabel,
              label: 'Average',
              colors: StatusColors.average(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AttendanceStatTile(
              value: '$_present',
              label: 'Present',
              colors:
                  StatusColors.of(context, Status.PRESENT),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AttendanceStatTile(
              value: '$_absent',
              label: 'Absent',
              colors: StatusColors.of(context, Status.ABSENT),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Attendance Over Time chart card.
      Container(
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
            Text(
              'Attendance Over Time',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Based on current class snapshot',
              style: TextStyle(
                  fontSize: 12, color: colors.subtitleText),
            ),
            const SizedBox(height: 12),
            AttendanceLineChart(points: _points),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Recent Sessions card.
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
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
                Text(
                  'Recent Sessions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              const TeacherSessionsScreen())),
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7CF6),
                    ),
                  ),
                ),
              ],
            ),
            if (_recentSessions.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'No recent sessions for this class yet.',
                style: TextStyle(
                    fontSize: 13, color: colors.subtitleText),
              ),
            ] else ...[
              for (final s in _recentSessions) ...[
                Divider(color: colors.dividerColor, height: 1),
                RecentSessionRow(
                  session: s,
                  presentCount: _present,
                  totalCount: _total,
                ),
              ],
            ],
          ],
        ),
      ),
    ];
  }

  Widget _buildDayPlaceholder(AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Text(
        'Day view coming soon',
        style: TextStyle(color: colors.subtitleText, fontSize: 14),
      ),
    );
  }

  Widget _errorCard(AppColors colors) {
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline,
              size: 36, color: colors.subtitleText),
          const SizedBox(height: 10),
          Text(
            _error ?? 'Could not load statistics',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 14, color: colors.subtitleText),
          ),
        ],
      ),
    );
  }
}
