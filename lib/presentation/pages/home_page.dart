import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video_analysis/video_analysis_cubit.dart';
import '../bloc/video_analysis/video_analysis_state.dart';
import '../widgets/url_input_widget.dart';
import '../widgets/video_info_widget.dart';
import '../widgets/common_button.dart';
import '../widgets/common_loading_dialog.dart';
import 'download_page.dart';
import '../../domain/entities/video_info.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Downloader'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocListener<VideoAnalysisCubit, VideoAnalysisState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: (lastAnalyzedUrl) {
              CommonLoadingDialog.show(context, message: 'Analyzing video...');
            },
            success: (videoInfo, lastAnalyzedUrl) {
              CommonLoadingDialog.hide(context);
            },
            error: (message, lastAnalyzedUrl) {
              CommonLoadingDialog.hide(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
          );
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UrlInputWidget(
                  onUrlSubmitted: (url) {
                    context.read<VideoAnalysisCubit>().analyzeVideo(url);
                  },
                ),
                const SizedBox(height: 24),
                // const DownloadPathWidget(),
                // const SizedBox(height: 24),
                BlocBuilder<VideoAnalysisCubit, VideoAnalysisState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => _buildInitialState(context),
                      loading: (lastAnalyzedUrl) => _buildLoadingState(),
                      success: (videoInfo, lastAnalyzedUrl) =>
                          _buildSuccessState(context, videoInfo),
                      error: (message, lastAnalyzedUrl) =>
                          _buildErrorState(context, message),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Enter YouTube URL to start',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Paste a YouTube video URL above to analyze and download',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox.shrink(); // Hide loading state since we have dialog
  }

  Widget _buildSuccessState(BuildContext context, VideoInfo videoInfo) {
    return Column(
      children: [
        VideoInfoWidget(videoInfo: videoInfo),
        const SizedBox(height: 16),
        CommonButton(
          text: 'Download Video',
          icon: Icons.download,
          onPressed: () => _navigateToDownload(context, videoInfo),
          isFullWidth: true,
          size: CommonButtonSize.large,
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text('Error', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToDownload(BuildContext context, VideoInfo videoInfo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadPage(videoInfo: videoInfo),
      ),
    );
  }
}
