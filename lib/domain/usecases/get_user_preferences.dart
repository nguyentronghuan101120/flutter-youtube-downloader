import 'package:injectable/injectable.dart';
import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';
import '../../core/usecases/base_usecase.dart';
import '../../core/result/result.dart';

@injectable
class GetUserPreferences
    implements BaseUseCaseNoParams<Result<UserPreferences>> {
  final PreferencesRepository repository;

  GetUserPreferences(this.repository);

  @override
  Future<Result<UserPreferences>> execute() async {
    try {
      final preferences = await repository.getUserPreferences();
      return Result.success(preferences);
    } catch (e) {
      return Result.failure('Failed to get user preferences: $e');
    }
  }
}
