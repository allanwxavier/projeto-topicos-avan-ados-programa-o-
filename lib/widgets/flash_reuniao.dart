import 'package:flutter/material.dart';

class FlashReuniao {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF537686),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
