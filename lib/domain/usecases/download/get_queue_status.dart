import 'package:injectable/injectable.dart';
import '../../repositories/download_repository.dart';
import '../../../core/result/result.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class GetQueueStatus implements BaseUseCaseNoParams<Result<QueueStatus>> {
  final DownloadRepository repository;

  GetQueueStatus(this.repository);

  @override
  Future<Result<QueueStatus>> execute() async {
    try {
      final result = await repository.getQueueStatus();
      if (result.isSuccess) {
        return Result.success(result.data!);
      } else {
        return Result.failure(result.errorMessage!);
      }
    } catch (e) {
      return Result.failure('Failed to get queue status: $e');
    }
  }
}
