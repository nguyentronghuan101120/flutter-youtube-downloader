import 'package:injectable/injectable.dart';
import '../../entities/download_task.dart';
import '../../repositories/download_repository.dart';
import '../../../core/usecases/base_usecase.dart';
import '../../../core/result/result.dart';

@injectable
class PauseDownloadUseCase
    implements BaseUseCase<Result<DownloadTask>, String> {
  final DownloadRepository _downloadRepository;

  const PauseDownloadUseCase({required DownloadRepository downloadRepository})
    : _downloadRepository = downloadRepository;

  @override
  Future<Result<DownloadTask>> execute(String taskId) async {
    try {
      return await _downloadRepository.pauseDownload(taskId);
    } catch (e) {
      return Result.failure('Failed to pause download: $e');
    }
  }
}
