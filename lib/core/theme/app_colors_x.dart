import 'package:flutter/material.dart';
import 'app_color_tokens.dart';

/// Shorthand context accessor.
///
/// Usage: final c = context.ext;  →  Container(color: c.surface)
extension AppColorsX on BuildContext {
  AppColorTokens get ext => Theme.of(this).ext;

  // Legacy alias kept for AccountPage and any migrated screens
  // ignore: library_private_types_in_public_api
  _AppContextColors get colors => _AppContextColors(this);
}

class _AppContextColors {
  final BuildContext _ctx;
  const _AppContextColors(this._ctx);

  AppColorTokens get _t => Theme.of(_ctx).ext;

  Color get surface        => _t.surface;
  Color get backgroundGrey => _t.backgroundGrey;
  Color get inputFill      => _t.inputFill;
  Color get textPrimary    => _t.textPrimary;
  Color get textSecondary  => _t.textSecondary;
  Color get textTertiary   => _t.textTertiary;
  Color get border         => _t.border;
  Color get borderLight    => _t.borderLight;
  Color get divider        => _t.divider;
  Color get shadow         => _t.shadow;
  Color get shadowLight    => _t.shadowLight;
  Color get error          => _t.error;
  Color get success        => _t.success;
  Color get warning        => _t.warning;

  static const Color primary     = Color(0xFF009688);
  static const Color primaryDark = Color(0xFF00A99D);
}
