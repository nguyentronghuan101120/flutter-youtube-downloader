import 'package:injectable/injectable.dart';
import '../../entities/download_task.dart';
import '../../repositories/download_repository.dart';
import '../../../core/usecases/base_usecase.dart';
import '../../../core/result/result.dart';

@injectable
class CancelDownloadUseCase
    implements BaseUseCase<Result<DownloadTask>, String> {
  final DownloadRepository _downloadRepository;

  const CancelDownloadUseCase({required DownloadRepository downloadRepository})
    : _downloadRepository = downloadRepository;

  @override
  Future<Result<DownloadTask>> execute(String taskId) async {
    try {
      return await _downloadRepository.cancelDownload(taskId);
    } catch (e) {
      return Result.failure('Failed to cancel download: $e');
    }
  }
}
