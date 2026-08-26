import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyUp/core/theme/app_theme.dart';
import 'package:studyUp/screens/onboarding_screen.dart';
import 'package:studyUp/screens/welcome_screen.dart';
import 'package:studyUp/widgets/app_logo.dart';

import 'test_utils.dart';

void main() {
  testWidgets('welcome shows the brand, image and a general description',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const WelcomeScreen()),
    );

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Welcome to StudyUp'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('welcome plays without errors under the dark theme',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: const WelcomeScreen()),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Get Started navigates to the onboarding flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const WelcomeScreen()),
    );

    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.byKey(const Key('get-started-btn')));
    await pumpUntil(
      tester,
      () => find.byType(OnboardingScreen).evaluate().isNotEmpty,
    );
    await pumpUntil(
      tester,
      () => find.byType(WelcomeScreen).evaluate().isEmpty,
    );

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
