import '../../domain/repositories/app_settings_repository.dart';
import '../../data/datasources/app_settings_local_data_source.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final AppSettingsLocalDataSource localDataSource;

  AppSettingsRepositoryImpl(this.localDataSource);

  @override
  Future<bool> isFirstTimeUser() async {
    return await localDataSource.isFirstTimeUser();
  }

  @override
  Future<void> setFirstTimeUserSeen() async {
    await localDataSource.setFirstTimeUserSeen();
  }
}
