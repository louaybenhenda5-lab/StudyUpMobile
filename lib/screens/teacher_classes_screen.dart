import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/Classroom.dart';
import '../providers/ClassroomViewModel.dart';
import '../providers/SessionViewModel.dart';
import '../providers/UserViewModel.dart';
import 'classroom_detail_screen.dart';

/// Teacher's own classes, derived from real backend data.
///
/// Backend has no `GET /my-classes`: classes are the distinct
/// `classroomId` values from `GET /api/session/my`, enriched with names
/// from `GET /api/level/get`.
class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({super.key});

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

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
    final userVm = context.read<UserViewModel>();
    final token = userVm.token;
    if (token == null || token.isEmpty) return;
    // Load both in parallel; each notifies its own listeners.
    await Future.wait([
      context.read<SessionViewModel>().loadMySessions(token),
      context.read<ClassroomViewModel>().loadClassrooms(token),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1B2233);
    final sessionVm = context.watch<SessionViewModel>();
    final classroomVm = context.watch<ClassroomViewModel>();

    final entries = _buildEntries(sessionVm, classroomVm);
    final filtered = _query.isEmpty
        ? entries
        : entries
            .where((e) =>
                e.displayName.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Text(
              'My Classes',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Classes you teach — from your real schedule',
              style: TextStyle(fontSize: 13, color: colors.subtitleText),
            ),
            const SizedBox(height: 16),
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
                  hintText: 'Search classes',
                  hintStyle:
                      TextStyle(color: colors.inputHint, fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search, color: colors.inputHint, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (sessionVm.isLoading && entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.buttonGradient[1]),
                ),
              )
            else if (entries.isEmpty)
              _emptyState(colors, textPrimary,
                  sessionVm.error ?? classroomVm.error)
            else if (filtered.isEmpty)
              _emptyState(
                  colors, textPrimary, 'No classes match "$_query".')
            else
              for (final e in filtered) ...[
                _classCard(context, colors, textPrimary, e),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }

  List<_TeacherClassEntry> _buildEntries(
      SessionViewModel sessionVm, ClassroomViewModel classroomVm) {
    final sessions = sessionVm.mySessions;
    final classrooms = classroomVm.classrooms ?? [];
    final byId = {for (final c in classrooms) c.id: c};

    // Group teacher sessions by classroomId.
    final sessionCount = <String, int>{};
    final classNumById = <String, String>{};
    for (final s in sessions) {
      final id = s.classroomId ?? '';
      if (id.isEmpty) continue;
      sessionCount[id] = (sessionCount[id] ?? 0) + 1;
      if (classNumById[id]?.isEmpty != false && s.classNum.isNotEmpty) {
        classNumById[id] = s.classNum;
      }
    }

    final entries = <_TeacherClassEntry>[];
    for (final id in sessionCount.keys) {
      final known = byId[id];
      entries.add(_TeacherClassEntry(
        classroomId: id,
        classroom: known ??
            Classroom(
                id: id,
                level: 0,
                levelId: 0,
                name: classNumById[id]?.isNotEmpty == true
                    ? 'Class ${classNumById[id]}'
                    : 'Class',
                students: const []),
        sessionCount: sessionCount[id] ?? 0,
      ));
    }
    entries.sort((a, b) => a.displayName.compareTo(b.displayName));
    return entries;
  }

  Widget _emptyState(AppColors colors, Color textPrimary, String? detail) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 44, color: colors.subtitleText),
          const SizedBox(height: 10),
          Text('No classes assigned yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimary)),
          const SizedBox(height: 4),
          Text(
            detail ?? 'Classes from your schedule will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.subtitleText),
          ),
        ],
      ),
    );
  }

  Widget _classCard(BuildContext context, AppColors colors, Color textPrimary,
      _TeacherClassEntry entry) {
    final c = entry.classroom;
    final subtitle = c.students.isNotEmpty
        ? '${c.students.length} students • ${entry.sessionCount} sessions/week'
        : '${entry.sessionCount} sessions/week'
            '${c.sessionType != null ? ' • ${c.sessionType!.displayName}' : ''}';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => ClassroomDetailScreen(classroom: c)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.inputBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors.buttonGradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  c.name.isNotEmpty ? c.name.split(' ').last : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.displayName,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 13, color: colors.subtitleText)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: colors.subtitleText, size: 22),
          ],
        ),
      ),
    );
  }
}

class _TeacherClassEntry {
  final String classroomId;
  final Classroom classroom;
  final int sessionCount;

  _TeacherClassEntry(
      {required this.classroomId,
      required this.classroom,
      required this.sessionCount});

  String get displayName => classroom.name;
}
