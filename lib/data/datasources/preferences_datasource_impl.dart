import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_preferences_model.dart';
import 'preferences_datasource.dart';

class PreferencesDataSourceImpl implements PreferencesDataSource {
  static const String _downloadTypeKey = 'download_type';
  static const String _selectedFormatKey = 'selected_format';
  static const String _selectedQualityKey = 'selected_quality';

  @override
  Future<UserPreferences> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final downloadTypeString = prefs.getString(_downloadTypeKey);
    final selectedFormat = prefs.getString(_selectedFormatKey);
    final selectedQuality = prefs.getString(_selectedQualityKey);

    final downloadType = downloadTypeString != null
        ? DownloadType.values.firstWhere(
            (type) => type.name == downloadTypeString,
            orElse: () => DownloadType.videoOnly,
          )
        : DownloadType.videoOnly;

    return UserPreferencesModel(
      downloadType: downloadType,
      selectedFormat: selectedFormat ?? 'MP4',
      selectedQuality: selectedQuality ?? '1080p',
    );
  }

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString(_downloadTypeKey, preferences.downloadType.name),
      prefs.setString(_selectedFormatKey, preferences.selectedFormat),
      prefs.setString(_selectedQualityKey, preferences.selectedQuality),
    ]);
  }

  @override
  Future<void> saveDownloadType(DownloadType downloadType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_downloadTypeKey, downloadType.name);
  }

  @override
  Future<void> saveSelectedFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedFormatKey, format);
  }

  @override
  Future<void> saveSelectedQuality(String quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedQualityKey, quality);
  }

  @override
  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_downloadTypeKey),
      prefs.remove(_selectedFormatKey),
      prefs.remove(_selectedQualityKey),
    ]);
  }
}
