import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color gold = Color(0xFFF1C40F);
  static const Color darkNavy = Color(0xFF0B132B);
  static const Color navy = Color(0xFF1D3557);
  static const Color deepBlue = Color(0xFF0F1C3F);
  static const Color darkest = Color(0xFF030817);
  static const Color border = Color(0xFF3A506B);
  static const Color red = Color(0xFFA83232);
  static const Color green = Color(0xFF27AE60);
  static const Color blue = Color(0xFF3498DB);
  static const Color orange = Color(0xFFF39C12);
}

class AppTheme {
  static TextStyle get titleStyle => GoogleFonts.changa(
        color: AppColors.gold,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get subtitleStyle => GoogleFonts.changa(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get labelStyle => GoogleFonts.changa(
        color: AppColors.gold,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkest,
        textTheme: GoogleFonts.changaTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.navy,
          surface: AppColors.darkNavy,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkNavy,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.gold, width: 2),
          ),
        ),
      );

  static BoxDecoration get backgroundDecoration => const BoxDecoration(
        gradient: RadialGradient(
          colors: [AppColors.deepBlue, AppColors.darkest],
          center: Alignment.center,
          radius: 1.2,
        ),
      );
}
