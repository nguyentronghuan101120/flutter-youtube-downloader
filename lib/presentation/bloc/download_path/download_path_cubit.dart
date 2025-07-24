import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import '../../../domain/usecases/get_download_path.dart';
import 'download_path_state.dart';

@injectable
class DownloadPathCubit extends Cubit<DownloadPathState> {
  final GetDownloadPath _getDownloadPath;

  DownloadPathCubit({required GetDownloadPath getDownloadPath})
    : _getDownloadPath = getDownloadPath,
      super(const DownloadPathState.initial());

  Future<void> loadDownloadPath() async {
    emit(const DownloadPathState.loading());

    try {
      final result = await _getDownloadPath.execute();

      result.when(
        success: (path) {
          developer.log(
            '[download_path_cubit.dart] - Loaded download path: $path',
          );
          emit(DownloadPathState.loaded(path: path));
        },
        failure: (error) {
          developer.log(
            '[download_path_cubit.dart] - Error loading download path: $error',
          );
          emit(DownloadPathState.error(message: error));
        },
      );
    } catch (e) {
      developer.log(
        '[download_path_cubit.dart] - Exception loading download path: $e',
      );
      emit(DownloadPathState.error(message: e.toString()));
    }
  }

  Future<void> refreshDownloadPath() async {
    await loadDownloadPath();
  }
}
