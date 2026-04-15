import 'package:flutter/material.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/injection_container.dart';

class NavigationUtils {
  NavigationUtils._();

  /// Handles the result from a navigation action (e.g., pushNamed).
  ///
  /// [context] is required to check if the widget is still mounted.
  /// [navigation] is the Future returned by the navigation call.
  /// [onRefresh] is the callback to execute if the result is true OR the global refresh service says so.
  /// [refreshType] and [id] are used to check the DataRefreshService.
  static Future<void> handleResult({
    required BuildContext context,
    required Future<dynamic> navigation,
    required VoidCallback onRefresh,
    RefreshType? refreshType,
    String? id,
  }) async {
    final result = await navigation;
    
    // Check if the context is still valid
    if (!context.mounted) return;

    final refreshCubit = sl<DataRefreshCubit>();

    // Determine if refresh is needed based on:
    // 1. Navigation result (returning true)
    // 2. Global refresh service flag (more reliable for complex flows)
    bool needsRefresh = (result == true);

    if (refreshType != null) {
      if (refreshCubit.shouldRefresh(refreshType, id: id)) {
        needsRefresh = true;
        refreshCubit.clearRefresh(refreshType, id: id);
      }
    }

    if (needsRefresh) {
      onRefresh();
    }
  }
}
