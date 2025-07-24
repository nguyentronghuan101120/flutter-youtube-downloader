import 'package:injectable/injectable.dart';
import '../../repositories/download_repository.dart';
import '../../../core/result/result.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class ClearFailedDownloads implements BaseUseCaseNoParams<Result<void>> {
  final DownloadRepository repository;

  ClearFailedDownloads(this.repository);

  @override
  Future<Result<void>> execute() async {
    try {
      final result = await repository.clearFailedDownloads();
      if (result.isSuccess) {
        return const Result.success(null);
      } else {
        return Result.failure(result.errorMessage!);
      }
    } catch (e) {
      return Result.failure('Failed to clear failed downloads: $e');
    }
  }
}
