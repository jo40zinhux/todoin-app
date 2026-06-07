import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings implements UseCase<AppSettings, NoParams> {
  final SettingsRepository repository;

  GetSettings(this.repository);

  @override
  Future<AppSettings> call(NoParams params) async {
    return repository.getSettings();
  }
}
