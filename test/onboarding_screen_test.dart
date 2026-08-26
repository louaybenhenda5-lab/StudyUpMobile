import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyUp/core/theme/app_theme.dart';
import 'package:studyUp/screens/login_screen.dart';
import 'package:studyUp/screens/onboarding_screen.dart';
import 'package:studyUp/widgets/app_logo.dart';

import 'test_utils.dart';

void main() {
  Widget harness() =>
      MaterialApp(theme: AppTheme.lightTheme, home: const OnboardingScreen());

  testWidgets('first slide shows title, skip and Next button',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Learn with Expert Trainers'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Next button advances slides and morphs into Get Started',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());

    // Slide 2.
    await tester.tap(find.text('Next'));
    await pumpUntil(
      tester,
      () =>
          find.text('Browse Curated Courses').evaluate().isNotEmpty,
    );
    expect(find.text('Browse Curated Courses'), findsOneWidget);

    // Slide 3 (last).
    await tester.tap(find.text('Next'));
    await pumpUntil(
      tester,
      () => find.text('Get Started').evaluate().isNotEmpty,
    );
    expect(find.text('Track & Grow Your Career'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skip jumps straight to the last slide',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.text('Skip'));
    await pumpUntil(
      tester,
      () => find.text('Get Started').evaluate().isNotEmpty,
    );

    expect(find.text('Track & Grow Your Career'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Get Started transitions to the login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.text('Next'));
    await pumpUntil(
      tester,
      () => find.text('Browse Curated Courses').evaluate().isNotEmpty,
    );
    await tester.tap(find.text('Next'));
    await pumpUntil(
      tester,
      () => find.text('Get Started').evaluate().isNotEmpty,
    );

    await tester.tap(find.text('Get Started'));
    await pumpUntil(
      tester,
      () => find.byType(LoginScreen).evaluate().isNotEmpty,
    );
    // Let the cover fully cover the screen and fade its opacity to reveal the
    // Login screen that sits underneath it.
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
