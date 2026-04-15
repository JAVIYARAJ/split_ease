import 'package:shared_preferences/shared_preferences.dart';

abstract class AppSettingsLocalDataSource {
  Future<bool> isFirstTimeUser();
  Future<void> setFirstTimeUserSeen();
}

const String kIsFirstTimeUserKey = 'is_first_time_user';

class AppSettingsLocalDataSourceImpl implements AppSettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  AppSettingsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<bool> isFirstTimeUser() async {
    return sharedPreferences.getBool(kIsFirstTimeUserKey) ?? true;
  }

  @override
  Future<void> setFirstTimeUserSeen() async {
    await sharedPreferences.setBool(kIsFirstTimeUserKey, false);
  }
}
