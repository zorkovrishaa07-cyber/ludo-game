import 'package:flutter/material.dart';

class AppTheme {
  // Vibrant game colors
  static const Color primaryDark = Color(0xFF1A1A2E);
  static const Color secondaryDark = Color(0xFF16213E);
  static const Color cardDark = Color(0xFF0F3460);
  static const Color accentGold = Color(0xFFE94560);
  static const Color gold = Color(0xFFFFD700);

  // Ludo & Player Colors
  static const Color ludoRed = Color(0xFFE53935);
  static const Color ludoGreen = Color(0xFF43A047);
  static const Color ludoYellow = Color(0xFFFFB300);
  static const Color ludoBlue = Color(0xFF1E88E5);

  static const Color ludoRedLight = Color(0xFFFFEBEE);
  static const Color ludoGreenLight = Color(0xFFE8F5E9);
  static const Color ludoYellowLight = Color(0xFFFFFDE7);
  static const Color ludoBlueLight = Color(0xFFE3F2FD);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      primaryColor: accentGold,
      cardColor: secondaryDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
