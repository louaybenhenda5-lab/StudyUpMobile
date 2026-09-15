import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/enums/Status.dart';
import '../models/Session.dart';
import '../models/StudentStatus.dart';
import '../models/User.dart';
import '../providers/SessionViewModel.dart';
import '../providers/UserViewModel.dart';
import '../services/WebSocketService.dart';
import 'attendance/attendance_history_page.dart';
import 'attendance/mark_attendance_page.dart';

class SessionDetailScreen extends StatefulWidget {
  final Session? session;

  const SessionDetailScreen({super.key, this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final WebSocketService _webSocketService = WebSocketService();

  Session? _session;
  List<User> _students = [];
  final Map<String, Status> _statuses = {};
  bool _connecting = false;
  String? _wsMessage;
  bool _loadingStudents = false;
  String? _studentsError;
  final _searchController = TextEditingController();
  String _query = '';
  StreamSubscription<StudentStatus>? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    await _ensureSession();
    await _loadStudents();
    _connectWebSocket();
  }

  Future<void> _ensureSession() async {
    if (_session != null) return;

    final userViewModel = context.read<UserViewModel>();
    final sessionViewModel = context.read<SessionViewModel>();
    final token = userViewModel.token;
    final userId = userViewModel.currentUser?.id;

    if (token != null && token.isNotEmpty && userId != null && userId.isNotEmpty) {
      await sessionViewModel.loadTodaySession(token, userId);
      if (mounted) {
        setState(() => _session = sessionViewModel.todaySession);
      }
    }
  }

  Future<void> _loadStudents() async {
    setState(() {
      _loadingStudents = true;
      _studentsError = null;
    });

    final userViewModel = context.read<UserViewModel>();
    final token = userViewModel.token;

    if (token == null || token.isEmpty) {
      setState(() => _loadingStudents = false);
      return;
    }

    final session = _session;
    List<User> students = [];

    // Real backend read: students belong to the session's classroom.
    if (session != null &&
        session.classroomId != null &&
        session.classroomId!.isNotEmpty) {
      final sessionViewModel = context.read<SessionViewModel>();
      students =
          await sessionViewModel.loadStudentsByClass(token, session.classroomId!);
      if (students.isEmpty && sessionViewModel.error != null) {
        debugPrint('[SessionDetail] students error: ${sessionViewModel.error}');
        _studentsError = 'Couldn\'t load students. Pull to retry.';
      }
    } else {
      _studentsError = 'No classroom linked to this session.';
    }

    if (!mounted) return;

    setState(() {
      _students = students;
      for (final student in students) {
        if (student.status != null) {
          _statuses[student.id] = student.status!;
        }
      }
      _loadingStudents = false;
    });
  }

  void _connectWebSocket() {
    final session = _session;
    final userViewModel = context.read<UserViewModel>();
    final token = userViewModel.token;

    if (session == null || token == null || token.isEmpty) return;

    setState(() => _connecting = true);

    _statusSubscription = _webSocketService.statusStream.listen((status) {
      if (!mounted) return;
      setState(() {
        _statuses[status.studentId] = status.status ?? Status.PRESENT;
        _wsMessage = 'Updated ${status.status?.displayName}';
      });
    });

    _webSocketService.connect(session.id, jwtToken: token);

    // Need a short delay for the STOMP handshake + subscription before sending.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _connecting = false;
          _wsMessage = _webSocketService.isConnected ? 'Live · status sync enabled' : 'Connection unavailable';
        });
      }
    });
  }

  void _toggleStatus(String studentId, Status status) {
    // Optimistic update with real backend send via WS SEND /app/student.status.
    setState(() {
      _statuses[studentId] = status;
    });
    _webSocketService.sendStudentStatus(studentId, status);
    if (!_webSocketService.isConnected && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Saved locally — reconnecting for live sync')),
      );
    }
  }

  Future<void> _deleteSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session'),
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final userViewModel = context.read<UserViewModel>();
    final sessionViewModel = context.read<SessionViewModel>();
    final token = userViewModel.token;
    final session = _session;

    if (token == null || session == null) return;

    final success = await sessionViewModel.deleteSession(token, session.id);
    if (!mounted) return;

    if (success) {
      _webSocketService.dispose();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session deleted')),
      );
      Navigator.of(context).maybePop();
    } else {
      debugPrint('[SessionDetail] delete error: ${sessionViewModel.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not delete session. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _statusSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1B2233);
    final session = _session;

    return Scaffold(
      backgroundColor: colors.headerBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Session Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: session == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AttendanceHistoryPage(session: session),
                      ),
                    ),
            icon: Icon(Icons.bar_chart_outlined, color: textPrimary),
            tooltip: 'Attendance history',
          ),
          IconButton(
            onPressed: _deleteSession,
            icon: Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete session',
          ),
        ],
      ),
      body: session == null
          ? Center(
              child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.buttonGradient[1]),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _buildSessionInfoCard(context, colors, session, textPrimary),
                const SizedBox(height: 12),
                _buildAttendanceActions(context, colors, session),
                const SizedBox(height: 20),

                // Attendance section.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Students (${_students.length})',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
                    ),
                    if (_connecting)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (_wsMessage != null)
                      Text(
                        _wsMessage!,
                        style: TextStyle(fontSize: 12, color: colors.subtitleText),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSummaryBar(colors),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.inputBorder),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        setState(() => _query = v.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search students',
                      hintStyle:
                          TextStyle(color: colors.inputHint, fontSize: 14),
                      prefixIcon: Icon(Icons.search,
                          color: colors.inputHint, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildStudentsSection(context, colors, textPrimary),
              ],
            ),
    );
  }

  Widget _buildSessionInfoCard(BuildContext context, AppColors colors, Session session, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors.buttonGradient),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  session.subject?.displayName ?? 'Session',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                session.eachTwoWeeks ? 'Every 2 weeks' : 'Weekly',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            session.day?.displayName ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.white.withValues(alpha: 0.9), size: 18),
              const SizedBox(width: 6),
              Text(
                '${session.startTimeFormatted} - ${session.endTimeFormatted}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (session.classNum.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.meeting_room_outlined, color: Colors.white.withValues(alpha: 0.9), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Class ${session.classNum}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          if (session.teacher != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.white.withValues(alpha: 0.9), size: 18),
                const SizedBox(width: 6),
                Text(
                  session.teacher!.displayName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceActions(
      BuildContext context, AppColors colors, Session session) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MarkAttendancePage(session: session),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7CF6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Mark Attendance',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      AttendanceHistoryPage(session: session),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7CF6),
                side: const BorderSide(color: Color(0xFF2E7CF6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'History',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBar(AppColors colors) {
    var present = 0;
    var absent = 0;
    for (final s in _students) {
      final st = _statuses[s.id];
      if (st == Status.PRESENT) present++;
      if (st == Status.ABSENT) absent++;
    }
    final marked = present + absent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Row(
        children: [
          _summaryItem(colors, 'Present $present', const Color(0xFF27AE60)),
          const SizedBox(width: 8),
          _summaryItem(colors, 'Absent $absent', const Color(0xFFE74C3C)),
          const SizedBox(width: 8),
          _summaryItem(
              colors, 'Marked $marked/${_students.length}', colors.subtitleText),
        ],
      ),
    );
  }

  Widget _summaryItem(AppColors colors, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ),
    );
  }

  Widget _buildStudentsSection(BuildContext context, AppColors colors, Color textPrimary) {
    if (_loadingStudents) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2.5),
      );
    }

    final visible = _query.isEmpty
        ? _students
        : _students
            .where((s) =>
                s.displayName.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    if (visible.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.inputBorder),
        ),
        child: Column(
          children: [
            Icon(Icons.person_search_outlined, size: 36, color: colors.subtitleText),
            const SizedBox(height: 10),
            Text(
              _students.isEmpty
                  ? 'No students available for this session'
                  : 'No students match your search',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colors.subtitleText),
            ),
            const SizedBox(height: 4),
            Text(
              _studentsError ??
                  'Tap a student to mark them present or absent',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colors.subtitleText),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final student in visible)
          _buildStudentStatusTile(colors, student, textPrimary),
      ],
    );
  }

  Widget _buildStudentStatusTile(AppColors colors, User student, Color textPrimary) {
    final current = _statuses[student.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors.buttonGradient),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                student.initials.isNotEmpty ? student.initials : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.displayName,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary),
                ),
                if (student.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    student.email,
                    style: TextStyle(fontSize: 13, color: colors.subtitleText),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Present toggle.
          GestureDetector(
            onTap: () => _toggleStatus(student.id, Status.PRESENT),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: current == Status.PRESENT
                    ? const Color(0xFF27AE60)
                    : colors.inputBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: current == Status.PRESENT ? const Color(0xFF27AE60) : colors.inputBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 15,
                    color: current == Status.PRESENT ? Colors.white : colors.subtitleText,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Present',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: current == Status.PRESENT ? Colors.white : colors.subtitleText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Absent toggle.
          GestureDetector(
            onTap: () => _toggleStatus(student.id, Status.ABSENT),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: current == Status.ABSENT
                    ? const Color(0xFFE74C3C)
                    : colors.inputBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: current == Status.ABSENT ? const Color(0xFFE74C3C) : colors.inputBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.close,
                    size: 15,
                    color: current == Status.ABSENT ? Colors.white : colors.subtitleText,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Absent',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: current == Status.ABSENT ? Colors.white : colors.subtitleText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}