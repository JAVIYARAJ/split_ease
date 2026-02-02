import '../repositories/app_settings_repository.dart';

class IsFirstTimeUser {
  final AppSettingsRepository repository;

  IsFirstTimeUser(this.repository);

  Future<bool> call() async {
    return await repository.isFirstTimeUser();
  }
}
