import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/video_info.dart';
import '../../../domain/usecases/download/start_download.dart';
import '../../../domain/usecases/download/get_active_downloads.dart';
import '../../../domain/repositories/download_repository.dart';
import '../../../core/utils/video_info_utils.dart';
import 'download_state.dart';

@injectable
class DownloadCubit extends Cubit<DownloadState> {
  final StartDownload _startDownload;
  final GetActiveDownloads _getActiveDownloads;

  DownloadCubit({
    required StartDownload startDownload,
    required GetActiveDownloads getActiveDownloads,
  }) : _startDownload = startDownload,
       _getActiveDownloads = getActiveDownloads,
       super(const DownloadState.initial());

  Future<void> prepareDownload(VideoInfo videoInfo) async {
    emit(const DownloadState.loading());

    try {
      final videoStreams = videoInfo.videoStreams;
      final audioStreams = videoInfo.audioStreams;

      developer.log(
        '[download_cubit.dart] - Video streams count: ${videoStreams.length}',
      );
      developer.log(
        '[download_cubit.dart] - Audio streams count: ${audioStreams.length}',
      );

      emit(
        DownloadState.ready(
          videoInfo: videoInfo,
          videoStreams: videoStreams,
          audioStreams: audioStreams,
        ),
      );
    } catch (e) {
      emit(DownloadState.failed(message: 'Failed to analyze video: $e'));
    }
  }

  Future<void> startDownload({
    required String url,
    required String format,
    required String quality,
    String? outputPath,
  }) async {
    emit(const DownloadState.loading());

    try {
      final videoId = VideoInfoUtils.extractVideoId(url);
      if (videoId == null) {
        emit(
          DownloadState.failed(message: 'Could not extract video ID from URL'),
        );
        return;
      }

      final params = StartDownloadParams(
        videoId: videoId,
        title: _extractTitle(url),
        url: url,
        format: format,
        quality: quality,
        outputPath: outputPath ?? await _getDefaultOutputPath(),
      );

      final result = await _startDownload.execute(params);

      result.when(
        success: (createdTask) {
          developer.log(
            '[download_cubit.dart] - Download started successfully: ${createdTask.title}',
          );
          // Emit ready state to show format selection again
          emit(
            DownloadState.ready(
              videoInfo: VideoInfo(
                id: videoId,
                title: createdTask.title,
                author: 'Unknown',
                duration: Duration.zero,
                thumbnailUrl: '',
                formats: [],
                url: url,
                viewCount: 0,
              ),
              videoStreams: [],
              audioStreams: [],
            ),
          );
        },
        failure: (error) {
          emit(DownloadState.failed(message: error));
        },
      );
    } catch (e) {
      emit(DownloadState.failed(message: 'Failed to start download: $e'));
    }
  }

  Future<void> startMultipleDownloads({
    required String url,
    required List<Map<String, String>> formats,
    String? outputPath,
  }) async {
    emit(const DownloadState.loading());

    try {
      final videoId = VideoInfoUtils.extractVideoId(url);
      if (videoId == null) {
        emit(
          DownloadState.failed(message: 'Could not extract video ID from URL'),
        );
        return;
      }

      int successCount = 0;
      int failureCount = 0;

      for (final format in formats) {
        try {
          final params = StartDownloadParams(
            videoId: videoId,
            title: _extractTitle(url),
            url: url,
            format: format['format']!,
            quality: format['quality']!,
            outputPath: outputPath ?? await _getDefaultOutputPath(),
          );

          final result = await _startDownload.execute(params);

          result.when(
            success: (createdTask) {
              developer.log(
                '[download_cubit.dart] - Download started successfully: ${createdTask.title} (${format['format']} - ${format['quality']})',
              );
              successCount++;
            },
            failure: (error) {
              developer.log(
                '[download_cubit.dart] - Download failed: $error (${format['format']} - ${format['quality']})',
              );
              failureCount++;
            },
          );
        } catch (e) {
          developer.log(
            '[download_cubit.dart] - Download failed with exception: $e (${format['format']} - ${format['quality']})',
          );
          failureCount++;
        }
      }

      // Emit ready state to show format selection again
      emit(
        DownloadState.ready(
          videoInfo: VideoInfo(
            id: videoId,
            title: 'Video_${DateTime.now().millisecondsSinceEpoch}',
            author: 'Unknown',
            duration: Duration.zero,
            thumbnailUrl: '',
            formats: [],
            url: url,
            viewCount: 0,
          ),
          videoStreams: [],
          audioStreams: [],
        ),
      );

      // Show summary if there were failures
      if (failureCount > 0) {
        final message =
            'Started $successCount downloads successfully. $failureCount downloads failed.';
        developer.log('[download_cubit.dart] - $message');
      }
    } catch (e) {
      emit(DownloadState.failed(message: 'Failed to start downloads: $e'));
    }
  }

  Future<void> checkAndLoadAppropriateState(VideoInfo videoInfo) async {
    emit(const DownloadState.loading());

    try {
      final activeResult = await _getActiveDownloads.execute();

      activeResult.when(
        success: (activeDownloads) {
          if (activeDownloads.isNotEmpty) {
            // If there are active downloads, still show ready state for format selection
            prepareDownload(videoInfo);
          } else {
            // If no active downloads, prepare download for the current video
            prepareDownload(videoInfo);
          }
        },
        failure: (failure) => emit(DownloadState.failed(message: failure)),
      );
    } catch (e) {
      emit(
        DownloadState.failed(message: 'Failed to check download status: $e'),
      );
    }
  }

  String _extractTitle(String url) {
    return 'Video_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> _getDefaultOutputPath() async {
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        return '${downloadsDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      }
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      return '${downloadsDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    } catch (e) {
      final tempDir = await getTemporaryDirectory();
      return '${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    }
  }
}
