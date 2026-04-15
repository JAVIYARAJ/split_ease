abstract class AppSettingsRepository {
  Future<bool> isFirstTimeUser();
  Future<void> setFirstTimeUserSeen();
}
