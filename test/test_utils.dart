import 'package:flutter_test/flutter_test.dart';

/// Pumps small frames until [condition] holds or [maxIterations] is reached.
///
/// The animated route/scroll transitions in this app advance one frame at a
/// time on the widget-test clock, so a single long `pump` may not finish a
/// transition the first time. This helper pumps repeatedly, which is also why
/// `pumpAndSettle` can't be used (the onboarding screens run infinite loops).
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration step = const Duration(milliseconds: 50),
  int maxIterations = 60,
}) async {
  for (var i = 0; i < maxIterations && !condition(); i++) {
    await tester.pump(step);
  }
}
