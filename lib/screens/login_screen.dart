import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/UserViewModel.dart';
import 'register_screen.dart';
import 'student_schedule_screen.dart';
import 'teacher_tabs_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  String? _emailError;
  String? _passwordError;
  String? _loginError;
  bool _loginButtonPressed = false;
  bool _studentButtonPressed = false;
  bool _isLoggingIn = false;

  static const _brandBlue = Color(0xFF2E7CF6);

  late final AnimationController _enter;
  late final Animation<double> _enterFade;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _enterFade = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final textColor = isDark ? Colors.white : const Color(0xFF1B2233);
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: colors.headerBackground,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _enterFade,
          builder: (context, child) => Opacity(
            opacity: _enterFade.value,
            child: Transform.translate(
              offset: Offset(0, (1 - _enter.value) * 12),
              child: Transform.scale(
                scale: 0.96 + 0.04 * _enter.value,
                child: child,
              ),
            ),
          ),
          child: Column(
          children: [
            if (!keyboardOpen) ...[
              SizedBox(height: 10),
              // ---------- HEADER ----------
              Expanded(
                flex: 42,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative circle — outer, top-right corner, partially clipped
                  Positioned(
                    right: -85,
                    top: 60,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: colors.headerCircleOuter,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Decorative circle — inner, overlapping lower-left of the outer circle
                  Positioned(
                    right: -85,
                    top: 190,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: colors.headerCircleInner,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Books + plant image — smaller, far right
                  Positioned(
                    right: 0,
                    bottom: 4,
                    child: Image.asset(
                      'assets/images/login.png',
                      height: 120,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomRight,
                    ),
                  ),
                  // Logo + text content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/Glogo.png',
                          height: 72,
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                            children: const [
                              TextSpan(text: 'Study'),
                              TextSpan(
                                text: 'Up',
                                style: TextStyle(color: Color(0xFF2E7CF6)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                              children: const [
                                TextSpan(text: 'Welcome '),
                                TextSpan(
                                  text: 'Back!',
                                  style: TextStyle(color: Color(0xFF2E7CF6)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sign in to continue your learning\njourney with us.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: colors.subtitleText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ],

            // ---------- FORM CARD ----------
            Expanded(
              flex: keyboardOpen ? 1 : 58,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_loginError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _loginError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Text(
                        'Email or Phone',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Enter your email or phone',
                        icon: Icons.email_outlined,
                        colors: colors,
                        textColor: textColor,
                        errorText: _emailError,
                        focusNode: _emailFocus,
                        activeColor: _brandBlue,
                        onChanged: (_) {
                          if (_emailError != null) setState(() => _emailError = null);
                          if (_loginError != null) setState(() => _loginError = null);
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        colors: colors,
                        textColor: textColor,
                        obscure: _obscurePassword,
                        errorText: _passwordError,
                        focusNode: _passwordFocus,
                        activeColor: _brandBlue,
                        onChanged: (_) {
                          if (_passwordError != null) setState(() => _passwordError = null);
                          if (_loginError != null) setState(() => _loginError = null);
                        },
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: colors.inputHint,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(
                                    () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF2E7CF6),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLoginButton(colors),
                      const SizedBox(height: 16),
                      _buildStudentButton(colors),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: colors.signupBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: colors.subtitleText,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                  );
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    color: Color(0xFF2E7CF6),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required AppColors colors,
    required Color textColor,
    bool obscure = false,
    Widget? suffix,
    String? errorText,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    Color? activeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListenableBuilder(
          listenable: focusNode ?? AlwaysStoppedAnimation(0),
          builder: (context, _) {
            final hasFocus = focusNode?.hasFocus ?? false;
            final borderColor = errorText != null
                ? Colors.red
                : hasFocus
                    ? (activeColor ?? colors.buttonGradient[1])
                    : colors.inputBorder;

            return Container(
              decoration: BoxDecoration(
                color: colors.inputBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                obscureText: obscure,
                style: TextStyle(color: textColor, fontSize: 14),
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: colors.inputHint, fontSize: 14),
                  prefixIcon: Icon(icon, color: colors.inputHint, size: 20),
                  suffixIcon: suffix,
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                ),
              ),
            );
          },
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildLoginButton(AppColors colors) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _loginButtonPressed = true),
      onTapUp: (_) => setState(() => _loginButtonPressed = false),
      onTapCancel: () => setState(() => _loginButtonPressed = false),
      onTap: () async {
        if (_isLoggingIn) return;
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        setState(() {
          _loginError = null;
          _emailError = email.isEmpty ? 'Email is required' : null;
          _passwordError = password.isEmpty ? 'Password is required' : null;
        });
        if (_emailError != null || _passwordError != null) return;

        setState(() => _isLoggingIn = true);
        try {
          final userViewModel = context.read<UserViewModel>();
          final success = await userViewModel.login(
            _emailController.text.trim(),
            _passwordController.text,
          );
          if (!mounted) return;
          if (success) {
            // Teacher area only: verify backend role from GET /me.
            if (userViewModel.isTeacher) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) =>
                        const TeacherTabsScreen(initialIndex: 0)),
              );
            } else {
              // Do not leave a non-teacher token behind.
              await userViewModel.logout();
              if (!mounted) return;
              setState(() => _loginError =
                  'This section is for teachers. Please use the correct app.');
            }
          } else {
            setState(() => _loginError = userViewModel.error);
          }
        } finally {
          if (mounted) setState(() => _isLoggingIn = false);
        }
      },
      child: AnimatedScale(
        scale: _loginButtonPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: colors.buttonGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: _loginButtonPressed
                ? [
              BoxShadow(
                color: _brandBlue.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ]
                : null,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
              child: _isLoggingIn
                  ? const SizedBox(
                      key: ValueKey('login-spinner'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Login',
                      key: ValueKey('login-label'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentButton(AppColors colors) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _studentButtonPressed = true),
      onTapUp: (_) => setState(() => _studentButtonPressed = false),
      onTapCancel: () => setState(() => _studentButtonPressed = false),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const StudentScheduleScreen(),
          ),
        );
      },
      child: AnimatedScale(
        scale: _studentButtonPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.buttonGradient[1], width: 1.5),
            boxShadow: _studentButtonPressed
                ? [
              BoxShadow(
                color: _brandBlue.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ]
                : null,
          ),
          child: Center(
            child: Text(
              'Continue as Student',
              style: TextStyle(
                color: colors.buttonGradient[1],
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}