import 'package:injectable/injectable.dart';
import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';

@injectable
class SaveUserPreferences {
  final PreferencesRepository repository;

  SaveUserPreferences(this.repository);

  Future<void> call(UserPreferences preferences) async {
    await repository.saveUserPreferences(preferences);
  }
}
