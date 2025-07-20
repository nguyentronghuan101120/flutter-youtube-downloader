import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/preferences_datasource.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesDataSource dataSource;

  PreferencesRepositoryImpl({required this.dataSource});

  @override
  Future<UserPreferences> getUserPreferences() async {
    try {
      return await dataSource.getUserPreferences();
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      await dataSource.saveUserPreferences(preferences);
    } catch (e) {
      throw Exception('Failed to save user preferences: $e');
    }
  }

  @override
  Future<void> saveDownloadType(DownloadType downloadType) async {
    try {
      await dataSource.saveDownloadType(downloadType);
    } catch (e) {
      throw Exception('Failed to save download type: $e');
    }
  }

  @override
  Future<void> saveSelectedFormat(String format) async {
    try {
      await dataSource.saveSelectedFormat(format);
    } catch (e) {
      throw Exception('Failed to save selected format: $e');
    }
  }

  @override
  Future<void> saveSelectedQuality(String quality) async {
    try {
      await dataSource.saveSelectedQuality(quality);
    } catch (e) {
      throw Exception('Failed to save selected quality: $e');
    }
  }

  @override
  Future<void> clearAllPreferences() async {
    try {
      await dataSource.clearAllPreferences();
    } catch (e) {
      throw Exception('Failed to clear preferences: $e');
    }
  }
}
