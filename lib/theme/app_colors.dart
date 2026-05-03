import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0E1A); // Quase preto azulado
  static const Color surface = Color(0xFF141B2D); // Cards e superfícies normais
  static const Color surfaceElevated = Color(0xFF1C2438); // Modais, app bars
  static const Color surfaceGlass = Color(0x14FFFFFF);

  // Bordas e divisores
  static const Color border = Color(0x1FFFFFFF); // Branco 12%
  static const Color borderActive = Color(0xFF00E5FF); // Cyan no foco

  // Acentos neon
  static const Color neonCyan = Color(0xFF00E5FF); // Primária
  static const Color neonMagenta = Color(0xFFFF00E5); // Secundária
  static const Color neonLime = Color(0xFFB3FF00); // Sucesso/destaque
  static const Color neonOrange = Color(0xFFFF6B00); // Avisos

  // Estados semânticos
  static const Color success = Color(0xFF22D3A4);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4D6D);
  static const Color info = Color(0xFF00E5FF);

  // Texto
  static const Color textPrimary = Color(0xFFF1F5F9); // Quase branco
  static const Color textSecondary = Color(0xFF94A3B8); // Cinza azulado
  static const Color textMuted = Color(0xFF64748B); // Mais apagado
  static const Color textOnNeon = Color(0xFF0A0E1A); // Texto sobre botão neon

  // Gradientes prontos
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

  /// Gradiente sutil de fundo da tela inteira.
  /// Cria a sensação de profundidade sem competir com o conteúdo.
  static const RadialGradient backgroundGradient = RadialGradient(
    center: Alignment(-0.5, -0.8),
    radius: 1.5,
    colors: [Color(0xFF1A2444), Color(0xFF0A0E1A)],
    stops: [0.0, 0.7],
  );
}
