import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema futurista do aplicativo MeetSync.
/// Define cores neon, gradientes e tipografia moderna.
class AppTheme {
  // ─── Cores principais ───────────────────────────────────────
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonGreen = Color(0xFF39FF14);

  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color borderGlow = Color(0xFF334155);

  // ─── Gradientes ─────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0E1A),
      Color(0xFF0F172A),
      Color(0xFF1A0533),
    ],
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonCyan, neonPurple],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [neonCyan, Color(0xFF06B6D4)],
  );

  // ─── ThemeData ──────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPurple,
        surface: darkSurface,
        error: neonPink,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 1.2,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      useMaterial3: true,
    );
  }
}
