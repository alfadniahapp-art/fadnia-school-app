import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // 🎨 الألوان الافتراضية
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
  /// ⚠️ الألوان القديمة (للتوافق مع الكود الحالي)
  static Color primaryColor = AppColors.gold;
  static Color backgroundColor = AppColors.darkNavy;

  /// تحديث الألوان ديناميكياً
  static void updateColors({
    Color? primary,
    Color? background,
  }) {
    if (primary != null) primaryColor = primary;
    if (background != null) backgroundColor = background;
  }

  static TextStyle get titleStyle => GoogleFonts.changa(
        color: primaryColor,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get subtitleStyle => GoogleFonts.changa(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get labelStyle => GoogleFonts.changa(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      );

  static ThemeData buildTheme({
    Color primary = AppColors.gold,
    Color background = AppColors.darkNavy,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkest,
      textTheme: GoogleFonts.changaTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: AppColors.navy,
        surface: background,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: primary,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: background,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
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
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(primary),
        trackColor: MaterialStateProperty.all(primary.withOpacity(0.3)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: MaterialStateProperty.all(background),
        ),
      ),
    );
  }

  static ThemeData get darkTheme =>
      buildTheme(primary: primaryColor, background: backgroundColor);

  static BoxDecoration get backgroundDecoration => const BoxDecoration(
        gradient: RadialGradient(
          colors: [AppColors.deepBlue, AppColors.darkest],
          center: Alignment.center,
          radius: 1.2,
        ),
      );
}
