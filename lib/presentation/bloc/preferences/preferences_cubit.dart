import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/user_preferences.dart';
import '../../../domain/usecases/get_user_preferences.dart';
import '../../../domain/usecases/save_user_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/result/result.dart';
import 'preferences_state.dart';

@injectable
class PreferencesCubit extends Cubit<PreferencesState> {
  final GetUserPreferences _getUserPreferences;
  final SaveUserPreferences _saveUserPreferences;

  PreferencesCubit(this._getUserPreferences, this._saveUserPreferences)
    : super(const PreferencesInitial());

  Future<void> loadPreferences() async {
    emit(const PreferencesLoading());
    try {
      final result = await _getUserPreferences.execute(null);
      if (result.isSuccess) {
        emit(PreferencesLoaded(preferences: result.data!));
      } else {
        emit(PreferencesError(message: result.errorMessage!));
      }
    } catch (e) {
      emit(PreferencesError(message: e.toString()));
    }
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    try {
      final result = await _saveUserPreferences.execute(preferences);
      if (result.isSuccess) {
        emit(PreferencesLoaded(preferences: preferences));
      } else {
        emit(PreferencesError(message: result.errorMessage!));
      }
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
