import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyUp/screens/login_screen.dart';
import 'package:studyUp/screens/register_screen.dart';
import 'package:studyUp/screens/onboarding_screen.dart';
import 'package:studyUp/screens/welcome_screen.dart';
import 'package:studyUp/screens/teacher_tabs_screen.dart';
import 'package:studyUp/screens/student_schedule_screen.dart';
import 'package:studyUp/screens/classroom_list_screen.dart';
import 'package:studyUp/screens/teacher_sessions_screen.dart';
import 'package:studyUp/screens/session_detail_screen.dart';
import 'core/theme/app_theme.dart';
import 'providers/UserViewModel.dart';
import 'providers/ClassroomViewModel.dart';
import 'providers/ScheduleViewModel.dart';
import 'providers/SessionViewModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userViewModel = UserViewModel();
  await userViewModel.loadFromStorage();
  runApp(MyApp(userViewModel: userViewModel));
}

class MyApp extends StatelessWidget {
  final UserViewModel? userViewModel;

  const MyApp({super.key, this.userViewModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>(
          create: (_) => userViewModel ?? UserViewModel(),
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
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: _initialScreen(userViewModel),
        routes: {
          OnboardingScreen.routeName: (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/teacher/dashboard': (context) =>
              const TeacherTabsScreen(initialIndex: 0),
          '/teacher/sessions': (context) => const TeacherSessionsScreen(),
          '/teacher/session-detail': (context) => const SessionDetailScreen(),
          '/teacher/classrooms': (context) => const ClassroomListScreen(),
          '/student/schedule': (context) => const StudentScheduleScreen(),
        },
      ),
    );
  }

  Widget _initialScreen(UserViewModel? userViewModel) {
    // Teacher side only: non-teacher tokens must not enter teacher tabs.
    // Schedule (index 0) is the default/initial main page.
    if (userViewModel?.isLoggedIn == true && userViewModel?.isTeacher == true) {
      return const TeacherTabsScreen(initialIndex: 0);
    }
    return const WelcomeScreen();
  }
}