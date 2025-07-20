import '../../domain/entities/user_preferences.dart';
import '../../core/constants/app_constants.dart';

class UserPreferencesModel extends UserPreferences {
  const UserPreferencesModel({
    required super.downloadType,
    required super.selectedFormat,
    required super.selectedQuality,
  });

  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      downloadType: DownloadType.values.firstWhere(
        (type) => type.name == map['downloadType'],
        orElse: () => DownloadType.videoOnly,
      ),
      selectedFormat: map['selectedFormat'] ?? 'MP4',
      selectedQuality: map['selectedQuality'] ?? '1080p',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'downloadType': downloadType.name,
      'selectedFormat': selectedFormat,
      'selectedQuality': selectedQuality,
    };
  }

  factory UserPreferencesModel.defaultPreferences() {
    return const UserPreferencesModel(
      downloadType: DownloadType.videoOnly,
      selectedFormat: 'MP4',
      selectedQuality: '1080p',
    );
  }
}
