import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/Classroom.dart';
import '../providers/ClassroomViewModel.dart';
import '../providers/UserViewModel.dart';
import 'classroom_detail_screen.dart';

class ClassroomListScreen extends StatefulWidget {
  final bool showBackButton;

  const ClassroomListScreen({super.key, this.showBackButton = true});

  @override
  State<ClassroomListScreen> createState() => _ClassroomListScreenState();
}

class _ClassroomListScreenState extends State<ClassroomListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClassrooms();
    });
  }

  Future<void> _loadClassrooms() async {
    final userViewModel = context.read<UserViewModel>();
    final classroomViewModel = context.read<ClassroomViewModel>();
    final token = userViewModel.token;
    if (token != null && token.isNotEmpty) {
      await classroomViewModel.loadClassrooms(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1B2233);
    final classroomViewModel = context.watch<ClassroomViewModel>();

    return Scaffold(
      backgroundColor: colors.headerBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: textPrimary),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          'Classrooms',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadClassrooms,
        child: _buildBody(context, colors, classroomViewModel, isDark, textPrimary),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppColors colors,
    ClassroomViewModel viewModel,
    bool isDark,
    Color textPrimary,
  ) {
    if (viewModel.isLoading && viewModel.classrooms == null) {
      return Center(
        child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.buttonGradient[1]),
      );
    }

    final classrooms = viewModel.classrooms ?? [];

    if (classrooms.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 48, color: colors.subtitleText),
                  const SizedBox(height: 12),
                  Text(
                    'No classrooms available',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.error ?? 'Pull to refresh',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: colors.subtitleText),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final grouped = <int, List<Classroom>>{};
    for (final c in classrooms) {
      grouped.putIfAbsent(c.level, () => []).add(c);
    }
    final sortedLevels = grouped.keys.toList()..sort();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        for (final level in sortedLevels) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              'Level $level',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.subtitleText,
              ),
            ),
          ),
          ...grouped[level]!.map((c) => _buildClassroomCard(context, colors, c, isDark, textPrimary)),
        ],
      ],
    );
  }

  Widget _buildClassroomCard(
    BuildContext context,
    AppColors colors,
    Classroom classroom,
    bool isDark,
    Color textPrimary,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClassroomDetailScreen(classroom: classroom),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
                  classroom.name.isNotEmpty ? classroom.name.split(' ').last : '${classroom.levelId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classroom.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    classroom.students.isNotEmpty
                        ? '${classroom.students.length} students'
                        : classroom.sessionType?.displayName ?? 'Level ${classroom.level}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.subtitleText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.subtitleText, size: 22),
          ],
        ),
      ),
    );
  }
}