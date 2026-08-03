import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).isDark;
    final scaffoldBg = Theme.of(context).ext.scaffoldBg;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: scaffoldBg,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(child: child),
      ),
    );
  }
}
