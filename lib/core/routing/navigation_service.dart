import 'package:flutter/material.dart';

class NavigationService {

  NavigationService._();
  /// Global navigator key
  /// Allows navigation without BuildContext
  /// Used in MaterialApp.navigatorKey
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  /// Pushes a new route onto the navigation stack
  ///
  /// Use when:
  /// - Opening a new screen
  /// - You want to come back to the previous screen
  ///
  /// Example:
  /// NavigationService.pushNamed('/details');
  static Future<dynamic> pushNamed(
      String route, {
        Object? args,
      }) {
    return navigatorKey.currentState!
        .pushNamed(route, arguments: args);
  }

  /// Replaces the current route with a new one
  ///
  /// Use when:
  /// - Navigating after login
  /// - Splash → Home
  /// - You don't want the user to go back
  ///
  /// Example:
  /// NavigationService.pushReplacement('/home');
  static Future<dynamic> pushReplacement(String route, {Object? args}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(route, arguments: args);
  }

  /// Clears the entire navigation stack and pushes a new route
  ///
  /// Use when:
  /// - Logout
  /// - Session expired
  /// - Resetting app navigation state
  ///
  /// Example:
  /// NavigationService.pushAndRemoveUntil('/login');
  static void pushAndRemoveUntil(String route) {
    navigatorKey.currentState!
        .pushNamedAndRemoveUntil(route, (route) => false);
  }

  /// Pops the current route (go back)
  ///
  /// Use when:
  /// - Closing dialogs or bottom sheets
  /// - Returning to previous screen
  ///
  /// Example:
  /// NavigationService.pop();
  static void pop({dynamic arg}) {
    navigatorKey.currentState!.pop(arg);
  }
}