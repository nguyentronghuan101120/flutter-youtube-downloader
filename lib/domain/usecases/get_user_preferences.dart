import 'package:injectable/injectable.dart';
import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';

@injectable
class GetUserPreferences {
  final PreferencesRepository repository;

  GetUserPreferences(this.repository);

  Future<UserPreferences> call() async {
    return await repository.getUserPreferences();
  }
}
