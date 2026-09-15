import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyUp/core/theme/app_theme.dart';
import 'package:studyUp/providers/ClassroomViewModel.dart';
import 'package:studyUp/providers/ScheduleViewModel.dart';
import 'package:studyUp/providers/SessionViewModel.dart';
import 'package:studyUp/providers/UserViewModel.dart';
import 'package:studyUp/screens/teacher_classes_screen.dart';
import 'package:studyUp/screens/schedule_page.dart';
import 'package:studyUp/screens/teacher_profile_page.dart';
import 'package:studyUp/screens/teacher_stats_screen.dart';
import 'package:studyUp/screens/teacher_tabs_screen.dart';
import 'package:studyUp/widgets/teacher_radial_menu.dart';

void main() {
  Future<void> pumpTabs(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>(
            create: (_) => UserViewModel(),
          ),
          ChangeNotifierProvider<ClassroomViewModel>(
            create: (_) => ClassroomViewModel(),
          ),
          ChangeNotifierProvider<ScheduleViewModel>(
            create: (_) => ScheduleViewModel(),
          ),
          ChangeNotifierProvider<SessionViewModel>(
            create: (_) => SessionViewModel(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const TeacherTabsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> openMenu(WidgetTester tester) async {
    final fab = find.byTooltip('Open menu');
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  Future<void> selectItem(
      WidgetTester tester, String label, IconData icon) async {
    await openMenu(tester);
    // Each destination exposes a tooltip + semantics label.
    expect(
      find.descendant(
        of: find.byType(TeacherRadialMenu),
        matching: find.byTooltip(label),
      ),
      findsOneWidget,
    );
    final button = find.descendant(
      of: find.byType(TeacherRadialMenu),
      matching: find.byIcon(icon),
    );
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  testWidgets('schedule is default and radial menu switches Schedule/Classes/Stats/Profile pages',
      (WidgetTester tester) async {
    await pumpTabs(tester);

    // Schedule is the default/initial main page (Home removed).
    expect(find.byType(SchedulePage), findsOneWidget);
    expect(find.byType(TeacherRadialMenu), findsOneWidget);

    await selectItem(tester, 'Classes', Icons.menu_book_rounded);
    expect(find.byType(TeacherClassesScreen), findsOneWidget);

    await selectItem(tester, 'Stats', Icons.bar_chart_rounded);
    expect(find.byType(TeacherStatsScreen), findsOneWidget);

    await selectItem(tester, 'Profile', Icons.person_rounded);
    expect(find.byType(TeacherProfilePage), findsOneWidget);

    await selectItem(tester, 'Schedule', Icons.calendar_today_rounded);
    expect(find.byType(SchedulePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('radial menu auto-closes after selection',
      (WidgetTester tester) async {
    await pumpTabs(tester);
    await openMenu(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(TeacherRadialMenu),
        matching: find.byIcon(Icons.bar_chart_rounded),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(TeacherStatsScreen), findsOneWidget);
    // Menu closed: reopening must show the FAB tooltip again.
    expect(find.byTooltip('Open menu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
