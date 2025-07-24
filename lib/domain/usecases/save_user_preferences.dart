import 'package:injectable/injectable.dart';
import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';
import '../../core/usecases/base_usecase.dart';
import '../../core/result/result.dart';

@injectable
class SaveUserPreferences
    implements BaseUseCase<Result<void>, UserPreferences> {
  final PreferencesRepository repository;

  SaveUserPreferences(this.repository);

  @override
  Future<Result<void>> execute(UserPreferences preferences) async {
    try {
      await repository.saveUserPreferences(preferences);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to save user preferences: $e');
    }
  }
}
