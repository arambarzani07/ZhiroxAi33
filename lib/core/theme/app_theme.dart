import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color primary = Color(0xFF1B4DFF);
  static const Color navy = Color(0xFF0F172A);
  static const Color gold = Color(0xFFF5B942);
  static const Color danger = Color(0xFFE11D48);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF111827);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'NotoKufiArabic',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surfaceLight,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'NotoKufiArabic',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1120),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: surfaceDark,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF182235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
