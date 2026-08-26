import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyUp/main.dart';
import 'package:studyUp/screens/login_screen.dart';
import 'package:studyUp/screens/onboarding_screen.dart';
import 'package:studyUp/screens/welcome_screen.dart';

import 'test_utils.dart';

void main() {
  testWidgets('welcome shows then navigates to the onboarding flow on Get Started',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // The welcome screen is the initial screen.
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);

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

    // Welcome is gone and the onboarding screen is visible.
    expect(find.byType(WelcomeScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}
