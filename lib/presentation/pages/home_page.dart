import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../bloc/video_analysis/video_analysis_cubit.dart';
import '../bloc/video_analysis/video_analysis_state.dart';
import '../bloc/preferences/preferences_cubit.dart';
import '../bloc/preferences/preferences_state.dart';
import '../widgets/url_input_widget.dart';
import '../widgets/video_info_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load preferences khi app khởi động
    context.read<PreferencesCubit>().loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Downloader'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            BlocBuilder<PreferencesCubit, PreferencesState>(
              builder: (context, preferencesState) {
                if (preferencesState is PreferencesLoaded) {
                  return UrlInputWidget(
                    selectedDownloadType:
                        preferencesState.preferences.downloadType,
                    onDownloadTypeChanged: (downloadType) {
                      context.read<PreferencesCubit>().updateDownloadType(
                        downloadType,
                      );
                    },
                    onFormatSelected: (format, quality) {
                      context.read<PreferencesCubit>().updateSelectedFormat(
                        format,
                      );
                      context.read<PreferencesCubit>().updateSelectedQuality(
                        quality,
                      );
                    },
                  );
                } else if (preferencesState is PreferencesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  // Fallback với default values
                  return UrlInputWidget(
                    selectedDownloadType: DownloadType.videoOnly,
                    onDownloadTypeChanged: (downloadType) {
                      context.read<PreferencesCubit>().updateDownloadType(
                        downloadType,
                      );
                    },
                    onFormatSelected: (format, quality) {
                      context.read<PreferencesCubit>().updateSelectedFormat(
                        format,
                      );
                      context.read<PreferencesCubit>().updateSelectedQuality(
                        quality,
                      );
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<VideoAnalysisCubit, VideoAnalysisState>(
                builder: (context, videoState) {
                  if (videoState is VideoAnalysisLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (videoState is VideoAnalysisLoaded) {
                    return BlocBuilder<PreferencesCubit, PreferencesState>(
                      builder: (context, preferencesState) {
                        if (preferencesState is PreferencesLoaded) {
                          return VideoInfoWidget(
                            videoInfo: videoState.videoInfo,
                            downloadType:
                                preferencesState.preferences.downloadType,
                            selectedFormat:
                                preferencesState.preferences.selectedFormat,
                            selectedQuality:
                                preferencesState.preferences.selectedQuality,
                          );
                        } else {
                          // Fallback với default values
                          return VideoInfoWidget(
                            videoInfo: videoState.videoInfo,
                            downloadType: DownloadType.videoOnly,
                            selectedFormat: 'MP4',
                            selectedQuality: '1080p',
                          );
                        }
                      },
                    );
                  } else if (videoState is VideoAnalysisError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            videoState.message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Enter a YouTube URL to start',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
