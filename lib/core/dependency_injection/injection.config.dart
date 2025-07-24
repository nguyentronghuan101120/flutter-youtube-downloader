// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_youtube_downloader/core/dependency_injection/external_module.dart'
    as _i429;
import 'package:flutter_youtube_downloader/core/services/download_service.dart'
    as _i632;
import 'package:flutter_youtube_downloader/core/services/youtube_service.dart'
    as _i691;
import 'package:flutter_youtube_downloader/data/datasources/download_datasource.dart'
    as _i787;
import 'package:flutter_youtube_downloader/data/datasources/preferences_datasource.dart'
    as _i406;
import 'package:flutter_youtube_downloader/data/datasources/preferences_datasource_impl.dart'
    as _i69;
import 'package:flutter_youtube_downloader/data/datasources/youtube_datasource.dart'
    as _i446;
import 'package:flutter_youtube_downloader/data/repositories/download_repository_impl.dart'
    as _i888;
import 'package:flutter_youtube_downloader/data/repositories/preferences_repository_impl.dart'
    as _i387;
import 'package:flutter_youtube_downloader/data/repositories/storage_repository_impl.dart'
    as _i76;
import 'package:flutter_youtube_downloader/data/repositories/video_repository_impl.dart'
    as _i132;
import 'package:flutter_youtube_downloader/domain/repositories/download_repository.dart'
    as _i856;
import 'package:flutter_youtube_downloader/domain/repositories/preferences_repository.dart'
    as _i485;
import 'package:flutter_youtube_downloader/domain/repositories/storage_repository.dart'
    as _i244;
import 'package:flutter_youtube_downloader/domain/repositories/video_repository.dart'
    as _i142;
import 'package:flutter_youtube_downloader/domain/usecases/analyze_playlist.dart'
    as _i526;
import 'package:flutter_youtube_downloader/domain/usecases/analyze_video.dart'
    as _i311;
import 'package:flutter_youtube_downloader/domain/usecases/download/cancel_download.dart'
    as _i411;
import 'package:flutter_youtube_downloader/domain/usecases/download/clear_completed_downloads.dart'
    as _i42;
import 'package:flutter_youtube_downloader/domain/usecases/download/clear_failed_downloads.dart'
    as _i657;
import 'package:flutter_youtube_downloader/domain/usecases/download/get_active_downloads.dart'
    as _i512;
import 'package:flutter_youtube_downloader/domain/usecases/download/get_all_downloads.dart'
    as _i1018;
import 'package:flutter_youtube_downloader/domain/usecases/download/get_completed_downloads.dart'
    as _i877;
import 'package:flutter_youtube_downloader/domain/usecases/download/get_download_by_id.dart'
    as _i571;
import 'package:flutter_youtube_downloader/domain/usecases/download/get_failed_downloads.dart'
    as _i497;
import 'package:flutter_youtube_downloader/domain/usecases/download/get_queue_status.dart'
    as _i329;
import 'package:flutter_youtube_downloader/domain/usecases/download/get_queued_downloads.dart'
    as _i672;
import 'package:flutter_youtube_downloader/domain/usecases/download/pause_download.dart'
    as _i44;
import 'package:flutter_youtube_downloader/domain/usecases/download/reorder_download_queue.dart'
    as _i977;
import 'package:flutter_youtube_downloader/domain/usecases/download/resume_download.dart'
    as _i359;
import 'package:flutter_youtube_downloader/domain/usecases/download/set_download_priority.dart'
    as _i1070;
import 'package:flutter_youtube_downloader/domain/usecases/download/start_download.dart'
    as _i728;
import 'package:flutter_youtube_downloader/domain/usecases/get_user_preferences.dart'
    as _i501;
import 'package:flutter_youtube_downloader/domain/usecases/save_user_preferences.dart'
    as _i993;
import 'package:flutter_youtube_downloader/presentation/bloc/playlist_analysis/playlist_analysis_cubit.dart'
    as _i996;
import 'package:flutter_youtube_downloader/presentation/bloc/preferences/preferences_cubit.dart'
    as _i270;
import 'package:flutter_youtube_downloader/presentation/bloc/video_analysis/video_analysis_cubit.dart'
    as _i384;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as _i578;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final externalModule = _$ExternalModule();
    gh.lazySingleton<_i578.YoutubeExplode>(() => externalModule.youtubeExplode);
    gh.lazySingleton<_i691.YouTubeService>(() => _i691.YouTubeService());
    gh.lazySingleton<_i446.YouTubeDataSource>(() => _i446.YouTubeDataSource());
    gh.lazySingleton<_i632.DownloadService>(() => _i632.DownloadService());
    gh.factory<_i244.StorageRepository>(() => _i76.StorageRepositoryImpl());
    gh.factory<_i406.PreferencesDataSource>(
      () => _i69.PreferencesDataSourceImpl(),
    );
    gh.lazySingleton<_i787.DownloadDataSource>(
      () => _i787.DownloadDataSourceImpl(),
    );
    gh.lazySingleton<_i142.VideoRepository>(
      () => _i132.VideoRepositoryImpl(
        dataSource: gh<_i446.YouTubeDataSource>(),
        youtubeService: gh<_i691.YouTubeService>(),
      ),
    );
    gh.lazySingleton<_i856.DownloadRepository>(
      () => _i888.DownloadRepositoryImpl(
        downloadDataSource: gh<_i787.DownloadDataSource>(),
      ),
    );
    gh.factory<_i485.PreferencesRepository>(
      () => _i387.PreferencesRepositoryImpl(gh<_i406.PreferencesDataSource>()),
    );
    gh.factory<_i311.AnalyzeVideoUseCase>(
      () => _i311.AnalyzeVideoUseCase(
        videoRepository: gh<_i142.VideoRepository>(),
      ),
    );
    gh.factory<_i526.AnalyzePlaylistUseCase>(
      () => _i526.AnalyzePlaylistUseCase(
        videoRepository: gh<_i142.VideoRepository>(),
      ),
    );
    gh.factory<_i512.GetActiveDownloads>(
      () => _i512.GetActiveDownloads(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i329.GetQueueStatus>(
      () => _i329.GetQueueStatus(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i571.GetDownloadById>(
      () => _i571.GetDownloadById(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i977.ReorderDownloadQueue>(
      () => _i977.ReorderDownloadQueue(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i877.GetCompletedDownloads>(
      () => _i877.GetCompletedDownloads(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i1018.GetAllDownloads>(
      () => _i1018.GetAllDownloads(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i42.ClearCompletedDownloads>(
      () => _i42.ClearCompletedDownloads(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i1070.SetDownloadPriority>(
      () => _i1070.SetDownloadPriority(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i497.GetFailedDownloads>(
      () => _i497.GetFailedDownloads(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i657.ClearFailedDownloads>(
      () => _i657.ClearFailedDownloads(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i672.GetQueuedDownloads>(
      () => _i672.GetQueuedDownloads(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i384.VideoAnalysisCubit>(
      () => _i384.VideoAnalysisCubit(
        analyzeVideoUseCase: gh<_i311.AnalyzeVideoUseCase>(),
      ),
    );
    gh.factory<_i993.SaveUserPreferences>(
      () => _i993.SaveUserPreferences(gh<_i485.PreferencesRepository>()),
    );
    gh.factory<_i501.GetUserPreferences>(
      () => _i501.GetUserPreferences(gh<_i485.PreferencesRepository>()),
    );
    gh.factory<_i728.StartDownloadUseCase>(
      () => _i728.StartDownloadUseCase(
        downloadRepository: gh<_i856.DownloadRepository>(),
      ),
    );
    gh.factory<_i44.PauseDownloadUseCase>(
      () => _i44.PauseDownloadUseCase(
        downloadRepository: gh<_i856.DownloadRepository>(),
      ),
    );
    gh.factory<_i359.ResumeDownloadUseCase>(
      () => _i359.ResumeDownloadUseCase(
        downloadRepository: gh<_i856.DownloadRepository>(),
      ),
    );
    gh.factory<_i411.CancelDownloadUseCase>(
      () => _i411.CancelDownloadUseCase(
        downloadRepository: gh<_i856.DownloadRepository>(),
      ),
    );
    gh.factory<_i270.PreferencesCubit>(
      () => _i270.PreferencesCubit(
        gh<_i501.GetUserPreferences>(),
        gh<_i993.SaveUserPreferences>(),
      ),
    );
    gh.factory<_i996.PlaylistAnalysisCubit>(
      () => _i996.PlaylistAnalysisCubit(
        analyzePlaylistUseCase: gh<_i526.AnalyzePlaylistUseCase>(),
      ),
    );
    return this;
  }
}

class _$ExternalModule extends _i429.ExternalModule {}
