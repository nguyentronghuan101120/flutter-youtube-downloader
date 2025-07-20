import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user_preferences.dart';
import '../../../domain/usecases/get_user_preferences.dart';
import '../../../domain/usecases/save_user_preferences.dart';
import '../../../core/constants/app_constants.dart';
import 'preferences_state.dart';

class PreferencesCubit extends Cubit<PreferencesState> {
  final GetUserPreferences _getUserPreferences;
  final SaveUserPreferences _saveUserPreferences;

  PreferencesCubit({
    required GetUserPreferences getUserPreferences,
    required SaveUserPreferences saveUserPreferences,
  }) : _getUserPreferences = getUserPreferences,
       _saveUserPreferences = saveUserPreferences,
       super(const PreferencesInitial());

  Future<void> loadPreferences() async {
    emit(const PreferencesLoading());
    try {
      final preferences = await _getUserPreferences();
      emit(PreferencesLoaded(preferences: preferences));
    } catch (e) {
      emit(PreferencesError(message: e.toString()));
    }
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    try {
      await _saveUserPreferences(preferences);
      emit(PreferencesLoaded(preferences: preferences));
    } catch (e) {
      emit(PreferencesError(message: e.toString()));
    }
  }

  Future<void> updateDownloadType(DownloadType downloadType) async {
    final currentState = state;
    if (currentState is PreferencesLoaded) {
      final updatedPreferences = currentState.preferences.copyWith(
        downloadType: downloadType,
      );
      await savePreferences(updatedPreferences);
    }
  }

  Future<void> updateSelectedFormat(String format) async {
    final currentState = state;
    if (currentState is PreferencesLoaded) {
      final updatedPreferences = currentState.preferences.copyWith(
        selectedFormat: format,
      );
      await savePreferences(updatedPreferences);
    }
  }

  Future<void> updateSelectedQuality(String quality) async {
    final currentState = state;
    if (currentState is PreferencesLoaded) {
      final updatedPreferences = currentState.preferences.copyWith(
        selectedQuality: quality,
      );
      await savePreferences(updatedPreferences);
    }
  }
}
