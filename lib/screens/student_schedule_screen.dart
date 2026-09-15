import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/Classroom.dart';
import '../models/Session.dart';
import '../models/enums/Day.dart';
import '../models/enums/Subject.dart';
import '../services/ClassroomService.dart';
import '../services/ScheduleService.dart';
import 'session_detail_screen.dart';

/// Public student schedule: pick a class from a dropdown filter, then see
/// that class's timetable. No login/token required from the student side.
///
/// Data comes from the existing backend via [ClassroomService.getClassrooms]
/// and [ScheduleService.getSchedule], called with an empty token. If the
/// backend enforces auth, a friendly error with retry is shown instead.
class StudentScheduleScreen extends StatefulWidget {
  /// Test seam: skip the classes network call when provided.
  final List<Classroom>? initialClassrooms;

  /// Test seam: classroomId -> sessions, skips the schedule network call.
  final Map<String, List<Session>>? initialSchedules;

  const StudentScheduleScreen({
    super.key,
    this.initialClassrooms,
    this.initialSchedules,
  });

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  static const Color _accentPurple = Color(0xFF6C5DD3);

  static const _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final _classroomService = ClassroomService();
  final _scheduleService = ScheduleService();

  List<Classroom> _classrooms = [];
  Classroom? _selectedClass;
  List<Session> _sessions = [];

  bool _loadingClasses = true;
  String? _classesError;
  bool _loadingSchedule = false;
  String? _scheduleError;

  int _viewIndex = 0; // 0 = Day, 1 = Week
  late DateTime _anchorWeekMonday;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _anchorWeekMonday = _mondayOf(now);
    _selectedDate = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  Future<void> _loadClasses() async {
    if (widget.initialClassrooms != null) {
      if (!mounted) return;
      setState(() {
        _classrooms = widget.initialClassrooms!;
        _loadingClasses = false;
        _classesError = null;
        if (_classrooms.isNotEmpty) {
          _selectedClass = _classrooms.first;
        }
      });
      if (_selectedClass != null) await _loadSchedule(_selectedClass!.id);
      return;
    }
    if (!mounted) return;
    setState(() {
      _loadingClasses = true;
      _classesError = null;
    });
    try {
      // Student has no token: attempt public read with empty token.
      final list = await _classroomService.getClassrooms('');
      if (!mounted) return;
      setState(() {
        _classrooms = list;
        _loadingClasses = false;
        if (_classrooms.isNotEmpty) {
          _selectedClass = _classrooms.first;
        }
      });
      if (_selectedClass != null) await _loadSchedule(_selectedClass!.id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingClasses = false;
        _classesError = e.toString();
      });
    }
  }

  Future<void> _loadSchedule(String classroomId) async {
    final cached = widget.initialSchedules?[classroomId];
    if (cached != null) {
      if (!mounted) return;
      setState(() {
        _sessions = cached;
        _loadingSchedule = false;
        _scheduleError = null;
      });
      return;
    }
    // If the whole screen was given canned data but this id is missing,
    // treat it as an empty timetable rather than hitting the network.
    if (widget.initialSchedules != null) {
      if (!mounted) return;
      setState(() {
        _sessions = const [];
        _loadingSchedule = false;
        _scheduleError = null;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _loadingSchedule = true;
      _scheduleError = null;
    });
    try {
      final schedule = await _scheduleService.getSchedule('', classroomId);
      if (!mounted) return;
      setState(() {
        _sessions = schedule.sessions;
        _loadingSchedule = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingSchedule = false;
        _scheduleError = e.toString();
      });
    }
  }

  Future<void> _refresh() async {
    if (_selectedClass == null) {
      await _loadClasses();
    } else {
      await _loadSchedule(_selectedClass!.id);
    }
  }

  void _onClassChanged(Classroom? value) {
    if (value == null || value.id == _selectedClass?.id) return;
    setState(() {
      _selectedClass = value;
      _sessions = const [];
    });
    _loadSchedule(value.id);
  }

  DateTime _mondayOf(DateTime d) {
    final date = DateTime(d.year, d.month, d.day);
    return date.subtract(Duration(days: date.weekday - 1));
  }

  List<DateTime> get _weekDates =>
      List.generate(7, (i) => _anchorWeekMonday.add(Duration(days: i)));

  Day? _dayForDate(DateTime d) {
    switch (d.weekday) {
      case 1:
        return Day.MONDAY;
      case 2:
        return Day.TUESDAY;
      case 3:
        return Day.WEDNESDAY;
      case 4:
        return Day.THURSDAY;
      case 5:
        return Day.FRIDAY;
      case 6:
        return Day.SATURDAY;
      case 7:
        return Day.SUNDAY;
      default:
        return null;
    }
  }

  List<Session> _sessionsForDate(List<Session> all, DateTime d) {
    final day = _dayForDate(d);
    final list = all.where((s) => s.day == day).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  int _countForDate(List<Session> all, DateTime d) =>
      _sessionsForDate(all, d).length;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      default:
        return 'Sun';
    }
  }

  void _shift(int days) {
    setState(() {
      if (_viewIndex == 0) {
        _selectedDate = _selectedDate.add(Duration(days: days));
        _anchorWeekMonday = _mondayOf(_selectedDate);
      } else {
        _anchorWeekMonday =
            _anchorWeekMonday.add(Duration(days: days >= 0 ? 7 : -7));
        if (_selectedDate.isBefore(_anchorWeekMonday) ||
            _selectedDate.isAfter(
                _anchorWeekMonday.add(const Duration(days: 6)))) {
          _selectedDate = _anchorWeekMonday;
        }
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _anchorWeekMonday = _mondayOf(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final visible = _sessionsForDate(_sessions, _selectedDate);

    return Scaffold(
      backgroundColor: colors.headerBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded,
                color: _accentPurple, size: 22),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select your class to see its timetable',
                  style:
                      TextStyle(fontSize: 13, color: colors.subtitleText),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildClassDropdown(colors),
                      const SizedBox(height: 16),
                      _buildViewToggle(colors),
                      const SizedBox(height: 20),
                      _buildDateNavigator(colors),
                      const SizedBox(height: 16),
                      if (_viewIndex == 0)
                        _buildDaySelector(colors, _sessions)
                      else
                        _buildWeekGrid(colors, _sessions),
                      const SizedBox(height: 20),
                      if (_loadingClasses ||
                          (_loadingSchedule && _sessions.isEmpty))
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colors.buttonGradient[1]),
                          ),
                        )
                      else if (_classesError != null &&
                          _classrooms.isEmpty)
                        _buildErrorCard(
                            colors,
                            "Couldn't load classes. Pull to retry.",
                            _loadClasses)
                      else if (_classrooms.isEmpty)
                        _buildErrorCard(colors, 'No classes available.',
                            _loadClasses)
                      else if (_scheduleError != null &&
                          _sessions.isEmpty)
                        _buildErrorCard(
                            colors,
                            "Couldn't load schedule. Pull to retry.",
                            _refresh)
                      else if (visible.isEmpty)
                        _buildEmptyCard(colors)
                      else
                        for (final s in visible)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 14),
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        SessionDetailScreen(
                                            session: s)),
                              ),
                              child: _StudentSessionCard(
                                session: s,
                                classroomName:
                                    _selectedClass?.name ?? '',
                                colors: colors,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDropdown(AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Classroom>(
          value: _selectedClass,
          hint: Text('Select a class',
              style:
                  TextStyle(color: colors.inputHint, fontSize: 14)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: colors.subtitleText),
          dropdownColor: colors.cardBackground,
          style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600),
          items: [
            for (final c in _classrooms)
              DropdownMenuItem<Classroom>(
                value: c,
                child: Text(c.name.isNotEmpty ? c.name : 'Class'),
              ),
          ],
          onChanged: _loadingClasses ? null : _onClassChanged,
        ),
      ),
    );
  }

  Widget _buildViewToggle(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: colors.signupBg, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Expanded(child: _toggleButton('Day', 0, colors)),
          Expanded(child: _toggleButton('Week', 1, colors)),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, int index, AppColors colors) {
    final selected = _viewIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _viewIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _accentPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : colors.subtitleText,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
      ),
    );
  }

  Widget _buildDateNavigator(AppColors colors) {
    final label =
        '${_selectedDate.day} ${_monthNames[_selectedDate.month]}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left_rounded,
              color: colors.textPrimary, size: 26),
          onPressed: () => _shift(-1),
        ),
        Row(
          children: [
            const Icon(Icons.calendar_month_rounded,
                color: _accentPurple, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ],
        ),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded,
              color: colors.textPrimary, size: 26),
          onPressed: () => _shift(1),
        ),
      ],
    );
  }

  Widget _buildDaySelector(AppColors colors, List<Session> sessions) {
    final dates = _weekDates;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final d = dates[index];
          final selected = _sameDay(d, _selectedDate);
          final count = _countForDate(sessions, d);
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              decoration: BoxDecoration(
                color: selected ? _accentPurple : colors.signupBg,
                borderRadius: BorderRadius.circular(16),
                border: count > 0 && !selected
                    ? Border.all(
                        color: _accentPurple.withValues(alpha: 0.4))
                    : null,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_weekdayShort(d.weekday),
                      style: TextStyle(
                          color: selected
                              ? Colors.white70
                              : colors.subtitleText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('${d.day}',
                      style: TextStyle(
                          color: selected
                              ? Colors.white
                              : colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekGrid(AppColors colors, List<Session> sessions) {
    final dates = _weekDates;
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 0.72,
      children: [
        for (final d in dates)
          GestureDetector(
            onTap: () => setState(() => _selectedDate = d),
            child: Container(
              decoration: BoxDecoration(
                color: _sameDay(d, _selectedDate)
                    ? _accentPurple
                    : colors.signupBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_weekdayShort(d.weekday),
                      style: TextStyle(
                          color: _sameDay(d, _selectedDate)
                              ? Colors.white70
                              : colors.subtitleText,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('${d.day}',
                      style: TextStyle(
                          color: _sameDay(d, _selectedDate)
                              ? Colors.white
                              : colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _countForDate(sessions, d) > 0
                          ? (_sameDay(d, _selectedDate)
                              ? Colors.white
                              : _accentPurple)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorCard(
      AppColors colors, String message, Future<void> Function() onRetry) {
    debugPrint('[StudentSchedule] load error: $message');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.inputBorder)),
      child: Column(
        children: [
          Text(message,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: colors.subtitleText, fontSize: 14)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => onRetry(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: colors.signupBg, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.calendar_month_rounded,
                  color: _accentPurple, size: 34),
              Positioned(
                bottom: -2,
                right: -4,
                child: Icon(Icons.access_time_rounded,
                    color: _accentPurple, size: 14),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No classes on this day! 🎉',
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text('Enjoy your free time and keep learning.',
                    style: TextStyle(
                        color: colors.subtitleText, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentSessionCard extends StatelessWidget {
  final Session session;
  final String classroomName;
  final AppColors colors;

  const _StudentSessionCard(
      {required this.session,
      required this.classroomName,
      required this.colors});

  Color get _color {
    const palette = [
      Color(0xFF6C5DD3),
      Color(0xFF2F86FB),
      Color(0xFF2ED47A),
      Color(0xFFFF9142),
      Color(0xFFFF4D79),
    ];
    final idx = (session.subject?.index ?? 0) % palette.length;
    return palette[idx];
  }

  IconData get _icon {
    switch (session.subject) {
      case Subject.MATH:
        return Icons.calculate_rounded;
      case Subject.PHYSIC:
        return Icons.science_rounded;
      case Subject.INFO:
        return Icons.code_rounded;
      case Subject.HISTORY:
        return Icons.history_rounded;
      case Subject.SPORT:
        return Icons.sports_soccer_rounded;
      case Subject.MUSIC:
        return Icons.music_note_rounded;
      case Subject.ART:
        return Icons.palette_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subject = session.subject?.displayName ?? 'Session';
    final room = classroomName.isNotEmpty
        ? classroomName
        : (session.classNum.isNotEmpty
            ? 'Class ${session.classNum}'
            : session.day?.displayName ?? '');
    final teacher = session.teacher?.displayName ?? '';
    final sub = teacher.isEmpty ? room : '$room • $teacher';
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                  color: _color,
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16))),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(_icon, color: _color, size: 22),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject,
                        style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(sub,
                        style: TextStyle(
                            color: colors.subtitleText, fontSize: 12.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _StudentDashedDivider(color: colors.dividerColor),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(session.startTimeFormatted,
                      style: TextStyle(
                          color: _color,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  Text(session.endTimeFormatted,
                      style: TextStyle(
                          color: colors.subtitleText, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentDashedDivider extends StatelessWidget {
  final Color color;
  const _StudentDashedDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      width: 1,
      child: Column(
        children: List.generate(
          6,
          (i) => Expanded(
            child: Container(
                margin: const EdgeInsets.symmetric(vertical: 1.5),
                color: color),
          ),
        ),
      ),
    );
  }
}
