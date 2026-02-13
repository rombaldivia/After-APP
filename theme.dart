import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF0B0F1A);
  static const Color neonBlue = Color(0xFF00C2FF);
  static const Color neonRed = Color(0xFFFF2E63);
  static const Color card = Color(0xFF141B2D);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    fontFamily: 'Montserrat',
    colorScheme: const ColorScheme.dark(
      primary: neonBlue,
      secondary: neonRed,
    ),
    cardColor: card,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
