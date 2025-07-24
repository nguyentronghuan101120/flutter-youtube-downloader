import 'package:injectable/injectable.dart';
import '../../../domain/entities/download_task.dart';
import '../../../domain/repositories/download_repository.dart';
import '../../../core/result/result.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class StartDownload
    implements BaseUseCase<Result<DownloadTask>, StartDownloadParams> {
  final DownloadRepository _repository;

  StartDownload({required DownloadRepository repository})
    : _repository = repository;

  @override
  Future<Result<DownloadTask>> execute(StartDownloadParams params) async {
    try {
      // Start download using repository
      return await _repository.startDownload(params);
    } catch (e) {
      return Result.failure('Failed to start download: $e');
    }
  }
}
