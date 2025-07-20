import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/video_info.dart';
import '../../../domain/usecases/analyze_video.dart';

part 'video_analysis_state.dart';

@injectable
class VideoAnalysisCubit extends Cubit<VideoAnalysisState> {
  final AnalyzeVideoUseCase _analyzeVideoUseCase;

  VideoAnalysisCubit(this._analyzeVideoUseCase) : super(VideoAnalysisInitial());

  Future<void> analyzeVideo(String url) async {
    emit(VideoAnalysisLoading());

    final result = await _analyzeVideoUseCase(url);

    result.fold(
      (failure) => emit(VideoAnalysisError(failure.message)),
      (videoInfo) => emit(VideoAnalysisSuccess(videoInfo)),
    );
  }

  void reset() {
    emit(VideoAnalysisInitial());
  }
}
