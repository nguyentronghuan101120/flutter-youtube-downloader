import '../../domain/entities/user_preferences.dart';

// UserPreferencesModel giờ chỉ là alias cho UserPreferences vì entity đã có freezed
typedef UserPreferencesModel = UserPreferences;

// Extension để thêm các helper methods cho UserPreferencesModel
extension UserPreferencesModelUtils on UserPreferencesModel {
  /// Creates UserPreferencesModel from JSON map
  static UserPreferencesModel fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel.fromJson(map);
  }

  /// Converts UserPreferencesModel to JSON map
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Creates UserPreferencesModel from UserPreferences entity
  static UserPreferencesModel fromEntity(UserPreferences entity) {
    return entity;
  }

  /// Converts UserPreferencesModel to UserPreferences entity
  UserPreferences toEntity() {
    return this;
  }
}
