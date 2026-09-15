import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/Session.dart';
import '../providers/SessionViewModel.dart';
import '../providers/UserViewModel.dart';
import 'session_detail_screen.dart';

class TeacherSessionsScreen extends StatefulWidget {
  const TeacherSessionsScreen({super.key});

  @override
  State<TeacherSessionsScreen> createState() => _TeacherSessionsScreenState();
}

class _TeacherSessionsScreenState extends State<TeacherSessionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessions();
    });
  }

  Future<void> _loadSessions() async {
    final userViewModel = context.read<UserViewModel>();
    final sessionViewModel = context.read<SessionViewModel>();
    final token = userViewModel.token;

    if (token != null && token.isNotEmpty) {
      await sessionViewModel.loadMySessions(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1B2233);
    final sessionViewModel = context.watch<SessionViewModel>();

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
          'My Sessions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSessions,
        child: _buildBody(context, colors, sessionViewModel, isDark, textPrimary),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppColors colors,
    SessionViewModel viewModel,
    bool isDark,
    Color textPrimary,
  ) {
    if (viewModel.isLoading && viewModel.mySessions.isEmpty) {
      return Center(
        child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.buttonGradient[1]),
      );
    }

    final sessions = viewModel.mySessions;

    if (sessions.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 48, color: colors.subtitleText),
                  const SizedBox(height: 12),
                  Text(
                    'No sessions yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.error ?? 'Sessions assigned to you will appear here.',
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

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        for (final session in sessions) ...[
          _buildSessionCard(context, colors, session, textPrimary),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        Text(
          'Swipe down to refresh. Tap a session to view its details and mark attendance.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: colors.subtitleText),
        ),
      ],
    );
  }

  Widget _buildSessionCard(BuildContext context, AppColors colors, Session session, Color textPrimary) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SessionDetailScreen(session: session)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors.buttonGradient),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.buttonGradient[1].withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
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
            const SizedBox(height: 14),
            Text(
              session.day?.displayName ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${session.startTimeFormatted} - ${session.endTimeFormatted}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            if (session.classNum.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Class ${session.classNum}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                Text(
                  'View session & mark attendance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}