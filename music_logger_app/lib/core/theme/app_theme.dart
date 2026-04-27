import 'package:flutter/material.dart';

/// App-wide color palette and theme definitions.
class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color accentColor = Color(0xFFFF6584);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: primaryColor,
        fontFamily: 'Inter', // Add Inter font to pubspec.yaml assets when ready
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: primaryColor,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      );
}
