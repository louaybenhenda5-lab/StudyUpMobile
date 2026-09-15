import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/Session.dart';
import '../../../models/User.dart';
import '../../../models/enums/Status.dart';
import '../../../providers/SessionViewModel.dart';
import '../../../providers/UserViewModel.dart';
import '../../../services/WebSocketService.dart';
import 'models/attendance_ui_models.dart';
import 'widgets/attendance_stat_tile.dart';
import 'widgets/class_session_header_card.dart';
import 'widgets/status_dropdown_pill.dart';

/// "Mark Attendance" screen — reference screenshot 1.
///
/// Faithful port of the provided reference layout, adapted to the real
/// StudyUp backend:
/// * reuses existing [Session], [User], [Status] (PRESENT/ABSENT only —
///   Excused is hidden, no new backend fields/endpoints);
/// * roster comes from `GET /api/session/student-by-class/{id}`;
/// * save sends via the existing WS `SEND /app/student.status` and listens
///   for live updates on `/admin/{sessionId}`.
class MarkAttendancePage extends StatefulWidget {
  final Session session;

  const MarkAttendancePage({super.key, required this.session});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  final WebSocketService _ws = WebSocketService();
  final _searchController = TextEditingController();

  List<User> _students = [];
  final Map<String, Status> _statuses = {};
  final Set<String> _dirty = {};
  StreamSubscription? _statusSub;

  bool _loading = true;
  String? _error;
  String _query = '';
  bool _saving = false;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await _loadStudents();
    _connectWs();
  }

  Future<void> _loadStudents() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = context.read<UserViewModel>().token;
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Please log in again.';
        });
      }
      return;
    }

    final classroomId = widget.session.classroomId;
    if (classroomId == null || classroomId.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'No classroom linked to this session.';
        });
      }
      return;
    }

    final vm = context.read<SessionViewModel>();
    final students = await vm.loadStudentsByClass(token, classroomId);
    if (!mounted) return;

    if (students.isEmpty && vm.error != null) {
      setState(() {
        _students = [];
        _loading = false;
        _error = "Couldn't load students. Pull to retry.";
      });
      return;
    }

    setState(() {
      _students = students;
      _statuses.clear();
      for (final s in students) {
        // Default unmarked students to PRESENT (common attendance UX).
        _statuses[s.id] = s.status ?? Status.PRESENT;
      }
      _dirty.clear();
      _loading = false;
    });
  }

  void _connectWs() {
    final token = context.read<UserViewModel>().token;
    if (token == null || token.isEmpty) return;
    setState(() => _connecting = true);

    _statusSub = _ws.statusStream.listen((update) {
      if (!mounted) return;
      setState(() {
        _statuses[update.studentId] = update.status ?? Status.PRESENT;
      });
    });

    _ws.connect(widget.session.id, jwtToken: token);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _connecting = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _statusSub?.cancel();
    _ws.dispose();
    super.dispose();
  }

  List<User> get _visible {
    if (_query.trim().isEmpty) return _students;
    final q = _query.trim().toLowerCase();
    return _students
        .where((s) => s.displayName.toLowerCase().contains(q))
        .toList();
  }

  int get _present =>
      _students.where((s) => _statuses[s.id] == Status.PRESENT).length;
  int get _absent =>
      _students.where((s) => _statuses[s.id] == Status.ABSENT).length;

  bool get _allSelected =>
      _students.isNotEmpty && _present == _students.length;

  void _setStatus(User student, Status status) {
    setState(() {
      _statuses[student.id] = status;
      _dirty.add(student.id);
    });
  }

  void _toggleSelectAll(bool? value) {
    final target = (value ?? false) ? Status.PRESENT : Status.ABSENT;
    setState(() {
      for (final s in _students) {
        _statuses[s.id] = target;
        _dirty.add(s.id);
      }
    });
  }

  void _markAll(Status status) {
    setState(() {
      for (final s in _students) {
        _statuses[s.id] = status;
        _dirty.add(s.id);
      }
    });
  }

  Future<void> _save() async {
    if (_saving || _students.isEmpty) return;
    setState(() => _saving = true);
    try {
      // Existing write path only: one WS SEND per (dirty) student.
      final targets = _dirty.isEmpty
          ? _students
          : _students.where((s) => _dirty.contains(s.id)).toList();
      for (final s in targets) {
        _ws.sendStudentStatus(s.id, _statuses[s.id] ?? Status.PRESENT);
      }
      _dirty.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ws.isConnected
                ? 'Attendance saved (${targets.length} students)'
                : 'Saved locally — reconnecting for live sync',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
          'Mark Attendance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadStudents,
                child: _loading
                    ? ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        children: [
                          ClassSessionHeaderCard(
                              session: widget.session),
                          const SizedBox(height: 48),
                          const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5),
                          ),
                        ],
                      )
                    : _error != null && _students.isEmpty
                        ? ListView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                                16, 4, 16, 16),
                            children: [
                              ClassSessionHeaderCard(
                                  session: widget.session),
                              const SizedBox(height: 16),
                              _errorCard(colors),
                            ],
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(
                                16, 4, 16, 16),
                            children: [
                              ClassSessionHeaderCard(
                                  session: widget.session),
                              const SizedBox(height: 16),

                              // Present / Absent summary tiles (no Excused:
                              // backend Status has PRESENT/ABSENT only).
                              Row(
                                children: [
                                  Expanded(
                                    child: AttendanceStatTile(
                                      value: '$_present',
                                      label: 'Present',
                                      colors: StatusColors.of(
                                          context, Status.PRESENT),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AttendanceStatTile(
                                      value: '$_absent',
                                      label: 'Absent',
                                      colors: StatusColors.of(
                                          context, Status.ABSENT),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Search field.
                              TextField(
                                controller: _searchController,
                                onChanged: (v) =>
                                    setState(() => _query = v),
                                style: TextStyle(
                                    color: colors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Search student',
                                  hintStyle: TextStyle(
                                      color: colors.inputHint),
                                  prefixIcon: Icon(Icons.search,
                                      color: colors.inputHint),
                                  filled: true,
                                  fillColor:
                                      colors.inputBackground,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: colors.inputBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: colors.inputBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF2E7CF6)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Select all + Mark all.
                              Row(
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Checkbox(
                                      value: _allSelected,
                                      onChanged: _toggleSelectAll,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  5)),
                                      activeColor:
                                          const Color(0xFF2E7CF6),
                                      side: BorderSide(
                                          color: colors.inputBorder),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Select All',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  if (_connecting) ...[
                                    const SizedBox(width: 8),
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child:
                                          CircularProgressIndicator(
                                              strokeWidth: 2),
                                    ),
                                  ],
                                  const Spacer(),
                                  PopupMenuButton<Status>(
                                    onSelected: _markAll,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                12)),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: Status.PRESENT,
                                        child: Text('Present'),
                                      ),
                                      const PopupMenuItem(
                                        value: Status.ABSENT,
                                        child: Text('Absent'),
                                      ),
                                    ],
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8),
                                      decoration: BoxDecoration(
                                        color: colors.signupBg,
                                        borderRadius:
                                            BorderRadius.circular(
                                                10),
                                      ),
                                      child: const Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Mark All',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color:
                                                  Color(0xFF2E7CF6),
                                            ),
                                          ),
                                          Icon(
                                              Icons
                                                  .keyboard_arrow_down_rounded,
                                              size: 18,
                                              color:
                                                  Color(0xFF2E7CF6)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Student list.
                              if (_visible.isEmpty)
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 28),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No students match your search',
                                    style: TextStyle(
                                        color:
                                            colors.subtitleText,
                                        fontSize: 14),
                                  ),
                                )
                              else
                                ..._visible.asMap().entries.map((e) {
                                  final idx =
                                      _students.indexOf(e.value) +
                                          1;
                                  return _StudentRow(
                                    index: idx,
                                    student: e.value,
                                    status: _statuses[e.value.id],
                                    onStatusChanged: (s) =>
                                        _setStatus(e.value, s),
                                  );
                                }),
                            ],
                          ),
              ),
            ),

            // Save button.
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: colors.headerBackground,
                border:
                    Border(top: BorderSide(color: colors.dividerColor)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      (_saving || _loading || _students.isEmpty)
                          ? null
                          : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7CF6),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF2E7CF6)
                        .withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation(
                                Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Attendance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
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
          Icon(Icons.person_search_outlined,
              size: 36, color: colors.subtitleText),
          const SizedBox(height: 10),
          Text(
            _error ?? 'Could not load students',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 14, color: colors.subtitleText),
          ),
          const SizedBox(height: 4),
          Text(
            'Pull down to retry.',
            style:
                TextStyle(fontSize: 12, color: colors.subtitleText),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final int index;
  final User student;
  final Status? status;
  final ValueChanged<Status> onStatusChanged;

  const _StudentRow({
    required this.index,
    required this.student,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPresent = (status ?? Status.ABSENT) == Status.PRESENT;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: isPresent,
              onChanged: (v) => onStatusChanged(
                (v ?? false) ? Status.PRESENT : Status.ABSENT,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              activeColor: const Color(0xFF2E7CF6),
              side: BorderSide(color: colors.inputBorder),
            ),
          ),
          const SizedBox(width: 10),
          _InitialsAvatar(name: student.displayName),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$index. ${student.displayName}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          StatusDropdownPill(
            status: status,
            onChanged: onStatusChanged,
          ),
        ],
      ),
    );
  }
}

/// Circular avatar with the student's initials (no photo asset/backend).
class _InitialsAvatar extends StatelessWidget {
  final String name;
  const _InitialsAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return CircleAvatar(
      radius: 18,
      backgroundColor: colors.avatarGradientEnd,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7CF6),
        ),
      ),
    );
  }
}
