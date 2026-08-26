import 'package:flutter/material.dart';
import 'package:studyUp/screens/login_screen.dart';
import 'package:studyUp/screens/register_screen.dart';
import 'package:studyUp/screens/onboarding_screen.dart';
import 'package:studyUp/screens/welcome_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
