import '../repositories/app_settings_repository.dart';

class SetFirstTimeUserSeen {
  final AppSettingsRepository repository;

  SetFirstTimeUserSeen(this.repository);

  Future<void> call() async {
    await repository.setFirstTimeUserSeen();
  }
}
