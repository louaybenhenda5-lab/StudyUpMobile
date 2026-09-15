import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/Classroom.dart';
import '../models/User.dart';
import '../providers/SessionViewModel.dart';
import '../providers/UserViewModel.dart';
import 'session_detail_screen.dart';

/// Class detail: header + teacher sessions in this class + live students.
///
/// Students come from real `GET /api/session/student-by-class/{id}`.
/// Tapping a session opens attendance marking.
class ClassroomDetailScreen extends StatefulWidget {
  final Classroom classroom;

  const ClassroomDetailScreen({super.key, required this.classroom});

  @override
  State<ClassroomDetailScreen> createState() => _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends State<ClassroomDetailScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  List<User> _students = [];
  bool _loadingStudents = true;
  String? _studentsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = context.read<UserViewModel>().token;
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _loadingStudents = false;
          _studentsError = 'Please log in again.';
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _loadingStudents = true;
        _studentsError = null;
      });
    }
    final sessionVm = context.read<SessionViewModel>();
    if (sessionVm.mySessions.isEmpty) {
      await sessionVm.loadMySessions(token);
    }
    final students =
        await sessionVm.loadStudentsByClass(token, widget.classroom.id);
    if (!mounted) return;
    setState(() {
      // Fall back to embedded list if live fetch is empty but classroom has data.
      _students = students.isNotEmpty ? students : widget.classroom.students;
      _loadingStudents = false;
      if (students.isEmpty && widget.classroom.students.isEmpty) {
        _studentsError = sessionVm.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1B2233);
    final sessionVm = context.watch<SessionViewModel>();
    final classSessions = sessionVm.mySessions
        .where((s) => s.classroomId == widget.classroom.id)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final filtered = _query.isEmpty
        ? _students
        : _students
            .where((s) =>
                s.displayName.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: colors.headerBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.classroom.name,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors.buttonGradient),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text('Level ${widget.classroom.level}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.classroom.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${_students.length} students'
                      '${classSessions.isNotEmpty ? ' • ${classSessions.length} sessions' : ''}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14)),
                  if (widget.classroom.teacher != null) ...[
                    const SizedBox(height: 4),
                    Text(
                        'Teacher: ${widget.classroom.teacher!.displayName}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Sessions',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 10),
            if (classSessions.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.inputBorder)),
                child: Text('No sessions for this class in your schedule.',
                    style:
                        TextStyle(fontSize: 13, color: colors.subtitleText)),
              )
            else
              for (final s in classSessions)
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => SessionDetailScreen(session: s)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.inputBorder)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  s.subject?.displayName ?? 'Session',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary)),
                              const SizedBox(height: 2),
                              Text(
                                  '${s.day?.displayName ?? ''} • ${s.startTimeFormatted} - ${s.endTimeFormatted}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: colors.subtitleText)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: colors.subtitleText),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 20),
            Text('Students',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
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
                  prefixIcon:
                      Icon(Icons.search, color: colors.inputHint, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 4),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_loadingStudents)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5)),
              )
            else if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.inputBorder)),
                child: Column(
                  children: [
                    Icon(Icons.person_off_outlined,
                        size: 36, color: colors.subtitleText),
                    const SizedBox(height: 10),
                    Text(
                      _students.isEmpty
                          ? 'No students in this classroom'
                          : 'No students match your search',
                      style: TextStyle(
                          fontSize: 14, color: colors.subtitleText),
                    ),
                    if (_studentsError != null) ...[
                      const SizedBox(height: 4),
                      Text("Couldn't refresh list. Pull to retry.",
                          style: TextStyle(
                              fontSize: 12, color: colors.subtitleText)),
                    ],
                  ],
                ),
              )
            else
              for (final student in filtered)
                _buildStudentTile(colors, student, textPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTile(
      AppColors colors, User student, Color textPrimary) {
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
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.displayName,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary)),
                if (student.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(student.email,
                      style: TextStyle(
                          fontSize: 13, color: colors.subtitleText)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
