import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom color tokens that aren't covered by ThemeData/ColorScheme directly.
class AppColors extends ThemeExtension<AppColors> {
  final Color headerBackground;
  final Color headerCircle;
  final Color headerCircleOuter;
  final Color headerCircleInner;
  final Color cardBackground;
  final Color inputBackground;
  final Color inputBorder;
  final Color inputHint;
  final Color subtitleText;
  final Color dividerColor;
  final Color signupBg;
  final Color avatarGradientStart;
  final Color avatarGradientEnd;
  final List<Color> buttonGradient;
  final Color onboardingCircleBg;
  final Color dotInactive;
  final Color textPrimary;

  const AppColors({
    required this.headerBackground,
    required this.headerCircle,
    required this.headerCircleOuter,
    required this.headerCircleInner,
    required this.cardBackground,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputHint,
    required this.subtitleText,
    required this.dividerColor,
    required this.signupBg,
    required this.avatarGradientStart,
    required this.avatarGradientEnd,
    required this.buttonGradient,
    required this.onboardingCircleBg,
    required this.dotInactive,
    required this.textPrimary,
  });

  static const light = AppColors(
    headerBackground: Color(0xFFF3F6FB),
    headerCircle: Color(0xFFE3E9F5),
    headerCircleOuter: Color(0xFFE9EEF8),
    headerCircleInner: Color(0xFFD3DEF2),
    cardBackground: Colors.white,
    inputBackground: Colors.white,
    inputBorder: Color(0xFFE1E5EE),
    inputHint: Color(0xFF9AA3B5),
    subtitleText: Color(0xFF7A8296),
    dividerColor: Color(0xFFE4E8F0),
    signupBg: Color(0xFFF1F4FA),
    avatarGradientStart: Color(0xFFEFF4FD),
    avatarGradientEnd: Color(0xFFD8E6FB),
    buttonGradient: [Color(0xFF5AA3FB), Color(0xFF2E7CF6)],
    onboardingCircleBg: Color(0xFFE9EEF8),
    dotInactive: Color(0xFFDDE3EE),
    textPrimary: Color(0xFF1B2233),
  );

  static const dark = AppColors(
    headerBackground: Color(0xFF0E1524),
    headerCircle: Color(0xFF1A2438),
    headerCircleOuter: Color(0xFF1B2740),
    headerCircleInner: Color(0xFF223052),
    cardBackground: Color(0xFF161E30),
    inputBackground: Color(0xFF1C2538),
    inputBorder: Color(0xFF2B3550),
    inputHint: Color(0xFF7C879E),
    subtitleText: Color(0xFF9AA5BC),
    dividerColor: Color(0xFF2B3550),
    signupBg: Color(0xFF1C2538),
    avatarGradientStart: Color(0xFF232E48),
    avatarGradientEnd: Color(0xFF1A2338),
    buttonGradient: [Color(0xFF5AA3FB), Color(0xFF2E7CF6)],
    onboardingCircleBg: Color(0xFF1B2740),
    dotInactive: Color(0xFF2B3550),
    textPrimary: Colors.white,
  );

  @override
  AppColors copyWith({
    Color? headerBackground,
    Color? headerCircle,
    Color? headerCircleOuter,
    Color? headerCircleInner,
    Color? cardBackground,
    Color? inputBackground,
    Color? inputBorder,
    Color? inputHint,
    Color? subtitleText,
    Color? dividerColor,
    Color? signupBg,
    Color? avatarGradientStart,
    Color? avatarGradientEnd,
    List<Color>? buttonGradient,
    Color? onboardingCircleBg,
    Color? dotInactive,
    Color? textPrimary,
  }) {
    return AppColors(
      headerBackground: headerBackground ?? this.headerBackground,
      headerCircle: headerCircle ?? this.headerCircle,
      headerCircleOuter: headerCircleOuter ?? this.headerCircleOuter,
      headerCircleInner: headerCircleInner ?? this.headerCircleInner,
      cardBackground: cardBackground ?? this.cardBackground,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      inputHint: inputHint ?? this.inputHint,
      subtitleText: subtitleText ?? this.subtitleText,
      dividerColor: dividerColor ?? this.dividerColor,
      signupBg: signupBg ?? this.signupBg,
      avatarGradientStart: avatarGradientStart ?? this.avatarGradientStart,
      avatarGradientEnd: avatarGradientEnd ?? this.avatarGradientEnd,
      buttonGradient: buttonGradient ?? this.buttonGradient,
      onboardingCircleBg: onboardingCircleBg ?? this.onboardingCircleBg,
      dotInactive: dotInactive ?? this.dotInactive,
      textPrimary: textPrimary ?? this.textPrimary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      headerBackground:
      Color.lerp(headerBackground, other.headerBackground, t)!,
      headerCircle: Color.lerp(headerCircle, other.headerCircle, t)!,
      headerCircleOuter:
      Color.lerp(headerCircleOuter, other.headerCircleOuter, t)!,
      headerCircleInner:
      Color.lerp(headerCircleInner, other.headerCircleInner, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputHint: Color.lerp(inputHint, other.inputHint, t)!,
      subtitleText: Color.lerp(subtitleText, other.subtitleText, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      signupBg: Color.lerp(signupBg, other.signupBg, t)!,
      avatarGradientStart:
      Color.lerp(avatarGradientStart, other.avatarGradientStart, t)!,
      avatarGradientEnd:
      Color.lerp(avatarGradientEnd, other.avatarGradientEnd, t)!,
      buttonGradient: buttonGradient,
      onboardingCircleBg:
      Color.lerp(onboardingCircleBg, other.onboardingCircleBg, t)!,
      dotInactive: Color.lerp(dotInactive, other.dotInactive, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static const _brandBlue = Color(0xFF2E7CF6);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.light.headerBackground,
    primaryColor: _brandBlue,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brandBlue,
      brightness: Brightness.light,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1B2233)),
        bodyMedium: TextStyle(color: Color(0xFF1B2233)),
      ),
    ),
    extensions: const [AppColors.light],
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark.headerBackground,
    primaryColor: _brandBlue,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brandBlue,
      brightness: Brightness.dark,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
      ),
    ),
    extensions: const [AppColors.dark],
  );
}

/// Convenience getter: `context.appColors`
extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}