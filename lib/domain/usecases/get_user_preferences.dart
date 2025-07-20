import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';

class GetUserPreferences {
  final PreferencesRepository repository;

  GetUserPreferences({required this.repository});

  Future<UserPreferences> call() async {
    return await repository.getUserPreferences();
  }
}
