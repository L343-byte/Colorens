import 'package:flutter/material.dart';

/// Utility for showing SnackBars.
class SnackbarUtils {
  /// Shows a success SnackBar.
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green, Icons.check_circle);
  }

  /// Shows an error SnackBar.
  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red, Icons.error);
  }

  /// Shows an information SnackBar.
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blue, Icons.info);
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
