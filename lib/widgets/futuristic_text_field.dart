// lib/widgets/futuristic_text_field.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FuturisticTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final bool isPassword;

  const FuturisticTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.neonCyan)
                : null,
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
