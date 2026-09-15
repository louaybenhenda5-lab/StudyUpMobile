import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/Classroom.dart';
import '../models/enums/Day.dart';
import '../models/Session.dart';
import '../providers/ScheduleViewModel.dart';
import '../providers/UserViewModel.dart';

class ScheduleViewScreen extends StatefulWidget {
  final Classroom classroom;

  const ScheduleViewScreen({super.key, required this.classroom});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedule();
    });
  }

  Future<void> _loadSchedule() async {
    final userViewModel = context.read<UserViewModel>();
    final scheduleViewModel = context.read<ScheduleViewModel>();
    final token = userViewModel.token;
    if (token != null && token.isNotEmpty) {
      await scheduleViewModel.loadSchedule(token, widget.classroom.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1B2233);
    final scheduleViewModel = context.watch<ScheduleViewModel>();

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
          widget.classroom.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSchedule,
        child: _buildBody(context, colors, scheduleViewModel, isDark, textPrimary),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppColors colors,
    ScheduleViewModel viewModel,
    bool isDark,
    Color textPrimary,
  ) {
    if (viewModel.isLoading && viewModel.currentSchedule == null) {
      return Center(
        child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.buttonGradient[1]),
      );
    }

    final schedule = viewModel.currentSchedule;

    if (schedule == null) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 48, color: colors.subtitleText),
                  const SizedBox(height: 12),
                  Text(
                    'No schedule for this classroom',
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

    final sessions = schedule.sessions;

    if (sessions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(Icons.event_note, color: colors.subtitleText, size: 48),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'No sessions scheduled',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
            ),
          ),
        ],
      );
    }

    // Group sessions by day keeping backend order (Monday..Sunday).
    final days = Day.values;
    final byDay = <Day, List<Session>>{};
    for (final d in days) {
      byDay[d] = [];
    }
    for (final s in sessions) {
      final day = s.day;
      if (day != null && byDay.containsKey(day)) {
        byDay[day]!.add(s);
      }
    }

    final hasContent = byDay.values.any((list) => list.isNotEmpty);

    if (!hasContent) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.event_note, color: colors.subtitleText, size: 48),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'No sessions scheduled',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        for (final day in days) ...[
          if (byDay[day]!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                day.displayName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.subtitleText,
                ),
              ),
            ),
            ...byDay[day]!.map((s) => _buildSessionCard(context, colors, s, isDark, textPrimary)),
          ],
        ],
      ],
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    AppColors colors,
    Session session,
    bool isDark,
    Color textPrimary,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: colors.buttonGradient[0].withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  session.startTimeFormatted,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.buttonGradient[1],
                  ),
                ),
                Text(
                  '- ${session.endTimeFormatted}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.subtitleText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.subject?.displayName ?? 'Session',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  session.classNum.isNotEmpty ? 'Class ${session.classNum}' : 'No class number',
                  style: TextStyle(fontSize: 13, color: colors.subtitleText),
                ),
                if (session.teacher != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    session.teacher!.displayName,
                    style: TextStyle(fontSize: 12, color: colors.subtitleText),
                  ),
                ],
              ],
            ),
          ),
          if (session.eachTwoWeeks)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '2 weeks',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C5CE7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}