import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video_analysis/video_analysis_cubit.dart';
import '../bloc/video_analysis/video_analysis_state.dart';
import '../widgets/url_input_widget.dart';
import '../widgets/video_info_widget.dart';
import 'video_analysis_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Downloader'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoAnalysisPage(),
                ),
              );
            },
            tooltip: 'Video Analysis',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // URL Input Widget
            BlocBuilder<VideoAnalysisCubit, VideoAnalysisState>(
              builder: (context, state) {
                return UrlInputWidget(
                  onUrlSubmitted: (url) {
                    context.read<VideoAnalysisCubit>().analyzeVideo(url);
                  },
                  isLoading: state.isLoading,
                  errorMessage: state.errorMessage,
                );
              },
            ),

            const SizedBox(height: 20),

            // Video Analysis Results
            Expanded(
              child: BlocBuilder<VideoAnalysisCubit, VideoAnalysisState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Analyzing video...'),
                        ],
                      ),
                    );
                  } else if (state.isSuccess && state.hasVideoInfo) {
                    return VideoInfoWidget(videoInfo: state.videoInfo!);
                  } else if (state.isError) {
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
                            state.errorMessage ?? 'An error occurred',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<VideoAnalysisCubit>().retry();
                            },
                            child: const Text('Retry'),
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
                            Icons.video_library,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Enter a YouTube URL to analyze',
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
