import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video_analysis/video_analysis_cubit.dart';
import '../bloc/video_analysis/video_analysis_state.dart';
import '../widgets/video_info_widget.dart';
import '../widgets/url_input_widget.dart';
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
        create: (context) =>
            VideoAnalysisCubit(analyzeVideoUseCase: context.read()),
        child: const _VideoAnalysisView(),
      ),
    );
  }
}

class _VideoAnalysisView extends StatelessWidget {
  const _VideoAnalysisView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoAnalysisCubit, VideoAnalysisState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // URL Input Section
              UrlInputWidget(
                onUrlSubmitted: (url) {
                  context.read<VideoAnalysisCubit>().analyzeVideo(url);
                },
                isLoading: state.isLoading,
              ),
              const SizedBox(height: 24),

              // Content Section
              Expanded(child: _buildContent(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, VideoAnalysisState state) {
    return state.when(
      initial: () => _buildInitialState(context),
      loading: (lastAnalyzedUrl) =>
          _buildLoadingState(context, lastAnalyzedUrl),
      success: (videoInfo, lastAnalyzedUrl) =>
          _buildSuccessState(context, videoInfo),
      error: (errorMessage, lastAnalyzedUrl) =>
          _buildErrorState(context, errorMessage, lastAnalyzedUrl),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Enter a YouTube URL to analyze',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Support for both videos and playlists',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, String? lastAnalyzedUrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analyzing video...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (lastAnalyzedUrl != null) ...[
            const SizedBox(height: 8),
            Text(
              lastAnalyzedUrl,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, VideoInfo videoInfo) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Success indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Analysis completed successfully',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Video info widget
          VideoInfoWidget(videoInfo: videoInfo),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String errorMessage,
    String? lastAnalyzedUrl,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.red[600]),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (lastAnalyzedUrl != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Last analyzed URL:',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastAnalyzedUrl,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (lastAnalyzedUrl != null) {
                      context.read<VideoAnalysisCubit>().analyzeVideo(
                        lastAnalyzedUrl,
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<VideoAnalysisCubit>().reset();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
