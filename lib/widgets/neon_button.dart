import 'package:flutter/material.dart';
import 'package:meu_projeto_faculdade/theme/app_theme.dart';

/// Botão com efeito neon pulsante.
/// Possui gradiente animado, glow externo e feedback tátil premium.
class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final List<Color>? gradientColors;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradientColors,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ??
        [AppTheme.neonCyan, const Color(0xFF06B6D4)];

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final glowOpacity = widget.isLoading
            ? 0.1
            : 0.15 + 0.1 * _pulseAnimation.value;

        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: colors),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withValues(alpha: glowOpacity),
                    blurRadius: 25 + 10 * _pulseAnimation.value,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: colors.last.withValues(alpha: glowOpacity * 0.5),
                    blurRadius: 15,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              widget.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
