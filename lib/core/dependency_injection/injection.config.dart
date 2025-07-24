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
import 'package:flutter_youtube_downloader/core/services/youtube_service.dart'
    as _i691;
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
import 'package:flutter_youtube_downloader/domain/usecases/get_downloads.dart'
    as _i257;
import 'package:flutter_youtube_downloader/domain/usecases/get_user_preferences.dart'
    as _i501;
import 'package:flutter_youtube_downloader/domain/usecases/save_user_preferences.dart'
    as _i993;
import 'package:flutter_youtube_downloader/domain/usecases/start_download.dart'
    as _i767;
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
    gh.factory<_i244.StorageRepository>(() => _i76.StorageRepositoryImpl());
    gh.factory<_i406.PreferencesDataSource>(
      () => _i69.PreferencesDataSourceImpl(),
    );
    gh.lazySingleton<_i142.VideoRepository>(
      () => _i132.VideoRepositoryImpl(
        dataSource: gh<_i446.YouTubeDataSource>(),
        youtubeService: gh<_i691.YouTubeService>(),
      ),
    );
    gh.lazySingleton<_i856.DownloadRepository>(
      () => _i888.DownloadRepositoryImpl(),
    );
    gh.factory<_i767.StartDownloadUseCase>(
      () => _i767.StartDownloadUseCase(
        downloadRepository: gh<_i856.DownloadRepository>(),
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
    gh.factory<_i257.GetActiveDownloads>(
      () => _i257.GetActiveDownloads(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i257.GetCompletedDownloads>(
      () => _i257.GetCompletedDownloads(gh<_i856.DownloadRepository>()),
    );
    gh.factory<_i257.GetQueuedDownloads>(
      () => _i257.GetQueuedDownloads(gh<_i856.DownloadRepository>()),
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
