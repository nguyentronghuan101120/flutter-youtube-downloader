import 'package:injectable/injectable.dart';
import '../../repositories/download_repository.dart';
import '../../../core/result/result.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class ReorderDownloadQueue implements BaseUseCase<Result<void>, List<String>> {
  final DownloadRepository repository;

  ReorderDownloadQueue(this.repository);

  @override
  Future<Result<void>> execute(List<String> taskIds) async {
    try {
      final result = await repository.reorderDownloadQueue(taskIds);
      if (result.isSuccess) {
        return const Result.success(null);
      } else {
        return Result.failure(result.errorMessage!);
      }
    } catch (e) {
      return Result.failure('Failed to reorder download queue: $e');
    }
  }
}
