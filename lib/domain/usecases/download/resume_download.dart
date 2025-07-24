import 'package:injectable/injectable.dart';
import '../../entities/download_task.dart';
import '../../repositories/download_repository.dart';
import '../../../core/usecases/base_usecase.dart';
import '../../../core/result/result.dart';

@injectable
class ResumeDownloadUseCase
    implements BaseUseCase<Result<DownloadTask>, ResumeDownloadParams> {
  final DownloadRepository _downloadRepository;

  const ResumeDownloadUseCase({required DownloadRepository downloadRepository})
    : _downloadRepository = downloadRepository;

  @override
  Future<Result<DownloadTask>> execute(ResumeDownloadParams params) async {
    try {
      return await _downloadRepository.resumeDownload(
        params.taskId,
        onProgress: params.onProgress,
      );
    } catch (e) {
      return Result.failure('Failed to resume download: $e');
    }
  }
}

class ResumeDownloadParams {
  final String taskId;
  final Function(double progress, int bytesDownloaded, int totalBytes)?
  onProgress;

  const ResumeDownloadParams({required this.taskId, this.onProgress});
}
