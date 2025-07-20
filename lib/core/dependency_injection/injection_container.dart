import 'package:get_it/get_it.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// Domain Layer
import '../../domain/repositories/video_repository.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../domain/usecases/analyze_video.dart';
import '../../domain/usecases/analyze_playlist.dart';
import '../../domain/usecases/start_download.dart';
import '../../domain/usecases/get_downloads.dart';
import '../../domain/usecases/get_user_preferences.dart';
import '../../domain/usecases/save_user_preferences.dart';

// Data Layer
import '../../data/datasources/youtube_datasource.dart';
import '../../data/datasources/preferences_datasource.dart';
import '../../data/datasources/preferences_datasource_impl.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../data/repositories/preferences_repository_impl.dart';

// Presentation Layer
import '../../presentation/bloc/video_analysis/video_analysis_cubit.dart';
import '../../presentation/bloc/preferences/preferences_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc/Cubit
  sl.registerFactory(() => VideoAnalysisCubit(analyzeVideo: sl()));
  sl.registerFactory(
    () => PreferencesCubit(getUserPreferences: sl(), saveUserPreferences: sl()),
  );
  // sl.registerFactory(() => DownloadCubit(startDownload: sl(), getDownloads: sl()));

  // Use cases
  sl.registerLazySingleton(() => AnalyzeVideo(repository: sl()));
  sl.registerLazySingleton(() => AnalyzePlaylist(repository: sl()));
  sl.registerLazySingleton(
    () => StartDownload(downloadRepository: sl(), storageRepository: sl()),
  );
  sl.registerLazySingleton(() => GetActiveDownloads(repository: sl()));
  sl.registerLazySingleton(() => GetCompletedDownloads(repository: sl()));
  sl.registerLazySingleton(() => GetQueuedDownloads(repository: sl()));
  sl.registerLazySingleton(() => GetUserPreferences(repository: sl()));
  sl.registerLazySingleton(() => SaveUserPreferences(repository: sl()));

  // Repository
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<PreferencesRepository>(
    () => PreferencesRepositoryImpl(dataSource: sl()),
  );
  // sl.registerLazySingleton<DownloadRepository>(
  //   () => DownloadRepositoryImpl(dataSource: sl()),
  // );
  // sl.registerLazySingleton<StorageRepository>(
  //   () => StorageRepositoryImpl(),
  // );

  // Data sources
  sl.registerLazySingleton<YouTubeDataSource>(
    () => YouTubeDataSourceImpl(youtubeExplode: sl()),
  );
  sl.registerLazySingleton<PreferencesDataSource>(
    () => PreferencesDataSourceImpl(),
  );
  // sl.registerLazySingleton<DownloadDataSource>(
  //   () => DownloadDataSourceImpl(dio: sl()),
  // );

  // External
  sl.registerLazySingleton(() => YoutubeExplode());
  // sl.registerLazySingleton(() => Dio());
}
