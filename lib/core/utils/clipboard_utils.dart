import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClipboardUtils {
  static Future<void> copyToClipboard(BuildContext context, String text, {String? successMessage}) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage ?? "Copied to clipboard"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
