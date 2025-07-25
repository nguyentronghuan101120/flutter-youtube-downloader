import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import '../../../domain/usecases/get_download_path.dart';
import '../../../domain/usecases/get_system_downloads_path.dart';
import 'download_path_state.dart';

@injectable
class DownloadPathCubit extends Cubit<DownloadPathState> {
  final GetDownloadPath _getDownloadPath;
  final GetSystemDownloadsPath _getSystemDownloadsPath;

  DownloadPathCubit({
    required GetDownloadPath getDownloadPath,
    required GetSystemDownloadsPath getSystemDownloadsPath,
  }) : _getDownloadPath = getDownloadPath,
       _getSystemDownloadsPath = getSystemDownloadsPath,
       super(const DownloadPathState.initial());

  Future<void> loadDownloadPath() async {
    emit(const DownloadPathState.loading());

    try {
      final downloadPathResult = await _getDownloadPath.execute();
      final systemDownloadsPathResult = await _getSystemDownloadsPath.execute();

      downloadPathResult.when(
        success: (downloadPath) {
          systemDownloadsPathResult.when(
            success: (systemDownloadsPath) {
              developer.log(
                '[download_path_cubit.dart] - Loaded download path: $downloadPath',
              );
              developer.log(
                '[download_path_cubit.dart] - System downloads path: $systemDownloadsPath',
              );
              emit(
                DownloadPathState.loaded(
                  path: downloadPath,
                  systemDownloadsPath: systemDownloadsPath,
                ),
              );
            },
            failure: (error) {
              developer.log(
                '[download_path_cubit.dart] - Error loading system downloads path: $error',
              );
              emit(
                DownloadPathState.loaded(
                  path: downloadPath,
                  systemDownloadsPath: null,
                ),
              );
            },
          );
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
