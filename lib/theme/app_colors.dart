import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF141B2D);
  static const Color surfaceElevated = Color(0xFF1C2438);
  static const Color surfaceGlass = Color(0x14FFFFFF);

  static const Color border = Color(0x1FFFFFFF);
  static const Color borderActive = Color(0xFF00E5FF);

  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonMagenta = Color(0xFFFF00E5);
  static const Color neonLime = Color(0xFFB3FF00);
  static const Color neonOrange = Color(0xFFFF6B00);

  static const Color success = Color(0xFF22D3A4);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4D6D);
  static const Color info = Color(0xFF00E5FF);

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textOnNeon = Color(0xFF0A0E1A);

  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [neonCyan, Color(0xFF00B8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientSecondary = LinearGradient(
    colors: [neonMagenta, Color(0xFF8B00FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient backgroundGradient = RadialGradient(
    center: Alignment(-0.5, -0.8),
    radius: 1.5,
    colors: [Color(0xFF1A2444), Color(0xFF0A0E1A)],
    stops: [0.0, 0.7],
  );
}
