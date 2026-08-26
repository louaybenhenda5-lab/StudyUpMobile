import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../core/theme/app_theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthdayController = TextEditingController();

  static const _brandBlue = Color(0xFF2E7CF6);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final textColor = isDark ? Colors.white : const Color(0xFF1B2233);

    return Scaffold(
      backgroundColor: colors.cardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- BACK BUTTON ----------
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.inputBackground
                        : colors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.inputBorder,
                      width: isDark ? 0 : 1,
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.arrow_back, color: textColor, size: 22),
                ),
              ),
              const SizedBox(height: 20),

              // ---------- TITLE ----------
              Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Start your StudyUp journey today',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.subtitleText,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ---------- PROFILE PHOTO ----------
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? colors.inputBorder
                                : colors.cardBackground,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.35)
                                  : Colors.black.withValues(alpha: 0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: const Alignment(-0.2, -0.3),
                              radius: 0.95,
                              colors: [
                                colors.avatarGradientStart,
                                colors.avatarGradientEnd,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 58,
                              color: _brandBlue,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 2,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _brandBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? colors.inputBackground
                                  : colors.cardBackground,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _brandBlue.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Tap to add a profile picture',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.subtitleText,
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // ---------- FIRST / LAST NAME ----------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'First Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _firstNameController,
                          hint: 'Enter first name',
                          icon: Icons.person_outline,
                          colors: colors,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _lastNameController,
                          hint: 'Enter last name',
                          icon: Icons.person_outline,
                          colors: colors,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---------- EMAIL ----------
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                colors: colors,
                textColor: textColor,
              ),
              const SizedBox(height: 20),

              // ---------- PASSWORD ----------
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
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colors.inputHint,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ---------- BIRTHDAY ----------
              Text(
                'Birthday',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _birthdayController.text =
                      '${picked.month}/${picked.day}/${picked.year}';
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: colors.inputBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.inputBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          color: colors.inputHint, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _birthdayController.text.isEmpty
                              ? 'Select your birthday'
                              : _birthdayController.text,
                          style: TextStyle(
                            color: _birthdayController.text.isEmpty
                                ? colors.inputHint
                                : textColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: colors.inputHint, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ---------- CREATE ACCOUNT BUTTON ----------
              GestureDetector(
                onTap: () {},
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
                  ),
                  child: const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ---------- LOGIN LINK ----------
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.subtitleText,
                    ),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Login',
                        style: const TextStyle(
                          color: _brandBlue,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            }
                          },
                      ),
                    ],
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.inputBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.inputBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: textColor, fontSize: 14),
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
  }
}