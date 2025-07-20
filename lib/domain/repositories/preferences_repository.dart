import '../entities/user_preferences.dart';
import '../../core/constants/app_constants.dart';

abstract class PreferencesRepository {
  Future<UserPreferences> getUserPreferences();
  Future<void> saveUserPreferences(UserPreferences preferences);
  Future<void> saveDownloadType(DownloadType downloadType);
  Future<void> saveSelectedFormat(String format);
  Future<void> saveSelectedQuality(String quality);
  Future<void> clearAllPreferences();
}
