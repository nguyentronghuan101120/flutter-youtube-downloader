import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';

class SaveUserPreferences {
  final PreferencesRepository repository;

  SaveUserPreferences({required this.repository});

  Future<void> call(UserPreferences preferences) async {
    await repository.saveUserPreferences(preferences);
  }
}
