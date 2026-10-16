import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Application theme configuration.
class AppTheme {
  static const Color primaryNavy = Color(0xFF005A9C);
  static const Color accentGold = Color(0xFFFFC72C);
  static const Color backgroundLight = Color(0xFFF9F9FA);
  static const Color textDark = Color(0xFF1C2833);
  static const Color tealSuccess = Color(0xFF009B8D);
  static const Color warningYellow = Color(0xFFF4DE3F);
  static const Color errorRed = Color(0xFFC70039);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  /// Returns the light theme data for the app.
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryNavy,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: accentGold,
        error: errorRed,
        surface: surfaceWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 255, 4, 4),
        foregroundColor: surfaceWhite,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          side: const BorderSide(color: primaryNavy),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryNavy, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textDark),
        bodyMedium: TextStyle(color: textDark),
        displayLarge: TextStyle(color: textDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryNavy,
        unselectedItemColor: Colors.grey,
        backgroundColor: surfaceWhite,
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
