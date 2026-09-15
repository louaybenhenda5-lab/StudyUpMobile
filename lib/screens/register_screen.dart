import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/UserViewModel.dart';
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
  final _codeController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _codeFocus = FocusNode();

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _birthdayError;
  String? _codeError;
  String? _registerError;

  File? _profilePhoto;
  bool _isButtonPressed = false;

  static const _brandBlue = Color(0xFF2E7CF6);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthdayController.dispose();
    _codeController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
    if (picked != null) {
      setState(() => _profilePhoto = File(picked.path));
    }
  }

  List<int>? _profilePhotoBytes() {
    if (_profilePhoto == null) return null;
    return _profilePhoto!.readAsBytesSync();
  }

  String? _profilePhotoFilename() {
    if (_profilePhoto == null) return null;
    final name = _profilePhoto!.path.split(Platform.pathSeparator).last;
    return name.isNotEmpty ? name : 'logo.jpg';
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
                  onTap: () => _pickImage(ImageSource.gallery),
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
                        child: ClipOval(
                          child: _profilePhoto != null
                              ? Image.file(
                            _profilePhoto!,
                            width: 108,
                            height: 108,
                            fit: BoxFit.cover,
                          )
                              : Container(
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
                  _profilePhoto != null
                      ? 'Tap to change profile picture'
                      : 'Tap to add a profile picture',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.subtitleText,
                  ),
                ),
              ),
              const SizedBox(height: 26),

              if (_registerError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _registerError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

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
                          errorText: _firstNameError,
                          focusNode: _firstNameFocus,
                          activeColor: _brandBlue,
                          onChanged: (_) {
                            if (_firstNameError != null) setState(() => _firstNameError = null);
                            if (_registerError != null) setState(() => _registerError = null);
                          },
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
                          errorText: _lastNameError,
                          focusNode: _lastNameFocus,
                          activeColor: _brandBlue,
                          onChanged: (_) {
                            if (_lastNameError != null) setState(() => _lastNameError = null);
                            if (_registerError != null) setState(() => _registerError = null);
                          },
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
                errorText: _emailError,
                focusNode: _emailFocus,
                activeColor: _brandBlue,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                  if (_registerError != null) setState(() => _registerError = null);
                },
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
                errorText: _passwordError,
                focusNode: _passwordFocus,
                activeColor: _brandBlue,
                onChanged: (_) {
                  if (_passwordError != null) setState(() => _passwordError = null);
                  if (_registerError != null) setState(() => _registerError = null);
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
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      _birthdayError = null;
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
              const SizedBox(height: 20),

              // ---------- INVITATION CODE ----------
              Text(
                'Invitation Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _codeController,
                hint: 'Enter invitation code',
                icon: Icons.confirmation_number_outlined,
                colors: colors,
                textColor: textColor,
                errorText: _codeError,
                focusNode: _codeFocus,
                activeColor: _brandBlue,
                onChanged: (_) {
                  if (_codeError != null) setState(() => _codeError = null);
                  if (_registerError != null) setState(() => _registerError = null);
                },
              ),
              const SizedBox(height: 28),

              // ---------- CREATE ACCOUNT BUTTON ----------
              GestureDetector(
                onTapDown: (_) => setState(() => _isButtonPressed = true),
                onTapUp: (_) => setState(() => _isButtonPressed = false),
                onTapCancel: () => setState(() => _isButtonPressed = false),
                onTap: () async {
                  final firstName = _firstNameController.text.trim();
                  final lastName = _lastNameController.text.trim();
                  final email = _emailController.text.trim();
                  final password = _passwordController.text;
                  final birthday = _birthdayController.text.trim();
                  final code = _codeController.text.trim();

                  setState(() {
                    _registerError = null;
                    _firstNameError = firstName.isEmpty ? 'First name is required' : null;
                    _lastNameError = lastName.isEmpty ? 'Last name is required' : null;
                    _emailError = email.isEmpty ? 'Email is required' : null;
                    _passwordError = password.isEmpty
                        ? 'Password is required'
                        : (password.length < 6 ? 'Password must be at least 6 characters' : null);
                    _birthdayError = birthday.isEmpty ? 'Birthday is required' : null;
                    _codeError = code.isEmpty ? 'Invitation code is required' : null;
                  });
                  if (_firstNameError != null || _lastNameError != null ||
                      _emailError != null || _passwordError != null ||
                      _birthdayError != null || _codeError != null) {
                    return;
                  }

                  final userViewModel = context.read<UserViewModel>();
                  final success = await userViewModel.register(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password,
                    birthday: birthday,
                    logoBytes: _profilePhotoBytes(),
                    logoFilename: _profilePhotoFilename(),
                    code: code,
                  );
                  if (!mounted) return;
                  final nav = Navigator.of(context);
                  if (success) {
                    if (nav.canPop()) {
                      nav.pop();
                    } else {
                      nav.pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                  } else {
                    setState(() => _registerError = userViewModel.error);
                  }
                },
                child: AnimatedScale(
                  scale: _isButtonPressed ? 0.97 : 1.0,
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
                      boxShadow: _isButtonPressed
                          ? [
                        BoxShadow(
                          color: _brandBlue.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                          : null,
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
}
