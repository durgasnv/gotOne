import 'package:flutter/material.dart';

/// Central design tokens mirrored from the HTML prototype.
class AppColors {
  AppColors._();

  static const background = Color(0xFF111111);
  static const surface = Color(0xFF1C1C1F);
  static const card = Color(0xFFF4F4F2);
  static const accent = Color(0xFFFF8A66); // coral — primary CTA
  static const mint = Color(0xFFCDEFB0); // green — confirm / active
  static const lavender = Color(0xFFCFC8FF); // purple — secondary
  static const sky = Color(0xFFA9E4EC); // blue — timer / countdown
  static const yellow = Color(0xFFFFE79A); // yellow — urgent / warning
  static const muted = Color(0xFF9A9AA3);
  static const onDark = Color(0xFFFFFFFF);
  static const onLight = Color(0xFF111111);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: 'InterTight',
    );
    final textTheme = base.textTheme.apply(
      bodyColor: AppColors.onDark,
      displayColor: AppColors.onDark,
    );
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        surface: AppColors.background,
        primary: AppColors.accent,
        secondary: AppColors.mint,
        tertiary: AppColors.lavender,
        onPrimary: AppColors.onLight,
        onSecondary: AppColors.onLight,
        onSurface: AppColors.onDark,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onDark,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onDark,
          letterSpacing: -0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.black,
        indicatorColor: Colors.white,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.onLight : AppColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? AppColors.onLight : AppColors.muted,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.mint, width: 3),
        ),
        hintStyle: const TextStyle(color: AppColors.muted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onLight,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFFDDDDDD),
        ),
        shape: StadiumBorder(),
        side: BorderSide.none,
      ),
    );
  }
}
