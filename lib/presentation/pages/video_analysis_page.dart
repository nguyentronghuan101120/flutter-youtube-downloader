import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video_analysis/video_analysis_cubit.dart';
import '../widgets/video_info_widget.dart';
import '../widgets/url_input_widget.dart';
import '../../core/constants/app_constants.dart';
import '../../core/dependency_injection/injection.dart';
import '../../domain/entities/video_info.dart';

class VideoAnalysisPage extends StatelessWidget {
  const VideoAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Analysis'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocProvider(
        create: (context) => getIt<VideoAnalysisCubit>(),
        child: const VideoAnalysisView(),
      ),
    );
  }
}

class VideoAnalysisView extends StatelessWidget {
  const VideoAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoAnalysisCubit, VideoAnalysisState>(
      listener: (context, state) {
        if (state is VideoAnalysisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  if (state.lastUrl != null) {
                    context.read<VideoAnalysisCubit>().analyzeVideo(
                      state.lastUrl!,
                    );
                  }
                },
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // URL Input Section
            UrlInputWidget(
              onUrlSubmitted: (url) {
                context.read<VideoAnalysisCubit>().analyzeVideo(url);
              },
            ),
            const SizedBox(height: 24),

            // Analysis Results Section
            Expanded(
              child: BlocBuilder<VideoAnalysisCubit, VideoAnalysisState>(
                builder: (context, state) {
                  return _buildAnalysisContent(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(BuildContext context, VideoAnalysisState state) {
    if (state is VideoAnalysisInitial) {
      return _buildInitialState(context);
    } else if (state is VideoAnalysisLoading) {
      return _buildLoadingState(context, state);
    } else if (state is VideoAnalysisSuccess) {
      return _buildSuccessState(context, state);
    } else if (state is VideoAnalysisError) {
      return _buildErrorState(context, state);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Enter a YouTube URL to analyze',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Get detailed information about video formats and quality options',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, VideoAnalysisLoading state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analyzing video...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (state.progress != null) ...[
            LinearProgressIndicator(
              value: state.progress,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(
              '${(state.progress! * 100).toInt()}% complete',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'This may take a few moments',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, VideoAnalysisSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success header
        Card(
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Video analysis completed successfully!',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Video info widget
        Expanded(
          child: VideoInfoWidget(
            videoInfo: state.videoInfo,
            downloadType: state.downloadType,
            selectedFormat: state.selectedFormat,
            selectedQuality: state.selectedQuality,
            onRetry: () {
              if (state.lastUrl != null) {
                context.read<VideoAnalysisCubit>().analyzeVideo(state.lastUrl!);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, VideoAnalysisError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Analysis Failed',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.red[700]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (state.lastUrl != null) {
                context.read<VideoAnalysisCubit>().analyzeVideo(state.lastUrl!);
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Analysis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              context.read<VideoAnalysisCubit>().reset();
            },
            icon: const Icon(Icons.clear),
            label: const Text('Start Over'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
