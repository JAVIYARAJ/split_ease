import 'package:flutter/material.dart';

class NavigationUtils {
  NavigationUtils._();

  /// Handles the result from a navigation action (e.g., pushNamed).
  ///
  /// [context] is required to check if the widget is still mounted.
  /// [navigation] is the Future returned by the navigation call.
  /// [onRefresh] is the callback to execute if the result is true.
  static Future<void> handleResult({
    required BuildContext context,
    required Future<dynamic> navigation,
    required VoidCallback onRefresh,
  }) async {
    final result = await navigation;
    
    // Check if the context is still valid
    if (!context.mounted) return;

    // Check if the result indicates success (true)
    if (result == true) {
      onRefresh();
    }
  }
}
