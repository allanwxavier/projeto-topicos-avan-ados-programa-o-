import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:meu_projeto_faculdade/theme/app_theme.dart';

/// Widget de fundo com gradiente animado e partículas flutuantes.
/// Cria a atmosfera futurista das telas do app.
class GradientBackground extends StatefulWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                math.sin(_controller.value * 2 * math.pi),
                math.cos(_controller.value * 2 * math.pi),
              ),
              end: Alignment(
                math.cos(_controller.value * 2 * math.pi),
                math.sin(_controller.value * 2 * math.pi + 1),
              ),
              colors: const [
                Color(0xFF0A0E1A),
                Color(0xFF0F172A),
                Color(0xFF1A0533),
                Color(0xFF0A1628),
              ],
            ),
          ),
          child: Stack(
            children: [
              _buildGlowOrb(
                top: 80,
                left: -60,
                size: 220,
                color: AppTheme.neonCyan.withValues(alpha: 0.08),
              ),
              _buildGlowOrb(
                bottom: 120,
                right: -80,
                size: 280,
                color: AppTheme.neonPurple.withValues(alpha: 0.06),
              ),
              _buildGlowOrb(
                top: MediaQuery.of(context).size.height * 0.4,
                right: 30,
                size: 150,
                color: AppTheme.neonPink.withValues(alpha: 0.04),
              ),
              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _GridPainter(
                  opacity: 0.03 + 0.02 * math.sin(_controller.value * math.pi),
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlowOrb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

/// Pinta um grid sutil de fundo para efeito cyberpunk.
class _GridPainter extends CustomPainter {
  final double opacity;
  _GridPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.neonCyan.withValues(alpha: opacity)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.opacity != opacity;
}
