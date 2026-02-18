import 'package:flutter/material.dart';

class NeonTheme {
  static const bg         = Color(0xFF060812);
  static const card       = Color(0xFF0C1024);

  static const neonPink   = Color(0xFFFF3BD4);
  static const neonPurple = Color(0xFF8B5CFF);
  static const neonCyan   = Color(0xFF2BF7FF);
  static const neonBlue   = Color(0xFF3B82F6);
  static const neonGreen  = Color(0xFF00FF87);

  // Alias para compatibilidad con archivos viejos
  static const accentPink   = neonPink;
  static const accentCyan   = neonCyan;
  static const accentPurple = neonPurple;
  static const accentGreen  = neonGreen;
  static const textPrimary  = Colors.white;
  static const textSecondary = Colors.white60;
}

ThemeData buildNeonTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: NeonTheme.bg,
    colorScheme: base.colorScheme.copyWith(
      primary:   NeonTheme.neonPink,
      secondary: NeonTheme.neonCyan,
      surface:   NeonTheme.card,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:  Colors.transparent,
      elevation:        0,
      foregroundColor:  Colors.white,
    ),
  );
}
