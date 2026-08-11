import 'package:StudyUp/main.dart';
import 'package:StudyUp/screens/Login.dart';
import 'package:StudyUp/screens/Splash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash screen plays then navigates to the login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // The animated splash is the initial screen.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    // Fast-forward past the 3s splash animation using the test clock.
    await tester.pump(const Duration(milliseconds: 3100));

    // Let the fade/slide transition to Login complete.
    await tester.pumpAndSettle();

    // Splash is gone and the Login screen is visible.
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
