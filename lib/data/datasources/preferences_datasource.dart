import '../../domain/entities/user_preferences.dart';
import '../../core/constants/app_constants.dart';

abstract class PreferencesDataSource {
  Future<UserPreferences> getUserPreferences();
  Future<void> saveUserPreferences(UserPreferences preferences);
  Future<void> saveDownloadType(DownloadType downloadType);
  Future<void> saveSelectedFormat(String format);
  Future<void> saveSelectedQuality(String quality);
  Future<void> clearAllPreferences();
}
