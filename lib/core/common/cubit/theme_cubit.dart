import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kThemeModeKey = 'app_theme_mode';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_load(_prefs));

  static ThemeMode _load(SharedPreferences prefs) {
    final stored = prefs.getString(_kThemeModeKey);
    switch (stored) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    switch (mode) {
      case ThemeMode.dark:
        await _prefs.setString(_kThemeModeKey, 'dark');
        break;
      case ThemeMode.light:
        await _prefs.setString(_kThemeModeKey, 'light');
        break;
      case ThemeMode.system:
        await _prefs.setString(_kThemeModeKey, 'system');
        break;
    }
    emit(mode);
  }

  Future<void> toggleDark() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  bool get isDark => state == ThemeMode.dark;
}
