import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyUp/core/theme/app_theme.dart';
import 'package:studyUp/models/Classroom.dart';
import 'package:studyUp/models/Session.dart';
import 'package:studyUp/models/enums/Day.dart';
import 'package:studyUp/models/enums/Subject.dart';
import 'package:studyUp/providers/UserViewModel.dart';
import 'package:studyUp/screens/login_screen.dart';
import 'package:studyUp/screens/student_schedule_screen.dart';

Day _todayDay() {
  switch (DateTime.now().weekday) {
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
    default:
      return Day.SUNDAY;
  }
}

void main() {
  Classroom classroom(String id, String name) =>
      Classroom(id: id, level: 1, levelId: 1, name: name);

  Session session(String id, Subject subject, Day day) => Session(
        id: id,
        subject: subject,
        day: day,
        startTime: '2026-01-01T08:00:00',
        endTime: '2026-01-01T10:00:00',
      );

  Future<void> pumpStudent(
    WidgetTester tester, {
    required List<Classroom> classes,
    required Map<String, List<Session>> schedules,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: StudentScheduleScreen(
          initialClassrooms: classes,
          initialSchedules: schedules,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows class dropdown and first class schedule by default',
      (WidgetTester tester) async {
    final day = _todayDay();
    final classes = [classroom('c1', 'Class A'), classroom('c2', 'Class B')];
    await pumpStudent(tester,
        classes: classes,
        schedules: {
          'c1': [session('s1', Subject.MATH, day)],
          'c2': [session('s2', Subject.INFO, day)],
        });

    expect(find.text('Schedule'), findsOneWidget);
    expect(find.byType(DropdownButton<Classroom>), findsOneWidget);
    expect(find.text('Class A'), findsWidgets);
    // First class timetable shown (Mathematics), not the second.
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Informatics'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing class updates the displayed schedule',
      (WidgetTester tester) async {
    final day = _todayDay();
    final classes = [classroom('c1', 'Class A'), classroom('c2', 'Class B')];
    await pumpStudent(tester,
        classes: classes,
        schedules: {
          'c1': [session('s1', Subject.MATH, day)],
          'c2': [session('s2', Subject.INFO, day)],
        });

    // Open the dropdown and pick Class B.
    await tester.tap(find.byType(DropdownButton<Classroom>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Class B').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Informatics'), findsOneWidget);
    expect(find.text('Mathematics'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows friendly error when classes fail to load',
      (WidgetTester tester) async {
    await pumpStudent(tester, classes: const [], schedules: const {});
    expect(find.text('No classes available.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Continue as Student opens student schedule, not teacher pages',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>(
            create: (_) => UserViewModel(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.ensureVisible(find.text('Continue as Student'));
    await tester.tap(find.text('Continue as Student'));
    await tester.pumpAndSettle();

    expect(find.byType(StudentScheduleScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
