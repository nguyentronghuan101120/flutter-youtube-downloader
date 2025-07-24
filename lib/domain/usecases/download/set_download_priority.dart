import 'package:injectable/injectable.dart';
import '../../repositories/download_repository.dart';
import '../../../core/result/result.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class SetDownloadPriority
    implements BaseUseCase<Result<void>, SetPriorityParams> {
  final DownloadRepository repository;

  SetDownloadPriority(this.repository);

  @override
  Future<Result<void>> execute(SetPriorityParams params) async {
    try {
      final result = await repository.setDownloadPriority(
        params.downloadId,
        params.priority,
      );
      if (result.isSuccess) {
        return const Result.success(null);
      } else {
        return Result.failure(result.errorMessage!);
      }
    } catch (e) {
      return Result.failure('Failed to set download priority: $e');
    }
  }
}

class SetPriorityParams {
  final String downloadId;
  final int priority;

  SetPriorityParams({required this.downloadId, required this.priority});
}
